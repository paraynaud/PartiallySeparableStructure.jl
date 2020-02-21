using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..Solver_SPS
using ..implementation_expr_tree
using ..M_evaluation_expr_tree

using ..implementation_L_SR1


σ = 10e-5
n = 100
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( 100 * (x[Integer(2*j-1)]^2 - x[Integer(2*j)])^2 + (x[Integer(2*j-1)] - 1)^2 + 90 * (x[Integer(2*j+1)]^2 - x[Integer(2*j+2)])^2 + (x[Integer(2*j+1)] -1)^2 + 10 * (x[Integer(2*j)] + x[Integer(2*j+2)] - 2)^2 + (x[Integer(2*j)] - x[Integer(2*j+2)]^2 * 0.1)  for j in 1:((n-2)/2) )) #rosenbrock function
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)



# @code_warntype Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

point_initial = x_k1 = (x -> 10000*x - 5000).(rand(n))

struct_algo = Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

implementation_L_SR1.solver_L_SR1(obj, n, point_initial)
