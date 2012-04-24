require 'Chee/version'
require 'Get_Set'
require 'net/ssh'
require 'net/scp'
require 'readline'

class Chee
  
  Result = Class.new {
    include Get_Set::DSL
    attr_get_set :exit_status, :out, :err
  }
  
  Exit_Error = Class.new(RuntimeError) {
    include Get_Set::DSL
    attr_get_set :exit_status, :out, :err
  }
  
  module DSL

    def server_array
      @server_array ||= []
    end

    def server *args
      return @server if args.empty?
      server_array << args
      server_array.uniq!
      @server = args
    end

    def print_data d
      print d
      STDOUT.flush
    end

    def ssh_to_all command
      @server_array.map { |opts|
        server *opts
        ssh command
      }.flatten
    end

    # 
    # Thread technique came from: 
    # http://stackoverflow.com/questions/6942279/ruby-net-ssh-channel-dies
    # 
    def ssh raw_cmd
      command = raw_cmd.strip
      if command["\n"]
        return command.split("\n").map(&:strip).map { |s|
          ssh s
        }
      end
      stdout = ""
      stderr = ""
      t      = nil # used to store a Thread

      ip, user, new_opts = *server
      opts = {:timeout=>3}.merge(new_opts || {})

      begin

        get_input = true
        @channel  = nil
        cmd       = ''
        prev_cmd  = ''
        prev_data = ''
        result    = Result.new

        t = Thread.new { 

          while get_input do

            cmd = begin
                    Readline.readline("", true).strip
                  rescue Interrupt => e # Send CTRL-C:
                    get_input = false
                    "^C"
                  end

            if @channel
              @channel.process
            else
              print "Connection closed. Could not send: #{cmd}\n"
            end

          end 

        }

        Net::SSH.start(ip, user, opts) { |ssh|

          @channel = ssh.open_channel do |ch1|

            ch1.on_extended_data do |ch, type, d|
              stderr << d
            end

            ch1.on_request 'exit-status' do |ch, d|
              result.exit_status d.read_long
            end

            ch1.on_open_failed { |ch, code, desc|
              stderr << "Failure to open channel: #{code.inspect}: #{desc}"
            }

            ch1.on_process do |ch|
              if cmd.strip == '^C'
                #ch.close
                ch.send_data( Net::SSH::Buffer.from(:byte, 3, :raw, "\n").to_s )
                stderr << "User requested interrupt."
              else
                if cmd.strip.empty?
                  # ignore it
                else
                  ch.send_data( "#{cmd}\n" ) 
                  prev_cmd = cmd
                  cmd = ''
                end
              end
            end

            ch1.on_data do |ch, d|

              stdout << d # .sub(%r!\r?\n\Z!,'')

              unless prev_cmd.to_s.strip == d.strip
                print_data d
              end

              prev_data = d
            end

            ch1.request_pty do |ch, success|
              if success
                # do nothing
              else
                ch.close
                (stderr << "Unknown error requesting pty.") 
              end
            end

            ch1.exec(command)

          end

          ssh.loop 0.1
        } # === Net::SSH.start

      rescue Timeout::Error  => e
        raise e.class, server.inspect

      rescue Net::SSH::AuthenticationFailed => e
        raise e.class, "Using: #{server.inspect}"

      ensure
        get_input = false
        t.exit if t
      end

      result.err stderr
      result.out stdout
      
      if !result.err.empty? || result.exit_status != 0
        e = Exit_Error.new("Exit: #{result.exit_status}, COMMAND: #{command}")
        e.exit_status result.exit_status
        e.out         result.out
        e.err         result.err
        raise e
      end

      result.out.strip!
      result
    end

  end # === module DSL

  extend DSL

end # === class Chee
