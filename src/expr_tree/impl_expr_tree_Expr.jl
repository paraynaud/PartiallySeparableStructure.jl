module implementation_expr_tree_Expr

    import ..abstract_expr_tree.create_expr_tree
    import ..abstract_expr_node.create_node_expr
    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children, ..interface_expr_tree._inverse_expr_tree

    function create_expr_tree( ex :: Expr)
        return ex
    end

    function _get_expr_node(ex :: Expr )
        hd = ex.head
        args = ex.args
        if hd == :call
            op = args[1]
            if op != :^
                return create_node_expr(op)
            else
                index_power = args[end]
                return create_node_expr(op, [index_power])
            end
        elseif hd == :ref
            name_variable = args[1]
            index_variable = args[2]
            return create_node_expr(name_variable,index_variable)
        else
            error("partie non traite des Expr pour le moment ")
        end
    end

    function _get_expr_node(ex :: Number )
        return create_node_expr(ex)
    end


    function _get_expr_children(ex :: Expr)
        hd = ex.head
        args = ex.args
        if hd == :ref
            return []
        elseif hd == :call
            op = args[1]
            if op != :^
                return args[2:end]
            else
                return args[2:end-1]
            end
        else
            error("partie non traité des expr")
        end
    end

    function _get_expr_children(t :: Number)
        return []
    end

    function _inverse_expr_tree(ex :: Expr)
        return Expr(:call, :-, ex)
    end

    function _inverse_expr_tree(ex :: Number)
        return Expr(:call, :-, ex)
    end



end
