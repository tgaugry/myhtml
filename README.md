# MyHTML

[![Build Status](https://travis-ci.org/kostya/myhtml.svg?branch=master)](http://travis-ci.org/kostya/myhtml)

Fast HTML5 Parser (Crystal wrapper for https://github.com/lexborisov/myhtml)

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  myhtml:
    github: kostya/myhtml
```

And run `crystal deps`

## Development Setup:

```shell
  git clone https://github.com/kostya/myhtml.git
  cd myhtml
  make
  crystal spec
```

## Usage

```crystal
# Example: print all html tree

require "myhtml"

def walk(node, level = 0)
  puts "#{" " * level}#{node.tag_name}#{node.attributes}(#{node.tag_text.strip})"
  node.children.each { |child| walk(child, level + 1) }
end

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        "<html><Div><span class='test'>HTML</span></div></html>"
      end

parser = Myhtml::Parser.new(str)
walk(parser.root!)
```

Output:
```
html{}()
 head{}()
 body{}()
  div{}()
   span{"class" => "test"}()
    -text{}(HTML)
```


## More Examples

[examples](https://github.com/kostya/myhtml/tree/master/examples)

[specs](https://github.com/kostya/myhtml/tree/master/spec)

## CSS Selectors with shard modest

[modest](https://github.com/kostya/modest)

## Benchmark

Comparing with nokorigi(libxml), and crystagiri(libxml). Parse 1000 times google page, code: https://github.com/kostya/modest/tree/master/bench

```crystal
require "modest"
page = File.read("./google.html")
s = 0
links = [] of String
1000.times do
  myhtml = Myhtml::Parser.new(page)
  links = myhtml.css("div.g h3.r a").map(&.attribute_by("href")).to_a
  s += links.size
  myhtml.free
end
p links.last
p s
```

Parse + Selectors

| Lang     |  Package           | Time, s | Memory, MiB |
| -------- | ------------------ | ------- | ----------- |
| Crystal  | modest(myhtml)     | 2.52    | 7.7         |
| Crystal  | Crystagiri(LibXML) | 19.89   | 14.3        |
| Ruby 2.2 | Nokogiri(LibXML)   | 45.05   | 136.2       |

Selectors Only (files with suffix 2)

| Lang     |  Package           | Time, s | Memory, MiB |
| -------- | ------------------ | ------- | ----------- |
| Crystal  | modest(myhtml)     | 0.18    | 4.6         |
| Crystal  | Crystagiri(LibXML) | 12.30   | 6.6         |
| Ruby 2.2 | Nokogiri(LibXML)   | 28.06   | 68.8        |
