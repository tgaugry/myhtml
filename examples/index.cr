# Example: find tags

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        "<html><Div><span class='test'>HTML</span></div><div class=O>1</div></html>"
      end

parser = Myhtml::Parser.new(str)

c = 0
parser.nodes(:div).each do |node|
  c += 1
  p node.tag_name
  p node.attributes
end

p c
