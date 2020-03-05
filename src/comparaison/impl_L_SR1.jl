module implementation_L_SR1

    using JuMP, MathOptInterface, LinearAlgebra, SparseArrays, NLPModellsjuMP
    using Test, BenchmarkTools, ProfileView, InteractiveUtils, Printf


    # include("../../src/ordered_include.jl")

    using LinearOperators, Krylov

    using ..PartiallySeparableStructure, ..Solver_SPS
    using ..implementation_expr_tree, ..M_evaluation_expr_tree
    using ..trait_expr_tree


    function compute_ratio(x :: AbstractVector{Y}, f_x :: Y, s :: Vector{Y}, obj :: implementation_expr_tree.t_expr_tree, B :: LSR1Operator{Float64}, g :: AbstractVector{Y})  where Y <: Number
        quad_model_s =  f_x + g' * s + 1/2 *  ((B * s)' * s) :: Y
        f_next_x = M_evaluation_expr_tree.evaluate_expr_tree(obj, x+s) :: Y
        num = f_x - f_next_x :: Y
        den = f_x - quad_model_s :: Y
        return num/den :: Y
    end


    function upgrade_TR_LSR1( pk :: Float64, # value of the ratio
                         x_k :: AbstractVector{T}, # actual point
                         s_k :: AbstractVector{T}, # point found at the iteration k
                         g_k :: AbstractVector{T}, # array of element gradient
                         B_k :: LSR1Operator, # SR1 approximation
                         obj :: implementation_expr_tree.t_expr_tree,
                         Δ :: Float64 # radius
                         ) where T <: Number
         η = 1e-3
         η1 =  0.75
         if pk > η
             x_k1 = x_k + s_k
             g_k1 = M_evaluation_expr_tree.calcul_gradient_expr_tree(obj, x_k1)
             y_k = g_k1 - g_k
             push!(B_k, s_k, y_k)
         else
             (x_k1, g_k1) = (x_k, g_k)
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
         return (x_k1, g_k1, Δ)
    end


    function solver_L_SR1(obj :: Expr, n :: Int, x_init :: AbstractVector{T}) where T <: Number
        opB(B) = LinearOperators.LinearOperator( n, n, true, true, x -> B * x )
        x0 = x_init
        work_obj = trait_expr_tree.transform_to_expr_tree(obj)
        g0 = M_evaluation_expr_tree.calcul_gradient_expr_tree(work_obj, x_init)
        B0 = LSR1Operator(n, scaling=true) #scaling=true
        delta0 = 1.0

        (x, g, B, Δ, ϵ) = (x0, g0, B0, delta0, 10^-6 )
        (cpt, mean_rad, mean_rho) = (0, 0, 0)
        while (norm(g,2) > ϵ + n * ϵ^2) && cpt < 1000  # stop condition
            cpt = cpt + 1
            f_xk = M_evaluation_expr_tree.evaluate_expr_tree(work_obj, x)
            g = M_evaluation_expr_tree.calcul_gradient_expr_tree(work_obj, x) :: AbstractVector{T}
            # @show cpt, f_xk, Δ, norm(g,2)
            @printf "%3d %8.1e %7.1e %7.1e  \n" cpt f_xk norm(g,2) Δ



            cg_res = Krylov.cg(opB(B), - g, radius = Δ)
            # @show cg_res
            sk = cg_res[1]  # we compute the potential next point

            (xp, gp, Bp) = (x, g, B) # we save the previous x,g,B

            pk = compute_ratio(x, f_xk, sk, work_obj, B, g) # we compute the ratio
            # (x, g, B, Δ) = upgrade_TR_LSR1(pk, x, sk, g, B, obj, Δ) # we upgrade x,g,B,∆
            (x, g, Δ) = upgrade_TR_LSR1(pk, x, sk, g, B, work_obj, Δ) # we upgrade x,g,B,∆
            # @printf "%3d %8.1e %7.1e %7.1e %8.1e %7.1e \n" cpt f_xk norm(g,2) Δ pk norm(sk,2)
            mean_rad = mean_rad + Δ
            mean_rho = mean_rho + pk
        end
        mean_rad = mean_rad / cpt
        mean_rho = mean_rho / cpt
        return (x, cpt , mean_rho, mean_rad)
    end

# utiliser les fonctions de JuMP.

end #fin du module
