using PkgBenchmark
using SolverBenchmark
import PartiallySeparableStructure


commit = benchmarkpkg("PartiallySeparableStructure")  #dernier commit sur la branche sur laquelle on se trouve
master_dvpt = benchmarkpkg("PartiallySeparableStructure", "master_dvpt") # branche master
judgement = judge(master_dvpt, commit)
# judgement = judge("PartiallySeparableStructure", "master")
export_markdown("benchmark/judgement.md", judgement)
