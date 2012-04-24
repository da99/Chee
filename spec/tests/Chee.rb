
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
  
  it 'accepts input from STDIN' do
    `bundle exec ruby spec/files/input.rb 2>&1`.strip
    .should == %@Input text: a\nYou entered: "a"@
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

