using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils

include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..Solver_SPS
using ..implementation_expr_tree
using ..M_evaluation_expr_tree

# using ..implementation_L_SR1


σ = 10e-5
n = 100
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( 100 * ( x[Integer(2*j-1)]^2 - x[Integer(2*j)] )^2 + ( x[Integer(2*j-1)] - 1 )^2 + 90 * ( x[Integer(2*j+1)]^2 - x[Integer(2*j+2)] )^2 + (x[Integer(2*j+1)] - 1)^2 + 10 * (x[Integer(2*j)] + x[Integer(2*j+2)] - 2)^2 + (x[Integer(2*j)] - x[Integer(2*j+2)])^2 * 0.1  for j in 1:((n-2)/2) )) #rosenbrock function


evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)


# @code_warntype Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

# point_initial = x_k1 = (x -> 100*x - 50).(rand(n))
# point_initial = (x -> 100*x).(ones(n))
println("fin JuMP")

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

struct_algo = Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)

# Juno.@enter Solver_SPS.solver_TR_SR1!(obj, n, point_initial, Float64)





# point_initial = ones(Float64, n)
#  y = ones(Float64, n)
#
# println("fin points ")
#
# s_a = Solver_SPS.alloc_struct_algo(obj,n)
# println("fin alloc")
# Solver_SPS.init_struct_algo!(s_a, point_initial)
#
# println("fin SolverSPS")
#
# res1 = PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B_k, y)
# # res2 = PartiallySeparableStructure.hess_matrix_dot_vector(s_a.sps, s_a.B_k, y)
# res2 = Vector{Float64}(undef,n)
# PartiallySeparableStructure.product_matrix_sps!(s_a.sps, s_a.B_k, y, res2)
# @show norm(res1 - res2,2)
#
# println("les benchmarks")
#
# b1 = @benchmark PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B_k, y)
# b2 = @benchmark PartiallySeparableStructure.product_matrix_sps!(s_a.sps, s_a.B_k, y, res2)
# b2 = @benchmark PartiallySeparableStructure.hess_matrix_dot_vector(s_a.sps, s_a.B_k, y) #nul
# b3 = @benchmark PartiallySeparableStructure.inefficient_product_matrix_sps(s_a.sps, s_a.B_k, y)
