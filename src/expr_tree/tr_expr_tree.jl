module trait_expr_tree

    using ..abstract_expr_tree

    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children, ..interface_expr_tree._inverse_expr_tree
    import ..implementation_expr_tree.t_expr_tree, ..interface_expr_tree._get_real_node
    import ..interface_expr_tree._transform_to_expr_tree, ..interface_expr_tree._expr_tree_to_create

    import Base.==
    using Base.Threads


    struct type_expr_tree end
    struct type_not_expr_tree end

    is_expr_tree(a :: abstract_expr_tree.ab_ex_tr) = type_expr_tree()
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



    modify_expr_tree!( a, b) = _modify_expr_tree!(is_expr_tree(a), is_expr_tree(b), a, b)
    _modify_expr_tree!(:: type_not_expr_tree, :: Any, :: Any, :: Any) = error("l'un des 2 paramètre n'est pas un arbre d'expression")
    _modify_expr_tree!( :: Any, :: type_not_expr_tree, :: Any, :: Any) = error("l'un des 2 paramètre n'est pas un arbre d'expression")
    _modify_expr_tree!( :: type_expr_tree, :: type_expr_tree, a, b) = _modify_expr_tree!(a,b)

"""
    get_real_node(a)
Fonction à prendre avec des pincettes, pour le moment utiliser seulement sur les feuilles.
"""
    get_real_node(a) = _get_real_node(is_expr_tree(a), a)
    _get_real_node(:: type_not_expr_tree, :: Any) = error("nous ne traitons pas un arbre d'expression")
    _get_real_node(:: type_expr_tree, a :: Any) = _get_real_node(a)


"""
    transform_to_expr_tree(expression_tree)
This function takes an argument expression_tree satisfying the trait is_expr_tree and return an expression tree of the type t_expr_tree.
This function is usefull in our algorithms to synchronise all the types satisfying the trait is_expr_tree (like Expr) to the type t_expr_tree.
"""
    transform_to_expr_tree(a) = _transform_to_expr_tree(is_expr_tree(a), a)
    _transform_to_expr_tree(:: type_not_expr_tree, :: Any) = error("nous ne traitons pas un arbre d'expression")
    _transform_to_expr_tree(:: type_expr_tree, a :: Any) = _transform_to_expr_tree(a)


    transform_to_Expr(ex) = _transform_to_Expr( trait_expr_tree.is_expr_tree(ex), ex)
    _transform_to_Expr( :: trait_expr_tree.type_expr_tree, ex) = _transform_to_Expr(ex)
    _transform_to_Expr( :: trait_expr_tree.type_not_expr_tree, ex) = error("notre parametre n'est pas un arbre d'expression")
    function _transform_to_Expr(ex)
        return abstract_expr_tree.create_Expr(ex)
    end


    expr_tree_to_create(expr_tree_to_create, expr_tree_of_good_type) = _expr_tree_to_create(expr_tree_to_create, expr_tree_of_good_type, is_expr_tree(expr_tree_to_create), is_expr_tree(expr_tree_of_good_type))
    _expr_tree_to_create(a, b, :: type_not_expr_tree, :: Any) = error("le type de l'arbre d'origine ne satisfait pas le trait")
    _expr_tree_to_create(a, b, :: Any, :: type_not_expr_tree) = error("le type de l'arbre que l'on cherche à créer ne satisfait pas le trait")
    function _expr_tree_to_create(a, b, :: type_expr_tree, :: type_expr_tree)
        uniformized_a = transform_to_expr_tree(a)
        # à priori on est sur que le type de uniformized_a est implementation_expr_tree.t_expr_tree
        return _expr_tree_to_create(uniformized_a, b)
    end

    export is_expr_tree, get_expr_node, get_expr_children, inverse_expr_tree

end  # module trait_expr_tree


module hl_trait_expr_tree

    import ..interface_expr_tree._expr_tree_to_create

    using ..trait_expr_tree, ..trait_expr_node
    using ..implementation_expr_tree, ..implementation_expr_tree_Expr

    function _expr_tree_to_create(original_ex :: implementation_expr_tree.t_expr_tree,  tree_of_needed_type :: Expr)
        return trait_expr_tree.transform_to_Expr(original_ex)
    end

    function _expr_tree_to_create(original_ex :: implementation_expr_tree.t_expr_tree, tree_of_needed_type :: implementation_expr_tree.t_expr_tree)
        return original_ex
    end


    function _cast_type_of_constant( ex ::  implementation_expr_tree.t_expr_tree, t :: DataType)
        ch = trait_expr_tree.get_expr_children(ex)
        if isempty(ch)
            nd = trait_expr_tree.get_expr_node(ex)
            trait_expr_node._cast_constant!(nd,t)
        else
            _cast_type_of_constant.(ch,t)
        end
    end

end



module algo_expr_tree

    using ..trait_tree
    using ..trait_expr_tree
    using ..trait_expr_node
    using ..abstract_expr_tree
    using ..abstract_expr_node
    using ..abstract_tree
    using ..implementation_tree
    using ..implementation_type_expr
    using ..hl_trait_expr_tree

    using SparseArrays





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


"""
    get_elemental_variable(expr_tree)

    Return the index of the variable appearing in the expression tree

    get_elemental_variable( :(x[1] + x[3]) )
    > [1, 3]
    get_elemental_variable( :(x[1]^2 + x[6] + x[2]) )
    > [1, 6, 2]
"""
    get_elemental_variable(a :: Any) = _get_elemental_variable(a, trait_expr_tree.is_expr_tree(a))
    _get_elemental_variable(a, :: trait_expr_tree.type_not_expr_tree) = error(" This is not an Expr tree")
    _get_elemental_variable(a, :: trait_expr_tree.type_expr_tree) = _get_elemental_variable(a)
    function _get_elemental_variable(expr_tree)
        nd =  trait_expr_tree.get_expr_node(expr_tree)
        if trait_expr_node.node_is_operator(nd)
            ch = trait_expr_tree.get_expr_children(expr_tree)
            n = length(ch)
            list_var =  Vector{Vector{Int}}(undef,n)

            Threads.@threads for i in 1:n
                list_var[i] = get_elemental_variable(ch[i])
            end

            # list_var = get_elemental_variable.(ch)
            res = unique!(vcat(list_var...))
            return res :: Vector{Int}
        elseif trait_expr_node.node_is_variable(nd)
            return [trait_expr_node.get_var_index(nd)] :: Vector{Int}
        elseif trait_expr_node.node_is_constant(nd)
            return  Vector{Int}([])
        else
            error("the node is neither operator/variable or constant")
        end
# @testset "test complet à
    end

"""
    get_Ui(index_new_var, n)
Create a the matrix U associated to the variable appearing in index_new_var.
This function create a sparse matrix of size length(index_new_var)×n.
"""
    function get_Ui(index_vars :: Vector{Int}, n :: Int)
        m = length(index_vars)
        U = sparse( [1:m;] :: Vector{Int}, index_vars,  ones(Int,length(index_vars)), m, n) :: SparseMatrixCSC{Int,Int}
        # :: SparseVector{Int,Int}
        return U
    end

"""
    element_fun_from_N_to_Ni!(expr_tree, vector)
Transform the tree expr_tree, which represent a function from Rⁿ ⇢ R, to an element
function from Rⁱ → R .
This function rename the variable of expr_tree to x₁,x₂,... instead of x₇,x₉ for example

"""
    element_fun_from_N_to_Ni!(expr_tree, a :: Vector{Int}) = _element_fun_from_N_to_Ni!(expr_tree, trait_expr_tree.is_expr_tree(expr_tree),a)
    _element_fun_from_N_to_Ni!(expr_tree, :: trait_expr_tree.type_not_expr_tree, a :: Vector{Int}) = error(" This is not an Expr tree")
    _element_fun_from_N_to_Ni!(expr_tree, :: trait_expr_tree.type_expr_tree, a :: Vector{Int}) = _element_fun_from_N_to_Ni!(expr_tree,a)
    element_fun_from_N_to_Ni!(expr_tree, a :: Dict{Int,Int}) = _element_fun_from_N_to_Ni!(expr_tree, trait_expr_tree.is_expr_tree(expr_tree),a)
    _element_fun_from_N_to_Ni!(expr_tree, :: trait_expr_tree.type_not_expr_tree, a :: Dict{Int,Int}) = error(" This is not an Expr tree")
    _element_fun_from_N_to_Ni!(expr_tree, :: trait_expr_tree.type_expr_tree, a :: Dict{Int,Int}) = _element_fun_from_N_to_Ni!(expr_tree,a)
    # Pour les 2 fonction suivantes.
    #     - La première prend en entrée un vecteur d'entier, la fonction N_to_Ni créé le dictionnaire qui sera nécessaire pour la seconde fonction,
    #     la première fonction défini juste le dictionnaire nécessaire pour la seconde fonction.
    #     - La seconde fonction est la fonction qui va réellement modifier l'arbre d'expression expr_tree, en modifiant les indices des variables
    #     en accord avec les valeurs dans le dictionnaire.
    function _element_fun_from_N_to_Ni!(expr_tree, elmt_var :: Vector{Int})
        function N_to_Ni(elemental_var :: Vector{Int})
            dic_var_value = Dict{Int,Int}()
            for i in 1:length(elemental_var)
                dic_var_value[elemental_var[i]] = i
            end
            return dic_var_value
        end
        new_var = N_to_Ni(elmt_var)
        element_fun_from_N_to_Ni!(expr_tree, new_var)
    end

    function _element_fun_from_N_to_Ni!(expr_tree, dic_new_var :: Dict{Int,Int})
        ch = trait_expr_tree.get_expr_children(expr_tree)
        if isempty(ch) # on est alors dans une feuille
            r_node = trait_expr_tree.get_real_node(expr_tree)
            trait_expr_node.change_from_N_to_Ni!(r_node, dic_new_var)
        else
            n = length(ch)
            for i in 1:n
                _element_fun_from_N_to_Ni!(ch[i], dic_new_var)
            end
        end
    end



"""
    cast_type_of_constant(expr_tree, t)
Cast the constant of the expression tree expr_tree to the type t.
"""
    cast_type_of_constant!(expr_tree, t :: DataType) = _cast_type_of_constant!(expr_tree, trait_expr_tree.is_expr_tree(expr_tree), t)
    _cast_type_of_constant!(expr_tree, :: trait_expr_tree.type_not_expr_tree, t :: DataType) =  error("this is not an expr tree")
    _cast_type_of_constant!(expr_tree, :: trait_expr_tree.type_expr_tree, t :: DataType) =  _cast_type_of_constant!(expr_tree, t)
# On chercher à caster les constantes de l'arbre au type t, on va donc parcourir l'arbre jusqu'à arriver aux feuilles
# où nous réaliserons l'opération de caster au type t une constante individuellement .
    function _cast_type_of_constant!(expr_tree, t :: DataType)
        work_tree = trait_expr_tree.transform_to_expr_tree(expr_tree)
        hl_trait_expr_tree._cast_type_of_constant(work_tree,t)
        @show dump(work_tree)
        res = trait_expr_tree.expr_tree_to_create(work_tree, expr_tree)
        return res
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
