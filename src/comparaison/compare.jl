include("../ordered_include.jl")

include("chained_wood.jl")
include("rosenbrock.jl")
include("chained_powel.jl")
include("chained_cragg_levy.jl")

using JSOSolvers, SolverBenchmark


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
  end
  return problem_array
end


println(" \n\n génération des problemes")
# n_array = [100,500,1000,2000,5000,10000]
n_array = [10,20,30,100]
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
  :trunk_sr1 => prob -> JSOSolvers.trunk(NLPModels.LSR1Model(prob), max_time=max_time, atol=atol, rtol=rtol),
  :trunk => prob -> JSOSolvers.trunk(prob, max_time=max_time, atol=atol, rtol=rtol)
  )


#= Lancement du benchmark sur les problèmes générés, sur les solvers défini dans la variable solvers =#
println("lancement des benchmmarks")
stats = bmark_solvers(solvers,problems)

error("fin")

#= Ecriture des résultats dans un fichier au format markdown=#
println("écriture des résultats markdown")
location_md = string("src/comparaison/results/result_bench_md.txt")
io = open(location_md,"w")
close(io)
io = open(location_md,"w+")
keys_solver = keys(stats)
for i in keys_solver
  markdown_table(io,stats[i])
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
  latex_table(io,stats[i])
end
close(io)


println("affichage du profile des solvers par rapport au problèmes")
performance_profile(stats, df->df.elapsed_time)

















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
