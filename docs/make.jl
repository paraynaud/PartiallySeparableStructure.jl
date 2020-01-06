using Documenter

include("../src/ordered_include.jl")
include("../src/PartiallySeparableStructure.jl")

using .PartiallySeparableStructure 


makedocs(modules = [PartiallySeparableStructure],
	 sitename="PartiallySeparableStructure.jl",
	 format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
)

deploydocs(repo = "github.com/paraynaud/PartiallySeparableStructure.jl.git")
