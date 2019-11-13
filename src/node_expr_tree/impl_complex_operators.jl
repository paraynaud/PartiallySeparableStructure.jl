module operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator

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


    export operator
end
