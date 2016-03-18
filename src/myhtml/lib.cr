module Myhtml
  # cd src/ext && make
  @[Link(ldflags: "#{__DIR__}/../ext/myhtml-c/lib/static_libmyhtml.a")]
  lib Lib
    type MyhtmlT = Void*
    type MyhtmlTreeT = Void*
    type MyhtmlTreeNodeT = Void*
    type MyhtmlTreeAttrT = Void*
    alias MyhtmlStatus = Int32
    alias MyhtmlTagIdT = LibC::SizeT

    fun create = myhtml_create : MyhtmlT*
    fun init = myhtml_init(myhtml : MyhtmlT*, opt : Int32, thread_count : LibC::SizeT, queue_size : LibC::SizeT) : MyhtmlStatus

    fun tree_create = myhtml_tree_create : MyhtmlTreeT*
    fun tree_init = myhtml_tree_init(tree : MyhtmlTreeT*, myhtml : MyhtmlT*) : MyhtmlStatus

    fun tree_destroy = myhtml_tree_destroy(tree : MyhtmlTreeT*) : MyhtmlTreeT*
    fun destroy = myhtml_destroy(myhtml : MyhtmlT*) : MyhtmlT*

    fun parse = myhtml_parse(tree : MyhtmlTreeT*, encoding : Int32, html : UInt8*, html_size : LibC::SizeT) : MyhtmlStatus

    fun tree_get_node_html = myhtml_tree_get_node_html(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun node_child = myhtml_node_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_next = myhtml_node_next(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*

    fun tag_name_by_id = myhtml_tag_name_by_id(tree : MyhtmlTreeT*, tag_id : MyhtmlTagIdT, length : LibC::SizeT*) : UInt8*
    fun node_tag_id = myhtml_node_tag_id(node : MyhtmlTreeNodeT*) : MyhtmlTagIdT
    fun node_text = myhtml_node_text(node : MyhtmlTreeNodeT*, length : LibC::SizeT*) : UInt8*

    fun node_attribute_first = myhtml_node_attribute_first(node : MyhtmlTreeNodeT*) : MyhtmlTreeAttrT*
    fun attribute_name = myhtml_attribute_name(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_value = myhtml_attribute_value(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_next = myhtml_attribute_next(attr : MyhtmlTreeAttrT*) : MyhtmlTreeAttrT*
  end
end
