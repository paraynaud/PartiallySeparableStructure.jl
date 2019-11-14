using Test
using InteractiveUtils


include("../../src/expr_tree/ordered_include.jl")

using .trait_expr_tree
using .abstract_expr_tree
using .algo_expr_tree
using .algo_tree


t_expr_1 = abstract_expr_tree.create_expr_tree( :(x[1] + x[2] ) )
t1 = algo_expr_tree.transform_expr_tree(t_expr_1)

t_expr_2 = abstract_expr_tree.create_expr_tree( :( (x[3]+x[4])^2 +  x[1] * x[2] ) )
t2 = algo_expr_tree.transform_expr_tree(t_expr_2)


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

t_expr_4 = abstract_expr_tree.create_expr_tree( :( (x[3]+x[4]) + (x[1] + x[2]) ) )
t4 = algo_expr_tree.transform_expr_tree(t_expr_4)

res_t4 = algo_expr_tree.delete_imbricated_plus(t4)
res_t_expr_4 = algo_expr_tree.delete_imbricated_plus(t_expr_4)
test_res_t_expr_4 = [:(x[3]), :(x[4]), :(x[1]), :(x[2])]
@test res_t_expr_4 == test_res_t_expr_4


t_expr_5 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) + (x[1] + x[2]) ) )
t5 = algo_expr_tree.transform_expr_tree(t_expr_5)
res_t_expr_5 = algo_expr_tree.delete_imbricated_plus(t_expr_5)
res_t5 = algo_expr_tree.delete_imbricated_plus(t5)
test_res_t_expr_5 = [ :(x[3]^2), :(x[5] * x[4]), :(x[1]), :(x[2])]
@test res_t_expr_5 == test_res_t_expr_5

t_expr_6 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] + x[2]) ) )
res_t_expr_6 = algo_expr_tree.delete_imbricated_plus(t_expr_6)
test_res_t_expr_6 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(x[2]))]
@test res_t_expr_6 == test_res_t_expr_6

t_expr_7 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )
res_t_expr_7 = algo_expr_tree.delete_imbricated_plus(t_expr_7)
test_res_t_expr_7 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(-(x[2])))]
@test res_t_expr_7 == test_res_t_expr_7

# code warntype
# InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(t_expr_7)
# InteractiveUtils.@code_warntype abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )


using MathOptInterface, JuMP

m = Model()
n_x = 1000000
# n_x = 5
@variable(m, x[1:n_x])
@NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) )
eval_test = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(eval_test, [:ExprGraph])
obj = MathOptInterface.objective_expr(eval_test)
t_obj =  algo_expr_tree.transform_expr_tree(obj)




test_res = algo_expr_tree._get_type_tree(t_expr_4)
@time test_res2 = algo_expr_tree._get_type_tree(t_obj)
@show trait_tree.get_node(test_res2)
