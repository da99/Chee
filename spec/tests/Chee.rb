
describe ":ssh_exec" do
  
  before do
    @localhost = 'localhost'    
    
    @wrong_ip = Hash[
      :ip=> 'localhosts',
      :user=>`whoami`.strip
    ]
    
    Chee.server @localhost
    @data = ''
    
    Chee.print_data { |d|
      @data << d
    }
  end
  
  it 'accepts a String for the server info.' do
    Chee.server "localhost"
    Chee.ssh("echo 'a'").out.should == "a"
  end

  it 'accepts a Hash for the server info.' do
    Chee.server 'localhost', `whoami`.strip, :password=>nil
    Chee.ssh("echo 'b'").out.should == 'b'
  end

  it 'uses :print_data to print data' do
    Chee.ssh 'echo c'
    @data.strip.should == 'c'
  end

  it 'uses a PTY' do
    Chee.ssh("tty").out.should.match %r!/dev/pts/\d+!
  end
  
  it 'accepts input from STDIN' do
    `bundle exec ruby spec/files/input.rb 2>&1`.strip
    .should == %@Input text: a\nYou entered: "a"@
  end

  it 'returns a SSH::Results' do
    Chee.ssh("hostname").should.be.is_a Chee::Result
  end
  
  it "strips returned data" do
    Chee.ssh("cat ~/.bashrc").out.gsub("\r", '')
    .should == `cat ~/.bashrc`.strip
  end
  
  it 'raises Net::SSH::AuthenticationFailed if login/password are incorrect' do
    lambda {
      Chee.server "github.com"
      Chee.ssh "hostname"
    }.should.raise(Net::SSH::AuthenticationFailed)
    .message.should.match %r!Using: ..github.com..!
  end

  it 'raises Chee::Exit_Error if return status is not zero' do
    e = lambda {
      Chee.ssh "HOSTNAMES"
    }.should.raise(Chee::Exit_Error)

    e.exit_status.should == 127
  end

end # === describe :ssh_exec

describe "Chee :server" do

  before { @m = My_SSH.new }
  
  it "adds server to server list" do
    @m.server 'local'
    @m.server_array.should.include ['local']
  end
  
  it "adds server to server list only once" do
    @m.server 'local'
    @m.server 'local'
    @m.server_array.should == [ ['local'] ]
  end
  
end # === Chee :server

describe "Chee :ssh_to_all" do

  before { 
    @m = My_SSH.new 
    @m.server "localhost"
    @m.server "localhost", nil
    @m.server "localhost", `whoami`.strip
  }

  it "sends commands to all servers in :server_array" do
    list = @m.ssh_to_all "ruby #{File.expand_path 'spec/files/abc.rb'}"
    list.map { |o| o.out.strip }.should == %w{ a b c }
  end

  it "returns an Array with all elements Chee::Result" do
    list = @m.ssh_to_all "uptime"
    list.map(&:class).should == [ Chee::Result, Chee::Result, Chee::Result]
  end

end # === Chee :ssh_to_all

