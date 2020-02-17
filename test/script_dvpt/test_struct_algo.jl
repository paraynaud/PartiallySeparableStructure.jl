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
@NLobjective(m, Min, sum( (x[j] + x[j+1])^3 for j in 1:n-1 ))
# @NLobjective(m, Min, sum( (x[j] * x[j+1])^2 * x[j+2]  for j in 1:n-2 ))
# @NLobjective(m, Min, sum( (x[j] + x[j+1]+ x[j+2] + x[j+3])^2   for j in 1:n-3 ))
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

empty_sps = Solver_SPS.alloc_struct_algo(obj,n)

x_k = rand(n)
x_k1 = (x -> 100*x).(rand(n))
Solver_SPS.init_struct_algo!(empty_sps, x_k, x_k1)
