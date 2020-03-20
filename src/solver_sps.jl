# include("../../src/ordered_include.jl")
module My_SPS_Model_Module


    using LinearOperators, Krylov, LinearAlgebra

    using Printf

    using ..trait_expr_tree, ..implementation_expr_tree
    using ..PartiallySeparableStructure

    import NLPModels: increment!
    using NLPModels

    @enum indice::Int8 fst=1 snd=2



    #Définition de la structure nécessaire pour mmon algo, c'est une deuxième version
    mutable struct struct_algo{T,Y <: Number}
        #structure partiellement séparable
        sps :: PartiallySeparableStructure.SPS{T}
        #tuple de B
        # tpl_B :: Tuple{PartiallySeparableStructure.Hess_matrix{Y}, PartiallySeparableStructure.Hess_matrix{Y}}
        tpl_B :: Vector{PartiallySeparableStructure.Hess_matrix{Y}}

        #tuple des gradients et la différence entre les gradients y
        # tpl_g :: Tuple{PartiallySeparableStructure.grad_vector{Y}, PartiallySeparableStructure.grad_vector{Y}}
        tpl_g :: Vector{PartiallySeparableStructure.grad_vector{Y}}
        grad :: AbstractVector{Y}
        y :: PartiallySeparableStructure.grad_vector{Y}
        # grad_y :: AbstractVector{Y}

        # tuple de x
        tpl_x :: Vector{Vector{Y}}
        #tuple des fx
        tpl_f :: Vector{Y}

        index :: indice
        #constantes pour l'algo potentiellement à supprimer plus tard
        Δ :: Float64
        η :: Float64
        η₁ :: Float64
        ϵ :: Float64

    end



    function alloc_struct_algo(obj :: T, n :: Int, type=Float64 :: DataType ) where T

        # détéction de la structure partiellement séparable
        sps = PartiallySeparableStructure.deduct_partially_separable_structure(obj,n) :: PartiallySeparableStructure.SPS{T}

        # construction des structure de données nécessaire pour le gradient à l'itération k/k+1 et le différence des gradients
        construct_element_grad = (y :: PartiallySeparableStructure.element_function{T} -> PartiallySeparableStructure.element_gradient{type}(Vector{type}(zeros(type, length(y.used_variable)) )) )
        g_k = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        g_k1 = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        g = Vector{PartiallySeparableStructure.grad_vector{type}}([g_k,g_k1])
        y = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        #finally a real sized gradient
        grad = Vector{type}(undef, n)

        # constructions des structures de données nécessaires pour le Hessien ou son approximation
        construct_element_hess = ( elm_fun :: PartiallySeparableStructure.element_function{T} -> PartiallySeparableStructure.element_hessian{type}( Array{type,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
        B_k = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))
        B_k1 = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))
        B = Vector{PartiallySeparableStructure.Hess_matrix{type}}([B_k, B_k1])

        #définition des 2 points xk et x_k1
        x_k = Vector{type}(undef, n)
        x_k1 = Vector{type}(undef, n)
        x = Vector{Vector{type}}([x_k, x_k1])

        f = Vector{type}([0,0])

        # grad_y = Vector{type}(undef, n)

        index = indice(1)

        Δ = 1.0
        η = 1e-3
        η₁ =  0.75
        ϵ = 1e-6

        # allocation de la structure de donné contenant tout ce dont nous avons besoin pour l'algorithme
        # algo_struct = struct_algo(sps, (B_k, B_k1), (g_k, g_k1), grad_k, y, grad_y, (x_k, x_k1), (type)(0), (type)(0), fst) :: struct_algo{T, type}
        algo_struct = struct_algo(sps, B, g, grad, y, x, f, index, Δ, η, η₁, ϵ) :: struct_algo{T, type}

        return algo_struct :: struct_algo{T, type}
    end


    function init_struct_algo!( s_a :: struct_algo{T,Y},
                                x_k :: AbstractVector{Y}) where T where Y <: Number

        s_a.index = fst
        s_a.tpl_x[Int(s_a.index)] = x_k

        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.tpl_x[Int(s_a.index)], s_a.tpl_g[Int(s_a.index)])
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.tpl_g[Int(s_a.index)], s_a.grad)

        # PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k, s_a.B_k)
        PartiallySeparableStructure.id_hessian!(s_a.sps, s_a.tpl_B[Int(s_a.index)])

        s_a.tpl_f[Int(s_a.index)] = PartiallySeparableStructure.evaluate_SPS(s_a.sps, s_a.tpl_x[Int(s_a.index)])

    end



    function other_index( s_a :: struct_algo{T,Y}) where T where Y <: Number
        if s_a.index == fst
            return snd :: indice
        else
            return fst :: indice
        end
    end



    function approx_quad(s_a :: struct_algo{T,Y}, x :: AbstractVector{Y}) where T where Y <: Number
        s_a.tpl_f[Int(s_a.index)] + s_a.grad' * x  +  1/2 *  PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.tpl_B[Int(s_a.index)], x)' * x
    end


    function compute_ratio(s_a :: struct_algo{T,Y}, s_k :: AbstractVector{Y}) where T where Y <: Number
        fxₖ = s_a.tpl_f[Int(s_a.index)] :: Y
        fxₖ₊₁ = PartiallySeparableStructure.evaluate_SPS(s_a.sps, s_a.tpl_x[Int(s_a.index)] + s_k) :: Y
        quadratic_approximation = approx_quad(s_a, s_k) :: Y
        num = fxₖ - fxₖ₊₁ :: Y
        den = fxₖ - quadratic_approximation :: Y
        ρₖ = num/den :: Y
        return (ρₖ, fxₖ₊₁) :: Tuple{Y,Y}
    end


    function update_xk1!(s_a :: struct_algo{T,Y}, B :: LinearOperator{Y}) where T where Y <: Number
        (s_k, info) = Krylov.cg(B, - s_a.grad, radius = s_a.Δ) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        (ρₖ, fxₖ₊₁) = compute_ratio(s_a, s_k :: Vector{Y})
        # println("norme de s_k: ", norm(s_k, 2), "  ρₖ: ", ρₖ)
        if ρₖ > s_a.η
            s_a.index = other_index(s_a)
            s_a.tpl_f[Int(s_a.index)] = fxₖ₊₁
            s_a.tpl_x[Int(s_a.index)] = s_a.tpl_x[Int(other_index(s_a))] + s_k

            PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.tpl_x[Int(s_a.index)], s_a.tpl_g[Int(s_a.index)])
            PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.tpl_g[Int(s_a.index)], s_a.grad)
            PartiallySeparableStructure.minus_grad_vec!(s_a.tpl_g[Int(s_a.index)], s_a.tpl_g[Int(other_index(s_a))], s_a.y)

            PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.tpl_B[Int(other_index(s_a))], s_a.tpl_B[Int(s_a.index)], s_a.y, s_k) #on obtient notre nouveau B_k
        else
            # println("changement par référence, la structure ne bouge donc pas")
        end

        if ρₖ >= s_a.η₁
            if norm(s_k) < 0.8 * s_a.Δ
                # println("le rayon ne bouge pas les conditions sur la norme ne sont pas satisfaites")
            else
                # println("le rayon augmente")
                s_a.Δ = s_a.Δ * 2
            end
        elseif ρₖ <= s_a.η
            # println("le rayon diminue")
            s_a.Δ = 1/2 * s_a.Δ
        else
            # println("le rayon ne bouge pas")
        end

    end


    #fonction traitant le coeur de l'algorithme, réalise principalement la boucle qui incrémente un compteur et met à jour la structure d'algo par effet de bord
    # De plus on effectue tous les affichage par itération dans cette fonction raison des printf
    function iterations_TR!(s_a :: struct_algo{T,Y}) where T where Y <: Number
        cpt_max = 200000
        cpt = 1 :: Int64
        n = s_a.sps.n_var
        # opB(s_a) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.tpl_B[s_a.index], x) )
        opB(s :: struct_algo{T,Y}) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s.sps, s.tpl_B[Int(s.index)], x) ) :: LinearOperator{Y}
        @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)] norm(s_a.grad,2) s_a.Δ
        b = true
        while ( ( norm(s_a.grad) > s_a.ϵ + s_a.sps.n_var * s_a.ϵ^2 )  &&  cpt < cpt_max )
            b = update_xk1!(s_a, opB(s_a))
            cpt = cpt + 1
            if b == false
                return cpt
            end
            if mod(cpt,500) == 0
                @printf "\n%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)] norm(s_a.grad,2) s_a.Δ
            end

        end

        if cpt < cpt_max
            println("\n\n\nNous nous somme arrêté grâce à un point stationnaire !!!")
            println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)]  norm(s_a.grad,2) s_a.Δ
        else
            println("\n\n\nNous nous sommes arrêté à cause du nombre d'itération max ")
            println("cpt,\tf_xk,\tnorm de g,\trayon ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)]  norm(s_a.grad,2) s_a.Δ
        end

        return cpt
    end


    solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number = _solver_TR_PSR1!(obj_Expr, n, x_init, trait_expr_tree.is_expr_tree(T), type)
    _solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_expr_tree, type=Float64 :: DataType) where T where Y <: Number = _solver_TR_PSR1!(obj_Expr, n, x_init, type)
    _solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_not_expr_tree, type=Float64 :: DataType) where T where Y <: Number = error("mal typé")
    function _solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number
        work_obj = trait_expr_tree.transform_to_expr_tree(obj_Expr) :: implementation_expr_tree.t_expr_tree
        s_a = alloc_struct_algo(work_obj, n :: Int, type :: DataType ) :: struct_algo{implementation_expr_tree.t_expr_tree, type}

        init_struct_algo!(s_a, x_init)

        cpt = iterations_TR!(s_a)

        return (cpt,s_a) :: Tuple{Int64,struct_algo{implementation_expr_tree.t_expr_tree, type}}
    end



end



# PartiallySeparableStructure.product_matrix_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B, x)
# PartiallySeparableStructure.product_vector_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_vector_sps(s_a.sps, s_a.g, x)
# PartiallySeparableStructure.update_SPS_SR1!(s_a :: struct_algo{T,Y}) where T where Y <: Number = PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.B_k, s_a.B_k1, PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y), s_a.x_k1 - s_a.x_k)
