using Test, Revise
using InteractiveUtils
using MathOptInterface, JuMP
using BenchmarkTools

# include("../../src/ordered_include.jl")


using .trait_expr_tree
using .abstract_expr_tree
using .algo_expr_tree
using .algo_tree


println("\n\n test_expr_tree\n\n") 

@testset "test building of trees and equality" begin
    expr_1 = :(x[1] + x[2] )
    t_expr_1 = abstract_expr_tree.create_expr_tree(expr_1)
    @test t_expr_1 == expr_1
    @test trait_expr_tree.expr_tree_equal(t_expr_1, expr_1)

    t1 = trait_expr_tree.transform_to_expr_tree(t_expr_1)
    @test trait_expr_tree.expr_tree_equal(t1, t_expr_1)

    expr_2 = :( (x[3]+x[4])^2 +  x[1] * x[2] )
    @test trait_expr_tree.expr_tree_equal(expr_1, expr_2) == false
    t_expr_2 = abstract_expr_tree.create_expr_tree(expr_2)
    @test t_expr_2 == expr_2
    t2 = trait_expr_tree.transform_to_expr_tree(t_expr_2)
    @test  trait_expr_tree.expr_tree_equal(expr_2, t2)
    @test  trait_expr_tree.expr_tree_equal(t_expr_2, t2)

    n3_1_1 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,1))
    n3_1_2 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,2))
    n3_1_op = abstract_expr_node.create_node_expr(:*)
    n3_1 = abstract_expr_tree.create_expr_tree( n3_1_op, [n3_1_1, n3_1_2])

    n3_2_1_1 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,3))
    n3_2_1_2 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,4))
    n3_2_1_op = abstract_expr_node.create_node_expr(:+)
    n3_2_1 = abstract_expr_tree.create_expr_tree(n3_2_1_op, [n3_2_1_1, n3_2_1_2])
    n3_2_op = abstract_expr_node.create_node_expr(:^,2, true)
    n3_2 = abstract_expr_tree.create_expr_tree(n3_2_op, [n3_2_1])
    n3_op = abstract_expr_node.create_node_expr(:+)
    t3 = abstract_expr_tree.create_expr_tree(n3_op,[n3_2,n3_1])
    @test  trait_expr_tree.expr_tree_equal(t_expr_2, t3)
    @test  trait_expr_tree.expr_tree_equal(t2, t3)

 end


@testset " Deletion of imbricated +" begin
    t_expr_4 = abstract_expr_tree.create_expr_tree( :( (x[3]+x[4]) + (x[1] + x[2]) ) )
    t4 = trait_expr_tree.transform_to_expr_tree(t_expr_4)
    res_t4 = algo_expr_tree.delete_imbricated_plus(t4)
    res_t_expr_4 = algo_expr_tree.delete_imbricated_plus(t_expr_4)
    test_res_t_expr_4 = [:(x[3]), :(x[4]), :(x[1]), :(x[2])]
    @test res_t_expr_4 == test_res_t_expr_4
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t4, res_t_expr_4))

    t_expr_5 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) + (x[1] + x[2]) ) )
    t5 = trait_expr_tree.transform_to_expr_tree(t_expr_5)
    res_t_expr_5 = algo_expr_tree.delete_imbricated_plus(t_expr_5)
    res_t5 = algo_expr_tree.delete_imbricated_plus(t5)
    test_res_t_expr_5 = [ :(x[3]^2), :(x[5] * x[4]), :(x[1]), :(x[2])]
    @test res_t_expr_5 == test_res_t_expr_5
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t5, res_t_expr_5))


    t_expr_6 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] + x[2]) ) )
    t6 = trait_expr_tree.transform_to_expr_tree(t_expr_6)
    res_t_expr_6 = algo_expr_tree.delete_imbricated_plus(t_expr_6)
    res_t6 = algo_expr_tree.delete_imbricated_plus(t6)
    test_res_t_expr_6 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(x[2]))]
    @test res_t_expr_6 == test_res_t_expr_6
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t6, res_t_expr_6))


    t_expr_7 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t7 = trait_expr_tree.transform_to_expr_tree(t_expr_7)
    res_t_expr_7 = algo_expr_tree.delete_imbricated_plus(t_expr_7)
    res_t7 = algo_expr_tree.delete_imbricated_plus(t7)
    test_res_t_expr_7 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(-(x[2])))]
    @test res_t_expr_7 == test_res_t_expr_7
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t7, res_t_expr_7))
end


# code warntype
# InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(t_expr_7)
# InteractiveUtils.@code_warntype abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )



@testset "get type of a expr tree" begin

    t_expr_8 = abstract_expr_tree.create_expr_tree( :( (x[3]^4)+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t8 = trait_expr_tree.transform_to_expr_tree(t_expr_8)

    test_res8 =  algo_expr_tree.get_type_tree(t_expr_8)
    test_res_t8 =  algo_expr_tree.get_type_tree(t8)
    @test test_res8 == test_res_t8
    @test trait_type_expr.is_more(test_res_t8)


    t_expr_cubic = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t_cubic = trait_expr_tree.transform_to_expr_tree(t_expr_cubic)

    res_cubic =  algo_expr_tree.get_type_tree(t_expr_cubic)
    res_t_cubic =  algo_expr_tree.get_type_tree(t_cubic)
    @test res_cubic == res_t_cubic
    @test trait_type_expr._is_cubic(res_t_cubic)

    t_expr_cubic2 = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ (x[5] * x[4]) - (x[1] - x[2]) + sin(5)) )
    t_cubic2 = trait_expr_tree.transform_to_expr_tree(t_expr_cubic2)

    res_cubic2 =  algo_expr_tree.get_type_tree(t_expr_cubic2)
    res_t_cubic2 =  algo_expr_tree.get_type_tree(t_cubic2)
    @test res_cubic2 == res_t_cubic2
    @test trait_type_expr._is_cubic(res_t_cubic2)

    t_expr_sin = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ sin(x[5] * x[4]) - (x[1] - x[2]) ) )
    t_sin = trait_expr_tree.transform_to_expr_tree(t_expr_sin)

    res_sin =  algo_expr_tree.get_type_tree(t_expr_sin)
    res_t_sin =  algo_expr_tree.get_type_tree(t_sin)
    @test res_sin == res_t_sin
    @test trait_type_expr.is_more(res_t_sin)



    m = Model()
    n_x = 100
    # n_x = 5
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) )
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])
    obj = MathOptInterface.objective_expr(eval_test)
    t_obj =  trait_expr_tree.transform_to_expr_tree(obj)

    test_res_obj = algo_expr_tree.get_type_tree(t_obj)
    @test trait_type_expr._is_quadratic(test_res_obj)
    @test trait_type_expr.is_more(test_res_obj) == false

    t_expr_9 = abstract_expr_tree.create_expr_tree( :( x[1] + sin(x[2])) )
    res_t_expr_9 = algo_expr_tree.delete_imbricated_plus(t_expr_9)

    # InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(t_expr_9)

    @test trait_type_expr.is_linear(algo_expr_tree.get_type_tree(t_expr_9)) == false
    @test trait_type_expr.is_more(algo_expr_tree.get_type_tree(t_expr_9))


end


@testset "test de la récupération des variable élementaires" begin
    t_expr_var = abstract_expr_tree.create_expr_tree( :( (x[1]^3)+ sin(x[1] * x[2]) - (x[3] - x[2]) ) )
    t_var = trait_expr_tree.transform_to_expr_tree(t_expr_var)
    res = algo_expr_tree.get_elemental_variable(t_var)
    res2 = algo_expr_tree.get_elemental_variable(t_expr_var)
    @test res == res2
    @test res == [1,2,3]
    t_expr_var1= abstract_expr_tree.create_expr_tree( :( (x[1]^3) ) )
    t_var1 = trait_expr_tree.transform_to_expr_tree(t_expr_var1)
    res_expr_var1 = algo_expr_tree.get_elemental_variable(t_expr_var1)
    res_var1 = algo_expr_tree.get_elemental_variable(t_var1)
    @test res_var1 == res_expr_var1
    @test res_var1 == [1]
end


@testset "test complet à partir d'un modèle JuMP" begin
    m = Model()
    # n_x = 50000
    n_x = 10
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( x[j] * x[j+1] for j in 1:n_x-1 ) + (sin(x[1]))^2 + x[n_x-1]^3  + 5 )
    # @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) + sin(x[1]))
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])
    obj = MathOptInterface.objective_expr(eval_test)
    t_obj =  trait_expr_tree.transform_to_expr_tree(obj)
    # DEFINITION DES OBJETS A TESTER
    elmt_fun = algo_expr_tree.delete_imbricated_plus(obj)
    type_elmt_fun = algo_expr_tree.get_type_tree.(elmt_fun)
    U = algo_expr_tree.get_elemental_variable.(elmt_fun)

    t_elmt_fun = algo_expr_tree.delete_imbricated_plus(t_obj)
    t_type_elmt_fun = algo_expr_tree.get_type_tree.(t_elmt_fun)
    t_U = algo_expr_tree.get_elemental_variable.(t_elmt_fun)

    #DEBUT DES TESTS
    x = ones(Float32, n_x)
    eval_ones = 15.708073371141893
    # TEST SUR LES FONCTIONS ELEMENTS
        # @test elmt_fun == t_elmt_fun # car type initiaux différents
        @test foldl(&,trait_expr_tree.expr_tree_equal.(elmt_fun, t_elmt_fun) )
        @test type_elmt_fun == t_type_elmt_fun

    # TEST SUR LES VARIABLES ELEMENTAIRE
        res_elemental_variable = Array{Int64,1}[[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [1], [9], []]
        @test U == t_U
        @test U == res_elemental_variable

    # TEST SUR LES EVALUATIONS
        # @time res = algo_expr_tree.evaluate_expr_tree(obj, x)
        # @time t_res = algo_expr_tree.evaluate_expr_tree(t_obj, x)
        # @time res = algo_expr_tree.evaluate_expr_tree(obj, x)
        # @time t_res = algo_expr_tree.evaluate_expr_tree(t_obj, x)
        res = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
        t_res = M_evaluation_expr_tree.evaluate_expr_tree(t_obj, x)
        @test res == t_res
        @test res == (Float32)(eval_ones)
    # TEST SUR LES EVALUATIONS DE FONCTIONS ELEMENTS
        n_element = length(elmt_fun)
        res_p = Vector{Number}(undef, n_element)

        for i in 1:n_element
            res_p[i] = M_evaluation_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
            # InteractiveUtils.@code_warntype res_p[i] = algo_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
        end
        # @time (Threads.@threads for i in 1:n_element
        #     res_p[i] = algo_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
        #     # InteractiveUtils.@code_warntype res_p[i] = algo_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
        # end)
        res_total = sum(res_p)
        @test (typeof(res))(res_total) == res
end












function expr_tree_factorielle_dif_node( n :: Integer)
    if n == 0
        constant_node = abstract_expr_node.create_node_expr(:x,1)
        new_leaf = abstract_expr_tree.create_expr_tree(constant_node)
        return new_leaf
    else
        if n % 3 == 0
            op_node = abstract_expr_node.create_node_expr(:+)
            new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_dif_node.((n-1) * ones(Integer,n)) )
            return new_node
        elseif n % 3 == 1
            op_node = abstract_expr_node.create_node_expr(:-)
            new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_dif_node.((n-1) * ones(Integer,n)) )
            return new_node
        elseif n % 3 == 2
            op_node = abstract_expr_node.create_node_expr(:*)
            new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_dif_node.((n-1) * ones(Integer,n)) )
            return new_node
        end
    end
end


function expr_tree_factorielle_plus( n :: Integer, op :: Symbol)
    if n == 0
        constant_node = abstract_expr_node.create_node_expr(1)
        new_leaf = abstract_expr_tree.create_expr_tree(constant_node)
        return new_leaf
        # return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(0))
    else
        op_node = abstract_expr_node.create_node_expr(op)
        new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_plus.( (n-1) * ones(Integer,n), op) )
        return new_node
        # return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(op), expr_tree_factorielle_plus.( (n-1) * ones(Integer,n), op) )
    end
end


@testset "test arbres factorielle désimbriqué les + et get_type " begin
    n = 5
    @time test_fac_expr_tree_plus = expr_tree_factorielle_plus(n, :+) :: implementation_expr_tree.t_expr_tree
    # test_fac_expr_tree = expr_tree_factorielle_dif_node(3) :: implementation_expr_tree.t_expr_tree
    # algo_tree.printer_tree(test_fac_expr_tree)
    # algo_tree.printer_tree(test_fac_expr_tree_plus)
    # @time algo_expr_tree.get_type_tree.(test_fac_expr_tree_plus_no_plus) # ca ne semble pas être une bonne idée ou alors encore parralélisé
    # algo_tree.printer_tree.(test_fac_expr_tree_plus_no_plus)
    # InteractiveUtils.@code_warntype algo_expr_tree.get_type_tree(test_fac_expr_tree_plus)
     test_fac_expr_tree_plus_no_plus = algo_expr_tree.delete_imbricated_plus(test_fac_expr_tree_plus)
     algo_expr_tree.get_type_tree(test_fac_expr_tree_plus)
     res3 = algo_expr_tree.get_elemental_variable(test_fac_expr_tree_plus)
     res = M_evaluation_expr_tree.evaluate_expr_tree(test_fac_expr_tree_plus,ones(5))
    @test res == factorial(n)

    # InteractiveUtils.@code_warntype algo_expr_tree.get_type_tree(test_fac_expr_tree_plus)
    # InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(test_fac_expr_tree_plus)
end

println("test du module PartiallySeparableStructure")
using ..PartiallySeparableStructure
using LinearAlgebra


# @testset "test gradient/hessian/product SPS" begin

    m = Model()
    n_x = 100
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n_x-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
    # @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) + sin(x[1]))
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])
    obj_o = MathOptInterface.objective_expr(eval_test)
    obj = copy(obj_o)
    x = (x -> 3*x).(ones(n_x))
    # @time g = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj,x)
    # @time H = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj, x)
    # println("\n\nmaintenant les fonction elements\n\n")
    # elmt_fun = algo_expr_tree.delete_imbricated_plus(obj)
    # U_i = algo_expr_tree.get_elemental_variable.(elmt_fun)
    # algo_expr_tree.element_fun_from_N_to_Ni!.(elmt_fun, U_i)
    # elmt_g = Vector{Vector{}}(undef,length(elmt_fun))
    # @Threads.threads for i in 1:length(elmt_fun)
    #     elmt_g[i] = M_evaluation_expr_tree.calcul_gradient_expr_tree(elmt_fun[i], Array(view(x,U_i[i])) )
    # end
    # elmt_H = Vector{Array{}}(undef,length(elmt_fun))
    # @Threads.threads for i in 1:length(elmt_fun)
    #     elmt_H[i] = M_evaluation_expr_tree.calcul_Hessian_expr_tree(elmt_fun[i], Array(view(x,U_i[i])) )
    # end

    # @benchmark PartiallySeparableStructure.deduct_partially_separable_structure(obj_o, n_x)
    S_test = PartiallySeparableStructure.deduct_partially_separable_structure(obj_o, n_x)
    res_test =  PartiallySeparableStructure.evaluate_SPS(S_test, x)
    res_test2 = M_evaluation_expr_tree.evaluate_expr_tree(obj,x)
    @test res_test == res_test2

    g_test = PartiallySeparableStructure.evaluate_gradient(S_test, x )
    g_test2 = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj,x)
    # @benchmark PartiallySeparableStructure.evaluate_gradient(S_test, x )
    # @benchmark M_evaluation_expr_tree.calcul_gradient_expr_tree(obj,x)
    @test g_test == g_test2

    H_test = PartiallySeparableStructure.evaluate_hessian(S_test, x )
    H_test2 = M_evaluation_expr_tree.calcul_Hessian_expr_tree(obj, x)
    @test Array(H_test) == H_test2

    B = PartiallySeparableStructure.struct_hessian(S_test, x )
    x2 = ones(n_x)
    # @benchmark PartiallySeparableStructure.product_matrix_sps(S_test,B,x2)
    # @code_warntype PartiallySeparableStructure.product_matrix_sps(S_test,B,x2)
    # @benchmark H_test2*x2
    id = zeros(n_x)
    id[1] = 1
    PartiallySeparableStructure.product_matrix_sps(S_test,B,id)
    @test norm(H_test2*x2 - PartiallySeparableStructure.product_matrix_sps(S_test,B,x2), 2) < 10e-10

    obj_o2 = trait_expr_tree.transform_to_expr_tree(obj_o)
    obj_o3 = trait_expr_tree.transform_to_Expr(obj_o2)
    @test obj_o == obj_o3

# end

a = :(x[1]^2 + 6.0)
b = trait_expr_tree.transform_to_expr_tree(a)
t = Float16
 algo_expr_tree.cast_type_of_constant!(a, t)
a_t = algo_expr_tree.cast_type_of_constant!(a, t)
b_t = algo_expr_tree.cast_type_of_constant!(b, t)
c = trait_expr_tree.transform_to_Expr(b)


# point_1_dim = Vector{Float16}([4])
# res = M_evaluation_expr_tree.evaluate_expr_tree(a, point_1_dim )
# res_t = M_evaluation_expr_tree.evaluate_expr_tree(a_t, point_1_dim )
# @show typeof(res), typeof(res_t)







""" COMPARAISON evnluation du gradient avec et sans structure partiellement séparable
model jump :
n_x = 1000
@variable(m, x[1:n_x])
@NLobjective(m, Min, sum( x[j]^2 * x[j+1] for j in 1:n_x-1 ) + x[1]*5 )

@benchmark M_evaluation_expr_tree.calcul_gradient_expr_tree(obj,x)
sans :
  memory estimate:  210.70 MiB
  allocs estimate:  2812868
  --------------
  minimum time:     368.598 ms (0.00% GC)
  median time:      529.942 ms (0.00% GC)
  mean time:        596.869 ms (15.94% GC)
  maximum time:     1.349 s (63.47% GC)
  --------------
  samples:          9
  evals/sample:     1

@benchmark PartiallySeparableStructure.evaluate_gradient(S_test, x )
avec :
  memory estimate:  1.41 MiB
  allocs estimate:  30899
  --------------
  minimum time:     3.497 ms (0.00% GC)
  median time:      5.446 ms (0.00% GC)
  mean time:        5.306 ms (0.00% GC)
  maximum time:     8.398 ms (0.00% GC)
  --------------
  samples:          941
  evals/sample:     1

@benchmark PartiallySeparableStructure.product_matrix_sps(S_test,B,x2)
  n_x = 100
    memory estimate:  27.38 KiB
    allocs estimate:  518
    --------------
    minimum time:     61.065 μs (0.00% GC)
    median time:      73.543 μs (0.00% GC)
    mean time:        73.789 μs (0.00% GC)
    maximum time:     760.961 μs (0.00% GC)
    --------------
    samples:          10000
    evals/sample:     1

  n_x = 1000
    memory estimate:  576.80 KiB
      allocs estimate:  9072
      --------------
      minimum time:     571.400 μs (0.00% GC)
      median time:      688.900 μs (0.00% GC)
      mean time:        875.745 μs (19.30% GC)
      maximum time:     1.167 s (99.94% GC)
      --------------
      samples:          6901
      evals/sample:     1

@benchmark H_test2*x2
  n_x = 100
  BenchmarkTools.Trial:
    memory estimate:  896 bytes
    allocs estimate:  1
    --------------
    minimum time:     4.038 μs (0.00% GC)
    median time:      5.524 μs (0.00% GC)
    mean time:        7.476 μs (0.00% GC)
    maximum time:     4.272 ms (0.00% GC)
    --------------
    samples:          10000
    evals/sample:     7
  n_x = 1000
      BenchmarkTools.Trial:
      memory estimate:  7.94 KiB
      allocs estimate:  1
      --------------
      minimum time:     99.699 μs (0.00% GC)
      median time:      111.101 μs (0.00% GC)
      mean time:        116.655 μs (0.00% GC)
      maximum time:     511.399 μs (0.00% GC)
      --------------
      samples:          10000
      evals/sample:     1

"""
