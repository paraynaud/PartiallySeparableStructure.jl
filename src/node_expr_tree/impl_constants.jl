module constants

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr
    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times

    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator

    import ..implementation_type_expr.t_type_expr_basic
    import ..interface_expr_node._get_type_node

    import Base.==

    mutable struct constant <: ab_ex_nd
        value :: Number
    end

    function create_node_expr(x :: Number)
        return constant(x)
    end


    _node_is_operator( c :: constant) = false
    _node_is_plus( c :: constant) = false
    _node_is_minus(c :: constant) = false
    _node_is_times(c :: constant) = false
    _node_is_power(c :: constant) = false

    _node_is_variable(c :: constant) = false

    _node_is_constant(c :: constant) = true


    _get_type_node(c :: constant) = t_type_expr_basic(0)

    (==)(a :: constant, b :: constant) = (a.value == b.value)

    export constant
end
