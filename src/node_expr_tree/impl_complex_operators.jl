module operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator


    import ..implementation_type_expr.t_type_expr_basic
    import ..trait_type_expr.type_power

    import ..interface_expr_node._get_type_node

    mutable struct complex_operator <: ab_ex_nd
        op :: Symbol
        args :: Array
    end


    function create_node_expr(op :: Symbol, args_sup :: Array)
        return complex_operator(op, args_sup)
    end

    _node_is_operator( op :: complex_operator ) = true
    _node_is_plus( op :: complex_operator ) = (op.op == :+)
    _node_is_minus(op :: complex_operator ) = (op.op == :-)
    _node_is_times(op :: complex_operator ) = (op.op == :*)
    _node_is_power(op :: complex_operator ) = (op.op == :^)

    _node_is_variable(op :: complex_operator ) = false

    _node_is_constant(op :: complex_operator ) = false

    function _get_type_node(op :: complex_operator, type_ch :: Vector{t_type_expr_basic})
        if _node_is_power(op)
            index_power = op.args[1]
            @show type_ch, index_power
            return type_power(index_power, type_ch[1])
        else
            error("non fait pour le moment ")
        end

    end


    export operator
end
