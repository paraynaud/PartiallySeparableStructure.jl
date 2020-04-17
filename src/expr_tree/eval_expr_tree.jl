module M_evaluation_expr_tree

    using ..trait_expr_tree, ..trait_expr_node
    using ..implementation_expr_tree
    using ..abstract_expr_node


    using ForwardDiff

    # IMPORTANT La fonction evaluate_expr_tree garde le type des variables,
    # Il faut cependant veiller à modifier les constantes dans les expressions pour qu'elles
    # n'augmentent pas le type
    @inline evaluate_expr_tree(a :: Any) = (x :: AbstractVector{} -> evaluate_expr_tree(a,x) )
    @inline evaluate_expr_tree(a :: Any, elmt_var :: Vector{Int}) = (x :: AbstractVector{} -> evaluate_expr_tree(a,view(x,elmt_var) ) )
    @inline evaluate_expr_tree(a :: Any, x :: AbstractVector{T})  where T <: Number = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: AbstractVector{T})  where T <: Number = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: AbstractVector{T}) where T <: Number = _evaluate_expr_tree(a, x)
    @inline function _evaluate_expr_tree(expr_tree :: Y, x  :: AbstractVector{T}) where T <: Number where Y
        nd = trait_expr_tree._get_expr_node(expr_tree)
        if  trait_expr_node.node_is_operator(nd) == false
            trait_expr_node.evaluate_node(nd, x)
        else
            ch = trait_expr_tree._get_expr_children(expr_tree)
            n = length(ch)
            temp = Vector{T}(undef,n)
            @inbounds map!(y -> evaluate_expr_tree(y,x), temp, ch)
            trait_expr_node.evaluate_node(nd, temp)
        end
    end

    # function _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x  :: AbstractVector{T}) where T <: Number
    #     if trait_expr_node.node_is_operator(expr_tree.field :: trait_expr_node.ab_ex_nd) :: Bool == false
    #         return trait_expr_node._evaluate_node(expr_tree.field, x) :: T
    #     else
    #         if trait_expr_node.node_is_plus(expr_tree.field) :: Bool
    #             return mapreduce( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, + , expr_tree.children) :: T
    #         elseif trait_expr_node.node_is_power(expr_tree.field)
    #             return trait_expr_node._evaluate_node(expr_tree.field, _evaluate_expr_tree(expr_tree.children[1],x) :: T)
    #         else
    #             n = length(expr_tree.children)
    #             temp = Vector{T}(undef, n)
    #             map!( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, temp, expr_tree.children)
    #             return trait_expr_node._evaluate_node(expr_tree.field,  temp) :: T
    #         end
    #     end
    # end
    @inline function _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x  :: AbstractVector{T}) where T <: Number
        if trait_expr_node.node_is_operator(expr_tree.field :: trait_expr_node.ab_ex_nd) :: Bool == false
            return trait_expr_node._evaluate_node(expr_tree.field, x)
        else
            n = length(expr_tree.children)
            temp = Vector{T}(undef, n)
            map!( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) , temp, expr_tree.children)
            return trait_expr_node._evaluate_node(expr_tree.field,  temp)
        end
    end





    # evaluate_expr_tree(a :: Any) = (x :: AbstractVector{} -> evaluate_expr_tree(a,x) )
    # evaluate_expr_tree(a :: Any, elmt_var :: Vector{Int}) = (x :: AbstractVector{} -> evaluate_expr_tree(a,view(x,elmt_var) ) )
    evaluate_expr_tree2(a :: implementation_expr_tree.t_expr_tree, x :: AbstractVector{T})  where T <: Number = _evaluate_expr_tree2(a, trait_expr_tree.is_expr_tree(a), x)
    _evaluate_expr_tree2(a :: implementation_expr_tree.t_expr_tree, :: trait_expr_tree.type_not_expr_tree, x :: AbstractVector{T})  where T <: Number = error(" This is not an Expr tree")
    _evaluate_expr_tree2(a :: implementation_expr_tree.t_expr_tree, :: trait_expr_tree.type_expr_tree, x :: AbstractVector{T}) where T <: Number = _evaluate_expr_tree2(a, x)
    function _evaluate_expr_tree2(expr_tree :: implementation_expr_tree.t_expr_tree , x  :: AbstractVector{T}) where T <: Number
        n_children = length(expr_tree.children)
        if n_children == 0
            return trait_expr_node._evaluate_node2(expr_tree.field,  x) :: T
        elseif n_children == 1
            temp = Vector{T}(undef,1)
            temp[1] = _evaluate_expr_tree2( expr_tree.children[1],  x) :: T
            return trait_expr_node._evaluate_node2(expr_tree.field, temp) :: T
        else
            field = expr_tree.field
            return mapreduce( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree2(y, x) :: T , trait_expr_node._evaluate_node2(field) , expr_tree.children :: Vector{implementation_expr_tree.t_expr_tree} ) :: T
        end
    end

    calcul_gradient_expr_tree(a :: Any, x :: Vector{}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x )
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_gradient_expr_tree(a, x)
    calcul_gradient_expr_tree(a :: Any, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x, elmt_var)
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree(a, x, elmt_var)
    function _calcul_gradient_expr_tree(expr_tree, x :: Vector{T}) where T <: Number
        g = ForwardDiff.gradient( evaluate_expr_tree(expr_tree), x)
        return g
    end
    function _calcul_gradient_expr_tree(expr_tree, x :: Vector{}, elmt_var :: Vector{Int})
        g = ForwardDiff.gradient( evaluate_expr_tree(expr_tree, elmt_var), x)
        return g
    end

    using ReverseDiff
    calcul_gradient_expr_tree2(a :: Any, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree2(a, is_expr_tree(a), x, elmt_var)
    calcul_gradient_expr_tree2(a :: Any, x :: Vector{}) = _calcul_gradient_expr_tree2(a, is_expr_tree(a), x )
    _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_gradient_expr_tree2(a, x)
    _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree2(a, x, elmt_var)
    function _calcul_gradient_expr_tree2(expr_tree, x :: Vector{T}) where T <: Number
        g = ReverseDiff.gradient( evaluate_expr_tree(expr_tree), x)
        return g
    end
    function _calcul_gradient_expr_tree2(expr_tree, x :: Vector{}, elmt_var :: Vector{Int})
        g = ReverseDiff.gradient( evaluate_element_expr_tree(expr_tree, elmt_var), x)
        return g
    end

    calcul_Hessian_expr_tree(a :: Any, x :: Vector{}) = _calcul_Hessian_expr_tree(a, is_expr_tree(a), x )
    _calcul_Hessian_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    _calcul_Hessian_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_Hessian_expr_tree(a, x)
    function _calcul_Hessian_expr_tree(expr_tree, x :: Vector{})
        H = ForwardDiff.hessian( evaluate_expr_tree(expr_tree), x)
        return H
    end


end










# _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x :: Vector{T})  where T <: Number =  _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x :: Vector{T} , true )

# function _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x :: Vector{T}) where T <: Number
#     if trait_expr_node.node_is_operator(expr_tree.field :: trait_expr_node.ab_ex_nd) == false
#         return trait_expr_node.evaluate_node(expr_tree.field, x) :: T
#     elseif trait_expr_node.node_is_plus(expr_tree.field)
#         @inbounds @fastmath mapreduce( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, + , expr_tree.children)
#         # mapreduce( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, + , expr_tree.children)
#     else
#         n = length(expr_tree.children)
#         temp = Vector{T}(undef, n)
#         @inbounds @fastmath map!( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, temp, expr_tree.children)
#         return trait_expr_node.evaluate_node(expr_tree.field,  temp) :: T
#     end
# end
#
# function _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x  :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number
#     if trait_expr_node.node_is_operator(expr_tree.field :: trait_expr_node.ab_ex_nd) :: Bool == false
#         return trait_expr_node._evaluate_node(expr_tree.field, x) :: T
#     else
#         if trait_expr_node.node_is_plus(expr_tree.field) :: Bool
#             return @fastmath mapreduce( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, + , expr_tree.children) :: T
#         elseif trait_expr_node.node_is_power(expr_tree.field)
#             return _evaluate_expr_tree(expr_tree.children[1],x) :: T
#         else
#             n = length(expr_tree.children)
#             temp = Vector{T}(undef, n)
#             @inbounds map!( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) :: T, temp, expr_tree.children)
#             return trait_expr_node._evaluate_node(expr_tree.field,  temp) :: T
#         end
#     end
# end
#
# evaluate_expr_tree(a :: Any, x :: Vector{T})  where T <: Number = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
# evaluate_expr_tree(a :: Any, x :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
# _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: Vector{T})  where T <: Number = error(" This is not an Expr tree")
# _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: Vector{T}) where T <: Number = _evaluate_expr_tree(a, x)
# _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number = error(" This is not an Expr tree")
# _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number = _evaluate_expr_tree(a,x)
# function _evaluate_expr_tree(expr_tree, x :: Vector{T}) where T <: Number
#     if isempty( trait_expr_tree._get_expr_children(expr_tree))
#         return trait_expr_node.evaluate_node(trait_expr_tree._get_expr_node(expr_tree), x) :: T
#     else
#         return trait_expr_node.evaluate_node(trait_expr_tree._get_expr_node(expr_tree), (y -> evaluate_expr_tree(y,x) ).( trait_expr_tree._get_expr_children(expr_tree))) :: T
#     end
# end
# function _evaluate_expr_tree(expr_tree, x :: Vector{T}) where T <: Number
#     nd = trait_expr_tree._get_expr_node(expr_tree)
#     ch = trait_expr_tree._get_expr_children(expr_tree)
#     if  trait_expr_node.node_is_operator(nd) == false
#         # @show expr_tree, nd
#         res = trait_expr_node.evaluate_node(nd, x) :: T
#         return res
#     else
#         n = length(ch)
#         temp = Vector{T}(undef,n)
#         for i in 1:n
#             temp[i] = evaluate_expr_tree(ch[i],x) :: T
#         end
#         res = trait_expr_node.evaluate_node(nd, temp) :: T
#         return res
#     end
# end
#
# function _evaluate_expr_tree(expr_tree, x  :: SubArray{T,1,Array{T,1},Tuple{Array{Int64,1}},false}) where T <: Number
#     nd = trait_expr_tree._get_expr_node(expr_tree)
#     ch = trait_expr_tree._get_expr_children(expr_tree)
#     if  trait_expr_node.node_is_operator(nd) == false
#         # @show expr_tree, nd
#         res = trait_expr_node.evaluate_node(nd, x) :: T
#         return res
#     else
#         n = length(ch)
#         temp = Vector{T}(undef,n)
#         for i in 1:n
#             temp[i] = evaluate_expr_tree(ch[i],x) :: T
#         end
#         res = trait_expr_node.evaluate_node(nd, temp) :: T
#         return res
#     end
# end




    #
    # evaluate_element_expr_tree(a :: Any, elmt_var :: Vector{Int}) = ( x :: Vector{T} where T <: Number -> evaluate_element_expr_tree(a, x, elmt_var) )
    # evaluate_element_expr_tree(a :: Any, x :: Vector{T}, elmt_var :: Vector{Int}) where T <: Number = _evaluate_element_expr_tree(a, trait_expr_tree.is_expr_tree(a), x, elmt_var )
    # evaluate_element_expr_tree(a :: Any, elmt_var :: Dict{Int,T where T <: Number}) =  _evaluate_element_expr_tree(a, trait_expr_tree.is_expr_tree(a), elmt_var )
    # _evaluate_element_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: Vector{T}, elmt_var :: Vector{Int}) where T <: Number = error(" This is not an Expr tree")
    # _evaluate_element_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: Vector{T}, elmt_var :: Vector{Int}) where T <: Number = _evaluate_element_expr_tree(a, x, elmt_var )
    # _evaluate_element_expr_tree(a, :: trait_expr_tree.type_expr_tree, elmt_var :: Dict{Int,T where T <: Number}) = _evaluate_element_expr_tree(a, elmt_var)
    # #La fonction du premier appel
    # function _evaluate_element_expr_tree(expr_tree, x :: Vector{T}, elmt_var :: Vector{Int}) where T <: Number
    #     function transition_array(elemental_var :: Vector{Int}, x :: Vector{T}) where T <: Number
    #         dic_var_value = Dict{Int,T where T <: Number}()
    #         for i in 1:length(elemental_var)
    #             dic_var_value[(elemental_var[i])] = x[i]
    #         end
    #         return dic_var_value
    #     end
    #     dic_var_value = transition_array(elmt_var, x ) :: Dict{Int,T where T <: Number}
    #     return _evaluate_element_expr_tree(expr_tree, dic_var_value)
    # end
    #
    # function _evaluate_element_expr_tree(expr_tree, dic_var_value :: Dict{Int, T }) where T <: Number
    #     nd = trait_expr_tree._get_expr_node(expr_tree)
    #     ch = trait_expr_tree._get_expr_children(expr_tree)
    #     if isempty(ch)
    #         res = trait_expr_node.evaluate_node(nd, dic_var_value) :: T
    #         return res
    #     else
    #         n = length(ch)
    #         temp = Vector{Number}(undef,n)
    #         for i in 1:n
    #             temp[i] = evaluate_element_expr_tree(ch[i],dic_var_value) :: T
    #         end
    #         res = trait_expr_node.evaluate_node(nd, temp)  :: T
    #         return res
    #     end
    # end
