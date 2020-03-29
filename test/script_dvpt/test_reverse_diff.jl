using ReverseDiff: GradientTape, GradientConfig, gradient, gradient!, compile

using DiffResults
"""
#########
# setup #
#########

# some objective function to work with
f(a, b) = sum(a' * b + a * b')

# pre-record a GradientTape for `f` using inputs of shape 100x100 with Float64 elements
const f_tape = GradientTape(f, (rand(100, 100), rand(100, 100)))

# compile `f_tape` into a more optimized representation
const compiled_f_tape = compile(f_tape)

# some inputs and work buffers to play around with
a, b = rand(100, 100), rand(100, 100)
inputs = (a, b)
results = (similar(a), similar(b))
all_results = map(DiffResults.GradientResult, results)
cfg = GradientConfig(inputs)

####################
# taking gradients #
####################

# with pre-recorded/compiled tapes (generated in the setup above) #
#-----------------------------------------------------------------#

# this should be the fastest method, and non-allocating
gradient!(results, compiled_f_tape, inputs)

# the same as the above, but in addition to calculating the gradients, the value `f(a, b)`
# is loaded into the the provided `DiffResult` instances (see DiffResults.jl documentation).
gradient!(all_results, compiled_f_tape, inputs)

# this should be the second fastest method, and also non-allocating
gradient!(results, f_tape, inputs)

# you can also make your own function if you want to abstract away the tape
∇f!(results, inputs) = gradient!(results, compiled_f_tape, inputs)

# with a pre-allocated GradientConfig #
#-------------------------------------#
# these methods are more flexible than a pre-recorded tape, but can be
# wasteful since the tape will be re-recorded for every call.

gradient!(results, f, inputs, cfg)

gradient(f, inputs, cfg)

# without a pre-allocated GradientConfig #
#----------------------------------------#
# convenient, but pretty wasteful since it has to allocate the GradientConfig itself

gradient!(results, f, inputs)

gradient(f, inputs)
"""



using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..implementation_expr_tree
using ..M_evaluation_expr_tree
println("\n\n Début script de dvpt\n\n")

n = 10000
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( (x[j] + x[j+1])^3 for j in 1:n-1 ))
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])

obj = MathOptInterface.objective_expr(evaluator)
obj2 = trait_expr_tree.transform_to_expr_tree(obj)
obj3 = trait_expr_tree.transform_to_expr_tree(obj)


x = (α -> α - 50).( (β -> 100 * β).( rand(n) ) )
y = (β -> 100 * β).(rand(n))

# détection de la structure partiellement séparable
SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)
SPS2 = PartiallySeparableStructure.deduct_partially_separable_structure(obj3, n)


f2 = M_evaluation_expr_tree.evaluate_expr_tree(obj2)
# pre-record a GradientTape for `f` using inputs of shape 100x100 with Float64 elements
const f_tape2 = GradientTape(f2, rand(n))

# compile `f_tape` into a more optimized representation
const compiled_f_tape2 = compile(f_tape2)

# some inputs and work buffers to play around with
a2 = rand(n)
inputs2 = a2
results2 = similar(a2)
all_results2 = DiffResults.GradientResult(results2)
cfg = GradientConfig(inputs2)



benchgrad = @benchmark gradient!(results2, compiled_f_tape2, inputs2)
benchgrad2 =  @benchmark M_evaluation_expr_tree.calcul_gradient_expr_tree(obj2, inputs2)

f = (x :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{typeof(inputs2[1])}( Vector{typeof(inputs2[1])}(undef, length(x.used_variable) )) )
grad_x = PartiallySeparableStructure.grad_vector{typeof(inputs2[1])}( f.(SPS2.structure) )
benchgrad3 =  @benchmark PartiallySeparableStructure.evaluate_SPS_gradient!(SPS2,inputs2,grad_x)


using ForwardDiff: GradientConfig, Chunk, gradient!
using ForwardDiff



results3 = similar(inputs2)
cfg10 = ForwardDiff.GradientConfig(f2, x, Chunk{10}());
benchgrad4 =  @benchmark ForwardDiff.gradient!(results3,f2,inputs2,cfg10)
