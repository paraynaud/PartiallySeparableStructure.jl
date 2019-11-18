using Test
using InteractiveUtils
using MathOptInterface, JuMP

include("../../src/expr_tree/ordered_include.jl")

using .trait_expr_tree
using .abstract_expr_tree
using .algo_expr_tree
using .algo_tree




@testset "test building of trees and equality" begin
    expr_1 = :(x[1] + x[2] )
    t_expr_1 = abstract_expr_tree.create_expr_tree(expr_1)
    @test t_expr_1 == expr_1
    @test  trait_expr_tree.expr_tree_equal(t_expr_1, expr_1)

    t1 = algo_expr_tree.transform_expr_tree(t_expr_1)
    @test trait_expr_tree.expr_tree_equal(t1, t_expr_1)

    expr_2 = :( (x[3]+x[4])^2 +  x[1] * x[2] )
    @test trait_expr_tree.expr_tree_equal(expr_1, expr_2) == false
    t_expr_2 = abstract_expr_tree.create_expr_tree(expr_2)
    @test t_expr_2 == expr_2
    t2 = algo_expr_tree.transform_expr_tree(t_expr_2)
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
    n3_2_op = abstract_expr_node.create_node_expr(:^,[2])
    n3_2 = abstract_expr_tree.create_expr_tree(n3_2_op, [n3_2_1])
    n3_op = abstract_expr_node.create_node_expr(:+)
    t3 = abstract_expr_tree.create_expr_tree(n3_op,[n3_2,n3_1])
    @test  trait_expr_tree.expr_tree_equal(t_expr_2, t3)
    @test  trait_expr_tree.expr_tree_equal(t2, t3)

 end


@testset " Deletion of imbricated +" begin
    t_expr_4 = abstract_expr_tree.create_expr_tree( :( (x[3]+x[4]) + (x[1] + x[2]) ) )
    t4 = algo_expr_tree.transform_expr_tree(t_expr_4)
    res_t4 = algo_expr_tree.delete_imbricated_plus(t4)
    res_t_expr_4 = algo_expr_tree.delete_imbricated_plus(t_expr_4)
    test_res_t_expr_4 = [:(x[3]), :(x[4]), :(x[1]), :(x[2])]
    @test res_t_expr_4 == test_res_t_expr_4
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t4, res_t_expr_4))

    t_expr_5 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) + (x[1] + x[2]) ) )
    t5 = algo_expr_tree.transform_expr_tree(t_expr_5)
    res_t_expr_5 = algo_expr_tree.delete_imbricated_plus(t_expr_5)
    res_t5 = algo_expr_tree.delete_imbricated_plus(t5)
    test_res_t_expr_5 = [ :(x[3]^2), :(x[5] * x[4]), :(x[1]), :(x[2])]
    @test res_t_expr_5 == test_res_t_expr_5
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t5, res_t_expr_5))


    t_expr_6 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] + x[2]) ) )
    t6 = algo_expr_tree.transform_expr_tree(t_expr_6)
    res_t_expr_6 = algo_expr_tree.delete_imbricated_plus(t_expr_6)
    res_t6 = algo_expr_tree.delete_imbricated_plus(t6)
    test_res_t_expr_6 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(x[2]))]
    @test res_t_expr_6 == test_res_t_expr_6
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t6, res_t_expr_6))


    t_expr_7 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t7 = algo_expr_tree.transform_expr_tree(t_expr_7)
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

    m = Model()
    n_x = 10
    # n_x = 5
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) )
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])
    obj = MathOptInterface.objective_expr(eval_test)
    t_obj =  algo_expr_tree.transform_expr_tree(obj)




    test_res_obj = algo_expr_tree.get_type_tree(t_obj)
    @test trait_type_expr._is_quadratic(trait_tree.get_node(test_res_obj))
    @test trait_type_expr._is_more_than_quadratic(trait_tree.get_node(test_res_obj)) == false


    t_expr_8 = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t8 = algo_expr_tree.transform_expr_tree(t_expr_8)

    test_res8 =  algo_expr_tree.get_type_tree(t_expr_8)
    test_res_t8 =  algo_expr_tree.get_type_tree(t8)
    @test test_res8 == test_res_t8
    @test trait_type_expr._is_more_than_quadratic(trait_tree.get_node(test_res_t8) )

    @time test_res4 =  algo_expr_tree.get_type_tree(t_obj)
     # InteractiveUtils.@code_warntype   algo_expr_tree.get_type_tree(t8)

    
end
