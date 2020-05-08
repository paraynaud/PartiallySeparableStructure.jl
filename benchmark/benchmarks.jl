using BenchmarkTools


using PartiallySeparableStructure
using ..implementation_type_expr, ..implementation_expr_tree, ..trait_expr_tree
include("../src/comparaison/models/rosenbrock.jl")

const SUITE = BenchmarkGroup()


n = [100,200,500]

problems = create_Rosenbrock_JuMP_Model.(n)

SUITE["SPS_function"] = BenchmarkGroup()


for p in problems
  (m_ros, evaluator, obj_ros) = p
  obj_ros_expr_tree = trait_expr_tree.transform_to_expr_tree(obj_ros)

  n = m_ros.moi_backend.model_cache.model.num_variables_created
  SPS_ros = PartiallySeparableStructure.deduct_partially_separable_structure(obj_ros_expr_tree, n)
  x = ones(n)
  #calcul de la fonction objectif
  SUITE["SPS_function"]["OBJ ros $n var"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS($SPS_ros, $x)

  #calcul du gradient sous format gradient élémentaire
  f = (y :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(zeros(typeof(x[1]), length(y.used_variable)) )) )
  grad = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f.(SPS.structure) )
  SUITE["SPS_function"]["grad ros $n var"] = @benchmarkable PartiallySeparableStructure.evaluate_SPS_gradient!($SPS_ros, $x, $grad)

  #calcul du Hessien
  f = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
  t = f.(SPS2.structure) :: Vector{PartiallySeparableStructure.element_hessian{typeof(x[1])}}
  H = PartiallySeparableStructure.Hess_matrix{typeof(x[1])}(t)

  SUITE["SPS_function"]["Hessien ros $n var"] = @benchmarkable PartiallySeparableStructure.struct_hessian!($SPS_ros, $x, $H)


end

  # A = get_div_grad(N, N, N)
  # n = size(A, 1)
  # b = ones(n)
  # op = PreallocatedLinearOperator(A)
  # M = opEye()
  # SUITE["CG"]["DivGrad N=$N"]["Krylov"] = @benchmarkable cg($op, $b, M=$M, atol=0.0, rtol=$rtol, itmax=$n)
  # rtol = 1.0e-6
# error("test")
# @show SUITE["SPS_function"]["OBJ ros 100 var"]
