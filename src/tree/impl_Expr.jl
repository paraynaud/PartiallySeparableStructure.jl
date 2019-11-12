module implementation_Expr

    import ..interface_tree._get_node, ..interface_tree._get_children

    import ..abstract_tree.create_tree


    function create_tree(ex :: Expr)
        return ex
    end

    function _get_node(ex :: Expr)
        hd = ex.head
        args = ex.args
        if  hd == :call
            return args[1]
        elseif hd == :ref
            return args
        end
    end

    _get_node(ex :: Number ) = ex


    function _get_children(ex :: Expr )
        hd = ex.head
        args = ex.args
        if hd == :call
            return args[2:end]
        elseif hd == :ref
            return []
        end
    end
    _get_children(ex :: Number) = ex



end  # module implementation_Expr
