using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, InteractiveUtils

include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure

function create_chained_Powel_JuMP_Model(n :: Int)
    m = Model()
    @variable(m, x[1:n])
    @NLobjective(m, Min, sum( (x[Int(2*j-1)] + x[Int(2*j)])^2 + 5*(x[Int(2*j+1)] + x[Int(2*j+2)])^2 + (x[Int(2*j)] - 2 * x[Int(2*j+1)])^4 + 10*(x[Int(2*j-1)] + x[Int(2*j+2)])^4   for j in 1:((n-2)/2) )) #chained powel
    evaluator = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
    obj = MathOptInterface.objective_expr(evaluator)
    return (m, evaluator,obj)
end

function create_chained_cragg_levy_JuMP_Model(n :: Int)
    m = Model()
    @variable(m, x[1:n])
    @NLobjective(m, Min, sum( exp(x[Integer(2*j-1)])^4 + 100*(x[Integer(2*j)] - x[Integer(2*j+1)])^6 + (tan(x[Integer(2*j)]+1 - x[Integer(2*j+2)]))^4 + x[Integer(2*j-1)]^8 + (x[Integer(2*j+2)]-1)^2 for j in 1:((n-2)/2) ) ) #chained powel
    evaluator = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
    obj = MathOptInterface.objective_expr(evaluator)
    return (m, evaluator,obj)
end

function create_initial_point_chained_cragg_levy(n)
    point_initial = Vector{Float64}(undef, n)
    point_initial[1] = 1.0
    for i in 2:n
        point_initial[i] = 2.0
    end
    return point_initial
end

n_test = [100, 500, 1000, 2000, 5000]
# n_test = [50000]
# n_test = [ 20000]
res_obj = Vector{Any}(undef, length(n_test))
res_JuMP = Vector{Any}(undef, length(n_test))
res_grad_obj = Vector{Any}(undef, length(n_test))
res_grad_JuMP = Vector{Any}(undef, length(n_test))
# res_Hess_obj = Vector{Any}(undef, length(n_test))
# res_Hess_JuMP = Vector{Any}(undef, length(n_test))
res_product_obj = Vector{Any}(undef, length(n_test))
res_product_JuMP = Vector{Any}(undef, length(n_test))

for i in 1:length(n_test)

    n = n_test[i]
    σ = 1e-8*n
    # n= 20000
    # (m, evaluator, obj_expr) = create_chained_Powel_JuMP_Model(n)
    (m, evaluator, obj_expr) = create_chained_cragg_levy_JuMP_Model(n)
    obj = trait_expr_tree.transform_to_expr_tree(obj_expr)
    SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)

    x = create_initial_point_chained_cragg_levy(n)
    (y -> y + rand(1:10)).(x)
    SPS_tree_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
    JuMP_x = MathOptInterface.eval_objective( evaluator, x)

    @test abs(JuMP_x - SPS_tree_x) < σ

    @show abs(JuMP_x - SPS_tree_x)
    # b1 = @benchmark PartiallySeparableStructure.evaluate_SPS($SPS, $x)
    # b2 = @benchmark MathOptInterface.eval_objective($evaluator, $x)
    res_obj[i] = @benchmark PartiallySeparableStructure.evaluate_SPS($SPS, $x)
    res_JuMP[i] = @benchmark MathOptInterface.eval_objective($evaluator, $x)

    f = (y :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(zeros(typeof(x[1]), length(y.used_variable)) )) )
    grad_elt = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f.(SPS.structure) )
    grad = Vector{Float64}(zeros(Float64,n))
    PartiallySeparableStructure.evaluate_SPS_gradient!(SPS, x, grad_elt)
    grad = PartiallySeparableStructure.build_gradient(SPS, grad_elt)

    JuMP_gradient = Vector{ typeof(x[1]) }(undef,n)
    MathOptInterface.eval_objective_gradient(evaluator, JuMP_gradient, x)

    @test norm(JuMP_gradient - grad,2) < σ


 # b3 = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!($SPS, $x, $grad_elt)
 # b4 = @benchmark MathOptInterface.eval_objective_gradient($evaluator, $JuMP_gradient, $x)

    res_grad_obj[i] = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!($SPS, $x, $grad_elt)
    res_grad_JuMP[i] = @benchmark MathOptInterface.eval_objective_gradient($evaluator, $JuMP_gradient, $x)

    MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
    column = [x[1] for x in MOI_pattern]
    row = [x[2]  for x in MOI_pattern]
    MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
    MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
    values = [x for x in MOI_value_Hessian]
    MOI_half_hessian_en_x = sparse(row,column,values,n,n)
    MOI_hessian_en_x = Symmetric(MOI_half_hessian_en_x)


    f = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
    t = f.(SPS.structure) :: Vector{PartiallySeparableStructure.element_hessian{Float64}}
    H = PartiallySeparableStructure.Hess_matrix{Float64}(t)
    PartiallySeparableStructure.struct_hessian!(SPS, x, H)

    # res_Hess_obj[i] = @benchmark PartiallySeparableStructure.struct_hessian!($SPS, $x, $H)
    # res_Hess_JuMP[i] = @benchmark MathOptInterface.eval_hessian_lagrangian($evaluator, $MOI_value_Hessian, $x, 1.0, zeros(0))


    # SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
    res = Vector{typeof(x[1])}(undef,n)
    # b5 = @benchmark PartiallySeparableStructure.product_matrix_sps!($SPS, $H, $x, $res)
    # b6 = @benchmark $MOI_hessian_en_x * $x
    res_product_obj[i] = @benchmark PartiallySeparableStructure.product_matrix_sps!($SPS, $H, $x, $res)
    res_product_JuMP[i] = @benchmark $MOI_hessian_en_x * $x

end

@show res_obj
@show res_JuMP
@show res_grad_obj
@show res_grad_JuMP
# @show res_Hess_obj
# @show res_Hess_JuMP
@show res_product_obj
@show res_product_JuMP
# i=100
# σ = 1e-8*i
# (m, evaluator, obj_expr) = create_chained_Powel_JuMP_Model(i)
# obj = trait_expr_tree.transform_to_expr_tree(obj_expr)
# SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, i)
#
# x = rand(i)
# SPS_tree_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
# JuMP_x = MathOptInterface.eval_objective( evaluator, x)
#
# @test abs(JuMP_x - SPS_tree_x) < σ
#
# @show abs(JuMP_x - SPS_tree_x)
#
# res_obj[1] = @benchmark PartiallySeparableStructure.evaluate_SPS(SPS, x)
# @show res_obj[1]
# res_JuMP[1] = @benchmark MathOptInterface.eval_objective(evaluator, x)
# @show res_JuMP[1]
#
# b = @benchmarkable PartiallySeparableStructure.evaluate_SPS(SPS, x)
# tune!(b)
# run(b)
