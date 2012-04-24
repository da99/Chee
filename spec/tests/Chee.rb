
describe ":ssh_exec" do
  
  before do
    @localhost = 'localhost'    
    
    @wrong_ip = Hash[
      :ip=> 'localhosts',
      :user=>`whoami`.strip
    ]
    
    Chee.server @localhost
  end
  
  it 'accepts a String for the server info.' do
    Chee.server "localhost"
    Chee.ssh("echo 'a'").out.should == "a"
  end

  it 'accepts a Hash for the server info.' do
    Chee.server 'localhost', `whoami`.strip, :password=>nil
    Chee.ssh("echo 'b'").out.should == 'b'
  end

  it 'uses a PTY' do
    Chee.ssh("tty").out.should.match %r!/dev/pts/\d+!
  end
  
  it 'returns a SSH::Results' do
    Chee.ssh("hostname").should.be.is_a Chee::Result
  end
  
  it "strips returned data" do
    target = `uptime`.strip.gsub(%r!\d+!, '[0-9]{1,2}')
    Chee.ssh("uptime").out.should.match %r!#{target}!
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

__END__
describe ":ssh_exits" do
  
  it 'captures exits based on key => int, val => Regexp' do
    lambda {
      ignore_exits("cat something.txt", 1=>%r!something\.txt\: No such file or directory!)
    }.should.not.raise
  end
  
  it 'captures exits based on key => int, val => String' do
    lambda {
      ignore_exits("cat something.txt", 1=>'something.txt: No such file or directory') 
    }.should.not.raise
  end
  
  it 'returns SSH::Results for a non-zero exit status' do
    ignore_exits("cat something.txt", 1=>'something.txt: No such file or directory')
    .should.be.is_a Unified_IO::Remote::SSH::Results
  end
  
  it 'returns SSH::Results for a zero exit status' do
    ignore_exits("uptime", 1=>'something.txt: No such file or directory')
    .should.be.is_a Unified_IO::Remote::SSH::Results
  end
  
end # === describe :ssh_exits
  

