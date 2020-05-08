# # using GitHub, JSON,

using PkgBenchmark
import PartiallySeparableStructure
judgement = judge("PartiallySeparableStructure", "master")
export_markdown("benchmark/judgement.md", judgement)
