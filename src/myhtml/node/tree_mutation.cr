struct Myhtml::Node
  #
  # Add a child node to the end
  #
  # This inserts the child node at the end of parent node's children
  #
  # ```crystal
  # document = Myhtml::Parser.new("<html><body><p>Hi!</p></body></html>")
  # body = document.body!
  # span = document.tree.create_node(:span)
  #
  # body.append_child(span)
  # body.to_html # <body><p>Hi!</p><span></span></body>
  # ```
  #
  def append_child(child : Node)
    Lib.tree_node_add_child(raw_node, child.raw_node)
  end

  #
  # Add a sibling node before this node
  #
  # ```crystal
  # document = Myhtml::Parser.new("<html><body><main></main></body></html>")
  # main = document.css("main").first
  # header = document.tree.create_node(:header)
  #
  # main.insert_before(header)
  # document.body!.to_html # <body><header></header><main></main></body>
  # ```
  #
  def insert_before(node : Node)
    Lib.tree_node_insert_before(raw_node, node.raw_node)
  end

  #
  # Add a sibling node after this node
  #
  # ```crystal
  # document = Myhtml::Parser.new("<html><body><div></div></body></html>")
  # div = document.css("div").first
  # img = document.tree.create_node(:img)
  #
  # div.insert_after(img)
  # document.body!.to_html # <body><div></div><img></body>
  # ```
  #
  def insert_after(node : Node)
    Lib.tree_node_insert_after(raw_node, node.raw_node)
  end

  #
  # Remove node from tree
  #
  def remove!
    Lib.node_remove(@raw_node)
  end
end
