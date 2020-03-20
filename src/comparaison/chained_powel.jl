using NLPModels, JuMP, MathOptInterface, NLPModelsJuMP

function create_chained_Powel_JuMP_Model(n :: Int)
    m = Model()
    @variable(m, x[1:n])
    @NLobjective(m, Min, sum( (x[Int(2*j-1)] + x[Int(2*j)])^2 + 5*(x[Int(2*j+1)] + x[Int(2*j+2)])^2 + (x[Int(2*j)] - 2 * x[Int(2*j+1)])^4 + 10*(x[Int(2*j-1)] + x[Int(2*j+2)])^4   for j in 1:((n-2)/2) )) #chained powel
    evaluator = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
    obj = MathOptInterface.objective_expr(evaluator)
    return (m, evaluator,obj)
end


function create_initial_point_chained_Powel(n)
    point_initial = Vector{Float64}(undef, n)
    for i in 1:n
        if i <= 4 && mod(i,2) == 1
            point_initial[i] = 3
        elseif i <= 4 && mod(i,2) == 0
            point_initial[i] = -1
        elseif i > 4 && mod(i,2) == 1
            point_initial[i] = 0
        elseif i > 4 && mod(i,2) == 0
            point_initial[i] = 1
        else
            error("bizarre")
        end
    end
    return point_initial
end


(m, evaluator,obj) = create_chained_Powel_JuMP_Model(8)