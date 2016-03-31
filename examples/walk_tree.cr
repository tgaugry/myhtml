require "../src/myhtml"

def walk(node, level = 0)
  puts "#{" " * level}#{node.tag_name}#{node.attributes}(#{node.tag_text.strip})"
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
