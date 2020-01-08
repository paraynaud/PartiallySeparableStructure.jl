module PartiallySeparableStructure

    using ..implementation_type_expr
    using ..algo_expr_tree, ..trait_expr_tree, ..trait_type_expr, ..M_evaluation_expr_tree
    using ForwardDiff, SparseArrays
    using Base.Threads

    mutable struct element_function{T}
        fun :: T
        type :: implementation_type_expr.t_type_expr_basic
        used_variable :: Vector{Int}
        U :: SparseMatrixCSC{Int,Int}
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
        Sps[i] = element_function{T}(elmt_fun[i], type_i[i], elmt_var_i[i], U_i[i])
    end

    return SPS{T}(Sps, length_vec[], n)
end

"""
    evaluate_SPS(sps,x)
evalutate the partially separable function f = ∑fᵢ, stored in the sps structure at the point x.
f(x) = ∑fᵢ(xᵢ), so we compute independently each fᵢ(xᵢ) and we return the sum.
"""
    function evaluate_SPS(sps :: SPS{T}, x :: Vector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        res = Vector{Y}(undef, l_elmt_fun)
        @Threads.threads for i in 1:l_elmt_fun
            res[i] = M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun, Array(view(x, sps.structure[i].used_variable)) )
        end
        return sum(res)
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
            (rown, column, value) = findnz(sps.structure[i].U)
            temp = ForwardDiff.gradient(M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun), Array(view(x, sps.structure[i].used_variable))  )
            atomic_add!.(gradient_prl[column], temp)
        end
        gradient = (x -> x[]).(gradient_prl) :: Vector{Y}
        return gradient
    end

"""
    evaluate_hessian(sps,x)
evalutate the hessian of the partially separable function f = ∑ fᵢ, stored in the sps structure
at the point x. Return the sparse matrix of the hessian of size n × n.
"""
    function evaluate_hessian(sps :: SPS{T}, x :: Vector{Y} ) where T where Y <: Number
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
    function evaluate_element_hessian(elmt_fun :: element_function{T}, x :: Vector{Y}) where T where Y <: Number
        temp = ForwardDiff.hessian(M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun.fun), x ) :: Array{Y,2}
        temp_sparse = sparse(temp) :: SparseMatrixCSC{Y,Int}
        G = SparseMatrixCSC{Y,Int}(elmt_fun.U'*temp_sparse*elmt_fun.U)
        return findnz(G) :: Tuple{Vector{Int}, Vector{Int}, Vector{Y}}
    end



"""
    evaluate_hessian(sps,x)
evalutate the hessian of the partially separable function, stored in the sps structure
at the point x. Return the result as a Hess_matrix.
"""
    function struct_hessian(sps :: SPS{T}, x :: Vector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        elmt_hess = Vector{Tuple{Vector{Int},Vector{Int},Vector{Y}}}(undef, l_elmt_fun)
        temp = Vector{element_hessian{Y}}(undef, l_elmt_fun)
        @Threads.threads for i in 1:l_elmt_fun # a voir si je laisse le array(view()) la ou non
            temp[i] = element_hessian{Y}(ForwardDiff.hessian(M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun), Array(view(x, sps.structure[i].used_variable)) ) )
        end
        G = Hess_matrix{Y}(temp)
        return G
    end

"""
    product_matrix_sps(sps,B,x)
This function make the product of the structure B which represent a symetric matrix and the vector x.
We need the structure sps for the variable used in each B[i], to replace B[i]*x[i] in the result vector.
"""
    product_matrix_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = product_matrix_sps(s_a.sps, s_a.B, x)
    function product_matrix_sps(sps :: SPS{T}, B :: Hess_matrix{Z}, x :: Vector{Y}) where T where Z <: Number where Y <: Number
        l_elmt_fun = length(sps.structure)
        vector_prl = Vector{Threads.Atomic{Y}}((x-> Threads.Atomic{Y}(0)).([1:sps.n_var;]) )
         @Threads.threads for i in 1:l_elmt_fun
            (rown, column, value) = findnz(sps.structure[i].U)
            temp = B.arr[i].elmt_hess * Array(view(x, sps.structure[i].used_variable)) :: Vector{Y}
            atomic_add!.(vector_prl[column], temp)
        end
        vector_res = (x -> x[]).(vector_prl) :: Vector{Y}
        return vector_res
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


    function approx_B_SR1(sps :: SPS{T}, B :: Hess_matrix{Y}, y :: Vector{Y}, s :: Vector{Z}) where T where Y <: Number where Z <: Number
        l_elmt_fun = length(sps.structure)
        vector_prl = Vector{Threads.Atomic{Y}}((x-> Threads.Atomic{Y}(0)).([1:sps.n_var;]) )
         # @Threads.threads for i in 1:l_elmt_fun
         for i in 1:l_elmt_fun
            (rown, column, value) = findnz(sps.structure[i].U)
            temp = B.arr[i].elmt_hess * Array(view(x, sps.structure[i].used_variable))
        end
        vector_res = (x -> x[]).(vector_prl) :: Vector{Y}
        return vector_res
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
