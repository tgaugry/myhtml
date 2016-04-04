# Example: extract links and around texts from html

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename)
      else
        <<-HTML
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
        </html>
        HTML
      end

def extract_link(node)
  anchor = node.child.try &.tag_text.strip
  href = node.attribute_by("href")

  # closure: check node for non empty text
  text_tag = ->(node : Myhtml::Node) do
    node.is_text? &&
      node.each_parent.all? { |n| n.visible? && !n.object? } &&
      !node.tag_text.strip.empty?
  end

  before = node.left_iterator.find(&text_tag).try(&.tag_text.strip)
  after = (node.child || node).right_iterator.find(&text_tag).try(&.tag_text.strip)

  puts "(#{before}) <#{href}>(#{anchor}) (#{after})"
end

Myhtml::Parser.new.parse(str).each_tag(:a) { |node| extract_link(node) }

# Output:
#   (Before) </link1>(Link1) (After)
#   (#) </link2>(Link2) (--)
#   (⬠ ⬡ ⬢) </link3>(Link3) (⬣ ⬤ ⬥ ⬦)
