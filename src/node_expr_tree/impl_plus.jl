module plus_operators

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator
    import ..interface_expr_node._node_is_sin, ..interface_expr_node._node_is_cos, ..interface_expr_node._node_is_tan
    import ..interface_expr_node._cast_constant!, ..interface_expr_node._node_to_Expr

    import ..implementation_type_expr.t_type_expr_basic
    using ..trait_type_expr

    import ..interface_expr_node._get_type_node, ..interface_expr_node._evaluate_node

    import Base.==

    mutable struct plus_operator <: ab_ex_nd

    end


    _node_is_operator( op :: plus_operator ) = true
    _node_is_plus( op :: plus_operator ) = true
    _node_is_minus(op :: plus_operator ) = false
    _node_is_times(op :: plus_operator ) = false
    _node_is_power(op :: plus_operator ) = false
    _node_is_sin(op :: plus_operator) = false
    _node_is_cos(op :: plus_operator) = false
    _node_is_tan(op :: plus_operator) = false

    _node_is_variable(op :: plus_operator ) = false

    _node_is_constant(op :: plus_operator ) = false

    function _get_type_node(op :: plus_operator, type_ch :: Vector{t_type_expr_basic})
        if length(type_ch) == 1
            return type_ch[1]
        else
            return max(type_ch...)
        end
    end

    (==)(a :: plus_operator, b :: plus_operator) = true

    function _evaluate_node(op :: plus_operator, value_ch :: Vector{T}) where T <: Number
        if length(value_ch) > 1
            return sum(value_ch) :: T
        else
            error("probleme operateur plus ")
        end
    end

    function _evaluate_node(op :: plus_operator, value_ch :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number
        if length(value_ch) > 1
            return sum(value_ch) :: T
        else
            error("probleme operateur plus ")
        end
    end
    # function _evaluate_node(op :: plus_operator, value_ch :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number
    #     length(value_ch) > 1 && @fastmath sum(value_ch) :: T
    # end


    function _node_to_Expr(op :: plus_operator)
        return [:+]
    end

    export operator
end
