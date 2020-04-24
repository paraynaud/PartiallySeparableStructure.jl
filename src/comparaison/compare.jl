include("../ordered_include.jl")


repo_model = "models/"
include(repo_model * "chained_wood.jl")
include( repo_model * "rosenbrock.jl")
include( repo_model * "chained_powel.jl")
include( repo_model * "chained_cragg_levy.jl")

using JSOSolvers, SolverBenchmark

using ..PartiallySeparableStructure
using ..Quasi_Newton_update

i = 100
(m_ros, evaluator,obj) = create_Rosenbrock_JuMP_Model(i)
init = create_initial_point_Rosenbrock(i)
nlp = MathOptNLPModel(m_ros)
# cpt_pbfgs = My_SPS_Model_Module.solver_TR_PBFGS!(nlp,x=init)
cpt_pbfgs = My_SPS_Model_Module.solver_TR_PBFGS!(obj,i,init)
# cpt_lsr1 = My_SPS_Model_Module.solver_TR_PSR1!(nlp,x=init)
# my_LSR1(nlp,copy(init))
# my_LBFGS(nlp,copy(init))

s_a = cpt_pbfgs
index = Int(cpt_pbfgs.index)
autre_index = 2 - index + 1
B = s_a.tpl_B[index]
B₋₁ = s_a.tpl_B[autre_index]
res1 = PartiallySeparableStructure.check_Inf_Nan(B)
res2 = PartiallySeparableStructure.check_Inf_Nan(B₋₁)
s_a.sps.structure[69]
B_i = s_a.tpl_B[index].arr[69]
Bi_1 = s_a.tpl_B[autre_index].arr[69]
B2 = copy(Bi_1.elmt_hess)
B3 = copy(Bi_1.elmt_hess)
B4 = copy(Bi_1.elmt_hess)
B5 = copy(Bi_1.elmt_hess)
B6 = copy(Bi_1.elmt_hess)
y = s_a.y.arr[69].g_i

Δx1 = [1e-6, 1e-6]
Δx2 = [1.0, 1.0]
Δx3 = [-1e-10,- 1e-76]
Δx_complet = s_a.tpl_x[index] - s_a.tpl_x[autre_index]
Δx = view(Δx_complet, s_a.sps.structure[69].used_variable)
n = i
opB(B) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s_a.sps, B, x) )
(s_k, info) = Krylov.cg(opB(B₋₁), - s_a.grad, radius = s_a.Δ)
Δx_vrai  = view(s_k, s_a.sps.structure[69].used_variable)

Quasi_Newton_update.update_BFGS!(Δx1,y,Bi_1.elmt_hess,B2)
Quasi_Newton_update.update_BFGS!(Δx2,y,Bi_1.elmt_hess,B3)
Quasi_Newton_update.update_BFGS!(Δx3,y,Bi_1.elmt_hess,B4)
Quasi_Newton_update.update_BFGS!(Δx,y,Bi_1.elmt_hess,B5)
Quasi_Newton_update.update_BFGS!(Δx_vrai,y,Bi_1.elmt_hess,B6)
@show B2
@show B3
@show B4
@show B5
@show B6

error("fin")

α = 1 / (y' * Δx1)
β = - (1 / (Δx1' * B * Δx1) )
u = y * y'
v = B * Δx
terme1 = (α * u * u')
terme2 = (β * v * v')
B_1[:] = (B + terme1 + terme2) :: Array{Y,2}
# PartiallySeparableStructure.product_matrix_sps(s_a.sps,B,rand(i))



"""
    create_all_problems(n)
Function that create the problem that I will use with bmark_solver. I use function to generate automaticaly some Models, theses are defined in other
files in the same repo. n Is the size of the problems.
"""
function create_all_problems(nb_var_array :: Vector{Int})
  problem_array = []
  for i in nb_var_array
    (m_ros, evaluator,obj) = create_Rosenbrock_JuMP_Model(i)
    (m_chained, evaluator,obj) = create_chained_wood_JuMP_Model(i)
    (m_powel, evaluator,obj) = create_chained_Powel_JuMP_Model(i)
    (m_cragg_levy, evaluator,obj) = create_chained_cragg_levy_JuMP_Model(i)
    push!(problem_array, MathOptNLPModel(m_ros), MathOptNLPModel(m_chained), MathOptNLPModel(m_powel), MathOptNLPModel(m_cragg_levy))
    # init = create_initial_point_Rosenbrock(i)
    # push!(problem_array, (MathOptNLPModel(m_ros), init))
  end
  return problem_array
end


println(" \n\n génération des problemes")
n_array = [100,500,1000,2000]
n_array = [10,20,30]
# n_array = [1000,2000]
problems = create_all_problems(n_array)


println("\n\ndéfintion des solver\n\n")
const atol = 1.0e-5
const rtol = 1.0e-6
const max_time = 3600.0
solvers = Dict{Symbol,Function}(
  :my_lsr1 => (m -> my_LSR1(m)),
  :my_lbfgs => (m -> my_LBFGS(m)),
  :p_sr1 => (m -> My_SPS_Model_Module.solver_TR_PSR1!(m)),
  :p_bfgs => (m -> My_SPS_Model_Module.solver_TR_PBFGS!(m)),
  :trunk_sr1 => prob -> JSOSolvers.trunk(NLPModels.LSR1Model(prob), max_time=max_time, atol=atol, rtol=rtol),
  :trunk => prob -> JSOSolvers.trunk(prob, max_time=max_time, atol=atol, rtol=rtol)
  )

  # solvers = Dict{Symbol,Function}(
  #   :p_bfgs => ((nlp; kwargs...) -> My_SPS_Model_Module.solver_TR_PBFGS!(nlp;kwargs...)),
  #   )
  # (nlp,y) = problems[1]
# My_SPS_Model_Module.solver_TR_PBFGS!(nlp;x=y)
# solvers[:p_bfgs](nlp, x=y)

#= Lancement du benchmark sur les problèmes générés, sur les solvers défini dans la variable solvers =#
println("lancement des benchmmarks")
# SolverTools.solve_problems(solvers[:p_bfgs], problems; reset_problem=false)
# stats = bmark_solvers(solvers,problems,reset_problem=false, x=y)
stats = bmark_solvers(solvers,problems)
# error("fin")


#= Ecriture des résultats dans un fichier au format markdown=#
println("écriture des résultats markdown")
location_md = string("src/comparaison/results/result_bench_md.txt")
io = open(location_md,"w")
close(io)
io = open(location_md,"w+")
keys_solver = keys(stats)
for i in keys_solver
  markdown_table(io, stats[i], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
end
close(io)


#= Ecriture des résultats dans un fichier au format latex=#
println("écriture des résultats latex")
location_latex = string("src/comparaison/results/result_bench_latex.txt")
io = open(location_latex,"w")
close(io)
io = open(location_latex,"w+")
keys_solver = keys(stats)
for i in keys_solver
  latex_table(io, stats[i], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
end
close(io)


println("affichage du profile des solvers par rapport au problèmes")
performance_profile(stats, df->df.elapsed_time)






markdown_table(stdout, stats[:p_sr1], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])










#= non nécessaire actuellement, faisant office de test pour les dictionnaires et la création de fichier de résultat=#
#=
prob_name_file = Dict{Symbol,String}(
        :rosenbrock => "Rosenbrock",
        :chained_wood => "Chained_Wood",
        :chained_Powel => "Chained_Powel",
        :chained_Cragg_Levis => "Chained_Cragg_Levis",
        )

solver_name = Dict{Symbol,String}(
        :psr1 => "P-SR1",
        :trunk => "Trunk",
        :trunk_lsr1 => "Trunk_LSR1",
        :lsr1 => "L-SR1",
        :lbfgs => "L-BFGS",
        :pbfgs => "P-BFGS",
        )

solver_function = Dict{Symbol,String}(
        :psr1 => "P-SR1",
        :trunk => "Trunk",
        :trunk_lsr1 => "Trunk_LSR1",
        :lsr1 => "L-SR1",
        :lbfgs => "L-BFGS",
        :pbfgs => "P-BFGS",
        )

function open_close_all_result_file(prob_name_file, solver_name)
  for (k_prob, name_prob) ∈ prob_name_file
    depo_name = string("src/comparaison/results/",name_prob)
    for (k_solver, name_solver) ∈ solver_name
      file_name = string(name_prob, "_", name_solver,".txt")
      location = string(depo_name,"/", file_name)
      #on ouvre et on ferme le fichier, on le reset
      io = open(location,"w")
      close(io)
    end
  end
end
=#
