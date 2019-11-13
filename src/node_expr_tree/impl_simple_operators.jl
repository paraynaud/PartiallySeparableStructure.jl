module operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator


    mutable struct simple_operator <: ab_ex_nd
        op :: Symbol
    end


    function create_node_expr(op :: Symbol)
        return simple_operator(op)
    end

    _node_is_operator( op :: simple_operator) = true
    _node_is_plus( op :: simple_operator) = (op.op == :+)
    _node_is_minus(op :: simple_operator) = (op.op == :-)
    _node_is_times(op :: simple_operator) = (op.op == :*)
    _node_is_power(op :: simple_operator) = false

    _node_is_variable(op :: simple_operator) = false

    _node_is_constant(op :: simple_operator) = false

    export operator
end
