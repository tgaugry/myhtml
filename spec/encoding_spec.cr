require "./spec_helper"

PAGE1  = File.read("./spec/fixtures/1.htm")
PAGE2  = File.read("./spec/fixtures/2.htm")
PAGE25 = File.read("./spec/fixtures/25.htm")

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

  context "complex test" do
    it "default" do
      myhtml = Myhtml::Parser.new(PAGE25)
      myhtml.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_DEFAULT
      myhtml.nodes(:div).first.inner_text.should contain "\xC7\xE0\xE3\xF0\xF3\xE7\xEA\xE0"
    end

    it "direct" do
      myhtml = Myhtml::Parser.new(PAGE25, encoding: Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251)
      myhtml.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
      myhtml.nodes(:div).first.inner_text.should eq "Загрузка. Пожалуйста, подождите..."
    end

    it "parse from header" do
      encoding = Myhtml.parse_charset("Content-Type: text/html; charset=Windows-1251")
      myhtml = Myhtml::Parser.new(PAGE25, encoding: encoding)
      myhtml.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
      myhtml.nodes(:div).first.inner_text.should eq "Загрузка. Пожалуйста, подождите..."
    end

    it "parse from header" do
      encoding = Myhtml.parse_charset("text/html; charset=Windows-1251")
      myhtml = Myhtml::Parser.new(PAGE25, encoding: encoding)
      myhtml.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
      myhtml.nodes(:div).first.inner_text.should eq "Загрузка. Пожалуйста, подождите..."
    end

    it "detect from meta" do
      myhtml = Myhtml::Parser.new(PAGE25, detect_encoding_from_meta: true)
      myhtml.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
      myhtml.nodes(:div).first.inner_text.should eq "Загрузка. Пожалуйста, подождите..."
    end

    it "detect from trigrams" do
      myhtml = Myhtml::Parser.new(PAGE25, detect_encoding: true)
      myhtml.encoding.should eq Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251
      myhtml.nodes(:div).first.inner_text.should eq "Загрузка. Пожалуйста, подождите..."
    end
  end
end
