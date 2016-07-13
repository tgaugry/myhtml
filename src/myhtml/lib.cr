module Myhtml
  # cd src/ext && make
  @[Link(ldflags: "#{__DIR__}/../ext/myhtml-c/lib/libmyhtml_static.a")]
  lib Lib
    type MyhtmlT = Void*
    type MyhtmlTreeT = Void*
    type MyhtmlTreeNodeT = Void*
    type MyhtmlTreeAttrT = Void*
    type MyhtmlTagIndexT = Void*
    type MyhtmlTagIndexNodeT = Void*
    alias MyhtmlTagIdT = MyhtmlTags

    fun create = myhtml_create : MyhtmlT*
    fun init = myhtml_init(myhtml : MyhtmlT*, opt : MyhtmlOptions, thread_count : LibC::SizeT, queue_size : LibC::SizeT) : MyhtmlStatus

    fun tree_create = myhtml_tree_create : MyhtmlTreeT*
    fun tree_init = myhtml_tree_init(tree : MyhtmlTreeT*, myhtml : MyhtmlT*) : MyhtmlStatus

    fun tree_destroy = myhtml_tree_destroy(tree : MyhtmlTreeT*) : MyhtmlTreeT*
    fun destroy = myhtml_destroy(myhtml : MyhtmlT*) : MyhtmlT*

    fun parse = myhtml_parse(tree : MyhtmlTreeT*, encoding : MyhtmlEncodingList, html : UInt8*, html_size : LibC::SizeT) : MyhtmlStatus

    fun encoding_detect_and_cut_bom = myhtml_encoding_detect_and_cut_bom(text : UInt8*, length : LibC::SizeT, encoding : MyhtmlEncodingList*, new_text : UInt8**, new_size : LibC::SizeT*) : Bool

    fun tree_get_document = myhtml_tree_get_document(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_html = myhtml_tree_get_node_html(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_head = myhtml_tree_get_node_head(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_body = myhtml_tree_get_node_body(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*

    fun node_child = myhtml_node_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_next = myhtml_node_next(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_parent = myhtml_node_parent(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_prev = myhtml_node_prev(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_last_child = myhtml_node_last_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_remove = myhtml_node_remove(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*

    fun tag_name_by_id = myhtml_tag_name_by_id(tree : MyhtmlTreeT*, tag_id : MyhtmlTagIdT, length : LibC::SizeT*) : UInt8*
    fun node_tag_id = myhtml_node_tag_id(node : MyhtmlTreeNodeT*) : MyhtmlTagIdT
    fun node_text = myhtml_node_text(node : MyhtmlTreeNodeT*, length : LibC::SizeT*) : UInt8*

    fun node_attribute_first = myhtml_node_attribute_first(node : MyhtmlTreeNodeT*) : MyhtmlTreeAttrT*
    fun attribute_key = myhtml_attribute_key(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_value = myhtml_attribute_value(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_next = myhtml_attribute_next(attr : MyhtmlTreeAttrT*) : MyhtmlTreeAttrT*

    fun tree_get_tag_index = myhtml_tree_get_tag_index(tree : MyhtmlTreeT*) : MyhtmlTagIndexT*
    fun tag_index_first = myhtml_tag_index_first(tag_index : MyhtmlTagIndexT*, tag_id : MyhtmlTagIdT) : MyhtmlTagIndexNodeT*
    fun tag_index_entry_count = myhtml_tag_index_entry_count(tag_index : MyhtmlTagIndexT*, tag_id : MyhtmlTagIdT) : LibC::SizeT
    fun tag_index_tree_node = myhtml_tag_index_tree_node(index_node : MyhtmlTagIndexNodeT*) : MyhtmlTreeNodeT*
    fun tag_index_next = myhtml_tag_index_next(index_node : MyhtmlTagIndexNodeT*) : MyhtmlTagIndexNodeT*
  end
end
