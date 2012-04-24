
require File.expand_path('spec/helper')
require 'Chee'
require 'Bacon_Colored'
require 'pry'
require 'mocha-on-bacon'

class My_SSH

  include Chee::DSL

  def print_data data
  end
  
end # === My_SSH

File.write("/tmp/abc.txt", "")

# ======== Include the tests.
if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('spec/tests/*.rb').each { |file|
    require File.expand_path(file.sub('.rb', '')) if File.file?(file)
  }
end
