module operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr


    mutable struct complex_operator <: ab_ex_nd
        op :: Symbol
        args :: Array
    end


    function create_node_expr(op :: Symbol, args_sup :: Array)
        return complex_operator(op, args_sup)
    end

    export operator
end
