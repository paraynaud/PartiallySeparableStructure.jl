# using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
# using Test, BenchmarkTools, ProfileView, InteractiveUtils

using NLPModels, JuMP, MathOptInterface
using Printf

include("../ordered_include.jl")

using ..Test_NLP_model

# include("impl_LSR1_JUMP.jl")
include("impl_Tr_Cg_Ab.jl")

σ = 10e-5
n = 10000
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( 100 * (x[Integer(2*j-1)]^2 - x[Integer(2*j)])^2 + (x[Integer(2*j-1)] - 1)^2 + 90 * (x[Integer(2*j+1)]^2 - x[Integer(2*j+2)])^2 + (x[Integer(2*j+1)] -1)^2 + 10 * (x[Integer(2*j)] + x[Integer(2*j+2)] - 2)^2 + (x[Integer(2*j)] - x[Integer(2*j+2)]^2 * 0.1)  for j in 1:((n-2)/2) )) #rosenbrock function
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

# x = ones(n)
# x = (x -> 1000 *x - 5000).(rand(n))
# point_initial = (x -> 100*x).(ones(n))

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


# g = NLPModels.grad(nlp, x)
# @show g
nlp2 = Test_NLP_model.SPS_Model(obj,n)

B = LSR1Operator(n, scaling=true) :: LSR1Operator{Float64} #scaling=true
(x_f,cpt)  = solver_L_SR1_JuMP(nlp2, B, point_initial)
@show NLPModels.obj(nlp,x_f)
