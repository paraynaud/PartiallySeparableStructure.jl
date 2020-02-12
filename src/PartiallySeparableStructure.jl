module PartiallySeparableStructure

    using ..implementation_type_expr
    using ..algo_expr_tree, ..trait_expr_tree, ..trait_type_expr, ..M_evaluation_expr_tree
    using ..implementation_expr_tree, ..Quasi_Newton_update
    using ForwardDiff, SparseArrays
    using Base.Threads

    mutable struct element_function{T}
        fun :: T
        type :: implementation_type_expr.t_type_expr_basic
        used_variable :: Vector{Int}
        U :: SparseMatrixCSC{Int,Int}
        index :: Int
    end

    mutable struct SPS{T}
        structure :: Vector{element_function{T}}
        vec_length :: Int
        n_var :: Int
    end

    mutable struct element_hessian{T <: Number}
        elmt_hess :: Array{T,2}
    end

    mutable struct Hess_matrix{T <: Number}
        arr :: Vector{element_hessian{T}}
    end

    mutable struct element_gradient{ T <: Number}
        g_i :: Vector{T}
    end

    mutable struct grad_vector{ T <: Number}
        arr :: Vector{element_gradient{T}}
    end

    mutable struct struct_algo{T,Y <: Number}
        sps :: SPS{T}
        B :: Hess_matrix{Y}
        g :: grad_vector{Y}
    end

"""
    deduct_partially_separable_structure(expr_tree, n)

Find the partially separable structure of a function f stored as an expression tree expr_tree.
To define properly the size of sparse matrix we need the size of the problem : n.
At the end, we get the partially separable structure of f, f(x) = ∑fᵢ(xᵢ)
"""
deduct_partially_separable_structure(a :: Any, n :: Int) = _deduct_partially_separable_structure(a, trait_expr_tree.is_expr_tree(a), n)
_deduct_partially_separable_structure(a, :: trait_expr_tree.type_not_expr_tree, n :: Int) = error("l'entrée de la fonction n'est pas un arbre d'expression")
_deduct_partially_separable_structure(a, :: trait_expr_tree.type_expr_tree, n :: Int) = _deduct_partially_separable_structure(a, n )
function _deduct_partially_separable_structure(expr_tree :: T , n :: Int) where T
    work_expr_tree = copy(expr_tree)
    elmt_fun = algo_expr_tree.delete_imbricated_plus(work_expr_tree) :: Vector{T}
    m_i = length(elmt_fun)

    type_i = Vector{trait_type_expr.t_type_expr_basic}(undef, m_i)
    # type_i = algo_expr_tree._get_type_tree.(elmt_fun) :: Vector{trait_type_expr.t_type_expr_basic}
    Threads.@threads for i in 1:m_i
        type_i[i] = algo_expr_tree.get_type_tree(elmt_fun[i])
    end

    # elmt_var_i = algo_expr_tree.get_elemental_variable.(elmt_fun) :: Vector{ Vector{Int}}
    elmt_var_i =  Vector{ Vector{Int}}(undef,m_i)
    length_vec = Threads.Atomic{Int}(0)
    Threads.@threads for i in 1:m_i
        elmt_var_i[i] = algo_expr_tree.get_elemental_variable(elmt_fun[i])
        atomic_add!(length_vec, length(elmt_var_i[i]))
    end

    # U_i = algo_expr_tree.get_Ui.(elmt_var_i, n) :: Vector{SparseMatrixCSC{Int,Int}}
    U_i = Vector{SparseMatrixCSC{Int,Int}}(undef,m_i)
    Threads.@threads for i in 1:m_i
        U_i[i] = algo_expr_tree.get_Ui(elmt_var_i[i], n)
    end

    # algo_expr_tree.element_fun_from_N_to_Ni!.(elmt_fun,elmt_var_i)
    Threads.@threads for i in 1:m_i
        algo_expr_tree.element_fun_from_N_to_Ni!(elmt_fun[i],elmt_var_i[i])
    end

    Sps = Vector{element_function{T}}(undef,m_i)
    Threads.@threads for i in 1:m_i
        Sps[i] = element_function{T}(elmt_fun[i], type_i[i], elmt_var_i[i], U_i[i],i )
    end

    return SPS{T}(Sps, length_vec[], n)
end

function _deduct_partially_separable_structure(expr_tree :: implementation_expr_tree.t_expr_tree , n :: Int) where T
    elmt_fun = algo_expr_tree.delete_imbricated_plus(expr_tree) :: Vector{implementation_expr_tree.t_expr_tree}
    m_i = length(elmt_fun)

    type_i = Vector{trait_type_expr.t_type_expr_basic}(undef, m_i)
    # type_i = algo_expr_tree._get_type_tree.(elmt_fun) :: Vector{trait_type_expr.t_type_expr_basic}
    Threads.@threads for i in 1:m_i
        type_i[i] = algo_expr_tree.get_type_tree(elmt_fun[i])
    end

    # elmt_var_i = algo_expr_tree.get_elemental_variable.(elmt_fun) :: Vector{ Vector{Int}}
    elmt_var_i =  Vector{ Vector{Int}}(undef,m_i)
    length_vec = Threads.Atomic{Int}(0)
    Threads.@threads for i in 1:m_i
        elmt_var_i[i] = algo_expr_tree.get_elemental_variable(elmt_fun[i])
        atomic_add!(length_vec, length(elmt_var_i[i]))
    end

    # U_i = algo_expr_tree.get_Ui.(elmt_var_i, n) :: Vector{SparseMatrixCSC{Int,Int}}
    U_i = Vector{SparseMatrixCSC{Int,Int}}(undef,m_i)
    Threads.@threads for i in 1:m_i
        U_i[i] = algo_expr_tree.get_Ui(elmt_var_i[i], n)
    end

    # algo_expr_tree.element_fun_from_N_to_Ni!.(elmt_fun,elmt_var_i)
    Threads.@threads for i in 1:m_i
        algo_expr_tree.element_fun_from_N_to_Ni!(elmt_fun[i],elmt_var_i[i])
    end

    Sps = Vector{element_function{implementation_expr_tree.t_expr_tree}}(undef,m_i)
    Threads.@threads for i in 1:m_i
        Sps[i] = element_function{implementation_expr_tree.t_expr_tree}(elmt_fun[i], type_i[i], elmt_var_i[i], U_i[i], i)
    end

    return SPS{implementation_expr_tree.t_expr_tree}(Sps, length_vec[], n)
end

"""
    evaluate_SPS(sps,x)
evalutate the partially separable function f = ∑fᵢ, stored in the sps structure at the point x.
f(x) = ∑fᵢ(xᵢ), so we compute independently each fᵢ(xᵢ) and we return the sum.
"""
    function evaluate_SPS(sps :: SPS{T}, x :: AbstractVector{Y} ) where T where Y <: Number
        # on utilise un mapreduce de manière à ne pas allouer un tableau temporaire, on utilise l'opérateur + pour le reduce car cela correspond
        # à la définition des fonctions partiellement séparable.
        mapreduce(elmt_fun :: element_function{T} -> M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun.fun, view(x, elmt_fun.used_variable)) :: Y, + , sps.structure :: Vector{element_function{T}})
    end


"""
    evaluate_gradient(sps,x)
evalutate the gradient of the partially separable function f = ∑ fι, stored in the sps structure
at the point x, return a vector of size n (the number of variable) which is the gradient.
"""
    function evaluate_gradient(sps :: SPS{T}, x :: Vector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        gradient_prl = Vector{Threads.Atomic{Y}}((x-> Threads.Atomic{Y}(0)).([1:sps.n_var;]) )
         @Threads.threads for i in 1:l_elmt_fun
         # for i in 1:l_elmt_fun
            if isempty(sps.structure[i].U) == false
                (row, column, value) = findnz(sps.structure[i].U)
                temp = ForwardDiff.gradient(M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun), Array(view(x, sps.structure[i].used_variable))  )
                atomic_add!.(gradient_prl[column], temp)
            end
        end
        gradient = (x -> x[]).(gradient_prl) :: Vector{Y}
        return gradient
    end

    function evaluate_gradient(sps :: SPS{T}, x :: Vector{BigFloat} ) where T
        l_elmt_fun = length(sps.structure)
        gradient = Vector{BigFloat}(zeros(BigFloat, sps.n_var))
        for i in 1:l_elmt_fun
            (rown, column, value) = findnz(sps.structure[i].U)
            temp = ForwardDiff.gradient(M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun), Array(view(x, sps.structure[i].used_variable)) )
            gradient[column] = gradient[column] + temp
        end
        return gradient
    end


"""
    evaluate_SPS_gradient!(sps,x,g)
Compute the gradient of the partially separable structure sps, and store the result in the grad_vector structure g.
"""
    function evaluate_SPS_gradient!(sps :: SPS{T}, x :: AbstractVector{Y}, g :: grad_vector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        # @inbounds for i in 1:l_elmt_fun
        # Threads.@threads for i in 1:l_elmt_fun
        for i in 1:l_elmt_fun
            if isempty(sps.structure[i].U) == false
                element_gradient!(sps.structure[i].fun, view(x, sps.structure[i].used_variable), g.arr[i] )
            end
        end
    end

"""
    element_gradient!(expr_tree, x, g)
Compute the element grandient of the function represents by expr_tree according to the vector x, and store the result in the vector g
"""
    function element_gradient!( expr_tree :: Y, x :: AbstractVector{T}, g :: element_gradient{T} ) where T <: Number where Y
        ForwardDiff.gradient!(g.g_i, M_evaluation_expr_tree.evaluate_expr_tree(expr_tree), x  )
    end


"""
    build_gradient(sps, g)
Constructs a vector of size n from the list of element gradient of the sps structure which has numerous element gradient of size nᵢ.
The purpose of the function is to gather these element gradient into a real gradient of size n.
The function grad_ni_to_n will be use to transform a element gradient of size nᵢ to a element gradient of size n.
"""
    function build_gradient(sps :: SPS{T}, g :: grad_vector{Y}) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        n = sps.n_var
        f = (x -> Vector{Y}(zeros(Y,n)))
        g_temp = Vector{ Vector{Y} }( f.([1:l_elmt_fun;]))
        for i in 1:l_elmt_fun
            g_temp[i] = grad_ni_to_n(g.arr[i], sps.structure[i].used_variable, n)
        end
        return sum(g_temp)
    end

    function grad_ni_to_n(g :: element_gradient{Y}, used_var :: Vector{Int}, n :: Int ) where Y
        grad = zeros(Y,n)
        sort!(used_var)
        n = length(g.g_i)
        for i in 1:n
            grad[used_var[i]] = g.g_i[i]
        end
        return grad
    end

"""
    evaluate_hessian(sps,x)
evalutate the hessian of the partially separable function f = ∑ fᵢ, stored in the sps structure
at the point x. Return the sparse matrix of the hessian of size n × n.
"""
    function evaluate_hessian(sps :: SPS{T}, x :: AbstractVector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        elmt_hess = Vector{Tuple{Vector{Int},Vector{Int},Vector{Y}}}(undef, l_elmt_fun)
        # @Threads.threads for i in 1:l_elmt_fun # déterminer l'impact sur les performances de array(view())
        for i in 1:l_elmt_fun
            elmt_hess[i] = evaluate_element_hessian(sps.structure[i], Array(view(x, sps.structure[i].used_variable))) :: Tuple{Vector{Int},Vector{Int},Vector{Y}}
        end
        row = [x[1]  for x in elmt_hess] :: Vector{Vector{Int}}
        column = [x[2] for x in elmt_hess] :: Vector{Vector{Int}}
        values = [x[3] for x in elmt_hess] :: Vector{Vector{Y}}
        G = sparse(vcat(row...) :: Vector{Int} , vcat(column...) :: Vector{Int}, vcat(values...) :: Vector{Y}) :: SparseMatrixCSC{Y,Int}
        return G
    end




"""
    evaluate_element_hessian(fᵢ,xᵢ)
Compute the Hessian of the elemental function fᵢ : Gᵢ a n × n matrix. So xᵢ a vector of size nᵢ.
The result of the function is the triplet of the sparse matrix Gᵢ.
"""
    function evaluate_element_hessian(elmt_fun :: element_function{T}, x :: AbstractVector{Y}) where T where Y <: Number
        if elmt_fun.type != implementation_type_expr.constant
            temp = ForwardDiff.hessian(M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun.fun), x ) :: Array{Y,2}
            temp_sparse = sparse(temp) :: SparseMatrixCSC{Y,Int}
            G = SparseMatrixCSC{Y,Int}(elmt_fun.U'*temp_sparse*elmt_fun.U)
            return findnz(G) :: Tuple{Vector{Int}, Vector{Int}, Vector{Y}}
        else
            return (zeros(Int,0), zeros(Int,0), zeros(Y,0))
        end
    end


"""
    struct_hessian(sps,x)
evalutate the hessian of the partially separable function, stored in the sps structure at the point x. Return the Hessian in a particular structure : Hess_matrix.
"""
    function struct_hessian(sps :: SPS{T}, x :: AbstractVector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        f = ( elm_fun :: element_function{T} -> element_hessian{Y}(zeros(Y, length(elm_fun.used_variable), length(elm_fun.used_variable)) :: Array{Y,2} ) )
        t = f.(sps.structure) :: Vector{element_hessian{Y}}
        temp = Hess_matrix{Y}(t)
        for i in 1:l_elmt_fun # a voir si je laisse le array(view()) la ou non
            if sps.structure[i].type != implementation_type_expr.constant
                @inbounds ForwardDiff.hessian!(temp.arr[i].elmt_hess, M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun), view(x, sps.structure[i].used_variable) )
            end
        end
        return temp
    end

"""
    struct_hessian!(sps,x,H)
Evalutate the hessian of the partially separable function, stored in the sps structure at the point x. Store the Hessian in a particular structure H :: Hess_matrix.
"""
    function struct_hessian!(sps :: SPS{T}, x :: AbstractVector{Y}, H :: Hess_matrix{Y} )  where Y <: Number where T
        map( elt_fun -> element_hessian{Y}(ForwardDiff.hessian!(H.arr[elt_fun.index].elmt_hess :: Array{Y,2}, M_evaluation_expr_tree.evaluate_expr_tree(elt_fun.fun :: T), view(x, elt_fun.used_variable :: Vector{Int}) )), sps.structure :: Vector{element_function{T}})
    end



    function construct_Sparse_Hessian(sps :: SPS{T}, H :: Hess_matrix{Y} )  where Y <: Number where T
        mapreduce(elt_fun :: element_function{T} -> elt_fun.U' * sparse(H.arr[elt_fun.index].elmt_hess) * elt_fun.U, +, sps.structure  )
    end



"""
    product_matrix_sps(sps,B,x)
This function make the product of the structure B which represents a symetric matrix and the vector x.
We need the structure sps for the variable used in each B[i], to replace B[i]*x[i] in the result vector.
"""
    product_matrix_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = product_matrix_sps(s_a.sps, s_a.B, x)
    function product_matrix_sps(sps :: SPS{T}, B :: Hess_matrix{Y}, x :: Vector{Y}) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        vector_prl = Vector{Y}(zeros(Y, sps.n_var))
        function f_inter!(a :: AbstractVector{Z}, b :: AbstractVector{Z}) where Z <: Number
            l = length(a)
            for i in 1:l
                @inbounds a[i] += b[i]
            end
        end
        for i in 1:l_elmt_fun
            @inbounds temp = B.arr[i].elmt_hess :: Array{Y,2} * Array(view(x, sps.structure[i].used_variable)) :: Vector{Y}
            f_inter!(view(vector_prl,sps.structure[i].used_variable), temp )
        end
        return vector_prl
        # l_elmt_fun = length(sps.structure)
        # vector_prl = Vector{Threads.Atomic{Y}}((x-> Threads.Atomic{Y}(0)).([1:sps.n_var;]) )
        #  @Threads.threads for i in 1:l_elmt_fun
        #     (rown, column, value) = findnz(sps.structure[i].U)
        #     temp = B.arr[i].elmt_hess * Array(view(x, sps.structure[i].used_variable)) :: Vector{Y}
        #     atomic_add!.(vector_prl[column], temp)
        # end
        # vector_res = (x -> x[]).(vector_prl) :: Vector{Y}
        # return vector_res
    end

    function hess_matrix_dot_vector(sps :: SPS{T}, B :: Hess_matrix{Y}, x :: Vector{Y}) where T where Y <: Number
        mapreduce(elt_fun :: element_function{T} -> elt_fun.U' * sparse(B.arr[elt_fun.index].elmt_hess * view(x, elt_fun.used_variable)) ,+, sps.structure)
    end

    function inefficient_product_matrix_sps(sps :: SPS{T}, B :: Hess_matrix{Y}, x :: Vector{Y}) where T where Y <: Number
        construct_Sparse_Hessian(sps,B) * x
    end

"""
    product_vector_sps(sps, g, x)
compute the product g⊤ x = ∑ Uᵢ⊤ gᵢ⊤ xᵢ. So we need the sps structure to get the Uᵢ.
"""
    product_vector_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = product_vector_sps(s_a.sps, s_a.g, x)
    function product_vector_sps(sps :: SPS{T}, g :: grad_vector{Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number
        l_elmt_fun = length(sps.structure)
        res = Vector{Y}(undef,l_elmt_fun) #vecteur stockant le résultat des gradient élémentaire g_i * x_i
        # à voir si on ne passe pas sur un résultat direct avec des opérations atomique
        for i in 1:l_elmt_fun
            res[i] = g.arr[i]' * Array(view(x, sps.structure[i].used_variable))
        end
        return sum(res)
    end

"""
    Fonction ayant pour but de créer l'approximation SR1 de la structure SPS. Actuellement en suspend car je dois faire autre chose.
"""
    function update_SPS_SR1!(sps :: SPS{T}, B :: Hess_matrix{Y}, B_1 :: Hess_matrix{Y}, y :: Vector{Y}, s :: Vector{Y}) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
         # @Threads.threads for i in 1:l_elmt_fun
         for i in 1:l_elmt_fun
            (rown, column, value) = findnz(sps.structure[i].U)
            s_elem = Array(view(s, sps.structure[i].used_variable))
            y_elem = Array(view(y, sps.structure[i].used_variable))
            B_elem = B.arr[i].elmt_hess
            B_elem_1 = B_1.arr[i].elmt_hess
            Quasi_Newton_update.update_SR1!(s_elem, y_elem, B_elem, B_elem_1)
        end
    end

    function update_SPS_SR1!(sps :: SPS{T}, B :: Hess_matrix{Y}, B_1 :: Hess_matrix{Y}, y :: grad_vector{Y}, s :: Vector{Y}) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
         # @Threads.threads for i in 1:l_elmt_fun
         @inbounds for i in 1:l_elmt_fun
            s_elem = Array(view(s, sps.structure[i].used_variable))
            y_elem = y.arr[i].g_i
            B_elem = B.arr[i].elmt_hess
            B_elem_1 = B_1.arr[i].elmt_hess
            Quasi_Newton_update.update_SR1!(s_elem, y_elem, B_elem, B_elem_1)
        end
    end


    export deduct_partially_separable_structure

end # module




"""
Sans parralélisation le code suivant et sans le typage ajouté:

using ..PartiallySeparableStructure
m = Model()
n_x = 1000
@variable(m, x[1:n_x])
@NLobjective(m, Min, sum( x[j]^2 * x[j+1] for j in 1:n_x-1 ) + x[1]*5 )
# @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) + sin(x[1]))
eval_test = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(eval_test, [:ExprGraph])
obj_o = MathOptInterface.objective_expr(eval_test)
obj = copy(obj_o)

@benchmark PartiallySeparableStructure.deduct_partially_separable_structure(obj_o, n_x)

donne :
BenchmarkTools.Trial:
  memory estimate:  24.66 MiB
  allocs estimate:  91298
  --------------
  minimum time:     8.254 ms (0.00% GC)
  median time:      15.419 ms (0.00% GC)
  mean time:        22.168 ms (35.00% GC)
  maximum time:     291.164 ms (93.78% GC)
  --------------
  samples:          227
  evals/sample:     1
 ------------------------------------------------------------------------------------------------
Toujours sans parallélisation mais avec le typage on a :
BenchmarkTools.Trial:
  memory estimate:  24.57 MiB
  allocs estimate:  87545
  --------------
  minimum time:     11.650 ms (0.00% GC)
  median time:      15.854 ms (0.00% GC)
  mean time:        18.443 ms (17.74% GC)
  maximum time:     313.853 ms (94.39% GC)
  --------------
  samples:          271
  evals/sample:     1
------------------------------------------------------------------------------------------------


BenchmarkTools.Trial:
  memory estimate:  15.75 MiB
  allocs estimate:  54560
  --------------
  minimum time:     7.658 ms (0.00% GC)
  median time:      9.531 ms (0.00% GC)
  mean time:        12.812 ms (24.83% GC)
  maximum time:     439.355 ms (95.95% GC)
  --------------
  samples:          390
  evals/sample:     1
 """
