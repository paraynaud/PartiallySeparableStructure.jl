using JuMP, MathOptInterface
using Test

#Définition d'un modèle JuMP
m = Model()
n = 100
@variable(m, x[1:n])
# @NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
@NLobjective(m, Min, sum( x[j]^2 * x[j+1]^2 for j in 1:n-1 ) + x[1]*5 + sin(x[4]) - (5+x[1])^2 )
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph])
obj = MathOptInterface.objective_expr(evaluator)

#définition d'un premier vecteur d'une valeur aléatoire entre -50 et 50
x = (α -> α - 50).( (β -> 100 * β).(rand(n)) )
y = (β -> 100 * β).(rand(n))

# détection de la structure partiellement séparable
SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj, n)


SPS_en_x = PartiallySeparableStructure.evaluate_SPS( SPS, x)
MOI_obj_en_x = MathOptInterface.eval_objective( evaluator, x)
@show typeof(SPS_en_x) typeof(MOI_obj_en_x), SPS_en_x - MOI_obj_en_x
@test SPS_en_x == MOI_obj_en_x


SPS_en_y = PartiallySeparableStructure.evaluate_SPS( SPS, y)
MOI_obj_en_y = MathOptInterface.eval_objective( evaluator, y)
@show typeof(SPS_en_y) typeof(MOI_obj_en_y), SPS_en_y - MOI_obj_en_y
@test SPS_en_x == MOI_obj_en_x
