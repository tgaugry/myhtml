# MyHTML

Crystal wrapper for HTML5 Parser https://github.com/lexborisov/myhtml

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  myhtml:
    github: kostya/myhtml
```


## Usage

```crystal
require "myhtml"

require "../src/myhtml"

def walk(node, level = 0)
  puts "#{" " * level}#{node.tag_name}#{node.attributes}(#{node.tag_text})"
  node.each_child { |child| walk(child, level + 1) }
end

str = if filename = ARGV[0]?
  File.read(filename)
else
  "<html><Div><span class='test'>HTML</span></div></html>"
end

parser = Myhtml::Parser.new
parser.parse(str)
walk(parser.root!)
```

```
html{}()
 head{}()
 body{}()
  div{}()
   span{"class" => "test"}()
    -text{}(HTML)
```
