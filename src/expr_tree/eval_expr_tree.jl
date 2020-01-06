module M_evaluation_expr_tree

    using ..trait_expr_tree, ..trait_expr_node

    using ForwardDiff

    # IMPORTANT La fonction evaluate_expr_tree garde le type des variables,
    # Il faut cependant veiller à modifier les constantes dans les expressions pour qu'elles
    # n'augmentent pas le type
    evaluate_expr_tree(a :: Any) = (x :: Vector{} -> evaluate_expr_tree(a,x) )
    evaluate_expr_tree(a :: Any, x :: Vector{}) = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
    _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error(" This is not an Expr tree")
    _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: Vector{}) = _evaluate_expr_tree(a, x)
    function _evaluate_expr_tree(expr_tree, x :: Vector{})
        nd = trait_expr_tree._get_expr_node(expr_tree)
        ch = trait_expr_tree._get_expr_children(expr_tree)
        if isempty(ch)
            res = trait_expr_node.evaluate_node(nd, x) :: Number
            return res
        else
            n = length(ch)
            temp = Vector{Number}(undef,n)
            Threads.@threads for i in 1:n
                temp[i] = evaluate_expr_tree(ch[i],x) :: Number
            end
            res = trait_expr_node.evaluate_node(nd, temp) #:: Vector{Number}
            return res
        end
    end


    evaluate_element_expr_tree(a :: Any, elmt_var :: Vector{Int}) = ( x :: Vector{} -> evaluate_element_expr_tree(a, x, elmt_var) )
    evaluate_element_expr_tree(a :: Any, x :: Vector{}, elmt_var :: Vector{Int}) = _evaluate_element_expr_tree(a, trait_expr_tree.is_expr_tree(a), x, elmt_var )
    evaluate_element_expr_tree(a :: Any, elmt_var :: Dict{Int,T where T <: Number}) =  _evaluate_element_expr_tree(a, trait_expr_tree.is_expr_tree(a), elmt_var )
    _evaluate_element_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = error(" This is not an Expr tree")
    _evaluate_element_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = _evaluate_element_expr_tree(a, x, elmt_var )
    _evaluate_element_expr_tree(a, :: trait_expr_tree.type_expr_tree, elmt_var :: Dict{Int,T where T <: Number}) = _evaluate_element_expr_tree(a, elmt_var)
    #La fonction du premier appel
    function _evaluate_element_expr_tree(expr_tree, x :: Vector{}, elmt_var :: Vector{Int})
        function transition_array(elemental_var :: Vector{Int}, x :: Vector{})
            dic_var_value = Dict{Int,T where T <: Number}()
            for i in 1:length(elemental_var)
                dic_var_value[(elemental_var[i])] = x[i]
            end
            return dic_var_value
        end
        dic_var_value = transition_array(elmt_var, x )
        return _evaluate_element_expr_tree(expr_tree, dic_var_value)
    end

    function _evaluate_element_expr_tree(expr_tree, dic_var_value :: Dict{Int,T where T <: Number})
        nd = trait_expr_tree._get_expr_node(expr_tree)
        ch = trait_expr_tree._get_expr_children(expr_tree)
        if isempty(ch)
            res = trait_expr_node.evaluate_node(nd, dic_var_value) :: Number
            return res
        else
            n = length(ch)
            temp = Vector{Number}(undef,n)
            Threads.@threads for i in 1:n
                temp[i] = evaluate_element_expr_tree(ch[i],dic_var_value) :: Number
            end
            res = trait_expr_node.evaluate_node(nd, temp) #:: Vector{Number}
            return res
        end
    end



    calcul_gradient_expr_tree(a :: Any, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x, elmt_var)
    calcul_gradient_expr_tree(a :: Any, x :: Vector{}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x )
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_gradient_expr_tree(a, x)
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree(a, x, elmt_var)
    function _calcul_gradient_expr_tree(expr_tree, x :: Vector{})
        g = ForwardDiff.gradient( evaluate_expr_tree(expr_tree), x)
        return g
    end
    function _calcul_gradient_expr_tree(expr_tree, x :: Vector{}, elmt_var :: Vector{Int})
        g = ForwardDiff.gradient( evaluate_element_expr_tree(expr_tree, elmt_var), x)
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
