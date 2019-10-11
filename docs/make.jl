using Documenter


makedocs(modules = [hello_world],
	 sitename="PartiallySeparableStructure.jl",
	 format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
)

deploydocs(repo = "github.com/paraynaud/PartiallySeparableStructure.jl.git")


