using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure

#Définition d'un modèle JuMP
σ = 10e-5
n = 30000

m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
@NLobjective(m, Min, sum( (x[j] + x[j+1])^2 for j in 1:n-1 ))
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

#définition d'un premier vecteur d'une valeur aléatoire entre -50 et 50
# t :: DataType = Float64
# x = (α -> α - 50).( (β -> 100 * β).(rand(BigFloat, n)) )
x = (α -> α - 50).( (β -> 100 * β).( rand(n) ) )
# x_MOI = (α -> α - 50).( (β -> 100 * β).(rand(Float64, n)) )
# x = ones(n)
y = (β -> 100 * β).(rand(n))

# détection de la structure partiellement séparable
# SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)

obj2 = trait_expr_tree.transform_to_expr_tree(obj)
# SPS2 = PartiallySeparableStructure.deduct_partially_separable_structure(obj2, n)

# elmt_fun = algo_expr_tree.delete_imbricated_plus(obj)
# elmt_fun2 = algo_expr_tree.delete_imbricated_plus(obj2)
# elmt_var2 = algo_expr_tree.get_elemental_variable.(elmt_fun2)
#
# for i in 1:length(elmt_fun2)
#     algo_expr_tree._element_fun_from_N_to_Ni!(elmt_fun2[i],elmt_var2[i])
# end

    # SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
    # MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x)
    # Expr_obj_en_x = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    ev = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    ev_ = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)
    # @test M_evaluation_expr_tree.evaluate_expr_tree(obj, x) == M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)
    # @code_warntype M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    # @code_warntype M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)

    # ev2 = @benchmark MOI_obj_en_x = MathOptInterface.eval_objective(evaluator, x)
    # ev3 = @benchmark PartiallySeparableStructure.evaluate_SPS(SPS, x)

    # @profview  (@benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x))
    # M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)
    # @profview  (@benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj2, x))

"""
n=1000

BenchmarkTools.Trial:
  memory estimate:  363.00 KiB
  allocs estimate:  8034
  --------------
  minimum time:     338.700 μs (0.00% GC)
  median time:      471.800 μs (0.00% GC)
  mean time:        574.925 μs (0.00% GC)
  maximum time:     101.124 ms (0.00% GC)
  --------------
  samples:          8651
  evals/sample:     1

BenchmarkTools.Trial:
  memory estimate:  1.04 MiB
  allocs estimate:  27049
  --------------
  minimum time:     601.899 μs (0.00% GC)
  median time:      942.300 μs (0.00% GC)
  mean time:        1.100 ms (12.16% GC)
  maximum time:     607.230 ms (99.88% GC)
  --------------
  samples:          4534
  evals/sample:     1

BenchmarkTools.Trial:
  memory estimate:  1.60 MiB
  allocs estimate:  42084
  --------------
  minimum time:     953.600 μs (0.00% GC)
  median time:      1.433 ms (0.00% GC)
  mean time:        1.672 ms (12.51% GC)
  maximum time:     625.551 ms (99.79% GC)
  --------------
  samples:          2985
  evals/sample:     1

  MOI:
BenchmarkTools.Trial:
  memory estimate:  16 bytes
  allocs estimate:  1
  --------------
  minimum time:     717.647 ns (0.00% GC)
  median time:      727.206 ns (0.00% GC)
  mean time:        809.200 ns (0.00% GC)
  maximum time:     5.554 μs (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     136
"""


"""
n = 30000

ev_
BenchmarkTools.Trial:
  memory estimate:  10.76 MiB
  allocs estimate:  240019
  --------------
  minimum time:     18.256 ms (0.00% GC)
  median time:      22.196 ms (0.00% GC)
  mean time:        22.002 ms (0.00% GC)
  maximum time:     24.064 ms (0.00% GC)
  --------------
  samples:          228
  evals/sample:     1



BenchmarkTools.Trial:
  memory estimate:  36.62 MiB
  allocs estimate:  990065
  --------------
  minimum time:     31.617 ms (0.00% GC)
  median time:      45.944 ms (0.00% GC)
  mean time:        44.760 ms (0.00% GC)
  maximum time:     53.565 ms (0.00% GC)
  --------------
  samples:          112
  evals/sample:     1

avant améliorations n = 30000
BenchmarkTools.Trial:
  memory estimate:  39.37 MiB
  allocs estimate:  1169587
  --------------
  minimum time:     223.525 ms (0.00% GC)
  median time:      257.012 ms (0.00% GC)
  mean time:        255.706 ms (0.00% GC)
  maximum time:     290.271 ms (0.00% GC)
  --------------
  samples:          20
  evals/sample:     1

  memory estimate:  39.14 MiB
   allocs estimate:  1169587
   --------------
   minimum time:     177.868 ms (0.00% GC)
   median time:      206.463 ms (0.00% GC)
   mean time:        214.665 ms (0.00% GC)
   maximum time:     372.396 ms (0.00% GC)
   --------------
   samples:          24
   evals/sample:     1

"""
    # # TEST EN COURS
    # res = Vector{typeof(x[1])}(undef,length(elmt_fun))
    # for i in 1:length(elmt_fun)
    #     res[i] = M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun[i], x)
    # end
    # sum_res = sum(res)
    #
    # Coll = [Expr_obj_en_x, MOI_obj_en_x, SPS_en_x, sum_res]
    # Coll2 = [Expr_obj_en_x, MOI_obj_en_x, SPS_en_x]
    #
    # @show Coll
    #
    # max_coll = max(Coll...)
    #
    # diff = (x -> x - max_coll ).(Coll)
    # @show diff
    #
    # max_coll2 = max(Coll2...)
    #
    # diff2 = (x -> x - max_coll2).(Coll2)
    # @show diff2
    #
    # @show Coll[1] - Coll[2], Coll[1] - Coll[3], Coll[2] - Coll[3],  (Coll[1] - Coll[3] ) == (Coll[2] - Coll[3])
    #
    #
    # val_diff = [ -1.9073486328125e-6, -3.814697265625e-6, -4.1961669921875e-5, -1.430511474609375e-5, -3.337860107421875e-5,  -9.5367431640625e-7 ]
    # min_val_diff = min(abs.(val_diff)...)
    # @show test_denominateur_commum = (x -> x / min_val_diff).(val_diff)
    # -4.1961669921875e-5 / -1.9073486328125e-6 == 22
    # -1.430511474609375e-5 / -1.9073486328125e-6 == 7.5
    # -3.337860107421875e-5 / -9.5367431640625e-7 == 35
    # -1.9073486328125e-6 / -9.5367431640625e-7 == 2



# """ EVALUATION DES FONCTIONS """
#
# @testset "evaluation des fonctions par divers moyens" begin
#
#     SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
#     MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x)
#     Expr_obj_en_x = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
#
#     @test MOI_obj_en_x - Expr_obj_en_x < σ
#     @test SPS_en_x - MOI_obj_en_x < σ
#
#
#     SPS_en_y = PartiallySeparableStructure.evaluate_SPS(SPS, y)
#     MOI_obj_en_y = MathOptInterface.eval_objective(evaluator, y)
#     Expr_obj_en_y = M_evaluation_expr_tree.evaluate_expr_tree(obj, y)
#
#     @test SPS_en_y - MOI_obj_en_y < σ
#     @test MOI_obj_en_y - Expr_obj_en_y < σ
#
    # a = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    # b = @benchmark PartiallySeparableStructure.evaluate_SPS( SPS, x)
    # c = @benchmark MathOptInterface.eval_objective( evaluator, x)
# end
#
#
# """ EVALUATION DES GRADIENTS """
#
# @testset " evaluation du gradient par divers moyer" begin
    # MOI_gradient_en_x = Vector{ typeof(x[1]) }(undef,n)
    #
    # SPS_gradient_en_x = PartiallySeparableStructure.evaluate_gradient(SPS, x)
    # MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_x, x)

    # Expr_gradient_en_x = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, x)
#     @test norm(SPS_gradient_en_x - Expr_gradient_en_x,2) < σ
#     @test norm(SPS_gradient_en_x - MOI_gradient_en_x, 2) < σ
#
#     MOI_gradient_en_y = Vector{ typeof(y[1]) }(undef,n)
#
    # SPS_gradient_en_y = PartiallySeparableStructure.evaluate_gradient(SPS, y)
    # MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_y, y)
    # Expr_gradient_en_y = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, y)
#     @test norm(SPS_gradient_en_y - Expr_gradient_en_y, 2) < σ
#     @test norm(SPS_gradient_en_y - MOI_gradient_en_y, 2)  < σ

# g1 = @benchmark Expr_gradient_en_x = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, x)
#
# g2 = @benchmark PartiallySeparableStructure.evaluate_gradient(SPS, x)
# @show "fait 2"
# g3 = @benchmark MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_x, x)

# end
#
#
# """ EVALUATION DES HESSIANS """
#
# @testset "evaluation du Hessian par divers moyers" begin
#
#
#     MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
#     column = [x[1] for x in MOI_pattern]
#     row = [x[2]  for x in MOI_pattern]
#
#     MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
#     MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
#     values = [x for x in MOI_value_Hessian]
# #
#     MOI_half_hessian_en_x = sparse(row,column,values)
#     MOI_hessian_en_x = Symmetric(MOI_half_hessian_en_x)
#
    # SPS_Hessian_en_x = PartiallySeparableStructure.evaluate_hessian(SPS, x )
    # Expr_Hessian_en_x = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj, x)
#     #
#     # @test norm(MOI_hessian_en_x - Expr_Hessian_en_x, 2) < σ
#     # @test norm(sparse(MOI_hessian_en_x) - SPS_Hessian_en_x, 2) < σ
#
#     # on récupère le Hessian structuré du format SPS.
#     #Ensuite on calcul le produit entre le structure de donnée SPS_Structured_Hessian_en_x et y
#     prod1 = @benchmark (SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x);
#     SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)
# )
#
    # v_tmp = Vector{ Float64 }(undef, length(MOI_pattern))
#     MOI_Hessian_product_y = Vector{ typeof(y[1]) }(undef,n)
#      prod2 = @benchmark (MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0)))
#
#
#
#
#     @test norm(MOI_Hessian_product_y - SPS_product_Hessian_en_x_et_y, 2) < σ
#     @test norm(MOI_hessian_en_x*y - SPS_product_Hessian_en_x_et_y, 2) < σ
#     @test norm(MOI_Hessian_product_y - MOI_hessian_en_x*y, 2) < σ
#
#
#
# h4 = @benchmark Expr_Hessian_en_x = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj, x)
# @show "1"
# h0 = @benchmark SPS_Hessian_en_x = PartiallySeparableStructure.evaluate_hessian(SPS, x )
# @show "1"
# h1 = @benchmark SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
# @show "1"
# h2 = @benchmark MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
# #
# # @benchmark MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
# #
# @benchmark SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)
# @benchmark MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0))
#
# end










#
#
# @testset "vérification des types des évalations de la fonction/gradient/Hessian" begin
#     var_type_BigFloat = (α -> α - 50).( (β -> 100 * β).(rand(BigFloat,n)) )
#
#     # SPS_test_type = PartiallySeparableStructure.evaluate_SPS(SPS, var_type_BigFloat)
#     # @test typeof(var_type_BigFloat[1]) == typeof(SPS_test_type)
#     # SPS_gradient_test_type_en_x = PartiallySeparableStructure.evaluate_gradient(SPS, var_type_BigFloat)
#     # @test typeof(SPS_gradient_test_type_en_x[1]) == typeof(var_type_BigFloat[1])
# end
