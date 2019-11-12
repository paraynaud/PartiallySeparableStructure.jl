module trait_expr_tree

    import ..abstract_expr_tree.ab_ex_tr

    import ..interface_expr_tree._get_expr_node

    struct type_expr_tree end
    struct type_not_expr_tree end

    is_expr_tree(a :: ab_ex_tr) = type_expr_tree()
    is_expr_tree(a :: Expr) = type_expr_tree()
    is_expr_tree(a :: Any) = type_not_expr_tree()


    get_expr_node(a) = _get_expr_node(a, is_expr_tree(a))

    _get_expr_node(a, :: type_not_expr_tree) = error(" This is not a expr tree")
    _get_expr_node(a, :: type_expr_tree) = _get_expr_node(a)


    get_expr_children(a) = _get_expr_children(a, is_expr_tree(a))

    _get_expr_children(a, :: type_not_expr_tree) = error("This is not a expr tree")
    _get_expr_children(a, :: type_expr_tree) = _get_expr_children(a)

    export is_expr_tree, get_expr_node, get_expr_children

end  # module trait_expr_tree
