using Test

include("../src/PartiallySeparableStructure.jl")

using .PartiallySeparableStructure

@testset "test de testS " begin
    @test true
    @test greet() == nothing
    @test test_chemin(6) == 5
end
