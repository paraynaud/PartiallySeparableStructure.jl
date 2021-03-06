module power_operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator
    import ..interface_expr_node._node_is_sin, ..interface_expr_node._node_is_cos, ..interface_expr_node._node_is_tan
    import ..interface_expr_node._cast_constant!, ..interface_expr_node._node_to_Expr

    import ..implementation_type_expr.t_type_expr_basic
    using ..trait_type_expr

    import ..interface_expr_node._get_type_node, ..interface_expr_node._evaluate_node

    import  ..interface_expr_node._evaluate_node2

    import Base.==

    mutable struct power_operator{T <: Number} <: ab_ex_nd
        index :: T
    end


    function create_node_expr(op :: Symbol, arg :: T , ::Bool) where T <: Number
        return power_operator{T}(arg)
    end

    function create_node_expr(op :: power_operator{T} ) where T <: Number
        return power_operator{T}(op.index)
    end

    _node_is_operator( op :: power_operator{T} ) where T <: Number= true
    _node_is_plus( op :: power_operator{T} ) where T <: Number = false
    _node_is_minus(op :: power_operator{T} ) where T <: Number = false
    _node_is_times(op :: power_operator{T} ) where T <: Number = false
    _node_is_power(op :: power_operator{T} ) where T <: Number = true
    _node_is_sin(op :: power_operator{T}) where T <: Number = false
    _node_is_cos(op :: power_operator{T}) where T <: Number = false
    _node_is_tan(op :: power_operator{T}) where T <: Number = false

    _node_is_variable(op :: power_operator{T} ) where T <: Number = false

    _node_is_constant(op :: power_operator{T} ) where T <: Number = false

    function _get_type_node(op :: power_operator{T}, type_ch :: Vector{t_type_expr_basic}) where T <: Number
        length(type_ch) == 1 || error("power has more than one argument")
        return trait_type_expr.type_power(op.index, type_ch[1])
    end

    (==)(a :: power_operator{T}, b :: power_operator{T}) where T <: Number = ( a.index == b.index)

    # function _evaluate_node(op :: power_operator{Z}, value_ch :: Vector{T}) where T <: Number where Z <: Number
    #         length(value_ch) == 1 || error("power has more than one argument")
    #         return @fastmath @inbounds (T)( value_ch[1]^(op.index) ) :: T
    # end

    @inline function _evaluate_node(op :: power_operator{Z}, value_ch :: AbstractVector{T}) where T <: Number where Z <: Number
            length(value_ch) == 1 || error("power has more than one argument")
            # return @fastmath @inbounds ( value_ch[1]^(op.index) )
            return ( value_ch[1]^(op.index) )
    end

    function _evaluate_node2(op :: power_operator{Z}, value_ch :: AbstractVector{T}) where T <: Number where Z <: Number
            length(value_ch) == 1 || error("power has more than one argument")
            return @fastmath @inbounds (T)( value_ch[1]^(op.index) ) :: T
    end

    function _evaluate_node(op :: power_operator{Z}, value_ch :: T) where T <: Number where Z <: Number
            return @fastmath (T)( value_ch^(op.index) ) :: T
    end

    function _node_to_Expr(op :: power_operator{T}) where T <: Number
        return [:^, op.index]
    end

    function _cast_constant!(op :: power_operator{T}, t :: DataType) where T <: Number
        return op.index = (t)(op.index)
    end

    export operator
end
