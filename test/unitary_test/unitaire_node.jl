using ..abstract_expr_node, ..trait_expr_node

using ..variables
using ..constants
using ..simple_operators
using ..complex_operators

using MathOptInterface


@testset "test des constructeurs" begin
    @test abstract_expr_node.create_node_expr(4) == constants.constant(4)


    @test abstract_expr_node.create_node_expr(:x, 5) == variables.variable(:x, 5)
    @test abstract_expr_node.create_node_expr(:x, MathOptInterface.VariableIndex(5)) == variables.variable(:x, 5)

    @test abstract_expr_node.create_node_expr(:x, MathOptInterface.VariableIndex(5)) == abstract_expr_node.create_node_expr(:x, 5)



end
