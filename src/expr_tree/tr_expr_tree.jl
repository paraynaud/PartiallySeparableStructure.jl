module trait_expr_tree

    import ..abstract_expr_tree.ab_ex_tr

    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children

    struct type_expr_tree end
    struct type_not_expr_tree end

    is_expr_tree(a :: ab_ex_tr) = type_expr_tree()
    is_expr_tree(a :: Expr) = type_expr_tree()
    is_expr_tree(a :: Number) = type_expr_tree()
    is_expr_tree(a :: Any) = type_not_expr_tree()


    get_expr_node(a) = _get_expr_node(a, is_expr_tree(a))
    _get_expr_node(a, :: type_not_expr_tree) = error(" This is not a expr tree")
    _get_expr_node(a, :: type_expr_tree) = _get_expr_node(a)


    get_expr_children(a) = _get_expr_children(a, is_expr_tree(a))
    _get_expr_children(a, :: type_not_expr_tree) = error("This is not a expr tree")
    _get_expr_children(a, :: type_expr_tree) = _get_expr_children(a)


    export is_expr_tree, get_expr_node, get_expr_children

end  # module trait_expr_tree



module algo_expr_tree

    using ..trait_expr_tree
    using ..abstract_expr_tree
    using ..abstract_expr_node


    function transform_expr_tree(ex :: Expr)
        n_node = trait_expr_tree.get_expr_node(ex)
        children = trait_expr_tree.get_expr_children(ex)
        # @show children
        if isempty(children)
            # @show typeof(n_node) <: abstract_expr_node.ab_ex_nd
            return abstract_expr_tree.create_expr_tree(n_node)
        else
            n_children = transform_expr_tree.(children)
            # @show n_children
            return abstract_expr_tree.create_expr_tree(n_node, n_children)
        end
    end

    function transform_expr_tree(ex :: Number)
        return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(ex))
    end


end
