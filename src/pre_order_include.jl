#avant node_expr
include("type_expr/ordered_include.jl")

#avant expr_tree
include("node_expr_tree/ordered_include.jl")
#avant expr_tree
include("tree/ordered_include.jl")

# apres node_expr_tree et tree
include("expr_tree/ordered_include.jl")



#les méthodes quasi-newton
include("quasi_newton.jl")
