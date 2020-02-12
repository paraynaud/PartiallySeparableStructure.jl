using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure

println("\n\nCompare_With_MOI_JUMP\n\n")



#Définition d'un modèle JuMP
σ = 10e-5
n = 10000

m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
@NLobjective(m, Min, sum( (x[j] + x[j+1])^3 for j in 1:n-1 ))
# @NLobjective(m, Min, sum( (x[j+1] + sin(x[j])^2)^2 for j in 1:n-1 ))
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

#définition d'un premier vecteur d'une valeur aléatoire entre -50 et 50
# t :: DataType = Float64
# x = (α -> α - 50).( (β -> 100 * β).(rand(BigFloat, n)) )
x = (α -> α - 50).( (β -> 100 * β).( rand(n) ) )
# x_MOI = (α -> α - 50).( (β -> 100 * β).(rand(Float64, n)) )
# x = ones(n)
y = (β -> 100 * β).(rand(n))

# détection de la structure partiellement séparable
SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)

obj2 = trait_expr_tree.transform_to_expr_tree(obj)
obj3 = trait_expr_tree.transform_to_expr_tree(obj)
SPS2 = PartiallySeparableStructure.deduct_partially_separable_structure(obj3, n)

ones_ = ones(n)
# error("arret")
println("fin des initialisations")

""" EVALUATION DES FONCTIONS """
x_test = [ x[1], x[2], x[1], x[2], x[1], x[2], x[1], x[2], x[1], x[2]]
@testset "evaluation des fonctions par divers moyens" begin
    # SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, ones_)
    # MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, ones_)
    SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
    SPS2_en_x = PartiallySeparableStructure.evaluate_SPS( SPS2, x)
    MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x)

    # SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x_test)
    # MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x_test)

    Expr_obj_en_x = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    M_evaluation_expr_tree.evaluate_expr_tree(obj2,x)
    M_evaluation_expr_tree.evaluate_expr_tree(obj3,x)
    M_evaluation_expr_tree.evaluate_expr_tree(obj,x)

    @test abs(MOI_obj_en_x - Expr_obj_en_x) < σ
    @test abs(SPS_en_x - MOI_obj_en_x) < σ
    @test abs(SPS2_en_x - MOI_obj_en_x) < σ


    SPS_en_y = PartiallySeparableStructure.evaluate_SPS(SPS, y)
    MOI_obj_en_y = MathOptInterface.eval_objective(evaluator, y)
    Expr_obj_en_y = M_evaluation_expr_tree.evaluate_expr_tree(obj, y)

    @test abs(SPS_en_y - MOI_obj_en_y) < σ
    @test abs(MOI_obj_en_y - Expr_obj_en_y) < σ

    # bench_obj = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
    # bench_obj2 = @benchmark M_evaluation_expr_tree.evaluate_expr_tree(obj2, x)
    # bench_SPS = @benchmark PartiallySeparableStructure.evaluate_SPS( SPS, x)
    # bench_SPS2 = @benchmark PartiallySeparableStructure.evaluate_SPS( SPS2, x)
    # bench_MOI = @benchmark MathOptInterface.eval_objective( evaluator, x)
end


""" EVALUATION DES GRADIENTS """

@testset " evaluation du gradient par divers moyer" begin
    MOI_gradient_en_x = Vector{ typeof(x[1]) }(undef,n)

    f2 = (y :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(undef, length(y.used_variable) )) )
    f = (y :: PartiallySeparableStructure.element_function{Expr} -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(undef, length(y.used_variable) )) )
    dif_grad = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f.(SPS.structure) )
    dif_grad2 = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f2.(SPS2.structure) )


    SPS_gradient_en_x = PartiallySeparableStructure.evaluate_gradient(SPS, x)
    SPS2_gradient_en_x = PartiallySeparableStructure.evaluate_gradient(SPS2, x)
    MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_x, x)
    PartiallySeparableStructure.evaluate_SPS_gradient!(SPS, x, dif_grad)
    PartiallySeparableStructure.evaluate_SPS_gradient!(SPS2, x, dif_grad2)

    g_test = PartiallySeparableStructure.build_gradient(SPS, dif_grad)
    g_test2 = PartiallySeparableStructure.build_gradient(SPS2, dif_grad2)

    Expr_gradient_en_x = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, x)
    @test norm(SPS_gradient_en_x - Expr_gradient_en_x,2) < σ
    @test norm(SPS_gradient_en_x - MOI_gradient_en_x, 2) < σ
    @test norm(SPS_gradient_en_x - SPS2_gradient_en_x, 2) < σ
    @test norm(SPS2_gradient_en_x - MOI_gradient_en_x, 2) < σ
    @test norm(g_test - MOI_gradient_en_x, 2) < σ
    @test norm(g_test2 - MOI_gradient_en_x, 2) < σ


    MOI_gradient_en_y = Vector{ typeof(y[1]) }(undef,n)

    SPS_gradient_en_y = PartiallySeparableStructure.evaluate_gradient(SPS, y)
    MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_y, y)
    Expr_gradient_en_y = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, y)
    @test norm(SPS_gradient_en_y - Expr_gradient_en_y, 2) < σ
    @test norm(SPS_gradient_en_y - MOI_gradient_en_y, 2)  < σ

    # g1 = @benchmark Expr_gradient_en_x = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, x)

    # bench_grad_SPS = @benchmark PartiallySeparableStructure.evaluate_gradient(SPS, x)
    # bench_grad_SPS2 = @benchmark PartiallySeparableStructure.evaluate_gradient(SPS2, x)
    # bench_grad_MOI = @benchmark MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_x, x)
    # bench_grad_SPS_struct = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!(SPS, x, dif_grad)
    # bench_grad_SPS2_struct = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!(SPS2, x, dif_grad2)

end


""" EVALUATION DES HESSIANS """

@testset "evaluation du Hessian par divers moyers" begin


    MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
    column = [x[1] for x in MOI_pattern]
    row = [x[2]  for x in MOI_pattern]

    f = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
    t = f.(SPS2.structure) :: Vector{PartiallySeparableStructure.element_hessian{Float64}}
    H = PartiallySeparableStructure.Hess_matrix{Float64}(t)
    H2 = PartiallySeparableStructure.Hess_matrix{Float64}(t)
    H3 = PartiallySeparableStructure.Hess_matrix{Float64}(t)
#
    MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
    MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
    values = [x for x in MOI_value_Hessian]

    MOI_half_hessian_en_x = sparse(row,column,values,n,n)
    MOI_hessian_en_x = Symmetric(MOI_half_hessian_en_x)

    SPS_Hessian_en_x = PartiallySeparableStructure.evaluate_hessian(SPS, x )
    PartiallySeparableStructure.struct_hessian!(SPS, x, H)
    sp_H = PartiallySeparableStructure.construct_Sparse_Hessian(SPS, H)
    PartiallySeparableStructure.struct_hessian!(SPS2, x, H2)
    sp_H2 = PartiallySeparableStructure.construct_Sparse_Hessian(SPS2, H2)

    SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
    sp_H_test = PartiallySeparableStructure.construct_Sparse_Hessian(SPS, SPS_Structured_Hessian_en_x)

    @test norm(MOI_hessian_en_x - SPS_Hessian_en_x, 2) < σ
    @test norm(MOI_hessian_en_x - sp_H, 2) < σ
    @test norm(MOI_hessian_en_x - sp_H2, 2) < σ
    @test norm(MOI_hessian_en_x - sp_H_test, 2) < σ
    @test sp_H_test == sp_H




    # # on récupère le Hessian structuré du format SPS.
    # #Ensuite on calcul le produit entre le structure de donnée SPS_Structured_Hessian_en_x et y

    SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)


    v_tmp = Vector{ Float64 }(undef, length(MOI_pattern))
    MOI_Hessian_product_y = Vector{ typeof(y[1]) }(undef,n)
    MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0))
    #
    @test norm(MOI_Hessian_product_y - SPS_product_Hessian_en_x_et_y, 2) < σ
    @test norm(MOI_Hessian_product_y - MOI_hessian_en_x*y, 2) < σ



    # @show "0"
    # bench_product_matric_sps = @benchmark PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)
    # @show "1"
    # bench_dot_hess_matrix = @benchmark PartiallySeparableStructure.hess_matrix_dot_vector(SPS2, H2, y)
    # @show "2"
    # bench_MOI_hess_vector = @benchmark MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0))
    # @show "-3"
    # bench_SPS_HESS_Expr2 = @benchmark PartiallySeparableStructure.struct_hessian(SPS, x)
    # @show "-2"
    # bench_SPS_HESS_expr_tree2 = @benchmark PartiallySeparableStructure.struct_hessian(SPS2, x)
    # @show "0"







    # h4 = @benchmark Expr_Hessian_en_x = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj, x)

    # @show "0"
    # bench_SPS_HESS_Expr = @benchmark SPS_Hessian_en_x = PartiallySeparableStructure.evaluate_hessian(SPS, x )
    # @show "1"
    # bench_SPS_HESS_struct_Expr = @benchmark SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
    # @show "1.5"
    # bench_SPS2_HESS_struct_expr_tree = @benchmark SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS2, x)
    # @show "2"
    # bench_SPS2_HESS_expr_tree! = @benchmark PartiallySeparableStructure.struct_hessian!(SPS2, x, H)
    # @show "3"
    # bench_SPS_HESS_Expr! = @benchmark PartiallySeparableStructure.struct_hessian!(SPS, x, H)
    # @show "4"
    # bench_MOI_Hessian = @benchmark MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
    # @show "5"

    # @benchmark MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
    # @benchmark MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0))
    # @benchmark SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)
    # prod1 = @benchmark SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)
    # prod2 = @benchmark (MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0)))
end












@testset "vérification des types des évalations de la fonction/gradient/Hessian" begin
    var_type_BigFloat = (α -> α - 50).( (β -> 100 * β).(rand(BigFloat,n)) )

    # SPS_test_type = PartiallySeparableStructure.evaluate_SPS(SPS, var_type_BigFloat)
    # @test typeof(var_type_BigFloat[1]) == typeof(SPS_test_type)
    # SPS_gradient_test_type_en_x = PartiallySeparableStructure.evaluate_gradient(SPS, var_type_BigFloat)
    # @test typeof(SPS_gradient_test_type_en_x[1]) == typeof(var_type_BigFloat[1])
end
