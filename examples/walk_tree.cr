require "../src/myhtml"

str = if filename = ARGV[0]?
  File.read(filename)
else
  "<html><Div><span class='test'>HTML</span></div></html>"
end

parser = Myhtml::Parser.new
parser.parse(str)

def walk(node, level)
  return unless node

  print "#{" " * level}"

  print node.tag_name
  unless node.attributes.empty?
    print node.attributes.inspect
  end

  print ": \"#{node.tag_text}\""

  puts

  node.each_child do |child|
    walk(child, level + 1)
  end
end

walk(parser.root, 0)
