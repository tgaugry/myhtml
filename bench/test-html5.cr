require "./lib/html5/src/html"

page = File.read("./google.html")

t = Time.local
1000.times do
  doc = HTML5.parse(page)
end
p Time.local - t

t = Time.local
s = 0
links = [] of String
doc = HTML5.parse(page)
1000.times do
  #links = myhtml.css("div.g div.r a").map(&.attribute_by("href")).to_a
  #s += links.size
end
p links.last?
p s
p Time.local - t
