# using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
# using Test, BenchmarkTools, ProfileView, InteractiveUtils

using NLPModels, JuMP, MathOptInterface, NLPModelsJuMP
using Printf

include("../ordered_include.jl")

using ..My_SPS_Model_Module


σ = 10e-5
n = 100
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( 100 * (x[Integer(2*j-1)]^2 - x[Integer(2*j)])^2 + (x[Integer(2*j-1)] - 1)^2 + 90 * (x[Integer(2*j+1)]^2 - x[Integer(2*j+2)])^2 + (x[Integer(2*j+1)] -1)^2 + 10 * (x[Integer(2*j)] + x[Integer(2*j+2)] - 2)^2 + (x[Integer(2*j)] - x[Integer(2*j+2)])^2 * 0.1  for j in 1:((n-2)/2) )) #rosenbrock function
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

println("fin de la définition du modèle JuMP")

point_initial = Vector{Float64}(undef, n)

for i in 1:n
    if i <= 4 && mod(i,2) == 1
        point_initial[i] = -3
    elseif i <= 4 && mod(i,2) == 0
        point_initial[i] = -1
    elseif i > 4 && mod(i,2) == 1
        point_initial[i] = -2
    elseif i > 4 && mod(i,2) == 0
        point_initial[i] = 0
    else
        error("bizarre")
    end
end

println("fin de la définition du point iniitial")

println("résolution PSR1")
s = My_SPS_Model_Module.solver_TR_PSR1!(obj, n, point_initial)

println("résolution LSR1 JuMP")
nlp = MathOptNLPModel(m)

# B = LSR1Operator(n, scaling=true) :: LSR1Operator{Float64} #scaling=true
# (x_f,cpt)  = solver_L_SR1_Ab_NLP(nlp, B, point_initial)


@show MathOptInterface.eval_objective(evaluator, point_initial)
# @show MathOptInterface.eval_objective(evaluator, x_f)
@show MathOptInterface.eval_objective(evaluator, s.tpl_x[Int(s.index)])
@show MathOptInterface.eval_objective_gradient(evaluator, s.tpl_x[Int(s.index)])
