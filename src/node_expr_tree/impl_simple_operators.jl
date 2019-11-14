module operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator


    import ..implementation_type_expr.t_type_expr_basic
    import ..trait_type_expr.type_product
    import ..interface_expr_node._get_type_node

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


    function _get_type_node(op :: simple_operator, type_ch :: Vector{t_type_expr_basic})
        if _node_is_plus(op) || _node_is_minus(op)
            return max(type_ch...)
        else
            return foldl(type_product, type_ch)
        end
    end

    export operator
end
