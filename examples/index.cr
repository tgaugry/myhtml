require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename)
      else
        "<html><Div><span class='test'>HTML</span></div><div class=O>1</div></html>"
      end

parser = Myhtml::Parser.new
parser.parse(str)

p parser.count_tags(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV)

parser.each_tag(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV) do |node|
  p node.tag_name
  p node.attributes
end
