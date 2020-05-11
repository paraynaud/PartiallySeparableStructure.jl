# # using GitHub, JSON,
# using PkgBenchmark
#
# using PartiallySeparableStructure
#
# pkg = "PartiallySeparableStructure"
#
# dvpt = BenchmarkConfig("dvpt")
# master = BenchmarkConfig("master")
# master = benchmarkpkg("PartiallySeparableStructure", master)
# commit = benchmarkpkg("PartiallySeparableStructure", dvpt)  # current state of repository , script="../benchmark/benchmark.jl"
# # pathof(PartiallySeparableStructure) , script="/benchmark/benchmarks.jl"
#
# judgement = judge(commit, master)
#
# export_markdown("judgement.md", judgement)
# export_markdown("master.md", master)
# export_markdown("commit.md", commit)


using PkgBenchmark
using SolverBenchmark
import PartiallySeparableStructure

#
# using Plots
# # pyplot()  # recommended!
# using PlotThemes
# theme(:juno)
#
# common_plot_args = Dict{Symbol,Any}(
#   :linewidth => 2,
#   :alpha => .75,
#   :titlefontsize => 8,
#   :legendfontsize => 8,
#   :xtickfontsize => 6,
#   :ytickfontsize => 6,
#   :guidefontsize => 8,
# )
# Plots.default(; common_plot_args...)



commit = benchmarkpkg("PartiallySeparableStructure")  #dernier commit sur la branche sur laquelle on se trouve
master = benchmarkpkg("PartiallySeparableStructure", "master") # branche master
judgement = judge(master, commit)
# judgement = judge("PartiallySeparableStructure", "master")
export_markdown("benchmark/judgement.md", judgement)

# profile_package(judgement)
