require "./spec_helper"

record Link, before, href, anchor, after

def extract_link(node)
  anchor = node.child.try &.tag_text.strip
  href = node.attribute_by("href")

  # closure check node for non empty text
  text_tag = ->(node : Myhtml::Node) do
    if node.tag_id == Myhtml::Lib::MyhtmlTags::MyHTML_TAG__TEXT
      slice = node.tag_text_slice
      return if slice.size == 0
      !String.new(slice).each_char.all?(&.whitespace?) && node.each_parent.all?(&.visible?)
    end
  end

  before = node.left_iterator.find(&text_tag).try(&.tag_text.strip)
  after = (node.child || node).right_iterator.find(&text_tag).try(&.tag_text.strip)

  Link.new before, href, anchor, after
end

describe "integration" do
  it "parse links" do
    str = <<-HTML
      <html>
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
        <script>asdf</script>
        <span>⬣ ⬤ ⬥ ⬦</span>

        <a href='/link4'></a>
      </html>
    HTML

    parser = Myhtml::Parser.new
    parser.parse(str)
    res = [] of Link
    parser.each_tag(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A) { |node| res << extract_link(node) }
    res.size.should eq 4
    link1, link2, link3, link4 = res

    link1.should eq Link.new("Before", "/link1", "Link1", "After")
    link2.should eq Link.new("#", "/link2", "Link2", "--")
    link3.should eq Link.new("⬠ ⬡ ⬢", "/link3", "Link3", "⬣ ⬤ ⬥ ⬦")
    link4.should eq Link.new("⬣ ⬤ ⬥ ⬦", "/link4", nil, nil)
  end
end
