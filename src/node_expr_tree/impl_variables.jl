module variables

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator

    mutable struct variable <: ab_ex_nd
        name :: Symbol
        index :: Int64
    end

    function create_node_expr(n :: Symbol, id :: Int64)
        return variable(n,id)
    end


    _node_is_operator( v :: variable) = false
    _node_is_plus( v :: variable) = false
    _node_is_minus(v :: variable) = false
    _node_is_times(v :: variable) = false
    _node_is_power(v :: variable) = false

    _node_is_variable(v :: variable) = true

    _node_is_constant(v :: variable) = false

    export variable
end
