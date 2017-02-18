require "../src/myhtml"

filename = ARGV[0]? || "bla"
times = (ARGV[1]? || 1).to_i

# cache it
f = File.read(filename)
m = IO::Memory.new(f)

t = Time.now
times.times do
  m.rewind
  x = Myhtml::Parser.new(m)
  x.free
end
p "io: ", Time.now - t

t = Time.now
times.times do
  m.rewind
  x = Myhtml::Parser.new(m.gets_to_end)
  x.free
end
p "string", Time.now - t

t = Time.now
times.times do
  m.rewind
  x = Myhtml::Parser.new(m)
  x.free
end
p "io: ", Time.now - t

t = Time.now
times.times do
  m.rewind
  x = Myhtml::Parser.new(m.gets_to_end)
  x.free
end
p "string", Time.now - t
