using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools

# include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure

#Définition d'un modèle JuMP
σ = 10e-5
n = 10000

m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
@NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7]) )
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
obj = MathOptInterface.objective_expr(evaluator)

#définition d'un premier vecteur d'une valeur aléatoire entre -50 et 50
# t :: DataType = Float64
x = (α -> α - 50).( (β -> 100 * β).(rand(n)) )
y = (β -> 100 * β).(rand(n))

# détection de la structure partiellement séparable
SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)

""" EVALUATION DES FONCTIONS """

@testset "evaluation des fonctions par divers moyens" begin

    SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
    MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x)
    Expr_obj_en_x = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)

    @test MOI_obj_en_x - Expr_obj_en_x < σ
    @test SPS_en_x - MOI_obj_en_x < σ


    SPS_en_y = PartiallySeparableStructure.evaluate_SPS(SPS, y)
    MOI_obj_en_y = MathOptInterface.eval_objective(evaluator, y)
    Expr_obj_en_y = M_evaluation_expr_tree.evaluate_expr_tree(obj, y)

    @test SPS_en_y - MOI_obj_en_y < σ
    @test MOI_obj_en_y - Expr_obj_en_y < σ

end


""" EVALUATION DES GRADIENTS """

@testset " evaluation du gradient par divers moyer" begin
    MOI_gradient_en_x = Vector{ typeof(x[1]) }(undef,n)

    SPS_gradient_en_x = PartiallySeparableStructure.evaluate_gradient(SPS, x)
    MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_x, x)

    Expr_gradient_en_x = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, x)
    @test norm(SPS_gradient_en_x - Expr_gradient_en_x,2) < σ
    @test norm(SPS_gradient_en_x - MOI_gradient_en_x, 2) < σ

    MOI_gradient_en_y = Vector{ typeof(y[1]) }(undef,n)

    SPS_gradient_en_y = PartiallySeparableStructure.evaluate_gradient(SPS, y)
    MathOptInterface.eval_objective_gradient(evaluator, MOI_gradient_en_y, y)
    Expr_gradient_en_y = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, y)
    @test norm(SPS_gradient_en_y - Expr_gradient_en_y, 2) < σ
    @test norm(SPS_gradient_en_y - MOI_gradient_en_y, 2)  < σ
end


""" EVALUATION DES HESSIANS """

@testset "evaluation du Hessian par divers moyers" begin


    MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
    column = [x[1] for x in MOI_pattern]
    row = [x[2]  for x in MOI_pattern]

    MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
    MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
    values = [x for x in MOI_value_Hessian]

    MOI_half_hessian_en_x = sparse(row,column,values)
    MOI_hessian_en_x = Symmetric(MOI_half_hessian_en_x)

    # SPS_Hessian_en_x = PartiallySeparableStructure.evaluate_hessian(SPS, x )
    # Expr_Hessian_en_x = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj, x)
    #
    # @test norm(MOI_hessian_en_x - Expr_Hessian_en_x, 2) < σ
    # @test norm(sparse(MOI_hessian_en_x) - SPS_Hessian_en_x, 2) < σ

    # on récupère le Hessian structuré du format SPS.
    SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
    #Ensuite on calcul le produit entre le structure de donnée SPS_Structured_Hessian_en_x et y
    SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)


    v_tmp = Vector{ Float64 }(undef, length(MOI_pattern))
    MOI_Hessian_product_y = Vector{ typeof(y[1]) }(undef,n)
    MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0))




    @test norm(MOI_Hessian_product_y - SPS_product_Hessian_en_x_et_y, 2) < σ
    @test norm(MOI_hessian_en_x*y - SPS_product_Hessian_en_x_et_y, 2) < σ
    @test norm(MOI_Hessian_product_y - MOI_hessian_en_x*y, 2) < σ



# @benchmark SPS_Structured_Hessian_en_x = PartiallySeparableStructure.struct_hessian(SPS, x)
#
# @benchmark MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
# @benchmark MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
#
# @benchmark SPS_product_Hessian_en_x_et_y = PartiallySeparableStructure.product_matrix_sps(SPS, SPS_Structured_Hessian_en_x, y)
# @benchmark MathOptInterface.eval_hessian_lagrangian_product(evaluator, MOI_Hessian_product_y, x, y, 1.0, zeros(0))

end










#
#
# @testset "vérification des types des évalations de la fonction/gradient/Hessian" begin
#     var_type_BigFloat = (α -> α - 50).( (β -> 100 * β).(rand(BigFloat,n)) )
#
#     # SPS_test_type = PartiallySeparableStructure.evaluate_SPS(SPS, var_type_BigFloat)
#     # @test typeof(var_type_BigFloat[1]) == typeof(SPS_test_type)
#     # SPS_gradient_test_type_en_x = PartiallySeparableStructure.evaluate_gradient(SPS, var_type_BigFloat)
#     # @test typeof(SPS_gradient_test_type_en_x[1]) == typeof(var_type_BigFloat[1])
# end
