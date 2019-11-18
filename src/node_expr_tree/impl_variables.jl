module variables
    using MathOptInterface

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator

    import ..implementation_type_expr.t_type_expr_basic
    import ..interface_expr_node._get_type_node

    import Base.(==)

    mutable struct variable <: ab_ex_nd
        name :: Symbol
        index :: Int64
    end

    function create_node_expr(n :: Symbol, id :: Int64)
        return variable(n,id)
    end

    function create_node_expr(n :: Symbol, id :: MathOptInterface.VariableIndex)
        return variable(n,id.value)
    end

    _node_is_operator( v :: variable) = false
    _node_is_plus( v :: variable) = false
    _node_is_minus(v :: variable) = false
    _node_is_times(v :: variable) = false
    _node_is_power(v :: variable) = false

    _node_is_variable(v :: variable) = true

    _node_is_constant(v :: variable) = false

    _get_type_node(v :: variable) = t_type_expr_basic(1)

    (==)(a :: variable, b :: variable) =  (a.name == b.name) && (a.index == b.index)


    export variable
end
