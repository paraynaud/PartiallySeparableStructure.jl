include("../../src/ordered_include.jl")
module Test_NLP_model
    import NLPModels: increment!
    using NLPModels


    using ..PartiallySeparableStructure

    mutable struct SPS_Model{T} <: AbstractNLPModel
        meta :: NLPModelMeta
        storage :: PartiallySeparableStructure.SPS{T}
        counters :: Counters
    end

    function SPS_Model{T}(obj, n :: Int) where T
        meta = NLPModelMeta(n)
        storage = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)
        return SPS_Model{T}(meta, storage, Counters())
    end

    function NLPModels.obj(nlp :: SPS_Model{T}, x :: AbstractVector) where T
        increment!(nlp, :neval_obj)
        return PartiallySeparableStructure.evaluate_SPS(nlp.storage, x )
    end

    function NLPModels.grad!(nlp :: SPS_Model{T}, x :: AbstractVector, gx :: AbstractVector) where T
      increment!(nlp, :neval_grad)
      return PartiallySeparableStructure.evaluate_gradient(nlp.storage, x )
    end

    function NLPModels.hess(nlp :: SPS_Model{T}, x :: AbstractVector) where T
      increment!(nlp, :neval_hess)
      return Array(PartiallySeparableStructure.evaluate_hessian(nlp.storage, x ) )
    end


    function NLPModels.hprod!(nlp :: SPS_Model{T}, x :: AbstractVector, v :: AbstractVector, Hv :: AbstractVector; obj_weight=1.0, y=Float64[]) where T
        struct_hess = PartiallySeparableStructure.struct_hessian(nlp.storage, x)
        return PartiallySeparableStructure.product_matrix_sps(nlp.storage, struct_hess, v )
    end

end

using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools
using NLPModels
using JSOSolvers

using .Test_NLP_model



n = 1000

m = Model()
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + (x[1]*5)^2 + sin(x[4]) - (5+x[1])^2 + cos(x[6]) + tan(x[7])^2 )
@NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + (5+x[1])^2 )
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
objective = MathOptInterface.objective_expr(evaluator)


nlp_mod = Test_NLP_model.SPS_Model{Expr}(objective, n )
x = (y -> y-50).((x -> 100*x).(rand(n)))
@show NLPModels.obj(nlp_mod, x), MathOptInterface.eval_objective( evaluator, x)

JSOSolvers.trunk(nlp_mod, max_eval=1000, nm_itmax=50)
