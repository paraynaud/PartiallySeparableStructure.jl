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
