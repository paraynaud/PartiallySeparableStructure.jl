module PartiallySeparableStructure

    using ..implementation_type_expr
    using ..algo_expr_tree, ..trait_expr_tree, ..trait_type_expr, ..M_evaluation_expr_tree
    using ForwardDiff, SparseArrays
    using Base.Threads

    mutable struct element_function{T}
        fun :: T
        type :: implementation_type_expr.t_type_expr_basic
        used_variable :: Vector{Int64}
        U :: SparseMatrixCSC{Int64,Int64}
    end

    mutable struct SPS{T}
        structure :: Vector{element_function{T}}
        vec_length :: Int64
        n_var :: Int64
    end

    # mutable struct
    #     elmt_hess ::
    #     used_var ::
    # end
    #
    # mutable struct Hess_matrix
    #
    # end


"""
    deduct_partially_separable_structure(expr_tree, n)
Find the partially separable structure of the expression tree expr_tree.
n is the number of the variable.It is needed.
"""
    deduct_partially_separable_structure(a :: Any, n :: Int64) = _deduct_partially_separable_structure(a, trait_expr_tree.is_expr_tree(a), n)
    _deduct_partially_separable_structure(a, :: trait_expr_tree.type_not_expr_tree, n :: Int64) = error("l'entrée de la fonction n'est pas un arbre d'expression")
    _deduct_partially_separable_structure(a, :: trait_expr_tree.type_expr_tree, n :: Int64) = _deduct_partially_separable_structure(a, n )
    function _deduct_partially_separable_structure(expr_tree :: T , n :: Int64) where T
        work_expr_tree = copy(expr_tree)

        elmt_fun = algo_expr_tree.delete_imbricated_plus(work_expr_tree) :: Vector{T}
        m_i = length(elmt_fun)

        type_i = Vector{trait_type_expr.t_type_expr_basic}(undef, m_i)
        # type_i = algo_expr_tree._get_type_tree.(elmt_fun) :: Vector{trait_type_expr.t_type_expr_basic}
        Threads.@threads for i in 1:m_i
            type_i[i] = algo_expr_tree.get_type_tree(elmt_fun[i])
        end

        # elmt_var_i = algo_expr_tree.get_elemental_variable.(elmt_fun) :: Vector{ Vector{Int64}}
        elmt_var_i =  Vector{ Vector{Int64}}(undef,m_i)
        length_vec = Threads.Atomic{Int64}(0)
        Threads.@threads for i in 1:m_i
            elmt_var_i[i] = algo_expr_tree.get_elemental_variable(elmt_fun[i])
            atomic_add!(length_vec, length(elmt_var_i[i]))
        end

        # U_i = algo_expr_tree.get_Ui.(elmt_var_i, n) :: Vector{SparseMatrixCSC{Int64,Int64}}
        U_i = Vector{SparseMatrixCSC{Int64,Int64}}(undef,m_i)
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
evalutate the partially separable function, stored in the sps structure
at the point x
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
evalutate the gradient of the partially separable function, stored in the sps structure
at the point x, return a vector of size n (the number of variable) which is the gradient.
"""
    function evaluate_gradient(sps :: SPS{T}, x :: Vector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        gradient_prl = Vector{Threads.Atomic{Y}}((x-> Threads.Atomic{Y}(0)).(Vector{Int8}(undef,sps.n_var)) )
         @Threads.threads for i in 1:l_elmt_fun
            (rown, column, value) = findnz(sps.structure[i].U)
            temp = ForwardDiff.gradient(M_evaluation_expr_tree.evaluate_expr_tree(sps.structure[i].fun), Array(view(x, sps.structure[i].used_variable))  )
            atomic_add!.(gradient_prl[column], temp)
        end
        gradient = (x -> x[]).(gradient_prl) :: Vector{Y}
        return gradient
    end

"""
    evaluate_hessian(sps,x)
evalutate the hessian of the partially separable function, stored in the sps structure
at the point x. Return the sparse matrix of the hessian.
"""
    function evaluate_hessian(sps :: SPS{T}, x :: Vector{Y} ) where T where Y <: Number
        l_elmt_fun = length(sps.structure)
        elmt_hess = Vector{Tuple{Vector{Int64},Vector{Int64},Vector{Float64}}}(undef, l_elmt_fun)
         # @Threads.threads for i in 1:l_elmt_fun # a voir si je laisse le array(view()) la ou non
        @Threads.threads for i in 1:l_elmt_fun # a voir si je laisse le array(view()) la ou non
            elmt_hess[i] = evaluate_element_hessian(sps.structure[i], Array(view(x, sps.structure[i].used_variable)))
        end
        row = [x[1] for x in elmt_hess] :: Vector{Vector{Int64}}
        column = [x[2] for x in elmt_hess]:: Vector{Vector{Int64}}
        values = [x[3] for x in elmt_hess] :: Vector{Vector{Y}}
        G = sparse(vcat(row...),vcat(column...),vcat(values...))
        return G
    end


    function evaluate_element_hessian(elmt_fun :: element_function{T}, x :: Vector{Y}) where T where Y <: Number
        # (rown, column, value) = findnz(elmt_fun.U)
        temp = ForwardDiff.hessian(M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun.fun), x )
        temp_sparse = sparse(temp)
        G = elmt_fun.U'*temp_sparse*elmt_fun.U
        return findnz(G)
    end

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
