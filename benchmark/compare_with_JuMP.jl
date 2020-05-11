using BenchmarkTools
using JuMP, MathOptInterface
using PartiallySeparableStructure



include("../src/comparaison/models/rosenbrock.jl")

const SUITE = BenchmarkGroup()


n = [100,200,500]

problems = create_Rosenbrock_JuMP_Model.(n)



for p in problems
  (m_ros, evaluator, obj_ros) = p
  n = m_ros.moi_backend.model_cache.model.num_variables_created
  x = ones(n)
  SUITE["ROS $n variable"] = BenchmarkGroup()
  SUITE["ROS $n variable"]["OBJ"] = BenchmarkGroup()
  SUITE["ROS $n variable"]["GRAD"] = BenchmarkGroup()
  # définition des variables nécessaires


  #calcul de la structure partiellement séparable
  obj_ros_expr_tree = PartiallySeparableStructure.expr_tree_from_Expr(obj_ros)
  SPS_ros = PartiallySeparableStructure.deduct_partially_separable_structure(obj_ros_expr_tree, n)

  #calcul de la fonction objectif
  SUITE["ROS $n variable"]["OBJ"]["SPS"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS($SPS_ros, $x)
  SUITE["ROS $n variable"]["OBJ"]["JuMP"] = @benchmarkable MathOptInterface.eval_objective( $evaluator, $x)

  #calcul du gradient sous format gradient élémentaire
  f = (y :: PartiallySeparableStructure.element_function -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(zeros(typeof(x[1]), length(y.used_variable)) )) )
  grad = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f.(SPS_ros.structure) )
  SUITE["ROS $n variable"]["GRAD"]["SPS"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS_gradient!($SPS_ros, $x, $grad)

  grad_JuMP = Vector{Float64}(zeros(Float64,n))
  SUITE["ROS $n variable"]["GRAD"]["JuMP"] = @benchmarkable MathOptInterface.eval_objective_gradient($evaluator, $grad_JuMP, $x)

end


@show SUITE["ROS 100 variable"]
@show SUITE["ROS 100 variable"]["OBJ"]
dump(SUITE["ROS 100 variable"]["OBJ"])

@show SUITE["ROS 100 variable"]["OBJ"]["JuMP"]
dump(SUITE["ROS 100 variable"]["OBJ"]["JuMP"])
dump(SUITE["ROS 100 variable"]["OBJ"]["SPS"])
