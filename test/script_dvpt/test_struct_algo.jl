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
n = 10
m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
@NLobjective(m, Min, sum( (x[j] + x[j+1])^2 for j in 1:n-1 ))
# @NLobjective(m, Min, sum( (x[j] * x[j+1])^2 * x[j+2]  for j in 1:n-2 ))
# @NLobjective(m, Min, sum( (x[j] + x[j+1]+ x[j+2] + x[j+3])^2   for j in 1:n-3 ))
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

empty_sps = Solver_SPS.alloc_struct_algo(obj,n)

# x_k = rand(n)
x_k = ones(n)
x_k1 = (x -> 100*x).(rand(n))

Solver_SPS.init_struct_algo!(empty_sps, x_k, x_k1)

test = Solver_SPS.determine_xk1(empty_sps)

@show test
quad_approx_x_k = Solver_SPS.approx_quad(empty_sps, x_k)

Solver_SPS.update_xk1!(empty_sps)


Solver_SPS.solver_TR_SR1(obj, n, x_k, Float64)





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
