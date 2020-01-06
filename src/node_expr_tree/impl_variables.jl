module variables
    using MathOptInterface

    import ..abstract_expr_node.ab_ex_nd, ..abstract_expr_node.create_node_expr

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator
    import ..interface_expr_node._node_is_sin, ..interface_expr_node._node_is_cos, ..interface_expr_node._node_is_tan


    import ..implementation_type_expr.t_type_expr_basic
    import ..interface_expr_node._get_type_node, ..interface_expr_node._get_var_index
    import  ..interface_expr_node._evaluate_node, ..interface_expr_node._change_from_N_to_Ni!


    using ..implementation_type_expr

    import Base.(==)

    mutable struct variable <: ab_ex_nd
        name :: Symbol
        index :: Int
    end

    function create_node_expr(n :: Symbol, id :: Int)
        return variable(n, id)
    end

    function create_node_expr(n :: Symbol, id :: MathOptInterface.VariableIndex)
        return variable(n, id.value)
    end

    _node_is_operator( v :: variable) = false
    _node_is_plus( v :: variable) = false
    _node_is_minus(v :: variable) = false
    _node_is_times(v :: variable) = false
    _node_is_power(v :: variable) = false
    _node_is_sin(v :: variable) = false
    _node_is_cos(v :: variable) = false
    _node_is_tan(v :: variable) = false

    _node_is_variable(v :: variable) = true

    _node_is_constant(v :: variable) = false

    _get_type_node(v :: variable) = implementation_type_expr.return_linear()

    _get_var_index(v :: variable) = v.index :: Int

    (==)(a :: variable, b :: variable) =  (a.name == b.name) && (a.index == b.index)


    function _evaluate_node(v :: variable, x :: Vector{})
        return x[v.index] :: Number
    end

    function _evaluate_node(v :: variable, dic :: Dict{Int,Number})
        return dic[v.index] :: Number
    end
    function _change_from_N_to_Ni!(v :: variable, dic_new_var :: Dict{Int,Int})
        v.index = dic_new_var[v.index]
    end

    function _change_from_N_to_Ni!(v :: Expr, dic_new_var :: Dict{Int,Int})
        hd =v.head
        if hd != :ref
            error("on ne traite pas une variable")
        else
            new_index = change_index(v.args[2], dic_new_var)
            v.args[2] = new_index
        end
    end

    function change_index( x :: Int, dic_new_var :: Dict{Int,Int})
        return dic_new_var[x]
    end
    function change_index( x :: MathOptInterface.VariableIndex, dic_new_var :: Dict{Int,Int})
        return MathOptInterface.VariableIndex(dic_new_var[x.value])
    end


    export variable
end
