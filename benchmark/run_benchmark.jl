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
import PartiallySeparableStructure
judgement = judge("PartiallySeparableStructure", "master")
export_markdown("judgement.md", judgement)
