require "./spec_helper"

PAGE1 = File.read("./spec/fixtures/1.html")
PAGE2 = File.read("./spec/fixtures/2.html")

describe Myhtml::Node do
  it "default" do
    parser = Myhtml::Parser.new(PAGE1)
    parser.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_DEFAULT
    parser.nodes(:div).first.inner_text.should eq "хаха"
  end

  it "detect" do
    parser = Myhtml::Parser.new(PAGE1, detect_encoding_from_meta: true)
    parser.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_DEFAULT
    parser.nodes(:div).first.inner_text.should eq "хаха"
  end

  it "detect" do
    parser = Myhtml::Parser.new(PAGE2, detect_encoding_from_meta: true)
    parser.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
    parser.nodes(:div).first.inner_text.should eq "хаха"
  end

  it "encoding" do
    parser = Myhtml::Parser.new(PAGE2, encoding: Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251)
    parser.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
    parser.nodes(:div).first.inner_text.should eq "хаха"
  end
end
