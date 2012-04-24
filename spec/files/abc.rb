
def tmp
  "/tmp/abc.txt"
end

def read
  File.read(tmp).strip
end

def write txt
  File.write tmp, txt
end

if File.file?(tmp)
  case read
  when "a"
    write "b"
  when "b"
    write "c"
  else
    write "a"
  end
else
  `echo "a" > #{tmp}`
end

puts read


