using Documenter


makedocs(modules = [PartiallySeparableStructure],
	 sitename="PartiallySeparableStructure.jl",
	 format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
)

deploydocs(repo = "github.com/paraynaud/PartiallySeparableStructure.jl.git")
