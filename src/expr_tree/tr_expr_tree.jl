module trait_expr_tree

    import ..abstract_expr_tree.ab_ex_tr

    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children, ..interface_expr_tree._inverse_expr_tree
    import ..implementation_expr_tree.t_expr_tree


    struct type_expr_tree end
    struct type_not_expr_tree end

    is_expr_tree(a :: ab_ex_tr) = type_expr_tree()
    is_expr_tree(a :: t_expr_tree )= type_expr_tree()
    is_expr_tree(a :: Expr) = type_expr_tree()
    is_expr_tree(a :: Number) = type_expr_tree()
    is_expr_tree(a :: Any) = type_not_expr_tree()


    get_expr_node(a) = _get_expr_node(a, is_expr_tree(a))
    _get_expr_node(a, :: type_not_expr_tree) = error(" This is not an expr tree")
    _get_expr_node(a, :: type_expr_tree) = _get_expr_node(a)


    get_expr_children(a) = _get_expr_children(a, is_expr_tree(a))
    _get_expr_children(a, :: type_not_expr_tree) = error("This is not an expr tree")
    _get_expr_children(a, :: type_expr_tree) = _get_expr_children(a)


    inverse_expr_tree(a) = _inverse_expr_tree(a, is_expr_tree(a))
    _inverse_expr_tree(a, ::type_not_expr_tree) = error("This is not an expr tree")
    _inverse_expr_tree(a, ::type_expr_tree) = _inverse_expr_tree(a)


    export is_expr_tree, get_expr_node, get_expr_children, inverse_expr_tree

end  # module trait_expr_tree



module algo_expr_tree

    using ..trait_expr_tree
    using ..trait_expr_node
    using ..abstract_expr_tree
    using ..abstract_expr_node


    function transform_expr_tree(ex :: Expr)
        n_node = trait_expr_tree.get_expr_node(ex)
        children = trait_expr_tree.get_expr_children(ex)
        if isempty(children)
            return abstract_expr_tree.create_expr_tree(n_node)
        else
            n_children = transform_expr_tree.(children)
            return abstract_expr_tree.create_expr_tree(n_node, n_children)
        end
    end

    function transform_expr_tree(ex :: Number)
        return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(ex))
    end


    delete_imbricated_plus(a :: Any) = _delete_imbricated_plus(a, trait_expr_tree.is_expr_tree(a))
    _delete_imbricated_plus(a, :: trait_expr_tree.type_not_expr_tree) = error(" This is not an expr tree")
    _delete_imbricated_plus(a, :: trait_expr_tree.type_expr_tree) = _delete_imbricated_plus(a)

    function _delete_imbricated_plus( expr_tree)
        nd = trait_expr_tree.get_expr_node(expr_tree)
        if trait_expr_node.node_is_operator(nd)
            if trait_expr_node.node_is_plus(nd)
                ch = trait_expr_tree.get_expr_children(expr_tree)
                res = delete_imbricated_plus.(ch)
                return vcat(res...)
            elseif trait_expr_node.node_is_minus(nd)
                ch = trait_expr_tree.get_expr_children(expr_tree)
                if length(ch) == 1 #moins unaire donc un seul fils
                    temp = delete_imbricated_plus(ch)
                    res = trait_expr_tree.inverse_expr_tree.(temp)
                    return vcat(res...)
                else length(ch) == 2 #2 fils
                    res1 =  delete_imbricated_plus(ch[1])
                    temp =  delete_imbricated_plus(ch[2])
                    res2 = trait_expr_tree.inverse_expr_tree.(temp)
                    return vcat(vcat(res1...),vcat(res2...))
                end
            else
                return expr_tree
            end
        else
            return expr_tree
        end
    end

end
