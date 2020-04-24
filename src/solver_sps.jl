# include("../../src/ordered_include.jl")
module My_SPS_Model_Module


    using LinearOperators, Krylov, LinearAlgebra

    using Printf

    using ..trait_expr_tree, ..implementation_expr_tree
    using ..PartiallySeparableStructure

    import NLPModels: increment!
    using NLPModels

    using SolverTools
    using NLPModelsJuMP, JuMP, MathOptInterface

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


"""
    alloc_struct_algo(obj, n, type)
Alloc the structure needed for the whole Trust Region algorithm, which include the gradients vectors and Hessian approximations,
the vectors to store the points xₖ and xₖ₋₁, some constants Δ, η... and the Partially separable structure of the obj function.
"""
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


    function init_gradient_compiled_reverse()

    end

"""
    init_struct_algo(struct_algo, x )
Once the structure is allocated, we can use init_struct to init the structure struct_algo at the point x, which is the initial point
of the algorithm.
When the initialisation is done we can start the algorithme.
"""
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

"""
    other_index(i)
 i ∈ {1,2}. We use a trick to avoid useless copy of gradients and Hessians in the structure of the algorithm. So we need and index
 in the structure of the algorithm. The function other_index return the other index.
 The index is an enumerate type.
 If the index is currently to 1 (fst) in the structure s_a then other_index(s_a) return 2 (snd), and in the other case return 1  (fst)
"""
    function other_index( s_a :: struct_algo{T,Y}) where T where Y <: Number
        if s_a.index == fst
            return snd :: indice
        else
            return fst :: indice
        end
    end


"""
    approx_quad(struct_algo, pₖ   )
return the quadratic approximation m(pₖ) = fₖ + gₖᵀpₖ + 1/2.pₖᵀBpₖ. The values of  fₖ, gₖ and Bₖ are stored inside struct_algo.
"""
    function approx_quad(s_a :: struct_algo{T,Y}, x :: AbstractVector{Y}) where T where Y <: Number
        s_a.tpl_f[Int(s_a.index)] + s_a.grad' * x  +  1/2 *  PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.tpl_B[Int(s_a.index)], x)' * x
    end

"""
    compute_ratio(struct_algo, sₖ )
Compute the ratio :   (fₖ - fₖ₊₁)/(mₖ(0)-mₖ(sₖ)) , all the data about fₖ, mₖ is stored in struct_algo
"""
    function compute_ratio(s_a :: struct_algo{T,Y}, s_k :: AbstractVector{Y}) where T where Y <: Number
        fxₖ = s_a.tpl_f[Int(s_a.index)] :: Y
        fxₖ₊₁ = PartiallySeparableStructure.evaluate_SPS(s_a.sps, s_a.tpl_x[Int(s_a.index)] + s_k) :: Y
        quadratic_approximation = approx_quad(s_a, s_k) :: Y
        num = fxₖ - fxₖ₊₁ :: Y
        den = fxₖ - quadratic_approximation :: Y
        ρₖ = num/den :: Y
        return (ρₖ, fxₖ₊₁) :: Tuple{Y,Y}
    end


#=
FIN DE LA PARTIE COMMUNE
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
P-SR1
=#

"""
    update_PSR1!(struct_algo, B)
This function perform a step of a Trust-Region method using a conjuguate-gragient method to solve the sub-problem of the Trust-Region.
B is the LinearOperator needed by the cg (conjuguate-gragient method). struct_algo stored all the data relative to the problem and is modified if step is taken .
"""
    function update_PSR1!(s_a :: struct_algo{T,Y}, B :: LinearOperator{Y}) where T where Y <: Number
        # atol = sqrt(eps(Float64))
        # rtol = sqrt(eps(Float64))
        # (s_k, info) = Krylov.cg(B, - s_a.grad, atol=atol, rtol=rtol, radius = s_a.Δ, itmax=max(2*s_a.sps.n_var,50)) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        (s_k, info) = Krylov.cg(B, - s_a.grad, radius = s_a.Δ) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        (ρₖ, fxₖ₊₁) = compute_ratio(s_a, s_k :: Vector{Y})
        if ρₖ > s_a.η #= on accepte le nouveau point =#
            s_a.index = other_index(s_a)
            s_a.tpl_f[Int(s_a.index)] = fxₖ₊₁
            s_a.tpl_x[Int(s_a.index)] = s_a.tpl_x[Int(other_index(s_a))] + s_k

            PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.tpl_x[Int(s_a.index)], s_a.tpl_g[Int(s_a.index)])
            PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.tpl_g[Int(s_a.index)], s_a.grad)
            PartiallySeparableStructure.minus_grad_vec!(s_a.tpl_g[Int(s_a.index)], s_a.tpl_g[Int(other_index(s_a))], s_a.y)

            PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.tpl_B[Int(other_index(s_a))], s_a.tpl_B[Int(s_a.index)], s_a.y, s_k) #on obtient notre nouveau B_k
        else #= println("changement par référence, la structure ne bouge donc pas") =#
        end

        if ρₖ >= s_a.η₁
            if norm(s_k) < 0.8 * s_a.Δ #= le rayon ne bouge pas les conditions sur la norme ne sont pas satisfaites =#
                s_a.Δ = s_a.Δ
            else   #= le rayon augmenter=#
                s_a.Δ = s_a.Δ * 2
            end
        elseif ρₖ <= s_a.η  #=le rayon diminue=#
            s_a.Δ = 1/2 * s_a.Δ
        else  #= cas ou nous faisons ni une bonne ni une mauvais approximation=#
            s_a.Δ = s_a.Δ
        end
        # @show norm( PartiallySeparableStructure.product_matrix_sps(s_a.sps,s_a.tpl_B[Int(s_a.index)], s_a.tpl_x[Int(s_a.index)]) - s_a.grad,2)
        # y_entier = PartiallySeparableStructure.build_gradient(s_a.sps, s_a.y)
        # @show norm( PartiallySeparableStructure.product_matrix_sps(s_a.sps,s_a.tpl_B[Int(s_a.index)], s_k) - y_entier,2)

    end


    #fonction traitant le coeur de l'algorithme, réalise principalement la boucle qui incrémente un compteur et met à jour la structure d'algo par effet de bord
    # De plus on effectue tous les affichage par itération dans cette fonction raison des printf
    function iterations_TR!(s_a :: struct_algo{T,Y}, cpt_max = 200000) where T where Y <: Number
        cpt = 1 :: Int64
        n = s_a.sps.n_var
        # opB(s_a) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.tpl_B[s_a.index], x) )
        opB(s :: struct_algo{T,Y}) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s.sps, s.tpl_B[Int(s.index)], x) ) :: LinearOperator{Y}
        @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)] norm(s_a.grad,2) s_a.Δ
        n_g_init = norm(s_a.grad,2)
        while ( (norm(s_a.grad,2) > s_a.ϵ ) && (norm(s_a.grad,2) > s_a.ϵ * n_g_init)  &&  cpt < cpt_max )
            update_PSR1!(s_a, opB(s_a))
            cpt = cpt + 1
            if mod(cpt,500) == 0
                @printf "\n%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)] norm(s_a.grad,2) s_a.Δ
            end

        end

        if cpt < cpt_max
            println("\n\n\nNous nous somme arrêté grâce à un point stationnaire !!!")
            println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n\n\n" cpt s_a.tpl_f[Int(s_a.index)]  norm(s_a.grad,2) s_a.Δ
        else
            println("\n\n\nNous nous sommes arrêté à cause du nombre d'itération max ")
            println("cpt,\tf_xk,\tnorm de g,\trayon ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n\n\n" cpt s_a.tpl_f[Int(s_a.index)]  norm(s_a.grad,2) s_a.Δ
        end

        return cpt
    end



"""
    solver_TR_PSR1!(p)
Trust region method using the gradient conjugate method and the Partially Separable Structure of the problem of the parameters. This method use
SR1 approximation.
"""
    solver_TR_PSR1!(m :: T; x=Vector{Y}(undef,0) ) where T <: AbstractNLPModel where Y <: Number = _solver_TR_PSR1!(m,x=x )
    solver_TR_PSR1!(m :: T ) where T <: AbstractNLPModel = _solver_TR_PSR1!(m)
    solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number = _solver_TR_PSR1!(obj_Expr, n, x_init, trait_expr_tree.is_expr_tree(T), type)
    _solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_expr_tree, type=Float64 :: DataType) where T where Y <: Number = _solver_TR_PSR1!(obj_Expr, n, x_init, type)
    _solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_not_expr_tree, type=Float64 :: DataType) where T where Y <: Number = error("mal typé")
    function _solver_TR_PSR1!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number
        work_obj = trait_expr_tree.transform_to_expr_tree(obj_Expr) :: implementation_expr_tree.t_expr_tree
        s_a = alloc_struct_algo(work_obj, n :: Int, type :: DataType ) :: struct_algo{implementation_expr_tree.t_expr_tree, type}
        init_struct_algo!(s_a, x_init)

        cpt = iterations_TR!(s_a)

        x_final = s_a.tpl_x[Int(s_a.index)]
        return (x_final, s_a, cpt) :: Tuple{Vector{Y}, struct_algo{implementation_expr_tree.t_expr_tree, type}, Int}
    end

    function _solver_TR_PSR1_2!(m :: Z, obj_Expr :: T, n :: Int, type:: DataType, x_init :: AbstractVector{Y}) where T where Y where Z <: AbstractNLPModel
        Δt = @timed ((x_final, s_a, cpt) = solver_TR_PSR1!(obj_Expr, n, x_init, type))
        status= :unknown
        return GenericExecutionStats(status, m,
                               solution = x_final,
                               iter = cpt,  # not quite the number of iterations!
                               primal_feas = norm(NLPModels.grad(m, x_final),2),
                               dual_feas = -1,
                               objective = NLPModels.obj(m, x_final),
                               elapsed_time = Δt[2],
                              )
    end

    function _solver_TR_PSR1!( model_JUMP :: T; x= Vector{Y}(undef,0)) where T <: AbstractNLPModel where Y <: Number

        model = model_JUMP.eval.m
        evaluator = JuMP.NLPEvaluator(model)
        MathOptInterface.initialize(evaluator, [:ExprGraph])
        obj_Expr = MathOptInterface.objective_expr(evaluator) :: Expr
        n = model.moi_backend.model_cache.model.num_variables_created
        if isempty(x)
            x0 :: AbstractVector=copy(model_JUMP.meta.x0)
        else
            x0 = copy(x)
        end
        _solver_TR_PSR1_2!(model_JUMP, obj_Expr, n, typeof(x0[1]), x0)
    end



#=
FIN DE P-SR1
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
P-BFGS
=#




"""
    update_PBGS!(struct_algo, B)
This function perform a step of a Trust-Region method using a conjuguate-gragient method to solve the sub-problem of the Trust-Region.
B is the LinearOperator needed by the cg (conjuguate-gragient method). struct_algo stored all the data relative to the problem and is modified if step is taken .
"""
    function update_PBGS!(s_a :: struct_algo{T,Y}, B :: LinearOperator{Y}) where T where Y <: Number
        # atol = sqrt(eps(Float64))
        # rtol = sqrt(eps(Float64))
        # (s_k, info) = Krylov.cg(B, - s_a.grad, atol=atol, rtol=rtol, radius = s_a.Δ, itmax=max(2*s_a.sps.n_var,50)) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        (s_k, info) = Krylov.cg(B, - s_a.grad, radius = s_a.Δ) :: Tuple{Array{Y,1},Krylov.SimpleStats{Y}}
        (ρₖ, fxₖ₊₁) = compute_ratio(s_a, s_k :: Vector{Y})
        if ρₖ > s_a.η #= on accepte le nouveau point =#
            s_a.index = other_index(s_a)
            s_a.tpl_f[Int(s_a.index)] = fxₖ₊₁
            s_a.tpl_x[Int(s_a.index)] = s_a.tpl_x[Int(other_index(s_a))] + s_k

            PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.tpl_x[Int(s_a.index)], s_a.tpl_g[Int(s_a.index)])
            PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.tpl_g[Int(s_a.index)], s_a.grad)
            PartiallySeparableStructure.minus_grad_vec!(s_a.tpl_g[Int(s_a.index)], s_a.tpl_g[Int(other_index(s_a))], s_a.y)

            PartiallySeparableStructure.update_SPS_BFGS!(s_a.sps, s_a.tpl_B[Int(other_index(s_a))], s_a.tpl_B[Int(s_a.index)], s_a.y, s_k) #on obtient notre nouveau B_k
        else #= println("changement par référence, la structure ne bouge donc pas") =#
        end

        if ρₖ >= s_a.η₁
            if norm(s_k) < 0.8 * s_a.Δ #= le rayon ne bouge pas les conditions sur la norme ne sont pas satisfaites =#
                s_a.Δ = s_a.Δ
            else   #= le rayon augmenter=#
                s_a.Δ = s_a.Δ * 2
            end
        elseif ρₖ <= s_a.η  #=le rayon diminue=#
            s_a.Δ = 1/2 * s_a.Δ
        else  #= cas ou nous faisons ni une bonne ni une mauvais approximation=#
            s_a.Δ = s_a.Δ
        end
        # @show norm( PartiallySeparableStructure.product_matrix_sps(s_a.sps,s_a.tpl_B[Int(s_a.index)], s_a.tpl_x[Int(s_a.index)]) - s_a.grad,2)
        # y_entier = PartiallySeparableStructure.build_gradient(s_a.sps, s_a.y)
        # @show norm( PartiallySeparableStructure.product_matrix_sps(s_a.sps,s_a.tpl_B[Int(s_a.index)], s_k) - y_entier,2)
    end


    #fonction traitant le coeur de l'algorithme, réalise principalement la boucle qui incrémente un compteur et met à jour la structure d'algo par effet de bord
    # De plus on effectue tous les affichage par itération dans cette fonction raison des printf
    function iterations_TR_PBGFS!(s_a :: struct_algo{T,Y}, cpt_max = 200000) where T where Y <: Number
        cpt = 1 :: Int64
        n = s_a.sps.n_var
        # opB(s_a) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.tpl_B[s_a.index], x) )
        opB(s :: struct_algo{T,Y}) = LinearOperators.LinearOperator(n, n, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s.sps, s.tpl_B[Int(s.index)], x) ) :: LinearOperator{Y}
        @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)] norm(s_a.grad,2) s_a.Δ
        n_g_init = norm(s_a.grad,2)
        while ( (norm(s_a.grad,2) > s_a.ϵ ) && (norm(s_a.grad,2) > s_a.ϵ * n_g_init)  &&  cpt < cpt_max )
            update_PBGS!(s_a, opB(s_a))
            cpt = cpt + 1
            if mod(cpt,500) == 0
                @printf "\n%3d \t%8.1e \t%7.1e \t%7.1e \n" cpt s_a.tpl_f[Int(s_a.index)] norm(s_a.grad,2) s_a.Δ
            end

        end

        if cpt < cpt_max
            println("\n\n\nNous nous somme arrêté grâce à un point stationnaire !!!")
            println("cpt,\tf_xk,\tnorm de g,\trayon puis x en dessous ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n\n\n" cpt s_a.tpl_f[Int(s_a.index)]  norm(s_a.grad,2) s_a.Δ
        else
            println("\n\n\nNous nous sommes arrêté à cause du nombre d'itération max ")
            println("cpt,\tf_xk,\tnorm de g,\trayon ")
            @printf "%3d \t%8.1e \t%7.1e \t%7.1e \n\n\n" cpt s_a.tpl_f[Int(s_a.index)]  norm(s_a.grad,2) s_a.Δ
        end

        return cpt
    end


    """
        solver_TR_PSR1!(model)
    Trust region method using the gradient conjugate method and the Partially Separable Structure of the model from the parameters. This method use
    BFGS approximation.
    """
        solver_TR_PBFGS!(m :: T; x=Vector{Any}(undef,0) ) where T <: AbstractNLPModel = _solver_TR_PBFGS!(m,x=x )
        solver_TR_PBFGS!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number = _solver_TR_PBFGS!(obj_Expr, n, x_init, trait_expr_tree.is_expr_tree(T), type)
        _solver_TR_PBFGS!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_expr_tree, type=Float64 :: DataType) where T where Y <: Number = _solver_TR_PBFGS!(obj_Expr, n, x_init, type)
        _solver_TR_PBFGS!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, :: trait_expr_tree.type_not_expr_tree, type=Float64 :: DataType) where T where Y <: Number = error("mal typé")
        function _solver_TR_PBFGS!(obj_Expr :: T, n :: Int, x_init :: AbstractVector{Y}, type=Float64 :: DataType ) where T where Y <: Number
            work_obj = trait_expr_tree.transform_to_expr_tree(obj_Expr) :: implementation_expr_tree.t_expr_tree
            s_a = alloc_struct_algo(work_obj, n :: Int, type :: DataType ) :: struct_algo{implementation_expr_tree.t_expr_tree, type}
            init_struct_algo!(s_a, x_init)

            try
                cpt = iterations_TR_PBGFS!(s_a)
            catch
                return s_a
            end
            x_final = s_a.tpl_x[Int(s_a.index)]
            return (x_final, s_a, cpt) :: Tuple{Vector{Y}, struct_algo{implementation_expr_tree.t_expr_tree, type}, Int}
        end

        function _solver_TR_PBFGS_2!(m :: Z, obj_Expr :: T, n :: Int, type:: DataType, x_init :: AbstractVector{Y}) where T where Y where Z <: AbstractNLPModel
            Δt = @timed ((x_final, s_a, cpt) = solver_TR_PBFGS!(obj_Expr, n, x_init, type))
            status= :unknown
            return GenericExecutionStats(status, m,
                                   solution = x_final,
                                   iter = cpt,  # not quite the number of iterations!
                                   primal_feas = norm(NLPModels.grad(m, x_final),2),
                                   dual_feas = -1,
                                   objective = NLPModels.obj(m, x_final),
                                   elapsed_time = Δt[2],
                                  )
        end

    function _solver_TR_PBFGS!( model_JUMP :: T; x= Vector{Y}(undef,0)) where T <: AbstractNLPModel where Y <: Number
            model = model_JUMP.eval.m
            evaluator = JuMP.NLPEvaluator(model)
            MathOptInterface.initialize(evaluator, [:ExprGraph])
            obj_Expr = MathOptInterface.objective_expr(evaluator) :: Expr
            n = model.moi_backend.model_cache.model.num_variables_created
            if isempty(x)
                x0 :: AbstractVector=copy(model_JUMP.meta.x0)
            else
                x0 = copy(x)
            end
            _solver_TR_PBFGS_2!(model_JUMP, obj_Expr, n, typeof(x0[1]), x0)
        end

        # function _solver_TR_PBFGS!( model_JUMP :: T ; kwargs...) where T <: AbstractNLPModel
        #     getkwargs(kwargs)
        #     model = model_JUMP.eval.m
        #     evaluator = JuMP.NLPEvaluator(model)
        #     MathOptInterface.initialize(evaluator, [:ExprGraph])
        #     obj_Expr = MathOptInterface.objective_expr(evaluator) :: Expr
        #     n = model.moi_backend.model_cache.model.num_variables_created
        #     x :: AbstractVector=copy(model_JUMP.meta.x0)
        #     _solver_TR_PBFGS_2!(model_JUMP, obj_Expr, n, typeof(x[1]), x)
        # end



    end


# PartiallySeparableStructure.product_matrix_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B, x)
# PartiallySeparableStructure.product_vector_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_vector_sps(s_a.sps, s_a.g, x)
# PartiallySeparableStructure.update_SPS_SR1!(s_a :: struct_algo{T,Y}) where T where Y <: Number = PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.B_k, s_a.B_k1, PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y), s_a.x_k1 - s_a.x_k)
#
# f1(x :: Int,y :: Int) = x+y
# f1(x :: Int) = (y -> f1(x,y))
# f1(2)(3)
