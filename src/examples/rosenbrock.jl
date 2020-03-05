using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


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
@NLobjective(m, Min, sum( 100 * (x[j+1] - x[j]^2)^2 + (1 - x[j])^2  for j in 1:n-1 )) #rosenbrock function

evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)



# @code_warntype Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

# point_initial = x_k1 = (x -> 10000*x - 5000).(rand(n))
point_initial = x_k1 = (x -> 100*x).(ones(n))

struct_algo = Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

# implementation_L_SR1.solver_L_SR1(obj, n, point_initial)
