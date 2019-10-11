using Test

include("../src/PartiallySeparableStructure.jl")

using .PartiallySeparableStructure

@test true
@test greet() == nothing
