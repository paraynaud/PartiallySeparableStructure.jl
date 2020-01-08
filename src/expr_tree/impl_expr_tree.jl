module implementation_expr_tree

    using ..abstract_expr_node, ..trait_expr_node
    using ..abstract_expr_tree
    using ..trait_tree

    import ..abstract_expr_tree.create_expr_tree, ..abstract_expr_tree.create_Expr
    import ..interface_expr_tree._inverse_expr_tree

    import ..implementation_tree.type_node

    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children, ..interface_expr_tree._inverse_expr_tree


    t_expr_tree = type_node{ab_ex_nd}


    function create_Expr(t :: t_expr_tree)
        nd = trait_tree.get_node(t)
        ch = trait_tree.get_children(t)
        if isempty(ch)
            return trait_expr_node.node_to_Expr(nd)
        else
            children_Expr = create_Expr.(ch)
            node_Expr = trait_expr_node.node_to_Expr(nd)
            #défférenciation entre les opérateurs simple :+, :- et compliqué comme :^2z
            if length(node_Expr) == 1
                return Expr(:call, node_Expr[1], children_Expr...)
            elseif length(node_Expr) == 2
                return Expr(:call, node_Expr[1], children_Expr..., node_Expr[2])
            else
                error("non traité")
            end
        end
    end

    function create_expr_tree(field :: ab_ex_nd, children :: Vector{ type_node{ab_ex_nd}} )
        return type_node{ab_ex_nd}(field, children)
    end


    function create_expr_tree(field :: ab_ex_nd )
        return type_node{ab_ex_nd}(field, [])
    end




    function _get_expr_node(t :: t_expr_tree)
        return trait_tree.get_node(t)
    end

    function _get_expr_children(t :: t_expr_tree)
        return trait_tree.get_children(t)
    end


    function _inverse_expr_tree(t :: t_expr_tree)
        op_minus = abstract_expr_node.create_node_expr(:-)
        new_node = abstract_expr_tree.create_expr_tree(op_minus, [t])
        return new_node
    end

    export t_expr_tree

end  # moduleimplementation_expr_tree
