using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, InteractiveUtils
using Printf, Dates


include("../../src/ordered_include.jl")

include("chained_wood.jl")
include("rosenbrock.jl")
include("chained_powel.jl")
include("chained_cragg_levy.jl")

using ..PartiallySeparableStructure



n_test = [100, 500, 1000, 2000, 5000]
# n_test = [50000]
# n_test = [ 20000]
n_test = [100, 500]
res_obj = Vector{Any}(undef, length(n_test))
res_JuMP = Vector{Any}(undef, length(n_test))
res_grad_obj = Vector{Any}(undef, length(n_test))
res_grad_JuMP = Vector{Any}(undef, length(n_test))
res_product_obj = Vector{Any}(undef, length(n_test))
res_product_JuMP = Vector{Any}(undef, length(n_test))

for i in 1:length(n_test)
    #= définition des variables et du probleme =#
    n = n_test[i]
    σ = 1e-8*n
    # (m, evaluator, obj_expr) = create_chained_Powel_JuMP_Model(n)
    (m, evaluator, obj_expr) = create_chained_cragg_levy_JuMP_Model(n)
    obj = trait_expr_tree.transform_to_expr_tree(obj_expr)
    SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)

    x = create_initial_point_chained_cragg_levy(n)
    (y -> y + rand(1:10)).(x)

    #= calcul point obj=#
    SPS_tree_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
    JuMP_x = MathOptInterface.eval_objective( evaluator, x)
    @test abs(JuMP_x - SPS_tree_x) < σ

    res_obj[i] = @benchmark PartiallySeparableStructure.evaluate_SPS($SPS, $x)
    res_JuMP[i] = @benchmark MathOptInterface.eval_objective($evaluator, $x)


    #= calcul point grad=#
    f = (y :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(x[1])}(Vector{typeof(x[1])}(zeros(typeof(x[1]), length(y.used_variable)) )) )
    grad_elt = PartiallySeparableStructure.grad_vector{typeof(x[1])}( f.(SPS.structure) )
    grad = Vector{Float64}(zeros(Float64,n))
    PartiallySeparableStructure.evaluate_SPS_gradient!(SPS, x, grad_elt)
    grad = PartiallySeparableStructure.build_gradient(SPS, grad_elt)

    JuMP_gradient = Vector{ typeof(x[1]) }(undef,n)
    MathOptInterface.eval_objective_gradient(evaluator, JuMP_gradient, x)

    @test norm(JuMP_gradient - grad,2) < σ

    res_grad_obj[i] = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!($SPS, $x, $grad_elt)
    res_grad_JuMP[i] = @benchmark MathOptInterface.eval_objective_gradient($evaluator, $JuMP_gradient, $x)



    #= calcul point Hess=#
    MOI_pattern = MathOptInterface.hessian_lagrangian_structure(evaluator)
    column = [x[1] for x in MOI_pattern]
    row = [x[2]  for x in MOI_pattern]
    MOI_value_Hessian = Vector{ typeof(x[1]) }(undef,length(MOI_pattern))
    MathOptInterface.eval_hessian_lagrangian(evaluator, MOI_value_Hessian, x, 1.0, zeros(0))
    values = [x for x in MOI_value_Hessian]
    MOI_half_hessian_en_x = sparse(row,column,values,n,n)
    MOI_hessian_en_x = Symmetric(MOI_half_hessian_en_x)

    f = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{Float64}( Array{Float64,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
    t = f.(SPS.structure) :: Vector{PartiallySeparableStructure.element_hessian{Float64}}
    H = PartiallySeparableStructure.Hess_matrix{Float64}(t)
    PartiallySeparableStructure.struct_hessian!(SPS, x, H)

    res = Vector{typeof(x[1])}(undef,n)
    res_product_JuMP[i] = @benchmark $MOI_hessian_en_x * $x
    res_product_obj[i] = @benchmark PartiallySeparableStructure.product_matrix_sps!($SPS, $H, $x, $res)

end


""" AFFICHE LES R2SULTATS SOUS FORME DE TABLEAUX"""
my_results = [res_obj, res_grad_obj, res_product_obj]
JuMP_results = [res_JuMP, res_grad_JuMP, res_product_JuMP]


repo = "src/comparaison/results/"
io = open(repo * "result_mon_code.txt", "a+")
print(io, "\n\n" * string(Dates.now()) * "\n\n")
Printf.@printf(io, "|%-12s|%-12s|%-12s|%-12s|%-12s|%-12s|%-12s|\n", "size", "time(obj)", "alloc(obj)", "time(gra)", "alloc(grad)", "time(Hv)", "alloc(Hv)")
Printf.@printf(io, "%s\n", "-"^(13*7))
for i in 1:length(n_test)
    Printf.@printf(io, "|%-12d", n_test[i])
    for j in my_results
            Printf.@printf(io, "|%-12.2e|%-12.2e", median(j[i].times)*1e-9, j[i].allocs )
    end
    Printf.@printf(io, "|\n")
end
close(io)

io = open(repo * "result_JuMP.txt", "a+")
print(io, "\n\n" * string(Dates.now()) * "\n\n")
Printf.@printf(io, "|%-12s|%-12s|%-12s|%-12s|%-12s|%-12s|%-12s|\n", "size", "time(obj)", "alloc(obj)", "time(gra)", "alloc(grad)", "time(Hv)", "alloc(Hv)")
Printf.@printf(io, "%s\n", "-"^(13*7))
for i in 1:length(n_test)
    Printf.@printf(io, "|%-12d", n_test[i])
    for j in JuMP_results
            Printf.@printf(io, "|%-12.2e|%-12.2e", median(j[i].times)*1e-9, j[i].allocs )
    end
    Printf.@printf(io, "\n")
end
close(io)

""" AFFICHE LES RESULTATS SOUS FORME DE TABLEAUX LATEX"""

io = open(repo * "result_mon_code.tex", "a+")
print(io, "\n\n" * string(Dates.now()) * "\n\n")
Printf.@printf(io,"\\begin{equation} \n\t\\begin{array}{|c|c|c|c|c|c|c|}\n")
Printf.@printf(io, "\t\t%-12s & %-12s & %-12s & %-12s & %-12s & %-12s & %-12s \\\\ \\hline \n", "size", "time(obj)", "alloc(obj)", "time(gra)", "alloc(grad)", "time(Hv)", "alloc(Hv)")
for i in 1:length(n_test)
    Printf.@printf(io, "\t\t%-12d", n_test[i])
    for j in my_results
            Printf.@printf(io, " & %-12.2e & %-12.2e", median(j[i].times)*1e-9, j[i].allocs )
    end
    Printf.@printf(io, "\\\\ \\hline \n")
end
Printf.@printf(io, "\t\\end{array} \n\\end{equation}")
close(io)


io = open(repo * "result_JuMP.tex", "a+")
print(io, "\n\n" * string(Dates.now()) * "\n\n")
Printf.@printf(io,"\\begin{equation} \n\t\\begin{array}{|c|c|c|c|c|c|c|}\n")
Printf.@printf(io, "\t\t%-12s & %-12s & %-12s & %-12s & %-12s & %-12s & %-12s \\\\ \\hline \n", "size", "time(obj)", "alloc(obj)", "time(gra)", "alloc(grad)", "time(Hv)", "alloc(Hv)")
for i in 1:length(n_test)
    Printf.@printf(io, "\t\t%-12d", n_test[i])
    for j in JuMP_results
            Printf.@printf(io, " & %-12.2e & %-12.2e", median(j[i].times)*1e-9, j[i].allocs )
    end
    Printf.@printf(io, "\\\\ \\hline \n")
end
Printf.@printf(io, "\t\\end{array} \n\\end{equation}")
close(io)







# res_Hess_obj = Vector{Any}(undef, length(n_test))
# res_Hess_JuMP = Vector{Any}(undef, length(n_test))
# b2 = @benchmark MathOptInterface.eval_objective($evaluator, $x)
# b1 = @benchmark PartiallySeparableStructure.evaluate_SPS($SPS, $x)
# b3 = @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!($SPS, $x, $grad_elt)
# b4 = @benchmark MathOptInterface.eval_objective_gradient($evaluator, $JuMP_gradient, $x)
# b5 = @benchmark PartiallySeparableStructure.product_matrix_sps!($SPS, $H, $x, $res)
# b6 = @benchmark $MOI_hessian_en_x * $x
#= ce benchmark s'aver particulièrement lent =#
# res_Hess_obj[i] = @benchmark PartiallySeparableStructure.struct_hessian!($SPS, $x, $H)
# res_Hess_JuMP[i] = @benchmark MathOptInterface.eval_hessian_lagrangian($evaluator, $MOI_value_Hessian, $x, 1.0, zeros(0)
