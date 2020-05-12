using PkgBenchmark
using SolverBenchmark
import PartiallySeparableStructure


commit_solver = benchmarkpkg("PartiallySeparableStructure",script="benchmark/solver_benchmark.jl")  #dernier commit sur la branche sur laquelle on se trouve
master_solver = benchmarkpkg("PartiallySeparableStructure", "master_dvpt", script="benchmark/solver_benchmark.jl") # branche masterjudgement_solver = judge(master_solver, commit_solver)
# judgement = judge("PartiallySeparableStructure", "master")
judgement_solver = judge(master_solver, commit_solver)

export_markdown("benchmark/judgement_solver.md", judgement_solver)

# p = profile_solvers(commit_solver)
