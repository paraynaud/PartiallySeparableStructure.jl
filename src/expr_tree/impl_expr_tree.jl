module implementation_expr_tree

    import ..abstract_expr_node.ab_ex_nd
    import ..abstract_expr_tree.create_expr_tree, ..abstract_expr_tree.ab_ex_tr, ..interface_expr_tree._inverse_expr_tree
    import ..implementation_tree.type_node

    using ..trait_tree


    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children

    t_expr_tree = type_node{ab_ex_nd}


    function _get_expr_node(t :: t_expr_tree)
        return trait_tree.get_node(t)
    end

    function _get_expr_children(t :: t_expr_tree)
        return trait_tree.get_children(t)
    end

    function create_expr_tree(field :: ab_ex_nd, children :: Vector{ type_node{ab_ex_nd}} )
        return type_node{ab_ex_nd}(field, children)
    end

    function create_expr_tree(field :: ab_ex_nd )
        return type_node{ab_ex_nd}(field, [])
    end

    function _inverse_expr_tree(t :: t_expr_tree)
        op_minus = abstract_expr_node.create_node_expr(:-)
        new_node = abstract_expr_tree.create_expr_tree(op_minus, [t])
        return new_node
    end

    export t_expr_tree

end  # moduleimplementation_expr_tree
