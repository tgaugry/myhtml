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
    type MyhtmlCallbackSerializeF = UInt8*, LibC::SizeT, Void* ->

    struct MyhtmlVersion
      major : Int32
      minor : Int32
      patch : Int32
    end

    struct MyhtmlStringRawT
      data : UInt8*
      size : LibC::SizeT
      length : LibC::SizeT
    end

    struct MyhtmlCollectionT
      list : MyhtmlTreeNodeT**
      size : LibC::SizeT
      length : LibC::SizeT
    end

    fun create = myhtml_create : MyhtmlT*
    fun init = myhtml_init(myhtml : MyhtmlT*, opt : MyhtmlOptions, thread_count : LibC::SizeT, queue_size : LibC::SizeT) : MyhtmlStatus

    fun tree_create = myhtml_tree_create : MyhtmlTreeT*
    fun tree_init = myhtml_tree_init(tree : MyhtmlTreeT*, myhtml : MyhtmlT*) : MyhtmlStatus

    fun tree_destroy = myhtml_tree_destroy(tree : MyhtmlTreeT*) : MyhtmlTreeT*
    fun destroy = myhtml_destroy(myhtml : MyhtmlT*) : MyhtmlT*

    fun tree_parse_flags_set = myhtml_tree_parse_flags_set(tree : MyhtmlTreeT*, parse_flags : MyhtmlTreeParseFlags)

    fun parse = myhtml_parse(tree : MyhtmlTreeT*, encoding : MyhtmlEncodingList, html : UInt8*, html_size : LibC::SizeT) : MyhtmlStatus

    fun encoding_detect_and_cut_bom = myhtml_encoding_detect_and_cut_bom(text : UInt8*, length : LibC::SizeT, encoding : MyhtmlEncodingList*, new_text : UInt8**, new_size : LibC::SizeT*) : Bool
    fun version = myhtml_version : MyhtmlVersion

    fun tree_get_document = myhtml_tree_get_document(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_html = myhtml_tree_get_node_html(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_head = myhtml_tree_get_node_head(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_body = myhtml_tree_get_node_body(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*

    fun node_child = myhtml_node_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_next = myhtml_node_next(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_parent = myhtml_node_parent(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_prev = myhtml_node_prev(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_last_child = myhtml_node_last_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_remove = myhtml_node_remove(node : MyhtmlTreeNodeT*)

    fun node_set_data = myhtml_node_set_data(node : MyhtmlTreeNodeT*, data : Void*)
    fun node_get_data = myhtml_node_get_data(node : MyhtmlTreeNodeT*) : Void*

    fun tag_name_by_id = myhtml_tag_name_by_id(tree : MyhtmlTreeT*, tag_id : MyhtmlTagIdT, length : LibC::SizeT*) : UInt8*
    fun node_tag_id = myhtml_node_tag_id(node : MyhtmlTreeNodeT*) : MyhtmlTagIdT
    fun node_text = myhtml_node_text(node : MyhtmlTreeNodeT*, length : LibC::SizeT*) : UInt8*

    fun node_attribute_first = myhtml_node_attribute_first(node : MyhtmlTreeNodeT*) : MyhtmlTreeAttrT*
    fun attribute_key = myhtml_attribute_key(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_value = myhtml_attribute_value(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_next = myhtml_attribute_next(attr : MyhtmlTreeAttrT*) : MyhtmlTreeAttrT*

    fun serialization = myhtml_serialization(node : MyhtmlTreeNodeT*, str : MyhtmlStringRawT*) : Bool
    fun serialization_node = myhtml_serialization_node(node : MyhtmlTreeNodeT*, str : MyhtmlStringRawT*) : Bool

    fun string_raw_clean_all = myhtml_string_raw_clean_all(str_raw : MyhtmlStringRawT*)
    fun string_raw_destroy = myhtml_string_raw_destroy(str_raw : MyhtmlStringRawT*, destroy_obj : Bool) : MyhtmlStringRawT*

    fun get_nodes_by_attribute_value = myhtml_get_nodes_by_attribute_value(tree : MyhtmlTreeT*,
                                                                           collection : MyhtmlCollectionT*, node : MyhtmlTreeNodeT*, case_insensitive : Bool, key : UInt8*, key_len : LibC::SizeT,
                                                                           value : UInt8*, value_len : LibC::SizeT, status : MyhtmlStatus*) : MyhtmlCollectionT*

    fun get_nodes_by_tag_id = myhtml_get_nodes_by_tag_id(tree : MyhtmlTreeT*,
                                                         collection : MyhtmlCollectionT*, tag_id : MyhtmlTagIdT,
                                                         status : MyhtmlStatus*) : MyhtmlCollectionT*

    fun collection_destroy = myhtml_collection_destroy(collection : MyhtmlCollectionT*) : MyhtmlCollectionT*

    # encoding
    fun encoding_prescan_stream_to_determine_encoding = myhtml_encoding_prescan_stream_to_determine_encoding(data : UInt8*, data_size : LibC::SizeT) : MyhtmlEncodingList
    fun encoding_name_by_id = myhtml_encoding_name_by_id(encoding : MyhtmlEncodingList, length : LibC::SizeT*) : UInt8*
    fun encoding_extracting_character_encoding_from_charset = myhtml_encoding_extracting_character_encoding_from_charset(data : UInt8*, data_size : LibC::SizeT, encoding : MyhtmlEncodingList*) : Bool
    fun encoding_detect = myhtml_encoding_detect(text : UInt8*, length : LibC::SizeT, encoding : MyhtmlEncodingList*) : Bool
  end
end
