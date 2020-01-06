include("../../src/ordered_include.jl")

using Test, Revise
using InteractiveUtils
using MathOptInterface, JuMP
using BenchmarkTools

using .trait_expr_tree
using .abstract_expr_tree
using .algo_expr_tree
using .algo_tree
using .PartiallySeparableStructure


#My first model
    m = Model()
    n_x = 10
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( x[j+1]^2 * x[j]^2 for j in 1:n_x-1 ) + x[1]*5 + sin(x[2]) + (x[3]^2 * 5)*x[4] )
    # @NLobjective(m, Min, sum( (x[j] * x[j+1]  @time  for j in 1:n_x-1  ) ) + sin(x[1]))
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])

    obj_o = MathOptInterface.objective_expr(eval_test)
    obj = copy(obj_o)
    x = ones(n_x)

    # t_obj = algo_expr_tree.transform_expr_tree(obj)
    # algo_tree.printer_tree(t_obj)

    # algo_tree.printer_tree(obj)
    # séparation en fonction partiellement séparable
    elmt_fun = algo_expr_tree.delete_imbricated_plus(obj)
    elmt_fun2 = algo_expr_tree.delete_imbricated_plus(obj_o)
    # on détermine le type
    type = algo_expr_tree.get_type_tree(obj_o)
    type_i = algo_expr_tree.get_type_tree.(elmt_fun)

    # on récupère les variables élémentaires
    elmt_var = algo_expr_tree.get_elemental_variable.(elmt_fun)
    var = algo_expr_tree.get_elemental_variable(obj_o)


    # évaluation de la fonction
    obj_en_x = M_evaluation_expr_tree.evaluate_expr_tree(obj_o, x)
    # évaluation des fonction éléments
    algo_expr_tree.element_fun_from_N_to_Ni!.(elmt_fun, elmt_var)
    res_elmt_fun = Vector{Number}(undef, length(elmt_fun))
    for i in 1:length(elmt_fun)
        res_elmt_fun[i] = M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun[i], Array(view(x,elmt_var[i])))
    end
    obj_elmt_en_x = sum(res_elmt_fun)
    @test obj_elmt_en_x == obj_en_x

# Comparaison
#     m2 = Model()
#     n_x2 = 100
#     @variable(m2, x[1:n_x2])
#     @NLobjective(m2, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n_x2-1 ) + x[1]*5 )
#     # @NLobjective(m, Min, sum( (x[j] * x[j+1]  @time  for j in 1:n_x-1  ) ) + sin(x[1]))
#     eval_test2 = JuMP.NLPEvaluator(m2)
#     MathOptInterface.initialize(eval_test2, [:ExprGraph])
#     obj_perf = MathOptInterface.objective_expr(eval_test2)
#
#     x2 = ones(Float64,n_x2)
#     S_perf = PartiallySeparableStructure.deduct_partially_separable_structure(obj_perf, n_x2)
#
#     g_perf = PartiallySeparableStructure.evaluate_gradient(S_perf, x2 )
#     gradient = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj_perf, x2)
#     @test g_perf == gradient
#
#     H_test_perf = PartiallySeparableStructure.evaluate_hessian(S_perf, x2 )
#     Hessian = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj_perf, x2)
#     @test Array(H_test_perf) == Hessian
#
#     B = PartiallySeparableStructure.struct_hessian(S_perf, x2)
#     id1 = zeros(n_x2)
#     id1[1] = 1
#     @test PartiallySeparableStructure.product_matrix_sps(S_perf, B, id1) == Hessian[1,:] ==  Hessian[:,1]
#
#         # @benchmark PartiallySeparableStructure.deduct_partially_separable_structure(obj_perf, n_x2)
#         # @code_warntype PartiallySeparableStructure.deduct_partially_separable_structure(obj_perf, n_x2)
#
#         # @benchmark PartiallySeparableStructure.evaluate_gradient(S_perf, x2 )
#         # @benchmark M_evaluation_expr_tree.calcul_gradient_expr_tree(obj_perf, x2)
#         # @code_warntype PartiallySeparableStructure.evaluate_gradient(S_perf, x2 )
#
#         # @benchmark PartiallySeparableStructure.evaluate_hessian(S_test_perf, x2 )
#         # @code_warntype PartiallySeparableStructure.evaluate_hessian(S_test_perf, x2 )
#
#         # @benchmark PartiallySeparableStructure.struct_hessian(S_perf, x2 )
#         # @code_warntype PartiallySeparableStructure.struct_hessian(S_perf, x2 )
#
#
#
#
#
# # test performance
#     m3 = Model()
#     n_x3 = 10000
#     @variable(m3, x[1:n_x3])
#     @NLobjective(m3, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n_x3-1 ) + x[1]*5 )
#     # @NLobjective(m, Min, sum( (x[j] * x[j+1]  @time  for j in 1:n_x-1  ) ) + sin(x[1]))
#     eval_test3 = JuMP.NLPEvaluator(m3)
#     MathOptInterface.initialize(eval_test3, [:ExprGraph])
#     obj_high_perf = MathOptInterface.objective_expr(eval_test3)
#     x3 = ones(Float64,n_x3)
#
#     @time S_high_perf = PartiallySeparableStructure.deduct_partially_separable_structure(obj_high_perf, n_x3)
#     # @benchmark PartiallySeparableStructure.deduct_partially_separable_structure(obj_high_perf, n_x3)
#
#     @time g_high_perf = PartiallySeparableStructure.evaluate_gradient(S_high_perf, x3 )
#     # @benchmark PartiallySeparableStructure.evaluate_gradient(S_high_perf, x3 )
#
#     @time H_high_perf = PartiallySeparableStructure.evaluate_hessian(S_high_perf, x3 )
#     # @benchmark PartiallySeparableStructure.evaluate_hessian(S_high_perf, x3 )
#
#     @time B_high_perf = PartiallySeparableStructure.struct_hessian(S_high_perf, x3)
#     # @benchmark PartiallySeparableStructure.struct_hessian(S_high_perf, x3)
#
#     id2 = zeros(n_x3)
#     id2[1] = 1
#     @time r1 = H_high_perf*id2
#     @time r2 = PartiallySeparableStructure.product_matrix_sps(S_high_perf, B_high_perf, id2)
#     @test r1 == r2
#     @time H_high_perf*x3
#     # # j'ai du mal à battre le produit matrice vecteur de julia, surtout quand le vecteur est très creux
