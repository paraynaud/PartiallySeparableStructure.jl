module Solver_SPS


    using LinearOperators, Krylov, LinearAlgebra

    using Printf

    using ..trait_expr_tree, ..implementation_expr_tree
    using ..PartiallySeparableStructure


    mutable struct struct_algo{T,Y <: Number}
        sps :: PartiallySeparableStructure.SPS{T}
        B_k :: PartiallySeparableStructure.Hess_matrix{Y}
        B_k1 :: PartiallySeparableStructure.Hess_matrix{Y}
        g_k :: PartiallySeparableStructure.grad_vector{Y}
        grad_k :: AbstractVector{Y}
        g_k1 :: PartiallySeparableStructure.grad_vector{Y}
        y :: PartiallySeparableStructure.grad_vector{Y}
        grad_y :: AbstractVector{Y}
        x_k :: AbstractVector{Y}
        x_k1 :: AbstractVector{Y}
        f_xk :: Y
        f_xk1 :: Y
        Δ :: Float64
        η :: Float64
        η1 :: Float64
        ϵ :: Float64
    end


    #
    # function alloc_struct_algo(obj_Expr :: Expr, n :: Int, type=Float64 :: DataType )
    #     # transformation de l'Expr donné par JuMP en expr_tree plus rapide à traiter
    #     obj = trait_expr_tree.transform_to_expr_tree(obj_Expr) :: implementation_expr_tree.t_expr_tree
    #
    #     # détéction de la structure partiellement séparable
    #     sps = PartiallySeparableStructure.deduct_partially_separable_structure(obj,n) :: PartiallySeparableStructure.SPS{implementation_expr_tree.t_expr_tree}
    #
    #     # construction des structure de données nécessaire pour le gradient à l'itération k/k+1 et le différence des gradients
    #     construct_element_grad = (y :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{type}(Vector{type}(zeros(type, length(y.used_variable)) )) )
    #     g_k = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
    #     g_k1 = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
    #     y = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
    #
    #     # constructions des structures de données nécessaires pour le Hessien ou son approximation
    #     construct_element_hess = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{type}( Array{type,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
    #     B_k = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))
    #     B_k1 = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))
    #
    #     #définition des 2 points xk et x_k1
    #     x_k = Vector{type}(undef, n)
    #     x_k1 = Vector{type}(undef, n)
    #
    #     #finally a real sized gradient
    #     grad_k = Vector{type}(undef, n)
    #     grad_y = Vector{type}(undef, n)
    #
    #     Δ = 1.0
    #     η = 1e-3
    #     η1 =  0.75
    #     ϵ = 1e-6
    #     # allocation de la structure de donné contenant tout ce dont nous avons besoin pour l'algorithme
    #     algo_struct = struct_algo(sps, B_k, B_k1, g_k, grad_k, g_k1, y, grad_y, x_k, x_k1, (type)(0), (type)(0), Δ, η, η1, ϵ) :: struct_algo{implementation_expr_tree.t_expr_tree, type}
    #
    #     return algo_struct
    # end


    function alloc_struct_algo(obj :: T, n :: Int, type=Float64 :: DataType ) where T

        # détéction de la structure partiellement séparable
        sps = PartiallySeparableStructure.deduct_partially_separable_structure(obj,n) :: PartiallySeparableStructure.SPS{T}

        # construction des structure de données nécessaire pour le gradient à l'itération k/k+1 et le différence des gradients
        construct_element_grad = (y :: PartiallySeparableStructure.element_function{T} -> PartiallySeparableStructure.element_gradient{type}(Vector{type}(zeros(type, length(y.used_variable)) )) )
        g_k = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        g_k1 = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        y = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )

        # constructions des structures de données nécessaires pour le Hessien ou son approximation
        construct_element_hess = ( elm_fun :: PartiallySeparableStructure.element_function{T} -> PartiallySeparableStructure.element_hessian{type}( Array{type,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
        B_k = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))
        B_k1 = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))

        #définition des 2 points xk et x_k1
        x_k = Vector{type}(undef, n)
        x_k1 = Vector{type}(undef, n)

        #finally a real sized gradient
        grad_k = Vector{type}(undef, n)
        grad_y = Vector{type}(undef, n)

        Δ = 1.0
        η = 1e-3
        η1 =  0.75
        ϵ = 1e-6
        # allocation de la structure de donné contenant tout ce dont nous avons besoin pour l'algorithme
        algo_struct = struct_algo(sps, B_k, B_k1, g_k, grad_k, g_k1, y, grad_y, x_k, x_k1, (type)(0), (type)(0), Δ, η, η1, ϵ) :: struct_algo{T, type}

        return algo_struct :: struct_algo{T, type}
    end


    function init_struct_algo!( s_a :: struct_algo{T,Y},
                                x_k :: AbstractVector{Y},
                                x_k1 :: AbstractVector{Y},
                                g_k :: PartiallySeparableStructure.grad_vector{Y},
                                grad_k :: AbstractVector{Y},
                                g_k1 :: PartiallySeparableStructure.grad_vector{Y},
                                y :: PartiallySeparableStructure.grad_vector{Y},
                                grad_y :: AbstractVector{Y},
                                B_k :: PartiallySeparableStructure.Hess_matrix{Y},
                                B_k1 :: PartiallySeparableStructure.Hess_matrix{Y},
                                delta :: Float64,
                                eta :: Float64,
                                eta1 :: Float64,
                                epsilon :: Float64
                                ) where T where Y <: Number

        s_a.x_k = x_k
        s_a.x_k1 = x_k1
        s_a.g_k = g_k
        s_a.grad_k = grad_k
        s_a.g_k1 = g_k1
        s_a.y = y
        s_a.grad_y = grad_y
        s_a.B_k = B_k
        s_a.B_k1 = B_k1
        s_a.f_xk = PartiallySeparableStructure.evaluate_SPS(s_a.sps, x_k)
        s_a.f_xk1 = PartiallySeparableStructure.evaluate_SPS(s_a.sps, x_k1)
        s_a.Δ = delta
        s_a.η = eta
        s_a.η1 = eta1
        s_a.ϵ = epsilon
    end


    function init_struct_algo!( s_a :: struct_algo{T,Y},
                                x_k :: AbstractVector{Y}, x_k1 :: AbstractVector{Y}) where T where Y <: Number
        s_a.x_k = x_k
        s_a.x_k1 = x_k1

        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.x_k, s_a.g_k)
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.g_k, s_a.grad_k)
        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.x_k1, s_a.g_k1)
        PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y)
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.y, s_a.grad_y)
        PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k, s_a.B_k)
        PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k1, s_a.B_k1)
        s_a.f_xk = PartiallySeparableStructure.evaluate_SPS(s_a.sps, x_k)
        s_a.f_xk1 = PartiallySeparableStructure.evaluate_SPS(s_a.sps, x_k1)
        s_a.Δ = 1.0
        s_a.η = 1e-3
        s_a.η1 =  0.75
        s_a.ϵ = 1e-6
    end


    function init_struct_algo!( s_a :: struct_algo{T,Y},
                                x_k :: AbstractVector{Y}) where T where Y <: Number
        s_a.x_k = x_k

        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.x_k, s_a.g_k)
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.g_k, s_a.grad_k)

        PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k, s_a.B_k)

        s_a.f_xk = PartiallySeparableStructure.evaluate_SPS(s_a.sps, x_k)

        s_a.Δ = 1.0
        s_a.η = 1e-3
        s_a.η1 =  0.75
        s_a.ϵ = 1e-6
    end



    function approx_quad(s_a :: struct_algo{T,Y}, x :: AbstractVector{Y}) where T where Y <: Number
        # g = Vector{Y}(zeros(Y,s_a.sps.n_var))
        # PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.g_k, g)
        s_a.f_xk + s_a.grad_k' * x  + PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B_k, x)' * x
    end


    function determine_xk1(s_a :: struct_algo{T,Y}) where T where Y <: Number
        n = s_a.sps.n_var
        opB(B) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s_a.sps, B, x) )
        cg_res = Krylov.cg(opB(s_a.B_k), - s_a.grad_k, radius = s_a.Δ) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        return cg_res :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
    end


    function compute_ratio(s_a :: struct_algo{T,Y}, next_x :: AbstractVector{Y}) where T where Y <: Number
        f_x_k = s_a.f_xk :: Y
        f_next_x = PartiallySeparableStructure.evaluate_SPS(s_a.sps, next_x) :: Y
        num = f_x_k - f_next_x :: Y
        den = f_x_k - approx_quad(s_a, next_x) :: Y
        return (num/den , f_next_x) :: Tuple{Y,Y}
    end


    function change_x_k1_x_k!( s_a :: struct_algo{T,Y} ) where T where Y <: Number
        s_a.x_k = s_a.x_k1
        s_a.g_k = s_a.g_k1
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.g_k, s_a.grad_k)
        s_a.B_k = s_a.B_k1
        s_a.f_xk = s_a.f_xk1
    end


update_xk1!(s_a :: struct_algo{T,Y}) where T where Y <: Number = _update_xk1!(s_a)
    # update_xk1!(s_a :: struct_algo{T,Y}) where T where Y <: Number = _update_xk1!(s_a, trait_expr_tree.is_expr_tree(T))
    # _update_xk1!(s_a :: struct_algo{T,Y}, :: trait_expr_tree.type_expr_tree) where T where Y <: Number = _update_xk1!(s_a)
    # _update_xk1!(s_a :: struct_algo{T,Y}, :: trait_expr_tree.type_not_expr_tree) where T where Y <: Number = error("mal typé")
    function _update_xk1!(s_a :: struct_algo{T,Y}) where T where Y <: Number
        next_x = determine_xk1(s_a) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        (ratio, f_next_x) = compute_ratio(s_a, next_x[1] :: Array{Y,1})
        if ratio > s_a.η
            s_a.x_k1 = next_x[1]
            s_k = s_a.x_k1 - s_a.x_k :: AbstractVector{Y}
            PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.x_k1, s_a.g_k1)
            PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y)
            PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.B_k, s_a.B_k1, s_a.y, s_k) #on obtient notre nouveau B_k1
            s_a.f_xk1 = f_next_x
            println("\n\nOn change de point!!\n\n")
            change_x_k1_x_k!(s_a)
        else
            # changement par référence, la structure ne bouge donc pas
            println("changement par référence, la structure ne bouge donc pas")
        end

        if ratio >= s_a.η1
            if norm(s_k) < 0.8 * s_a.Δ
                # le rayon ne bouge pas
            else
                println("le rayon augmente")
                s_a.Δ = s_a.Δ * 2
            end
        elseif ratio <= s_a.η
            println("le rayon diminue")
            s_a.Δ = 1/2 * s_a.Δ
        end

    end


    function iterations_TR!(s_a :: struct_algo{T,Y}) where T where Y <: Number
        cpt = 1
        g = Vector{Y}(ones(Y, s_a.sps.n_var) )
        # norm_g = (x :: PartiallySeparableStructure.grad_vector{Y} ->  )
        while ( ( norm(g) > s_a.ϵ + s_a.sps.n_var * s_a.ϵ^2 )  &&  cpt < 1000 )
            update_xk1!(s_a)
            # @printf "%3d %8.1e %7.1e %7.1e %8.1e %7.1e \n" cpt s_a.f_xk norm(g,2) s_a.Δ pk norm(sk,2)
            cpt = cpt + 1
            PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.g_k, g)
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.f_xk norm(g,2) s_a.Δ

        end
        #affichage final
        if cpt < 999
            println("\n\n\nNous nous somme arrêté grâce à un point stationnaire !!!\n\n\n")
            println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.f_xk norm(g,2) s_a.Δ
        else
            println("\n\n\nNous nous sommes arrêté à cause du nombre d'itération max \n\n\n ")
            println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.f_xk norm(g,2) s_a.Δ

        end
    end


    solver_TR_SR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number = _solver_TR_SR1!(obj_Expr, n, x_init, trait_expr_tree.is_expr_tree(T), type)
    _solver_TR_SR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_expr_tree, type=Float64 :: DataType) where T where Y <: Number = _solver_TR_SR1!(obj_Expr, n, x_init, type)
    _solver_TR_SR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_not_expr_tree, type=Float64 :: DataType) where T where Y <: Number = error("mal typé")
    function _solver_TR_SR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number
        work_obj = trait_expr_tree.transform_to_expr_tree(obj_Expr) :: implementation_expr_tree.t_expr_tree
        s_a = alloc_struct_algo(work_obj, n :: Int, type :: DataType ) :: struct_algo{implementation_expr_tree.t_expr_tree, type}

        init_struct_algo!(s_a, x_init)

        iterations_TR!(s_a)

        return s_a :: struct_algo{implementation_expr_tree.t_expr_tree, type}
    end


end







# PartiallySeparableStructure.product_matrix_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B, x)
# PartiallySeparableStructure.product_vector_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_vector_sps(s_a.sps, s_a.g, x)
# PartiallySeparableStructure.update_SPS_SR1!(s_a :: struct_algo{T,Y}) where T where Y <: Number = PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.B_k, s_a.B_k1, PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y), s_a.x_k1 - s_a.x_k)
