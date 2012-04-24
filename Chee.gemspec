# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "Chee/version"

Gem::Specification.new do |s|
  s.name        = "Chee"
  s.version     = Chee::VERSION
  s.authors     = ["da99"]
  s.email       = ["i-hate-spam-45671204@mailinator.com"]
  s.homepage    = "https://github.com/da99/Chee"
  s.summary     = %q{User interaction with a SSH session.}
  s.description = %q{
    Send commands through SSH, but using a pseudo-terminal and STDIN.
    Uses Net::SSH. **Note:** Programs that
    redraw the screen (e.g. vim) don't work that well. Apt-get and 
    other programs that request input in a simple manner should work well enough.
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bacon'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'Bacon_Colored'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'mocha-on-bacon'
  s.add_development_dependency 'highline'
  
  # Specify any dependencies here; for example:
  s.add_runtime_dependency 'Get_Set'
  s.add_runtime_dependency 'net-ssh'
  s.add_runtime_dependency 'net-scp'
end
