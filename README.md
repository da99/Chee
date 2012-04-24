
Chee
================

Send commands through SSH, but using a tty/pty and STDIN.
That's right: Interactive SSH sessions. 

Limitations
-----------

* Programs that redraw the screen (e.g. vim) don't work that well. 
Apt-get and 
other programs that request input in a simple manner should work well enough.

* PTY (psuedo-terminal) is used. Which means it runs in a sub-shell. 
Which leads to *no* STDERR access. All output is done on STDOUT.

Installation
------------

    gem install Chee

Usage: DSL
------

You could include the DSL into your own object:

    require "Chee"
    Class My_SSH
      include Chee::DSL
    end

    o = My_SSH.new
    o.server 'my_server'
    o.ssh "uptime"

Or you could use Chee directly:

    require "Chee"
    Chee.server 'my_server'
    Chee.ssh "uptime"

`:server` accepts the same options as `Net::SSH.start`:
    
    Chee.server(
      'localhost', 
      'me', 
      :password => "try to use private/public keys", 
      :timeout  => 3  
    )
    
`:ssh` returns a `Chee::Result` object:

    result = Chee.ssh( "uptime" )
    result.out         # ==> output from STDOUT
    result.exit_status 

Usage: Printing Output
-----

Override default printing with `:print_data`:

    o.print_data { |data|
      # ignore data
    }

    # The default proc is equivalent to:
    o.print_data { |data| 
      print data   
      STDOUT.flush
    }

You can still get the output with the returned value of `:ssh` 
or `ssh_to_all`:

    o.ssh( "uptime" ).out

    o.ssh_to_all("uptime").map(&:out)

Usage: Single Server
-----

    require "Chee"
    
    Chee.server "my_server"  
    
    Chee.ssh %^ sudo add-apt-repository ppa:nginx/stable ^


Usage: Multiple Servers
------

    Chee.server 'server_1'
    Chee.server 'server_2', 'my_username'

    Chee.ssh_to_all "uptime"
    # --->  [ Chee::Result, Chee::Result ]

Usage: Multiple Line Command
----

Single Server, multiple commands:

    Chee.server 'localhost'
    
    Chee.ssh %^
    
      sudo add-apt-repository ppa:nginx/stable
      sudo apt-get install nginx
      
    ^
    # ---> [ Chee::Result, Chee::Result ]
    
Multiple servers, multiple commands:

    Chee.server 'localhost'
    Chee.server 'my_other_host'
    
    Chee.ssh_to_all %^
      echo "a"
      echo "b"
    ^
    # ---> [ Chee::Result, Chee::Result, Chee::Result, Chee::Result ]
    
Run Tests
---------

To run the tests:

    git clone git@github.com:da99/Chee.git
    cd Chee
    bundle update
    bundle exec bacon spec/main.rb
    
The tests assume you use passwordless SSH login using
private keys and put the following in your ~/.ssh/config:

    Host localhost
      User *your username*
      IdentityFile ~/.ssh/path_to_priv_key


The following is useful for Ubuntu users:

    sudo apt-get install ufw openssh-server
    sudo ufw allow from 127.0.0.1 to any port 22
    sudo ufw deny ssh
    sudo ufw default deny
    sudo ufw enable

* [UFW: Firewall](https://help.ubuntu.com/community/UFW)
* Common UFW rules: [http://blog.bodhizazen.net/linux/firewall-ubuntu-desktops/](http://blog.bodhizazen.net/linux/firewall-ubuntu-desktops/)
* [~/.ssh/config and private keys](http://www.cyberciti.biz/faq/force-ssh-client-to-use-given-private-key-identity-file/)

"I hate writing."
-----------------------------

If you know of existing software that makes the above redundant,
please tell me. The last thing I want to do is maintain code.

