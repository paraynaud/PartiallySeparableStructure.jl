using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..Solver_SPS
using ..implementation_expr_tree
using ..M_evaluation_expr_tree


println("\n\n Début script de dvpt\n\n")



#Définition d'un modèle JuMP
σ = 10e-5
n = 3
m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
# @NLobjective(m, Min, sum( (x[j] + cos(x[j+1])^2)^4 for j in 1:n-1 ))
@NLobjective(m, Min, sum( (x[j] + sin(x[j+1]))^4 for j in 1:n-1 ))
# @NLobjective(m, Min, sum( (x[j] + x[j+1] + sin(x[j])^2 )^4  for j in 1:n-1 ))
# @NLobjective(m, Min, sum( (x[j] + x[j+1]+ x[j+2] + x[j+3])^2   for j in 1:n-3 ))

# @NLobjective(m, Min, sum( 100 * (x[j+1] - x[j]^2)^2 + (1 - x[j])^2  for j in 1:n-1 )) #rosenbrock function

evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)
obj2 = trait_expr_tree.transform_to_expr_tree(obj)
# using ..trait_expr_tree, ..algo_tree
#
# obj2 = trait_expr_tree.transform_to_expr_tree(obj)
#
# obj3 = Base.copy(obj2)
# @show obj2 ==obj3
#
# obj2.children[1] = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(5))
# @show obj2
# @show obj3
# @show obj2 ==obj3
# error("test copy")

@code_warntype trait_expr_tree.transform_to_expr_tree(obj)
@code_warntype trait_expr_tree.transform_to_expr_tree(obj2)

@code_warntype PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)
@code_warntype PartiallySeparableStructure.deduct_partially_separable_structure(obj2, n)


res_sps = PartiallySeparableStructure.deduct_partially_separable_structure(obj2, n)



println("séparation ")

@code_warntype Solver_SPS.alloc_struct_algo(obj,n)
@code_warntype Solver_SPS.alloc_struct_algo(obj2,n)

empty_sps = Solver_SPS.alloc_struct_algo(obj,n)



@code_warntype Solver_SPS.alloc_struct_algo(obj,n)

# x_k = rand(n)
x_k = (x -> 200*x).(ones(n))
x_k1 = (x -> 100*x).(rand(n))

quad_approx_x_k = Solver_SPS.approx_quad(empty_sps, x_k)



# test = Solver_SPS.determine_xk1(empty_sps)
# @show test
# Solver_SPS.update_xk1!(empty_sps)
# Solver_SPS.change_x_k1_x_k!(empty_sps)

# Solver_SPS.init_struct_algo!(empty_sps, x_k, x_k1)
# Solver_SPS.iterations_TR!(empty_sps)







# println("début du solver")
# point_initial = x_k1 = (x -> 100*x).(rand(n))
# # struct_algo = Solver_SPS.solver_TR_SR1(obj, n, point_initial, Float64)
# @code_warntype Solver_SPS.solver_TR_SR1(obj, n, point_initial, Float64)





# MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_x, x_k)



# MOI_gradient_en_x = Vector{typeof(x_k[1])}(undef, n)
# MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
# column = [x[1] for x in MOI_pattern]
# row = [x[2]  for x in MOI_pattern]
# MOI_value_Hessian = Vector{ typeof(x_k[1]) }(undef,length(MOI_pattern))
# MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x_k, 1.0, zeros(0))
# values = [x for x in MOI_value_Hessian]
# MOI_half_hessian_en_x = sparse(row,column,values,n,n)
# MOI_hessian_en_x_sparse = Symmetric(MOI_half_hessian_en_x)
# MOI_hessian_en_x = Array(MOI_hessian_en_x_sparse)
#
#
# MOI_obj_en_x = MathOptInterface.eval_objective(evaluator, x_k)
#
# res = MOI_obj_en_x + MOI_gradient_en_x' * x_k + x_k' * MOI_hessian_en_x * x_k
