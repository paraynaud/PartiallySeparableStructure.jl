using LinearOperators, LinearAlgebra, Krylov, NLPModels
using Printf


function compute_ratio(x :: AbstractVector{Y}, f_x :: Y, s :: Vector{Y}, nlp :: AbstractNLPModel , B :: AbstractLinearOperator{Y}, g :: AbstractVector{Y})  where Y <: Number
    quad_model_s =  f_x + g' * s + 1/2 * ((B * s )' * s)  :: Y
    f_next_x = NLPModels.obj(nlp, x+s) :: Y
    num = f_x - f_next_x :: Y
    den = f_x - quad_model_s :: Y
    return (num/den, f_next_x) :: Tuple{Y,Y}
end


function upgrade_TR_LO!( pk :: Float64, # value of the ratio
                     x_k :: AbstractVector{T}, # actual point
                     s_k :: AbstractVector{T}, # point found at the iteration k
                     g_k :: AbstractVector{T}, # array of element gradient
                     B_k :: AbstractLinearOperator{T}, # SR1 approximation
                     nlp :: AbstractNLPModel ,
                     Δ :: Float64 # radius
                     ) where T <: Number
     η = 1e-3
     η1 =  0.75
     if pk > η
         x_k .= x_k + s_k
         g_p = Vector{T}(undef,length(g_k))
         g_p .= g_k
         NLPModels.grad!(nlp, x_k, g_k)
         y_k = g_k - g_p
         push!(B_k, s_k, y_k)
     else
     end
     if pk >= η1 #now we update ∆
         if norm(s_k, 2) < 0.8 * Δ
             Δ = Δ
         else
             Δ = 2 * Δ
         end
     elseif pk <= η
         Δ = 1/2 * Δ
     end
     return Δ
end

"""
    solver_L_SR1_Ab_NLP(nlp, B, x0)
solver_L_SR1_Ab_NLP is a optimisation method using Trust region with conjugate gradient. nlp is an AbstractNLPModel, B is an
AbstractLinearOperator and x0 is an AbstractVector reprensenting the initial point of the method. The method return a tuple:
with the final point and the number of iteration performming by the method.
Even if the name suggest LSR1, B can be a BFGS Operator.
"""
function solver_TR_CG_Ab_NLP_LO(nlp :: AbstractNLPModel, B :: AbstractLinearOperator{T}, x_init :: AbstractVector{T}, cpt_max = 1000000) where T <: Number
    η = 1e-3
    n = length(x_init)
    x = Vector{T}(undef,n)
    x .= x_init
    g = Vector{T}(undef,length(x_init))
    g = NLPModels.grad!(nlp, x, g)
    (Δ, ϵ, cpt) = (1.0, 10^-6, 0)
    f_xk = NLPModels.obj(nlp, x)
    @printf "%3d %8.1e %7.1e %7.1e  \n" cpt f_xk norm(g,2) Δ
    n_g_init = norm(g,2)
    while (norm(g,2) > ϵ) && (norm(g,2) > ϵ * n_g_init)  && cpt < cpt_max  # stop condition
        cpt = cpt + 1

        cg_res = Krylov.cg(B, - g, radius = Δ)
        sk = cg_res[1]  # result of the linear system solved by Krylov.cg

        (pk, f_temp) = compute_ratio(x, f_xk, sk, nlp, B, g) # we compute the ratio

        Δ = upgrade_TR_LO!(pk, x, sk, g, B, nlp, Δ) # we upgrade x,g,B,∆

        if  pk > η
            f_xk = f_temp
        end
        if mod(cpt,5000) == 0
            @printf "%3d %8.1e %7.1e %7.1e  \n" cpt f_xk norm(g,2) Δ
        end
    end

    if cpt < cpt_max
        println("\n\n\nNous nous somme arrêté grâce à un point stationnaire !!!\n\n\n")
        println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
        @printf "%3d %8.1e %7.1e %7.1e  \n" cpt f_xk norm(g,2) Δ
    else
        println("\n\n\nNous nous sommes arrêté à cause du nombre d'itération max \n\n\n ")
        println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
        @printf "%3d %8.1e %7.1e %7.1e  \n" cpt f_xk norm(g,2) Δ
    end

    return (x, cpt)
end



using SolverTools
function solver_TR_CG_Ab_NLP_LO_res(nlp :: AbstractNLPModel, B :: AbstractLinearOperator{T}, x_init :: AbstractVector{T}) where T <: Number
    Δt = @timed ((x_final,cpt) = solver_TR_CG_Ab_NLP_LO(nlp, B, x_init))
    status= :unknown
    return GenericExecutionStats(status, nlp,
                           solution = x_final,
                           iter = cpt,  # not quite the number of iterations!
                           primal_feas = norm(NLPModels.grad(nlp, x_final),2),
                           dual_feas = -1,
                           objective = NLPModels.obj(nlp, x_final),
                           elapsed_time = Δt[2],
                          )
end

function solver_TR_CG_Ab_NLP_L_SR1(nlp :: AbstractNLPModel, x_init :: AbstractVector{T}) where T <: Number
    B = LSR1Operator(nlp.meta.nvar, scaling=true) :: LSR1Operator{T} #scaling=true
    return solver_TR_CG_Ab_NLP_LO_res(nlp, B, x_init)
end


my_LSR1(x_init :: AbstractVector{T}) where T <: Number = (nlp -> my_LSR1(nlp,x_init) )
my_LSR1(nlp :: AbstractNLPModel,x_init :: AbstractVector{T}) where T = solver_TR_CG_Ab_NLP_L_SR1(nlp,x_init)
function my_LSR1(nlp :: AbstractNLPModel)
    x :: AbstractVector=copy(nlp.meta.x0)
    my_LSR1(nlp, x)
end


function solver_TR_CG_Ab_NLP_L_BFGS(nlp :: AbstractNLPModel, x_init :: AbstractVector{T}) where T <: Number
    B = LBFGSOperator(nlp.meta.nvar, scaling=true) :: LBFGSOperator{T} #scaling=true
    return solver_TR_CG_Ab_NLP_LO_res(nlp, B, x_init)
end

my_LBFGS(x_init :: AbstractVector{T}) where T <: Number = (nlp -> my_LBFGS(nlp,x_init) )
my_LBFGS(nlp :: AbstractNLPModel,x_init :: AbstractVector{T}) where T <: Number = solver_TR_CG_Ab_NLP_L_BFGS(nlp,x_init)
function my_LBFGS(nlp :: AbstractNLPModel)
    x :: AbstractVector=copy(nlp.meta.x0)
    my_LBFGS(nlp, x)
end
