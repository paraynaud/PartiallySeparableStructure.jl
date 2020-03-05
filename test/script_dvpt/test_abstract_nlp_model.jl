
module NLP_model_test1
    import NLPModels: increment!
    using NLPModels


    mutable struct NLP_Model1 <: AbstractNLPModel
        meta :: NLPModelMeta
        f :: Float64
        counters :: Counters
    end

    function NLP_Model1(f :: Float64) where T
        meta = NLPModelMeta(1)
        return NLP_Model1(meta, f, Counters())
    end

    function NLPModels.obj(nlp :: NLP_Model1, x :: AbstractVector) where T
        increment!(nlp, :neval_obj)
        res = sum( (y -> nlp.f * y).(x) )
        return Float64(6)
    end

    function NLPModels.grad!(nlp :: NLP_Model1, x :: AbstractVector, gx :: AbstractVector) where T
      increment!(nlp, :neval_grad)
      res = sum( (y -> nlp.f^2 * y).(x) )
      return res
    end

    function NLPModels.hess(nlp :: NLP_Model1, x :: AbstractVector) where T
      increment!(nlp, :neval_hess)
      res = sum( (y -> nlp.f^3 * y).(x) )
      return res :: AbstractVector
    end


    function NLPModels.hprod!(nlp :: NLP_Model1, x :: AbstractVector, v :: Float64, Hv :: AbstractVector; obj_weight=1.0, y=Float64[]) where T
        return 1
    end

    export hprod!

end



module NLP_model_test2
    import NLPModels: increment!
    using NLPModels


    mutable struct NLP_Model2 <: AbstractNLPModel
        meta :: NLPModelMeta
        f :: Tuple{Float64, Float64}
        counters :: Counters
    end

    function NLP_Model2(f :: Tuple{Float64, Float64}) where T
        meta = NLPModelMeta(1)
        return NLP_Model2(meta, f, Counters())
    end

    function NLPModels.obj(nlp :: NLP_Model2, x :: AbstractVector) where T
        increment!(nlp, :neval_obj)
        res =  (y -> nlp.f[1] * y).(x)
        return res :: AbstractVector
    end

    function NLPModels.grad!(nlp :: NLP_Model2, x :: AbstractVector, gx :: AbstractVector) where T
      increment!(nlp, :neval_grad)
      res = sum( (y -> nlp.f[2] * y).(x) )
      return res :: AbstractVector
    end

    function NLPModels.hess(nlp :: NLP_Model2, x :: AbstractVector) where T
      increment!(nlp, :neval_hess)
      return zeros(3,3)
    end

    function NLPModels.hprod!(nlp :: NLP_Model2, x :: AbstractVector, v :: AbstractVector, Hv :: AbstractVector; obj_weight=1.0, y=Float64[]) where T
        return 2
    end


    export hprod!
end


using ..NLP_model_test1, ..NLP_model_test2

using NLPModels

using InteractiveUtils


nlp_m1 = NLP_model_test1.NLP_Model1(5.0)
nlp_m2 = NLP_model_test2.NLP_Model2((5.0,4.0))




function test_ab_nlp(nlp :: AbstractNLPModel)
    x = ones(5)
    res = zeros(5)
    e1 = NLPModels.obj(nlp,x)
    t = 1
    e2 = NLPModels.hprod!(nlp,x,e1,res)
    @show e1, e2
end

test_ab_nlp(nlp_m1)
test_ab_nlp(nlp_m2)
@code_warntype test_ab_nlp(nlp_m1)
@code_warntype test_ab_nlp(nlp_m2)
