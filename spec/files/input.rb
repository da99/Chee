cmd = %^ bundle exec ruby #{File.expand_path __FILE__} ^
dir = File.expand_path('.')

if ARGV == ['STDIN']
  require "highline/import"
  input = ask("Input text: ")
  puts "You entered: #{input.inspect}"
  exit 0
end

if ARGV == ['Chee']
  require 'Chee'
  Chee.server 'localhost'
  Chee.ssh "cd #{dir} && #{cmd} STDIN"
  exit 0
end

require 'open3'
Open3.popen3( "#{cmd} Chee") do |i, o, e, w|
  
  print o.gets(' ')
  print o.gets(' ')
  i.puts 'a'
  sleep 1
  while txt = o.gets do
    puts txt
  end
  
  while txt = e.gets do
    puts txt
  end
  # Process.kill 'INT', w[:pid]
end

