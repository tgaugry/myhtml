require "./spec_helper"

def parser
  str = "
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
  "

  parser = Myhtml::Parser.new
  parser.parse(str)
  parser
end

INSPECT_NODE = ->(node : Myhtml::Node) {
  s = ""
  if node.tag_id == 0x01
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

  it "right_iterator from middle" do
    node = parser.select_tags(0x07f).first # td
    res = node.right_iterator.map(&INSPECT_NODE).join
    res.should eq "td|(Bla)|a|(text)|br|span|div|(Text)|"
  end

  it "right_iterator from last" do
    node = parser.select_tags(0x01).last # text
    res = node.right_iterator.map(&INSPECT_NODE).join
    res.should eq ""
  end

  it "left_iterator" do
    node = parser.select_tags(0x01).last # text
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(Text)|div|span|br|(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator from middle" do
    node = parser.select_tags(0x018).first # br
    res = node.left_iterator.map(&INSPECT_NODE).join
    res.should eq "(text)|a|(Bla)|td|td|tr|tbody|table|div|body|head|html|"
  end

  it "left_iterator from root" do
    res = parser.root!.left_iterator.map(&INSPECT_NODE).join
    res.should eq ""
  end
end
