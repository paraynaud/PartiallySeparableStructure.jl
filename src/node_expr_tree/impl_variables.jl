module variables

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr


    mutable struct variable <: ab_ex_nd
        name :: Symbol
        index :: Int64
    end

    function create_node_expr(n :: Symbol, id :: Int64)
        return variable(n,id)
    end

    export variable
end
