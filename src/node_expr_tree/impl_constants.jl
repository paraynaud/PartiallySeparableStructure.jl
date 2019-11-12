module constants

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr


    mutable struct constant <: ab_ex_nd
        value :: Number
    end

    function create_node_expr(x :: Number)
        return constant(x)
    end

    export constant
end
