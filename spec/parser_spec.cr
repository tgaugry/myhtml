require "./spec_helper"

describe Myhtml::Node do
  it "select_tags" do
    parser = Myhtml::Parser.new
    parser.parse("<html><body><div class=AAA style='color:red'>Haha</div>
      <div>blah</div>
      </body></html>")

    parser.count_tags(0x2a).should eq 2
    nodes = parser.select_tags(0x2a)
    nodes.size.should eq 2

    node1, node2 = nodes
    node1.child!.tag_text.should eq "Haha"
    node2.child!.tag_text.should eq "blah"
  end
end
