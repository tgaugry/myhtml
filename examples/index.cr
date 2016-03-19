require "../src/myhtml"

str = if filename = ARGV[0]?
  File.read(filename)
else
  "<html><Div><span class='test'>HTML</span></div><div class=O>1</div></html>"
end

parser = Myhtml::Parser.new
parser.parse(str)

p parser.tags_count(0x02a)
parser.each_tag(0x02a) do |node|
  p node.tag_name
  p node.attributes
end
