module constants

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr
    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times

    import  ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator
    import ..interface_expr_node._node_is_sin, ..interface_expr_node._node_is_cos, ..interface_expr_node._node_is_tan
    import ..interface_expr_node._get_type_node, ..interface_expr_node._evaluate_node, ..interface_expr_node._change_from_N_to_Ni!
    import ..interface_expr_node._cast_constant!, ..interface_expr_node._node_to_Expr

    using ..implementation_type_expr

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
        _node_is_sin(c :: constant) = false
        _node_is_cos(c :: constant) = false
        _node_is_tan(c :: constant) = false

    _node_is_variable(c :: constant) = false

    _node_is_constant(c :: constant) = true


    _get_type_node(c :: constant) = implementation_type_expr.return_constant()

    (==)(a :: constant, b :: constant) = (a.value == b.value)

    function _evaluate_node(c :: constant, x :: Vector{})
        return c.value :: Number
    end

    function _evaluate_node(c :: constant, dic :: Dict{Int, T where T <: Number})
        return c.value :: Number
    end

    _change_from_N_to_Ni!(v :: Number, dic_new_var :: Dict{Int,Int}) = ()
    _change_from_N_to_Ni!(c :: constant, dic_new_var :: Dict{Int,Int}) = ()



    function _cast_constant!(c :: constant, t :: DataType)
        # tmp =  create_node_expr((t)(1))
        # c = tmp
        # @show c.value,t , typeof( (t)(c.value)), tmp
        c.value = (t)(c.value)
    end

    function _cast_constant!(c :: Number, t :: DataType)
        return (t)(c)
    end


    function _node_to_Expr(c :: constant)
        return c.value
    end

    export constant
end
