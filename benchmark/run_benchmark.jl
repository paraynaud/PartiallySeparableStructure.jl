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

# judgement = judge("PartiallySeparableStructure", "master")

using PkgBenchmark
import PartiallySeparableStructure
commit = benchmarkpkg("PartiallySeparableStructure")
master = benchmarkpkg("PartiallySeparableStructure", "master")
judgement = judge(master, commit)
export_markdown("judgement.md", judgement)
