using BenchmarkTools
include("../src/ordered_include.jl")
include("../src/comparaison/models/rosenbrock.jl")

using .PartiallySeparableStructure

const SUITE = BenchmarkGroup()


n = [100,200,500]

problems = create_Rosenbrock_JuMP_Model.(n)

SUITE["SPS_function"] = BenchmarkGroup()


for p in problems
  (m_ros, evaluator, obj_ros) = p
  n = m_ros.moi_backend.model_cache.model.num_variables_created
  SPS_ros = PartiallySeparableStructure.deduct_partially_separable_structure(obj_ros, n)
  x = ones(n)
  SUITE["SPS_function"]["OBJ ros $n var"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS($SPS_ros, $x)
  # SUITE["CG"]["DivGrad N=$N"] = BenchmarkGroup()
  # A = get_div_grad(N, N, N)
  # n = size(A, 1)
  # b = ones(n)
  # op = PreallocatedLinearOperator(A)
  # M = opEye()
  # rtol = 1.0e-6
  # SUITE["CG"]["DivGrad N=$N"]["Krylov"] = @benchmarkable cg($op, $b, M=$M, atol=0.0, rtol=$rtol, itmax=$n)
end
# error("test")
# @show SUITE["SPS_function"]["OBJ ros 100 var"]
