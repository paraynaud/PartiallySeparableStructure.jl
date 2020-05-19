using PkgBenchmark
using SolverBenchmark
using Plots

# perform benchmarks
results = PkgBenchmark.benchmarkpkg("PartiallySeparableStructure", script="benchmark/compare_with_JuMP.jl")

# process benchmark results and post gist
p = profile_solvers(results)
error("error")
savefig(p, "benchmark/profile_JuMP.png")
