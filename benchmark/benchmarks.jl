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


# n = [100,200,500,1000,2000,5000]
n = [10,20,30]

problems = create_Rosenbrock_JuMP_Model.(n)



SUITE["SPS_function"] = BenchmarkGroup()


for p in problems
  (m_ros, evaluator, obj_ros) = p
  obj_ros_expr_tree = PartiallySeparableStructure.expr_tree_from_Expr(obj_ros)

  n = m_ros.moi_backend.model_cache.model.num_variables_created
  SPS_ros = PartiallySeparableStructure.deduct_partially_separable_structure(obj_ros_expr_tree, n)
  x = ones(n)
  #calcul de la fonction objectif
  SUITE["SPS_function"]["OBJ ros $n var"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS($SPS_ros, $x)

  #calcul du gradient sous format gradient élémentaire
  f = (y :: PartiallySeparableStructure.element_function -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(zeros(typeof(x[1]), length(y.used_variable)) )) )
  grad = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f.(SPS_ros.structure) )
  SUITE["SPS_function"]["grad ros $n var"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS_gradient!($SPS_ros, $x, $grad)

  #calcul du Hessien
  f = ( elm_fun :: PartiallySeparableStructure.element_function -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
  t = f.(SPS_ros.structure) :: Vector{PartiallySeparableStructure.element_hessian{typeof(x[1])}}
  H = PartiallySeparableStructure.Hess_matrix{typeof(x[1])}(t)

  SUITE["SPS_function"]["Hessien ros $n var"] = @benchmarkable PartiallySeparableStructure.struct_hessian!($SPS_ros, $x, $H)

end

const atol = 1.0e-5
const rtol = 1.0e-6
const max_time = 300.0
max_eval = 5000

nlp_problems = MathOptNLPModel.([p[1] for p in problems])
