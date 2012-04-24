
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

Usage
------

    require "Chee"
    
    # Configure server using ~/.ssh/config
    Chee.server "my_server" 
    Chee.ssh %^ sudo add-apt-repository ppa:nginx/stable ^
<!-- sudo apt-get install nginx -->
<!-- ^ -->

Or you could include the DSL into your own object:

    Class My_SSH

      include Chee::DSL

      def ssh cmd
        super cmd.strip
      end

    end # === Class My_SSH

Run Tests
---------

To run the tests:

    git clone git@github.com:da99/Chee.git
    cd Chee
    bundle update
    bundle exec bacon spec/main.rb
    
Don't forget to setup ssh server, firewall, and passwordless SSH using
private keys. The following is useful for Ubuntu users:

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

