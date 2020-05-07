# using GitHub, JSON,
using PkgBenchmark

import PartiallySeparableStructure

commit = benchmarkpkg("PartiallySeparableStructure")  # current state of repository , script="../benchmark/benchmark.jl"
# pathof(PartiallySeparableStructure) , script="/benchmark/benchmark.jl"
master = benchmarkpkg("PartiallySeparableStructure.jl", "master")

judgement = judge(commit, master)

export_markdown("judgement.md", judgement)
export_markdown("master.md", master)
export_markdown("commit.md", commit)
