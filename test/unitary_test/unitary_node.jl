# include("../../src/ordered_include.jl")

using ..abstract_expr_node, ..trait_expr_node

using ..variables
using ..constants
using ..simple_operators
using ..complex_operators

using Test
using MathOptInterface


@testset "test des constructeurs node" begin
    @test abstract_expr_node.create_node_expr(4) == constants.constant(4)


    @test abstract_expr_node.create_node_expr(:x, 5) == variables.variable(:x, 5)
    @test abstract_expr_node.create_node_expr(:x, MathOptInterface.VariableIndex(5)) == variables.variable(:x, 5)

    @test abstract_expr_node.create_node_expr(:x, MathOptInterface.VariableIndex(5)) == abstract_expr_node.create_node_expr(:x, 5)

    @test abstract_expr_node.create_node_expr(:+) == simple_operators.simple_operator(:+)
    @test abstract_expr_node.create_node_expr(:*) == simple_operators.simple_operator(:*)
    @test abstract_expr_node.create_node_expr(:^,2, true ) == power_operators.power_operator(2)
    @test abstract_expr_node.create_node_expr(:^,[2]) == complex_operators.complex_operator(:^,[2])

end

@testset "test des fonctions de tests" begin

    constant = abstract_expr_node.create_node_expr(4)
    variable = abstract_expr_node.create_node_expr(:x, 5)
    simple_operator = abstract_expr_node.create_node_expr(:+)
    power_operator = abstract_expr_node.create_node_expr(:^,2, true )
    collection = [constant, variable, simple_operator, power_operator]

    @test trait_expr_node.is_expr_node.( vcat(collection,[:+, :*]) ) == [trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_not_expr_node(), trait_expr_node.type_not_expr_node()]
    @test trait_expr_node.node_is_operator.( collection ) == [false, false, true, true]
    @test trait_expr_node.node_is_constant.( collection ) == [true, false, false, false]
    @test trait_expr_node.node_is_variable.( collection ) == [false, true, false, false]




    coll_simple_op = [ abstract_expr_node.create_node_expr(:+), abstract_expr_node.create_node_expr(:-), abstract_expr_node.create_node_expr(:*), abstract_expr_node.create_node_expr(:sin), abstract_expr_node.create_node_expr(:cos), abstract_expr_node.create_node_expr(:tan)]

    @test trait_expr_node.is_expr_node.(coll_simple_op) == [trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node(), trait_expr_node.type_expr_node()]
    @test trait_expr_node.node_is_operator.(coll_simple_op) == [true, true, true, true, true, true]
    @test trait_expr_node.node_is_plus.(coll_simple_op) == [true, false, false, false, false, false]
    @test trait_expr_node.node_is_minus.(coll_simple_op) == [false, true, false, false, false, false]
    @test trait_expr_node.node_is_times.(coll_simple_op) == [false, false, true, false, false, false]
    @test trait_expr_node.node_is_sin.(coll_simple_op) == [false, false, false, true, false, false]
    @test trait_expr_node.node_is_cos.(coll_simple_op) == [false, false, false, false, true, false]
    @test trait_expr_node.node_is_tan.(coll_simple_op) == [false, false, false, false, false, true]
    @test trait_expr_node.node_is_power.(coll_simple_op) == [false, false, false, false, false, false]

    @test trait_expr_node.node_is_constant.(coll_simple_op) == [false, false, false, false, false, false]
    @test trait_expr_node.node_is_variable.(coll_simple_op) == [false, false, false, false, false, false]

    @test trait_expr_node.get_var_index(variable) == 5
end
