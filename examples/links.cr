require "../src/myhtml"

str = if filename = ARGV[0]?
  File.read(filename)
else
  "<html><Div><span class='test'>HTML</span></div></html>"
end

parser = Myhtml::Parser.new
parser.parse(str)

$links = [] of Myhtml::Node

def walk(node)
  return unless node

  if node.tag_id == 4
    $links << node
    return
  end

  child = node.child
  while child
    walk(child)
    child = child.next
  end
end

walk(parser.root)

p $links.size
