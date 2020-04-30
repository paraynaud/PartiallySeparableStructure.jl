include("../ordered_include.jl")


repo_model = "models/"
include(repo_model * "chained_wood.jl")
include( repo_model * "rosenbrock.jl")
include( repo_model * "chained_powel.jl")
include( repo_model * "chained_cragg_levy.jl")
include( repo_model * "generalisation_Brown.jl")



using JSOSolvers, SolverBenchmark

using ..PartiallySeparableStructure
using ..Quasi_Newton_update
#
# i = 100
# (m_ros, evaluator,obj) = create_Rosenbrock_JuMP_Model(i)
# init = create_initial_point_Rosenbrock(i)
# nlp = MathOptNLPModel(m_ros)
# # cpt_pbfgs = My_SPS_Model_Module.solver_TR_PBFGS!(nlp,x=init)
# (final_point,s_a,cpt) = My_SPS_Model_Module.solver_TR_PBFGS!(obj,i,init)
# # cpt_lsr1 = My_SPS_Model_Module.solver_TR_PSR1!(nlp,x=init)
# # my_LSR1(nlp,copy(init))
# # my_LBFGS(nlp,copy(init))
#
# # s_a = cpt_pbfgs[2]
# index = Int(s_a.index)
# autre_index = 2 - index + 1
# B = s_a.tpl_B[index]
# B₋₁ = s_a.tpl_B[autre_index]
# res1 = PartiallySeparableStructure.check_Inf_Nan(B)
# res2 = PartiallySeparableStructure.check_Inf_Nan(B₋₁)
# fail_index = res1[1][1]
# s_a.sps.structure[fail_index]
# B_i = s_a.tpl_B[index].arr[fail_index]
# Bi_1 = s_a.tpl_B[autre_index].arr[fail_index]
# @show B_i
#
# B_test = copy(Bi_1.elmt_hess)
# B_test2 = copy(Bi_1.elmt_hess)
#
# n = i
#
# Δx_complet = s_a.tpl_x[index] - s_a.tpl_x[autre_index]
# Δx = view(Δx_complet, s_a.sps.structure[fail_index].used_variable)
# x₋₁ = s_a.tpl_x[autre_index]
#
# opB(B) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s_a.sps, B, x) )
# g_elem_1 = s_a.tpl_g[autre_index]
# y = s_a.y.arr[fail_index].g_i
# g = PartiallySeparableStructure.build_gradient(s_a.sps, g_elem_1)
# (s_k, info) = Krylov.cg(opB(B₋₁), - g, radius = s_a.Δ)
# Δx_vrai  = view(s_k, s_a.sps.structure[fail_index].used_variable)
#
# Quasi_Newton_update.update_BFGS!(Δx_vrai,y,Bi_1.elmt_hess,B_test)
# Quasi_Newton_update.update_BFGS!(Δx,y,Bi_1.elmt_hess,B_test2)
# @show B_test, B_test2
# @show Δx, Δx_vrai
#
# B_temp = Bi_1.elmt_hess
# Δx = Δx_vrai
# @show Δx
# @show Δx' * y
# @show α = 1 / (y' * Δx)
# @show β = - (1 / (Δx' * B_temp * Δx) )
# @show u = y * y'
# @show v = B_temp * Δx
# @show terme1 = (α * u * u')
# @show Δx' * B_temp * Δx
# @show v*v'
# @show terme2 = (β * v * v')
# @show (B_temp + terme1 + terme2)
#
# Quasi_Newton_update.update_BFGS!(Δx, y, )
# error("fin")
# B_1[:] = (B + terme1 + terme2) :: Array{Y,2}
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
    (m_brown, evaluator,obj) = create_generalisation_Brown(i)
    push!(problem_array, MathOptNLPModel(m_ros), MathOptNLPModel(m_chained), MathOptNLPModel(m_powel), MathOptNLPModel(m_cragg_levy), MathOptNLPModel(m_brown))
    # init = create_initial_point_Rosenbrock(i)
    # push!(problem_array, (MathOptNLPModel(m_ros), init))
  end
  return problem_array
end


println(" \n\n génération des problemes")
n_array = [100,500,1000,2000,5000]
# n_array = [10,20,30]
# n_array = [1000,2000]
# n_array = [100,200]
problems = create_all_problems(n_array)

# res = My_SPS_Model_Module.solver_TR_PBFGS!.(problems)
#
#
# My_SPS_Model_Module.solver_TR_PSR1!.(problems)
# error("fin")

println("\n\ndéfinition des solver\n\n")


solver_v2 = Dict{Symbol,Function}(
  :trunk => ((prob;kwargs...) -> JSOSolvers.trunk(prob;kwargs...)),
  :trunk_lsr1 => (prob; kwargs...) -> JSOSolvers.trunk(NLPModels.LSR1Model(prob); kwargs...),
  :my_lbfgs => ((prob;kwargs...) -> my_LBFGS(prob;kwargs...)),
  :my_lsr1 => ((prob;kwargs...) -> my_LSR1(prob;kwargs...)),
  :p_bfgs => ((prob;kwargs...) -> My_SPS_Model_Module.solver_TR_PBFGS!(prob; kwargs...)),
  :p_sr1 => ((prob;kwargs...) -> My_SPS_Model_Module.solver_TR_PSR1!(prob; kwargs...))
)

const atol = 1.0e-5
const rtol = 1.0e-6
const max_time = 1.0


#= Lancement du benchmark sur les problèmes générés, sur les solvers défini dans la variable solvers =#
println("lancement des benchmmarks")

stats = bmark_solvers(solver_v2, problems; max_time=max_time, max_eval = 5000, atol=atol, rtol=rtol)
keys_solver = keys(stats)

println("affichage du profile des solvers par rapport au problèmes")
performance_profile(stats, df->df.elapsed_time)
performance_profile(stats, df->df.iter)

println("affichage des tables")
markdown_table(stdout, stats[:p_sr1], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
markdown_table(stdout, stats[:p_bfgs], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
markdown_table(stdout, stats[:my_lbfgs], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
markdown_table(stdout, stats[:trunk], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
markdown_table(stdout, stats[:trunk_lsr1], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])




# error("fin")
#= Ecriture des résultats dans un fichier au format markdown=#
println("écriture des résultats markdown")
location_md = string("src/comparaison/results/result_bench_md.txt")
io = open(location_md,"w")
close(io)
io = open(location_md,"w+")
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
for i in keys_solver
  latex_table(io, stats[i], cols=[ :id, :name, :nvar, :elapsed_time, :iter, :status, :objective, :neval_obj, :neval_grad ])
end
close(io)










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
