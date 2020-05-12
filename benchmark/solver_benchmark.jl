using BenchmarkTools
using JSOSolvers, SolverBenchmark, SolverTools
using NLPModelsJuMP

include("../src/comparaison/models/rosenbrock.jl")
# include("../src/solver_sps.jl")
# include("../src/PartiallySeparableStructure.jl")

include("../src/ordered_include.jl")
# import PartiallySeparableStructure
# import PartiallySeparableStructure
using ..PartiallySeparableStructure
# using ..My_SPS_Model_Module


const SUITE = BenchmarkGroup()


# n = [100,200,500]
n = [10,20,30]

problems = create_Rosenbrock_JuMP_Model.(n)
nlp_problems = MathOptNLPModel.([p[1] for p in problems])



SUITE["Trunk"] = BenchmarkGroup()
SUITE["Trunk_LSR1"] = BenchmarkGroup()
SUITE["L-BFGS"] = BenchmarkGroup()
SUITE["L-SR1"] = BenchmarkGroup()
SUITE["P-SR1"] = BenchmarkGroup()
SUITE["P-BFGS"] = BenchmarkGroup()

for i in 1:length(problems)

  atol = 1.0e-5
  rtol = 1.0e-6
  max_time = 300.0
  max_eval = 5000
  (m_ros, evaluator, obj_ros) = problems[i]
  obj_ros_expr_tree = PartiallySeparableStructure.expr_tree_from_Expr(obj_ros)
  n = m_ros.moi_backend.model_cache.model.num_variables_created
  prob = nlp_problems[i]

  # SPS_ros = PartiallySeparableStructure.deduct_partially_separable_structure(obj_ros_expr_tree, n)

  SUITE["Trunk"]["ros $n var"] = @benchmarkable $(JSOSolvers.trunk)(prob)
  # SUITE["Trunk_LSR1"]["ros $n var"] = @benchmarkable JSOSolvers.trunk(NLPModels.LSR1Model(&prob); max_time=&max_time, max_eval=&max_eval, atol=&atol, rtol=&rtol)
  # SUITE["L-BFGS"]["ros $n var"] = @benchmarkable my_LBFGS(&prob; max_time=&max_time, max_eval=&max_eval, atol=&atol, rtol=&rtol)
  # SUITE["L-SR1"]["ros $n var"] = @benchmarkable my_LSR1(&prob; max_time=&max_time, max_eval=&max_eval, atol=&atol, rtol=&rtol)
  # SUITE["P-BFGS"]["ros $n var"] = @benchmarkable PartiallySeparableStructure.solver_TR_PBFGS!(&prob; max_time=&max_time, max_eval=&max_eval, atol=&atol, rtol=&rtol)
  # SUITE["P-SR1"]["ros $n var"] = @benchmarkable PartiallySeparableStructure.solver_TR_PSR1!(&prob; max_time=&max_time, max_eval=&max_eval, atol=&atol, rtol=&rtol)

end
