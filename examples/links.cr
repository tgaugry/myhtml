require "../src/myhtml"

str = if filename = ARGV[0]?
  File.read(filename)
else
  "<html>
    <div>
      Before
      <br>
      <a href='/link1'>Link1</a>
      <br>
      After
    </div>
    
    #
    <a href='/link2'>Link2</a>
    --

    <div>some<span>⬠ ⬡ ⬢</span></div>
    <a href='/link3'>Link3</a>
    <span>⬣ ⬤ ⬥ ⬦</span>

  </html>"
end

# example how to find anchor, and it left, right texts
def extract_link(node)
  anchor = node.child!.tag_text
  href = node.attributes["href"]?

  before = ""
  node.left_iterator.each do |node|
    if node.tag_id == Myhtml::Lib::MyhtmlTags::MyHTML_TAG__TEXT
      text = node.tag_text
      if !text.empty? && !text.each_char.all?(&.whitespace?)
        before = text.strip
        break
      end
    end
  end

  after = ""
  node.child.try &.right_iterator.each do |node|
    if node.tag_id == Myhtml::Lib::MyhtmlTags::MyHTML_TAG__TEXT
      text = node.tag_text
      if !text.empty? && !text.each_char.all?(&.whitespace?)
        after = text.strip
        break
      end
    end
  end

  puts "(#{before}) <#{href}>(#{anchor}) (#{after})"
end

parser = Myhtml::Parser.new
parser.parse(str)
parser.each_tag(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A) { |node| extract_link(node) }
