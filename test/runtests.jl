using Test

include("../PartiallySeparableStructure.jl")

using .PartiallySeparableStructure

@test true
@test greet() == nothing
