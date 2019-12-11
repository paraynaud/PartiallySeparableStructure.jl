module trait_expr_tree

    import ..abstract_expr_tree.ab_ex_tr

    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children, ..interface_expr_tree._inverse_expr_tree
    import ..implementation_expr_tree.t_expr_tree

    import Base.==
    using Base.Threads


    struct type_expr_tree end
    struct type_not_expr_tree end

    is_expr_tree(a :: ab_ex_tr) = type_expr_tree()
    is_expr_tree(a :: t_expr_tree )= type_expr_tree()
    is_expr_tree(a :: Expr) = type_expr_tree()
    is_expr_tree(a :: Number) = type_expr_tree()
    is_expr_tree(a :: Any) = type_not_expr_tree()


    get_expr_node(a) = _get_expr_node(a, is_expr_tree(a))
    _get_expr_node(a, :: type_not_expr_tree) = error(" This is not an expr tree")
    _get_expr_node(a, :: type_expr_tree) = _get_expr_node(a)


    get_expr_children(a) = _get_expr_children(a, is_expr_tree(a))
    _get_expr_children(a, :: type_not_expr_tree) = error("This is not an expr tree")
    _get_expr_children(a, :: type_expr_tree) = _get_expr_children(a)


    inverse_expr_tree(a) = _inverse_expr_tree(a, is_expr_tree(a))
    _inverse_expr_tree(a, ::type_not_expr_tree) = error("This is not an expr tree")
    _inverse_expr_tree(a, ::type_expr_tree) = _inverse_expr_tree(a)


    expr_tree_equal(a,b,eq :: Atomic{Bool}=Atomic{Bool}(true)) = hand_expr_tree_equal(a,b,is_expr_tree(a), is_expr_tree(b),eq)
    hand_expr_tree_equal(a , b, :: type_not_expr_tree, :: Any, eq) = error("we can't compare if these two tree are not expr tree")
    hand_expr_tree_equal(a , b, :: Any, :: type_not_expr_tree, eq) = error("we can't compare if these two tree are not expr tree")
    function hand_expr_tree_equal(a , b, :: type_expr_tree,  :: type_expr_tree, eq :: Atomic{Bool})
        if eq[]
            if _get_expr_node(a) == _get_expr_node(b)
                ch_a = _get_expr_children(a)
                ch_b = _get_expr_children(b)
                if length(ch_a) != length(ch_b)
                    Threads.atomic_and!(eq, false )
                elseif ch_a == []
                else
                    Threads.@threads for i in 1:length(ch_a)
                        expr_tree_equal(ch_a[i],ch_b[i],eq)
                    end
                end
            else
                Threads.atomic_and!(eq, false )
            end
            return eq[]
        end
        return false
    end





    export is_expr_tree, get_expr_node, get_expr_children, inverse_expr_tree

end  # module trait_expr_tree



module algo_expr_tree

    using ..trait_tree
    using ..trait_expr_tree
    using ..trait_expr_node
    using ..abstract_expr_tree
    using ..abstract_expr_node
    using ..abstract_tree
    using ..implementation_tree
    using ..implementation_type_expr

    using SparseArrays


    function transform_expr_tree(ex :: Expr)
        n_node = trait_expr_tree.get_expr_node(ex)
        children = trait_expr_tree.get_expr_children(ex)
        if isempty(children)
            return abstract_expr_tree.create_expr_tree(n_node)
        else
            n_children = transform_expr_tree.(children)
            return abstract_expr_tree.create_expr_tree(n_node, n_children)
        end
    end

    function transform_expr_tree(ex :: Number)
        return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(ex))
    end



"""
    delete_imbricated_plus(t)

    t must be a type which satisfies the trait_expr_tree. In that case if
    t represent a function, delete_imbricated_plus(t) will split that function
    into element function if it is possible.

    delete_imbricated_plus(:(x[1] + x[2] + x[3]*x[4] ) )
    [
    x[1],
    x[2],
    x[3] * x[4]
    ]

"""
    delete_imbricated_plus(a :: Any) = _delete_imbricated_plus(a, trait_expr_tree.is_expr_tree(a))
    _delete_imbricated_plus(a, :: trait_expr_tree.type_not_expr_tree) = error(" This is not an expr tree")
    _delete_imbricated_plus(a, :: trait_expr_tree.type_expr_tree) = _delete_imbricated_plus(a)
    function _delete_imbricated_plus( expr_tree :: T ) where T
        nd = trait_expr_tree.get_expr_node(expr_tree)
        if trait_expr_node.node_is_operator(nd)
            if trait_expr_node.node_is_plus(nd)
                ch = trait_expr_tree.get_expr_children(expr_tree)
                n = length(ch)
                res = Vector{}(undef,n)
                Threads.@threads for i in 1:n
                    res[i] = delete_imbricated_plus(ch[i])
                end
                return vcat(res...)
            elseif trait_expr_node.node_is_minus(nd)
                ch = trait_expr_tree.get_expr_children(expr_tree)
                if length(ch) == 1 #moins unaire donc un seul fils
                    temp = delete_imbricated_plus(ch)
                    res = trait_expr_tree.inverse_expr_tree.(temp)
                    return vcat(res...)
                else length(ch) == 2 #2 fils
                    res1 =  delete_imbricated_plus(ch[1])
                    temp =  delete_imbricated_plus(ch[2])
                    res2 = trait_expr_tree.inverse_expr_tree.(temp)
                    return vcat(vcat(res1...),vcat(res2...))
                end
            else
                return [expr_tree]
            end
        else
            return [expr_tree]
        end
    end


"""
    get_type_tree(t)

    Return the type of the expression tree t, whose the type is inside the trait_expr_tree

    get_type_tree( :(5+4)) = constant
    get_type_tree( :(x[1])) = linear
    get_type_tree( :(x[1]* x[2])) = quadratic

"""
    get_type_tree(a :: Any) = _get_type_tree(a, trait_expr_tree.is_expr_tree(a))
    _get_type_tree(a, :: trait_expr_tree.type_not_expr_tree) = error(" This is not an Expr tree")
    _get_type_tree(a, :: trait_expr_tree.type_expr_tree) = _get_type_tree(a)
    function _get_type_tree(expr_tree)
        ch = trait_expr_tree.get_expr_children(expr_tree)
        if isempty(ch)
            nd =  trait_expr_tree.get_expr_node(expr_tree)
            type_node = trait_expr_node.get_type_node(nd)
            return type_node
        else
            n = length(ch)
            ch_type =  Vector{implementation_type_expr.t_type_expr_basic}(undef,n)
            Threads.@threads for i in 1:n
                ch_type[i] = _get_type_tree(ch[i])
            end
            nd_op =  trait_expr_tree.get_expr_node(expr_tree)
            type_node = trait_expr_node.get_type_node(nd_op, ch_type)
            return type_node
        end
    end



    get_elemental_variable(a :: Any) = _get_elemental_variable(a, trait_expr_tree.is_expr_tree(a))
    _get_elemental_variable(a, :: trait_expr_tree.type_not_expr_tree) = error(" This is not an Expr tree")
    _get_elemental_variable(a, :: trait_expr_tree.type_expr_tree) = _get_elemental_variable(a)
    function _get_elemental_variable(expr_tree)
        nd =  trait_expr_tree.get_expr_node(expr_tree)
        if trait_expr_node.node_is_operator(nd)
            ch = trait_expr_tree.get_expr_children(expr_tree)
            n = length(ch)
            list_var =  Vector{Vector{Int64}}(undef,n)

            Threads.@threads for i in 1:n
                list_var[i] = get_elemental_variable(ch[i])
            end

            # list_var = get_elemental_variable.(ch)
            res = unique!(vcat(list_var...))
            return res :: Vector{Int64}
        elseif trait_expr_node.node_is_variable(nd)
            return [trait_expr_node.get_var_index(nd)] :: Vector{Int64}
        elseif trait_expr_node.node_is_constant(nd)
            return  Vector{Int64}([])
        else
            error("the node is neither operator/variable or constant")
        end
# @testset "test complet à
    end


    function get_Ui(index_vars :: Vector{Int64}, n :: Int64)
        U = sparse(index_vars, ones(Int64,length(index_vars)), n) :: SparseVecotr{Int64,Int64}
        return U
    end

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



    evaluate_element_expr_tree(a :: Any, x :: Vector{}, elmt_var :: Vector{Int64}) = _evaluate_element_expr_tree(a, trait_expr_tree.is_expr_tree(a), x, elmt_var )
    evaluate_element_expr_tree(a :: Any, elmt_var :: Dict{Int64,T where T <: Number}) =  _evaluate_element_expr_tree(a, trait_expr_tree.is_expr_tree(a), elmt_var )
    _evaluate_element_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int64}) = error(" This is not an Expr tree")
    _evaluate_element_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int64}) = _evaluate_element_expr_tree(a, x, elmt_var )
    _evaluate_element_expr_tree(a, :: trait_expr_tree.type_expr_tree, elmt_var :: Dict{Int64,T where T <: Number}) = _evaluate_element_expr_tree(a, elmt_var)
    #La fonction du premier appel
    function _evaluate_element_expr_tree(expr_tree, x :: Vector{}, elmt_var :: Vector{Int64})
        function transition_array(elemental_var :: Vector{Int64})
            dic_var_value = Dict{Int64,T where T <: Number}()
            for i in 1:length(elemental_var)
                dic_var_value[(elemental_var[i])] = x[i]
            end
            return dic_var_value
        end
        dic_var_value = transition_array(elmt_var)
        return _evaluate_element_expr_tree(expr_tree, dic_var_value)
    end

    function _evaluate_element_expr_tree(expr_tree, dic_var_value :: Dict{Int64,T where T <: Number})
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

    using ForwardDiff

    calcul_gradient_expr_tree(a :: Any, x :: Vector{}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x )
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_gradient_expr_tree(a, x)
    function _calcul_gradient_expr_tree(expr_tree, x :: Vector{})
        g = ForwardDiff.gradient( evaluate_expr_tree(expr_tree), x)
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



""" Old version of functions"""

    # function _get_type_tree(expr_tree)
    #     ch = trait_expr_tree.get_expr_children(expr_tree)
    #     if isempty(ch)
# @testset "test complet à
    #         nd =  trait_expr_tree.get_expr_node(expr_tree)
    #         type_node = trait_expr_node.get_type_node(nd)
    #         res_tree = abstract_tree.create_tree(type_node,[])
    #         return res_tree
    #     else
    #         n = length(ch)
    #         ch_type_tree =  Vector{implementation_tree.type_node{implementation_type_expr.t_type_expr_basic}}(undef,n)
    #         ch_type_node =  Vector{implementation_type_expr.t_type_expr_basic}(undef,n)
    #         # Threads.@threads for i in 1:n
    #         #     ch_type_tree[i] = _get_type_tree(ch[i])
    #         # end
    #         # Threads.@threads for i in 1:length(ch_type_tree)
    #         #     ch_type_node[i] = trait_tree.get_node(ch_type_tree[i])
    #         # end
    #         ch_type_tree = _get_type_tree.(ch)
# @testset "test complet à
    #         ch_type_node = trait_tree.get_node.(ch_type_tree)
    #         nd_op =  trait_expr_tree.get_expr_node(expr_tree)
    #         type_node = trait_expr_node.get_type_node(nd_op, ch_type_node)
    #         res_tree = abstract_tree.create_tree(type_node, ch_type_tree)
    #         return res_tree
    #     end
    # end
