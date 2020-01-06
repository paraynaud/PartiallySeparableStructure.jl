module trait_expr_node
    import ..abstract_expr_node.ab_ex_nd

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power, ..interface_expr_node._node_is_times
    import ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable,..interface_expr_node._node_is_operator
    import ..interface_expr_node._node_is_sin, ..interface_expr_node._node_is_cos, ..interface_expr_node._node_is_tan
    import ..interface_expr_node._get_type_node, ..interface_expr_node._get_var_index
    import ..interface_expr_node._evaluate_node, ..interface_expr_node._change_from_N_to_Ni!

    using ..implementation_type_expr
    using ..trait_type_expr


    struct type_expr_node end
    struct type_not_expr_node end

""" partie sur les opérateurs """

    is_expr_node(a :: ab_ex_nd) = type_expr_node()
    is_expr_node(a :: Expr) = type_expr_node()
    is_expr_node(a :: Number) = type_expr_node()
    is_expr_node(a :: Any) = type_not_expr_node()

    node_is_operator(a) = _node_is_operator(a, is_expr_node(a))
    _node_is_operator(a, ::type_expr_node) = _node_is_operator(a)
    _node_is_operator(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_plus(a) = _node_is_plus(a, is_expr_node(a))
    _node_is_plus(a, ::type_expr_node) = _node_is_plus(a)
    _node_is_plus(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_times(a) = _node_is_times(a, is_expr_node(a))
    _node_is_times(a, ::type_expr_node) = _node_is_times(a)
    _node_is_times(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_minus(a) = _node_is_minus(a, is_expr_node(a))
    _node_is_minus(a, ::type_expr_node) = _node_is_minus(a)
    _node_is_minus(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_power(a) = _node_is_power(a, is_expr_node(a))
    _node_is_power(a, ::type_expr_node) = _node_is_power(a)
    _node_is_power(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_sin(a) = _node_is_sin(a, is_expr_node(a))
    _node_is_sin(a, ::type_expr_node) = _node_is_sin(a)
    _node_is_sin(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_cos(a) = _node_is_cos(a, is_expr_node(a))
    _node_is_cos(a, ::type_expr_node) = _node_is_cos(a)
    _node_is_cos(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_tan(a) = _node_is_tan(a, is_expr_node(a))
    _node_is_tan(a, ::type_expr_node) = _node_is_tan(a)
    _node_is_tan(a, ::type_not_expr_node) = error("This node is not a expr node")

""" partie sur les variables """

    node_is_variable(a) = _node_is_variable(a, is_expr_node(a))
    _node_is_variable(a, ::type_expr_node) = _node_is_variable(a)
    _node_is_variable(a, ::type_not_expr_node) = error("This node is not a expr node")

    get_var_index(a) = _get_var_index(a, is_expr_node(a))
    _get_var_index(a, ::type_expr_node) = _get_var_index(a)
    _get_var_index(a, ::type_not_expr_node) = error("This node is not a expr node")


""" partie sur les constantes """

    node_is_constant(a) = _node_is_constant(a, is_expr_node(a))
    _node_is_constant(a, ::type_expr_node) = _node_is_constant(a)
    _node_is_constant(a, ::type_not_expr_node) = error("This node is not a expr node")


    get_type_node(a) = _get_type_node(a, is_expr_node(a))
    _get_type_node(a, ::type_expr_node) = _get_type_node(a)
    _get_type_node(a, ::type_not_expr_node) = error("This node is not a expr node")
    _get_type_node(a, :: type_not_expr_node, b :: Array) = error("nous n'avons pas que des types expr")
    get_type_node(a,b) = _get_type_node(a, is_expr_node(a), b)
    function _get_type_node(a, :: type_expr_node, b :: Array)
        if length(b) == 1
            if trait_type_expr.is_trait_type_expr(b[1]) == trait_type_expr.type_type_expr()
                temp = _get_type_node(a,b)
                return temp
            else
                error("erreur")
            end
        else
            # nous voulons vérifier que chaque élément du tableau vérifie bien le trait type_expr
            # application de la fonction à chauqe élement vérifiant si ils satisfassent le trait.
            trait_array = trait_type_expr.is_trait_type_expr.(b)
            # println("trait_array", trait_array)
             #une fois cela fait, on vérifie qu'il satisfasse chacun le trait
             preparation_cond = isa.(trait_array, trait_type_expr.type_type_expr)
             # on réalise un ⋂ sur le tableau vérifiant leurs appartenance au trait
             cond = foldl(&, preparation_cond) == true
             if cond
                 return _get_type_node(a,b)
             else
                 error("nous n'avons pas que des types expr")
             end
        end
    end



    evaluate_node(a, x :: Vector{}) = _evaluate_node(a, is_expr_node(a), x)
    _evaluate_node(a, ::type_expr_node, x:: Vector{}) = _evaluate_node(a, x)
    _evaluate_node(a, ::type_not_expr_node, x :: Vector{}) = error("This node is not a expr node")
    evaluate_node(a, x :: Dict{Int,Number}) = _evaluate_node(a, is_expr_node(a), x)
    _evaluate_node(a, ::type_expr_node, x:: Dict{Int,Number}) = _evaluate_node(a, x)
    _evaluate_node(a, ::type_not_expr_node, x :: Dict{Int,Number}) = error("This node is not a expr node")

    change_from_N_to_Ni!(a, dic_new_var :: Dict{Int,Int}) = _change_from_N_to_Ni!(a, is_expr_node(a), dic_new_var)
    _change_from_N_to_Ni!(a, ::type_expr_node, dic_new_var :: Dict{Int,Int}) = _change_from_N_to_Ni!(a, dic_new_var)
    _change_from_N_to_Ni!(a, ::type_not_expr_node, dic_new_var :: Dict{Int,Int}) = error("This node is not a expr node")

end  # module trait_expr_node


















""" old version of function """

# function _get_type_node(a, :: type_expr_node, b :: Array)
#     if length(b) == 1
#         if trait_type_expr.is_trait_type_expr(b[1]) == trait_type_expr.type_type_expr()
#             temp = _get_type_node(a,b)
#             return temp
#         else
#             error("erreur")
#         end
#     else
#         # nous voulons vérifier que chaque élément du tableau vérifie bien le trait type_expr
#         # application de la fonction à chauqe élement vérifiant si ils satisfassent le trait.
#          trait_array = trait_type_expr.is_trait_type_expr.(b)
#          #une fois cela fait, on vérifie qu'il satisfasse chacun le trait
#          preparation_cond = isa.(trait_array, trait_type_expr.type_type_expr)
#          # on réalise un ⋂ sur le tableau vérifiant leurs appartenance au trait
#          cond = foldl(&, preparation_cond) == true
#          if cond
#              return _get_type_node(a,b)
#          else
#              error("nous n'avons pas que des types expr")
#          end
#     end
# end
