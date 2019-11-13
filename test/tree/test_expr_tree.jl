using Test


include("../../src/expr_tree/ordered_include.jl")

using .trait_expr_tree
using .abstract_expr_tree
using .algo_expr_tree
using .algo_tree


@show t_expr_1 = abstract_expr_tree.create_expr_tree( :(x[1] + x[2] ) )
@show t1 = algo_expr_tree.transform_expr_tree(t_expr_1)

algo_tree.printer_tree(t_expr_1)
algo_tree.printer_tree(t1)

@show t_expr_2 = abstract_expr_tree.create_expr_tree( :( (x[3]+x[4])^2 +  x[1] * x[2] ) )
@show t2 = algo_expr_tree.transform_expr_tree(t_expr_2)

algo_tree.printer_tree(t_expr_2)
algo_tree.printer_tree(t2)

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
@test res_t_expr_4 == [:(x[3]), :(x[4]), :(x[1]), :(x[2])]


t_expr_5 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) + (x[1] + x[2]) ) )
t5 = algo_expr_tree.transform_expr_tree(t_expr_5)
res_t_expr_5 = algo_expr_tree.delete_imbricated_plus(t_expr_5)
res_t5 = algo_expr_tree.delete_imbricated_plus(t5)


t_expr_6 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] + x[2]) ) )
res_t_expr_6 = algo_expr_tree.delete_imbricated_plus(t_expr_6)
