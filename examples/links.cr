require "../src/myhtml"

str = if filename = ARGV[0]?
  File.read(filename)
else
  "<html><Div><span class='test'>HTML</span></div></html>"
end

parser = Myhtml::Parser.new
parser.parse(str)

def walk(node)
  return unless node

  if node.tag_id == 4
    # puts "a: #{node.attributes["href"]?}"
    puts "a"
    return
  end

  child = node.child
  while child
    walk(child)
    child = child.next
  end
end

walk(parser.root)
