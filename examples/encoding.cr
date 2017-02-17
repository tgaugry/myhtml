require "../src/myhtml"
page = "<html>...</html>"

# by default page parsed as UTF-8
myhtml = Myhtml::Parser.new(page)

# set encoding directly
myhtml = Myhtml::Parser.new(page, encoding: Myhtml::Lib::MyhtmlEncodingList::MyHTML_ENCODING_WINDOWS_1251)

# try to find encoding from <meta charset=...>
myhtml = Myhtml::Parser.new(page, detect_encoding_from_meta: true)

# try to detect encoding by trigrams (slow, and not 100% correct)
myhtml = Myhtml::Parser.new(page, detect_encoding: true)
