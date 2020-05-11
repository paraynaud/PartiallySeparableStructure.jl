using PkgBenchmark
using SolverBenchmark
import PartiallySeparableStructure


commit_solver = benchmarkpkg("PartiallySeparableStructure",script="solver_benchmark.lj")  #dernier commit sur la branche sur laquelle on se trouve
master_solver = benchmarkpkg("PartiallySeparableStructure", "master_dvpt", script="solver_benchmark.lj") # branche master
judgement_solver = judge(master_solver, commit_solver)
# judgement = judge("PartiallySeparableStructure", "master")
export_markdown("benchmark/judgement_solver.md", judgement_solver)
