using JuMP, MathOptInterface
# using Test, BenchmarkTools, ProfileView, InteractiveUtils, LinearAlgebra, SparseArrays


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..Solver_SPS
using ..implementation_expr_tree
using ..M_evaluation_expr_tree

# using ..implementation_L_SR1


σ = 10e-5
n = 10000
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( (5 + x[j] + sin(x[j+1]) + cos(x[j+2]) + tan(x[j+3]) + exp(x[j+4]) + (x[j+5] - x[j+6])*13 )^4   for j in 1:n-6 ) ) #rosenbrock function

evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)



# @code_warntype Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

# point_initial = x_k1 = (x -> 100*x - 50).(rand(n))
point_initial = (x -> 10*x).(ones(n))

struct_algo = Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

# implementation_L_SR1.solver_L_SR1(obj, n, point_initial)
