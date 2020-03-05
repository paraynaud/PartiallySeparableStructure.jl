module Test_NLP_model
    import NLPModels: increment!
    using NLPModels

    # include("ordered_include.jl")


    using ..PartiallySeparableStructure, ..Solver_SPS

    mutable struct SPS_Model{T,Y <: Number} <: AbstractNLPModel
        meta :: NLPModelMeta
        s_a :: Solver_SPS.struct_algo{T,Y}
        counters :: Counters
    end


    function SPS_Model(obj :: T, n :: Int, t=Float64 :: DataType) where T
        meta = NLPModelMeta(n)
        s_a = Solver_SPS.alloc_struct_algo(obj, n, t)
        return SPS_Model{T,t}(meta, s_a, Counters())
    end


    function NLPModels.obj(nlp :: SPS_Model{T,Y}, x :: AbstractVector{Y}) where T where Y <: Number
        increment!(nlp, :neval_obj)
        result = PartiallySeparableStructure.evaluate_SPS(nlp.s_a.sps, x)
        return result
    end

    function NLPModels.grad!(nlp :: SPS_Model{T,Y}, x :: AbstractVector{Y}, gx :: AbstractVector{Y}) where T where Y <: Number
      increment!(nlp, :neval_grad)

      PartiallySeparableStructure.evaluate_SPS_gradient!(nlp.s_a.sps, nlp.s_a.x_k, nlp.s_a.g_k)
      PartiallySeparableStructure.build_gradient!(nlp.s_a.sps, nlp.s_a.g_k, nlp.s_a.grad_k)
      gx .= nlp.s_a.grad_k
    end

    # function NLPModels.hess(nlp :: SPS_Model{T,Y}, x :: AbstractVector) where T
    #   increment!(nlp, :neval_hess)
    #   return Array(PartiallySeparableStructure.evaluate_hessian(nlp.storage, x ) )
    # end


    function NLPModels.hprod!(nlp :: SPS_Model{T,Y}, x :: AbstractVector{Y}, v :: AbstractVector{Y}, Hv :: AbstractVector{Y}; obj_weight=1.0, y=Float64[]) where T where Y <: Number
        sparse_hessian = struct_hessian(nlp.s_a.sps, x)
        PartiallySeparableStructure.product_matrix_sps!(nlp.s_a.sps, sparse_hessian, v, Hv)
    end

end
