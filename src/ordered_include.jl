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

# le coeur du module
include("PartiallySeparableStructure.jl")

include("solver_sps.jl")

include("abs_nlp_model_sps.jl")

include("comparaison/ordered_include.jl")
