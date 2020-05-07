# using GitHub, JSON,
using PkgBenchmark

using PartiallySeparableStructure

pkg = "PartiallySeparableStructure"

dvpt = BenchmarkConfig("dvpt")
master = BenchmarkConfig("master")
commit = benchmarkpkg("PartiallySeparableStructure", dvpt)  # current state of repository , script="../benchmark/benchmark.jl"
# pathof(PartiallySeparableStructure) , script="/benchmark/benchmarks.jl"
master = benchmarkpkg("PartiallySeparableStructure", master)

judgement = judge(commit, master)

export_markdown("judgement.md", judgement)
export_markdown("master.md", master)
export_markdown("commit.md", commit)
