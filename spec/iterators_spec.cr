require "./spec_helper"

def parser
  str = <<-HTML
    <html>
      <div>
        <table>
          <tr>
            <td></td>
            <td>Bla</td>
          </tr>
        </table>
        <a>text</a>
      </div>
      <br>
      <span>
        <div>
          Text
        </div>
      </span>
    </html>
  HTML

  parser = Myhtml::Parser.new
  parser.parse(str)
  parser
end

INSPECT_NODE = ->(node : Myhtml::Node) {
  s = ""
  if node.is_text?
    s += "(" + node.tag_text.strip + ")|" if !node.tag_text.strip.empty?
  else
    s += node.tag_name
    s += "|"
  end
  s
}

describe "iterators" do
  it "right_iterator" do
    res = parser.root!.right_iterator.map(&INSPECT_NODE).join
    res.should eq "head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "deep_children from html is equal to right_iterator" do
    res = parser.root!.deep_children.map(&INSPECT_NODE).join
    res.should eq "head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "right_iterator from middle" do
    node = parser.tags(:td).first # td
    res = node.right_iterator.map(&INSPECT_NODE).join
    res.should eq "td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "right_iterator from last" do
    node = parser.tags(:_text).to_a.last # text
    res = node.right_iterator.map(&INSPECT_NODE).join
    res.should eq ""
  end

  it "left_iterator" do
    node = parser.tags(:_text).to_a.last # text
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(Text)|div|span|br|(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator from middle" do
    node = parser.tags(:br).first # br
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator from root" do
    res = parser.root!.left_iterator.map(&INSPECT_NODE).join
    res.should eq ""
  end

  it "walk_tree" do
    str = [] of String
    parser.root!.walk_tree do |node|
      str << INSPECT_NODE.call(node)
    end
    str.join("").should eq "html|head|body|div|table|tbody|tr|td|td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "deep_children from div" do
    div = parser.tags(:div).first
    res = div.deep_children.map(&INSPECT_NODE).join
    res.should eq "table|tbody|tr|td|td|(Bla)|a|(text)|"
  end

  it "iterator tags on other iterator" do
    div = parser.tags(:div).first
    res = div.deep_children.tags(:_text).map(&.tag_text.strip).reject(&.empty?).to_a
    res.should eq %w{Bla text}
  end

end
