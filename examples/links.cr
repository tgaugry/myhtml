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

def extract_link(node)
  anchor = node.child!.tag_text.strip
  href = node.attribute_by("href")

  # closure check node for non empty text
  text_tag = -> (node : Myhtml::Node) do
    if node.tag_id == Myhtml::Lib::MyhtmlTags::MyHTML_TAG__TEXT
      slice = node.tag_text_slice
      return if slice.size == 0
      !String.new(slice).each_char.all?(&.whitespace?)
    end
  end

  before = node.left_iterator.find(&text_tag).try(&.tag_text.strip)
  after = (node.child || node).right_iterator.find(&text_tag).try(&.tag_text.strip)

  puts "(#{before}) <#{href}>(#{anchor}) (#{after})"
end

parser = Myhtml::Parser.new
parser.parse(str)
parser.each_tag(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A) { |node| extract_link(node) }

# (Before) </link1>(Link1) (After)
# (#) </link2>(Link2) (--)
# (⬠ ⬡ ⬢) </link3>(Link3) (⬣ ⬤ ⬥ ⬦)
