module operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr


    mutable struct simple_operator <: ab_ex_nd
        op :: Symbol
    end


    function create_node_expr(op :: Symbol)
        return simple_operator(op)
    end

    export operator
end
