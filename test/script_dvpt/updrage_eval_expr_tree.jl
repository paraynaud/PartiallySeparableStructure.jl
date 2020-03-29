using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..implementation_expr_tree
using ..M_evaluation_expr_tree
println("\n\n Début script de dvpt\n\n")



#Définition d'un modèle JuMP
σ = 10e-5
n = 10000
m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
@NLobjective(m, Min, sum( (x[j] + x[j+1])^3 for j in 1:n-1 ))
# @NLobjective(m, Min, sum( (x[j] * x[j+1])^2 * x[j+2]  for j in 1:n-2 ))
# @NLobjective(m, Min, sum( (x[j] + x[j+1]+ x[j+2] + x[j+3])^2   for j in 1:n-3 ))
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
SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)

obj2 = trait_expr_tree.transform_to_expr_tree(obj)
obj3 = trait_expr_tree.transform_to_expr_tree(obj)
SPS2 = PartiallySeparableStructure.deduct_partially_separable_structure(obj3, n)


println("comparasion des évaluations")


b_eval1 = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
b_eval2 = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)
b_eval3 = @benchmark M_evaluation_expr_tree.evaluate_expr_tree2(obj2, x)
@profview M_evaluation_expr_tree.evaluate_expr_tree2(obj2, x)
@profview @benchmark M_evaluation_expr_tree.evaluate_expr_tree2(obj2, x)
error("fin anticipé")


using StaticArrays

mutable struct type_node{T}
    field :: T
    children :: AbstractArray{T}
end



x = @SVector zeros(type_node{Int64},0)
a = type_node{Int64}(5 :: Int64, x)

v1 = SVector(1, 2, 3)

println("- set up des données fini")

println("- Début des test")
    @test PartiallySeparableStructure.evaluate_SPS(SPS2, x) -  PartiallySeparableStructure.evaluate_SPS(SPS, x) < σ
    @test M_evaluation_expr_tree.evaluate_expr_tree(obj2, x) - M_evaluation_expr_tree.evaluate_expr_tree(obj, x) < σ
    @test PartiallySeparableStructure.evaluate_SPS(SPS2, x) - M_evaluation_expr_tree.evaluate_expr_tree(obj2, x) < σ
    @test PartiallySeparableStructure.evaluate_SPS(SPS2, x) - MathOptInterface.eval_objective(evaluator, x) < σ

println(" fin des tests vérifiant les résultats")

println("- Génération des benchmarks evaluation des fonctions objectifs")

    # ev_obj_Expr = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    # println("  - obj Expr fait ")
    # ev_obj_expr_tree = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)
    # println("  - obj_expr_tree fait")
    #
    # ev_SPS_Expr = @benchmark PartiallySeparableStructure.evaluate_SPS(SPS, x)
    # println("  - SPS Expr fait")
    # ev_SPS_expr_tree9 = @benchmark PartiallySeparableStructure.evaluate_SPS(SPS2, x)
    # println("  - SPS expr_tree fait")
    # ev_MOI = @benchmark MOI_obj_en_x = MathOptInterface.eval_objective(evaluator, x)
    # println("  - Evaluation MOI faite")

println("- Les profiles des fonctions maintenant \n\n")
    # @profview  (@benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x))
    # @profview  (@benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj2, x))
    # @profview (@benchmark PartiallySeparableStructure.evaluate_SPS(SPS2, x))
    # @profview (@benchmark PartiallySeparableStructure.evaluate_SPS(SPS, x))
    # @profview (@benchmark MOI_obj_en_x = MathOptInterface.eval_objective(evaluator, x))


# println("test SPS gradient ")
    # x_init = ones(n)
    # f = (x :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(x_init[1])}(Vector{typeof(x_init[1])}(undef, length(x.used_variable) )) )
    # grad = PartiallySeparableStructure.grad_vector{typeof(x_init[1])}( f.(SPS2.structure) )
    #
    # bench_grad3 = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!(SPS2, x_init, grad)
    #
    # @benchmark ForwardDiff.gradient( M_evaluation_expr_tree.evaluate_expr_tree( SPS2.structure[1].fun), x_init[1:2]  )
    # @benchmark PartiallySeparableStructure.element_gradient!(SPS2.structure[1].fun, view(x_init, [1,2]), grad.arr[1])
    # @benchmark M_evaluation_expr_tree.evaluate_expr_tree(SPS2.structure[1].fun, view(x_init, [1,2]) )


println("test des mises à jour SR1 et BFGS")
    f_approx = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(zeros(Float64, length(elm_fun.used_variable), length(elm_fun.used_variable)) ) ) )
    v_elmt_hess = f_approx.(SPS2.structure)
    v_elmt_hess2 = f_approx.(SPS2.structure)
    v_elmt_hess3 = f_approx.(SPS2.structure)
    exact_Hessian = PartiallySeparableStructure.Hess_matrix{Float64}(v_elmt_hess)
    approx_hessian = PartiallySeparableStructure.Hess_matrix{Float64}(v_elmt_hess2)
    approx_hessian2 = PartiallySeparableStructure.Hess_matrix{Float64}(v_elmt_hess3)

    x_init = ones(n)
    x_2nd = (x -> 2*x).(x_init)
    fake_grad = (x -> - 50 + 100 * x).(rand(n))
    fake_grad2 = (x -> - 50 + 100 * x).(rand(n))
    s = x_2nd - x_init
    y = fake_grad2 - fake_grad

    PartiallySeparableStructure.struct_hessian!(SPS2, x, exact_Hessian)
    PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian, s, y)


    f = (x :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(x_init[1])}(Vector{typeof(x_init[1])}(undef, length(x.used_variable) )) )
    grad_x = PartiallySeparableStructure.grad_vector{typeof(x_init[1])}( f.(SPS2.structure) )
    grad_x_1 = PartiallySeparableStructure.grad_vector{typeof(x_init[1])}( f.(SPS2.structure) )
    grad_diff = PartiallySeparableStructure.grad_vector{typeof(x_init[1])}( f.(SPS2.structure) )
    PartiallySeparableStructure.evaluate_SPS_gradient!(SPS2, x_2nd, grad_x_1)

    println("on commence")
    bench_compute_grad = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!(SPS2, x_init, grad_x)
println("1")
    # bench_build_grad = @benchmark PartiallySeparableStructure.build_gradient(SPS2, grad_x)
    g_res = Vector{Float64}(zeros(Float64,n))
    bench_build_grad3 = @benchmark PartiallySeparableStructure.build_gradient!(SPS2, grad_x, g_res)
    println("2")
    bench_build_grad2 = @benchmark PartiallySeparableStructure.evaluate_gradient(SPS2, x)

error("fin")
    # @show gradient_de_x = PartiallySeparableStructure.build_gradient(SPS2, grad_x)
    # @show gradient_de_x_1 = PartiallySeparableStructure.build_gradient(SPS2, grad_x_1)
    # @show PartiallySeparableStructure.minus_grad_vec!(grad_x_1, grad_x, grad_diff)
    #
    # PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian2, grad_diff, s)
    # @show dif_gradient = PartiallySeparableStructure.build_gradient(SPS2, grad_diff)
    # @show Bs = PartiallySeparableStructure.product_matrix_sps(SPS2, approx_hessian2, s)
    # @show Bs2 = PartiallySeparableStructure.product_matrix_sps(SPS2, approx_hessian, s)
    # @show norm(Bs - dif_gradient, 2)


    #
    # bench_SPS_Hess_approx_grad_modif = @benchmark PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian2, dif_grad, s)
    # @show norm(PartiallySeparableStructure.build_gradient(SPS2,dif_grad) - PartiallySeparableStructure.product_matrix_sps(SPS2, approx_hessian, s),2)
    # SPS_Hess_approx2 = @benchmark PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian, s, fake_grad)

    # @code_warntype PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian, s, y)
    # @profview (@benchmark PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian, dif_grad, s))

    # @profview PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian, dif_grad, s)
    # using Profile
    # Profile.clear()
    # @profile PartiallySeparableStructure.update_SPS_SR1!(SPS2, exact_Hessian, approx_hessian, dif_grad, s)
    # ProfileView.view()

    # bench_forwardiff = @benchmark M_evaluation_expr_tree.calcul_gradient_expr_tree(obj,x)
    # bench_reversediff = @benchmark M_evaluation_expr_tree.calcul_gradient_expr_tree2(obj,x)

println("test du Hessien ")
println(" - set-up des structures de résultats")
MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
column = [x[1] for x in MOI_pattern]
row = [x[2]  for x in MOI_pattern]
# #
MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
# MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
# values = [x for x in MOI_value_Hessian]
# f2 = ( elm_fun :: PartiallySeparableStructure.element_function{Expr} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
# t2 = f2.(SPS.structure)
# H2 = PartiallySeparableStructure.Hess_matrix{Float64}(t2)
f = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
t = f.(SPS2.structure) :: Vector{PartiallySeparableStructure.element_hessian{Float64}}
H = PartiallySeparableStructure.Hess_matrix{Float64}(t)
# println("début des benchmark sur les Hessiens")
    # SPS_expr_tree_HESSIAN = @benchmark SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS2, x)
    # println("Hessien expr_tree")
#     SPS_Expr_HESSIAN = @benchmark SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
#     println("Hessien Expr")
    bench_MOI_HESSIAN = @benchmark MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
#     println("Hessien MOI")
    # SPS_HESS_expr_tree! = @benchmark PartiallySeparableStructure.struct_hessian!(SPS2, x, H)
    # println("Hessian! Expr fait ")
#     SPS_HESS_Expr! = @benchmark PartiallySeparableStructure.struct_hessian!(SPS, x, H2)
#     println("Hessian! expr_tree fait ")
# @profview (@benchmark PartiallySeparableStructure.struct_hessian!(SPS2, x, H))




""" evolution des temps de l'approximation SR1 sur la structure SPS
Utilisation du Hessien elementaire
BenchmarkTools.Trial:
  memory estimate:  7.93 MiB
  allocs estimate:  109989
  --------------
  minimum time:     3.335 ms (0.00% GC)
  median time:      6.135 ms (0.00% GC)
  mean time:        7.087 ms (13.38% GC)
  maximum time:     673.839 ms (99.21% GC)
  --------------
  samples:          705
  evals/sample:     1

J'ai mis des AbstractArray et AbstractVector
    BenchmarkTools.Trial:
      memory estimate:  12.36 MiB
      allocs estimate:  179984
      --------------
      minimum time:     89.265 ms (0.00% GC)
      median time:      96.222 ms (0.00% GC)
      mean time:        96.017 ms (0.00% GC)
      maximum time:     103.111 ms (0.00% GC)
      --------------
      samples:          53
      evals/sample:     1

Après avoir amélioré le calcul
BenchmarkTools.Trial:
  memory estimate:  11.18 MiB
  allocs estimate:  164926
  --------------
  minimum time:     36.273 ms (0.00% GC)
  median time:      138.827 ms (0.00% GC)
  mean time:        124.770 ms (0.00% GC)
  maximum time:     152.889 ms (0.00% GC)
  --------------
  samples:          41
  evals/sample:     1

BenchmarkTools.Trial:
  memory estimate:  11.24 MiB
  allocs estimate:  165720
  --------------
  minimum time:     42.881ms  (0.00% GC)
  median time:      140.130 ms (0.00% GC)
  mean time:        126.384 ms (0.00% GC)
  maximum time:     163.439 ms (0.00% GC)
  --------------
  samples:          40
  evals/sample:     1


"""


"""

n=10000

memory estimate:  1.98 MiB
allocs estimate:  59997
--------------
minimum time:     2.753 ms (0.00% GC)
median time:      3.599 ms (0.00% GC)
mean time:        3.783 ms (0.00% GC)
maximum time:     8.387 ms (0.00% GC)
--------------
samples:          1319
evals/sample:     1

BenchmarkTools.Trial:
  memory estimate:  3.97 MiB
  allocs estimate:  119979
  --------------
  minimum time:     6.667 ms (0.00% GC)
  median time:      8.362 ms (0.00% GC)
  mean time:        8.418 ms (0.00% GC)
  maximum time:     11.107 ms (0.00% GC)
  --------------
  samples:          594
  evals/sample:     1


n=1000


BenchmarkTools.Trial:
  memory estimate:  202.97 KiB
  allocs estimate:  5997
  --------------
  minimum time:     165.601 μs (0.00% GC)
  median time:      218.900 μs (0.00% GC)
  mean time:        259.198 μs (0.00% GC)
  maximum time:     1.455 ms (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     1

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
SPS (Principalement expr_tree)
BenchmarkTools.Trial:
  memory estimate:  2.56 MiB
  allocs estimate:  95932
  --------------
  minimum time:     10.305 ms (0.00% GC)
  median time:      110.892 ms (0.00% GC)
  mean time:        79.552 ms (0.00% GC)
  maximum time:     114.522 ms (0.00% GC)
  --------------
  samples:          64
  evals/sample:     1

OBJ (Principalement expr_tree) :
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
    # SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
    # MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x)
    # Expr_obj_en_x = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    #
    # @test MOI_obj_en_x - Expr_obj_en_x ≈ σ
    # @test SPS_en_x - MOI_obj_en_x ≈ σ
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

#     MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
#     column = [x[1] for x in MOI_pattern]
#     row = [x[2]  for x in MOI_pattern]
# # #
#     MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
#     MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
#     values = [x for x in MOI_value_Hessian]
# #
#     MOI_half_hessian_en_x = sparse(row,column,values)
#     MOI_hessian_en_x = Symmetric(MOI_half_hessian_en_x)

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
