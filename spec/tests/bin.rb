
bins = Dir.glob("bin/*")

unless bins.empty?
  describe "permissions of bin/" do
    bins.each { |file|
      it "should chmod 755 for: #{file}" do
        `stat -c %a #{file}`.strip
        .should.be == "755"
      end
    }
  end # === permissions of bin/
end # === unless bins.empty?
