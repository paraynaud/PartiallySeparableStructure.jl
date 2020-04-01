include("../ordered_include.jl")

include("chained_wood.jl")
include("rosenbrock.jl")
include("chained_powel.jl")
include("chained_cragg_levy.jl")

using ..My_SPS_Model_Module

using JSOSolvers


using ProfileView
#partie pour rosenbrock
# n_array = [100,500,1000, 2000, 3000, 5000, 10000]
n_array = [100,200,300]
#
i=1000
(m,evaluator,obj) = create_Rosenbrock_JuMP_Model(i)
println("fin de la définition du modèle JuMP")
initial_point = create_initial_point_Rosenbrock(i)
# valp, tp, bytesp, gctimep, memallocsp = @timed My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
# @show tp
My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
@profview My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
error("fin anticipé")


io_ros_p = open("src/comparaison/results/rosenbrock_p.txt","w")
close(io_ros_p)
io_ros_l = open("src/comparaison/results/rosenbrock_l.txt","w")
close(io_ros_l)
res=0
for i in n_array
    println(" \n\n nouveau modèle rosenbrock à ", i, " variables")
    (m,evaluator,obj) = create_Rosenbrock_JuMP_Model(i)
    println("fin de la définition du modèle JuMP")
    initial_point = create_initial_point_Rosenbrock(i)
    println("fin de la définition du point iniitial")


    valp, tp, bytesp, gctimep, memallocsp = @timed My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
    fxp = MathOptInterface.eval_objective(evaluator, valp[2].tpl_x[Int(valp[2].index)])
    io_ros_p = open("src/comparaison/results/rosenbrock_p.txt","a")
    @printf(io_ros_p, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, valp[1], fxp, tp, gctimep,  memallocsp.allocd )
    # println(io_ros_p, i,"\t&\t", valp[1],"\t&\t", tp,"\t&\t", gctimep,"\t&\t", memallocsp.allocd)
    close(io_ros_p)


    nlp = MathOptNLPModel(m)
    # B = LSR1Operator(i, scaling=true) :: LSR1Operator{Float64} #scaling=true
    # vall, tl, bytesl, gctimel, memallocsl = @timed solver_L_SR1_Ab_NLP(nlp, B, initial_point)
    # fxl = MathOptInterface.eval_objective(evaluator, vall[1])
    # io_ros_l = open("src/comparaison/results/rosenbrock_l.txt","a")
    # @printf(io_ros_l, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, vall[2], fxl, tl, gctimel,  memallocsl.allocd )
    # # println(io_ros_l, i,"\t&\t", vall[2],"\t&\t", tl,"\t&\t", gctimel,"\t&\t", memallocsl.allocd)
    # close(io_ros_l)

    # nlp.meta.x0 = copy(initial_point)
    @show JSOSolvers.trunk(nlp,x = initial_point, max_eval=20000, nm_itmax=20000)
end

error("fin test trunk")

# println("fin de la boucle")

# n_array = [100,500,1000, 2000, 3000, 5000, 10000, 20000, 100000]

io_chwoo_p = open("src/comparaison/results/chained_wood_p.txt","w")
io_chwoo_l = open("src/comparaison/results/chained_wood_l.txt","w")
close(io_chwoo_p)
close(io_chwoo_l)

for i in n_array
    println(" \n\n nouveau modèle chained wood à ", i, " variables")
    (m,evaluator,obj) = create_chained_wood_JuMP_Model(i)
    println("fin de la définition du modèle JuMP")
    initial_point = create_initial_point_chained_wood(i)
    println("fin de la définition du point iniitial")


    valp, tp, bytesp, gctimep, memallocsp = @timed My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
    # println(io_chwoo_p, i, "\t&\t", valp[1],"\t&\t", tp, "\t&\t", gctimep,"\t&\t", memallocsp.allocd)
    fxp = MathOptInterface.eval_objective(evaluator, valp[2].tpl_x[Int(valp[2].index)])
    io_chwoo_p = open("src/comparaison/results/chained_wood_p.txt","a")
    @printf(io_chwoo_p, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, valp[1], fxp, tp, gctimep,  memallocsp.allocd )
    close(io_chwoo_p)

    nlp = MathOptNLPModel(m)
    B = LSR1Operator(i, scaling=true) :: LSR1Operator{Float64} #scaling=true
    vall, tl, bytesl, gctimel, memallocsl = @timed solver_L_SR1_Ab_NLP(nlp, B, initial_point)
    fxl = MathOptInterface.eval_objective(evaluator, vall[1])
    # println(io_chwoo_l, i,"\t&\t", vall[2],"\t&\t", tl,"\t&\t", gctimel,"\t&\t", memallocsl.allocd)
    io_chwoo_l = open("src/comparaison/results/chained_wood_l.txt","a")
    @printf(io_chwoo_l, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, vall[2], fxl, tl, gctimel,  memallocsl.allocd )
    close(io_chwoo_l)
end


io_chpow_p = open("src/comparaison/results/chained_powel_p.txt","w")
io_chpow_l = open("src/comparaison/results/chained_powel_l.txt","w")
close(io_chpow_p)
close(io_chpow_l)

for i in n_array
    println(" \n\n nouveau modèle chained powel à ", i, " variables")
    (m,evaluator,obj) = create_chained_Powel_JuMP_Model(i)
    println("fin de la définition du modèle JuMP")
    initial_point = create_initial_point_chained_Powel(i)
    println("fin de la définition du point iniitial")


    valp, tp, bytesp, gctimep, memallocsp = @timed My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
    # println(io_chwoo_p, i, "\t&\t", valp[1],"\t&\t", tp, "\t&\t", gctimep,"\t&\t", memallocsp.allocd)
    fxp = MathOptInterface.eval_objective(evaluator, valp[2].tpl_x[Int(valp[2].index)])
    io_chpow_p = open("src/comparaison/results/chained_powel_p.txt","a")
    @printf(io_chpow_p, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, valp[1], fxp, tp, gctimep,  memallocsp.allocd )
    close(io_chpow_p)

    nlp = MathOptNLPModel(m)
    B = LSR1Operator(i, scaling=true) :: LSR1Operator{Float64} #scaling=true
    vall, tl, bytesl, gctimel, memallocsl = @timed solver_L_SR1_Ab_NLP(nlp, B, initial_point)
    # println(io_chwoo_l, i,"\t&\t", vall[2],"\t&\t", tl,"\t&\t", gctimel,"\t&\t", memallocsl.allocd)
    fxl = MathOptInterface.eval_objective(evaluator, vall[1])
    # println(io_chwoo_l, i,"\t&\t", vall[2],"\t&\t", tl,"\t&\t", gctimel,"\t&\t", memallocsl.allocd)
    io_chpow_l = open("src/comparaison/results/chained_powel_l.txt","a")
    @printf(io_chpow_l, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, vall[2], fxl, tl, gctimel,  memallocsl.allocd )
    close(io_chpow_l)
end

io_chcrag_levy_p = open("src/comparaison/results/chained_cragg_levy_p.txt","w")
io_chcrag_levy_l = open("src/comparaison/results/chained_cragg_levy_l.txt","w")
close(io_chcrag_levy_p)
close(io_chcrag_levy_l)

for i in n_array
    println(" \n\n nouveau modèle chained cragg levy à ", i, " variables")
    (m,evaluator,obj) = create_chained_cragg_levy_JuMP_Model(i)
    println("fin de la définition du modèle JuMP")
    initial_point = create_initial_point_chained_cragg_levy(i)
    println("fin de la définition du point iniitial")


    valp, tp, bytesp, gctimep, memallocsp = @timed My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
    fxp = MathOptInterface.eval_objective(evaluator, valp[2].tpl_x[Int(valp[2].index)])
    io_chcrag_levy_p = open("src/comparaison/results/chained_cragg_levy_p.txt","a")
    @printf(io_chcrag_levy_p, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, valp[1], fxp, tp, gctimep,  memallocsp.allocd )
    close(io_chcrag_levy_p)

    nlp = MathOptNLPModel(m)
    B = LSR1Operator(i, scaling=true) :: LSR1Operator{Float64} #scaling=true
    vall, tl, bytesl, gctimel, memallocsl = @timed solver_L_SR1_Ab_NLP(nlp, B, initial_point)
    fxl = MathOptInterface.eval_objective(evaluator, vall[1])
    io_chcrag_levy_l = open("src/comparaison/results/chained_cragg_levy_l.txt","a")
    @printf(io_chcrag_levy_l, "%3d \t&\t%3d \t&\t%8.1e \t&\t%8.1e \t&\t%7.1e \t&\t%7.1e \n", i, vall[2], fxl, tl, gctimel,  memallocsl.allocd )
    close(io_chcrag_levy_l)
end





# val, t, bytes, gctime, memallocs = @timed  My_SPS_Model_Module.solver_TR_PSR1!(obj, i, initial_point)
# println("\nla valeur de la fonction au point initial est ", MathOptInterface.eval_objective(evaluator, initial_point))
# println("Pour la méthode PSR1 on a fait ", cpt, " itérations pour trouver une valeur de fonction objectif de ",0 MathOptInterface.eval_objective(evaluator, s.tpl_x[Int(s.index)]), " en ",  t1, " secondes et donc une moyenne de ", t1/cpt, "seconde par itérations")
# println("Pour la méthode LSR1 on a fait ", cpt2, " itérations pour trouver une valeur de fonction objectif de ", MathOptInterface.eval_objective(evaluator, x_f), " en ",  t2, " secondes et donc une moyenne de ", t2/cpt2, "seconde par itérations")
# println("le rapport iteration PSR1/iteration LSR1 est ", (t1/cpt)/(t2/cpt2))
