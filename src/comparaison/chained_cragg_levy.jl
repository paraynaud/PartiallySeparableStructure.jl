using NLPModels, JuMP, MathOptInterface, NLPModelsJuMP

function create_chained_cragg_levy_JuMP_Model(n :: Int)
    m = Model()
    @variable(m, x[1:n])
    @NLobjective(m, Min, sum( exp(x[Integer(2*j-1)])^4 + 100*(x[Integer(2*j)] - x[Integer(2*j+1)])^6 + (tan(x[Integer(2*j)]+1 - x[Integer(2*j+2)]))^4 + x[Integer(2*j-1)]^8 + (x[Integer(2*j+2)]-1)^2 for j in 1:((n-2)/2) ) ) #chained powel
    evaluator = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
    obj = MathOptInterface.objective_expr(evaluator)
    return (m, evaluator,obj)
end


function create_initial_point_chained_cragg_levy(n)
    point_initial = Vector{Float64}(undef, n)
    point_initial[1] = 1.0
    for i in 2:n
        point_initial[i] = 2.0
    end
    return point_initial
end



 (m, evaluator,obj) = create_chained_cragg_levy_JuMP_Model(8)
