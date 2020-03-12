include("../../src/ordered_include.jl")
module My_SPS_Model_Module


    using LinearOperators, Krylov, LinearAlgebra

    using Printf

    using ..trait_expr_tree, ..implementation_expr_tree
    using ..PartiallySeparableStructure

    import NLPModels: increment!
    using NLPModels

    @enum indice fst=1 snd=2



    mutable struct struct_algo{T,Y <: Number}
        #structure partiellement séparable
        sps :: PartiallySeparableStructure.SPS{T}
        #tuple de B
        tpl_B :: Tuple{PartiallySeparableStructure.Hess_matrix{Y}, PartiallySeparableStructure.Hess_matrix{Y}}

        #tuple des gradients et la différence entre les gradients y
        tpl_g :: Tuple{PartiallySeparableStructure.grad_vector{Y}, PartiallySeparableStructure.grad_vector{Y}}
        # grad :: AbstractVector{Y}
        y :: PartiallySeparableStructure.grad_vector{Y}
        # grad_y :: AbstractVector{Y}

        # tuple de x
        tpl_x :: Tuple{AbstractVector{Y}, AbstractVector{Y}}
        #tuple des fx
        tpl_f :: Tuple{Y,Y}

        index :: indice
        #constantes pour l'algo potentiellement à supprimer plus tard
        Δ :: Float64
        η :: Float64
        η1 :: Float64
        ϵ :: Float64

    end



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
        # grad_k = Vector{type}(undef, n)
        # grad_y = Vector{type}(undef, n)


        # allocation de la structure de donné contenant tout ce dont nous avons besoin pour l'algorithme
        # algo_struct = struct_algo(sps, (B_k, B_k1), (g_k, g_k1), grad_k, y, grad_y, (x_k, x_k1), (type)(0), (type)(0), fst) :: struct_algo{T, type}
        algo_struct = struct_algo(sps, (B_k, B_k1), (g_k, g_k1), y,(x_k, x_k1), (type)(0), (type)(0), fst) :: struct_algo{T, type}

        return algo_struct :: struct_algo{T, type}
    end


    function init_struct_algo!( s_a :: struct_algo{T,Y},
                                x_k :: AbstractVector{Y}) where T where Y <: Number

        s_a.index = fst
        s_a.tpl_x[s_a.index] = x_k

        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.tpl_x[s_a.index], s_a.tpl_g[s_a.index])
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.tpl_g[s_a.index], s_a.grad)

        # PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k, s_a.B_k)
        PartiallySeparableStructure.id_hessian!(s_a.sps, s_a.tpl_B[s_a.index])

        s_a.tpl_f[s_a.index] = PartiallySeparableStructure.evaluate_SPS(s_a.sps, s_a.tpl_x[s_a.index])

    end



    function other_index( s_a :: struct_algo{T,Y}) where T where Y <: Number
        if s_a.index == fst
            return snd :: indice
        else
            return fst :: indice
        end
    end


    mutable struct SPS_Model{T,Y <: Number} <: AbstractNLPModel
        meta :: NLPModelMeta
        storage :: struct_algo{T,Y}
        counters :: Counters
    end



    function SPS_Model{T,Y}(obj, n :: Int, type=Float64 :: DataType) where T where Y <: Number
        meta = NLPModelMeta(n)
        storage = alloc_struct_algo(obj,n, type) :: struct_algo{T, type}
        return SPS_Model{T,type}(meta, storage, Counters())
    end

    function NLPModels.obj(nlp :: SPS_Model{T,Y}, x :: AbstractVector{Y}) where T where Y <: Number
        increment!(nlp, :neval_obj)
        fx = PartiallySeparableStructure.evaluate_SPS(nlp.storage.sps, x) :: Y
        return fx
    end

    function NLPModels.grad!(nlp :: SPS_Model{T,Y}, x :: AbstractVector{Y}, gx :: AbstractVector{Y}) where T where Y <: Number
      increment!(nlp, :neval_grad)
      PartiallySeparableStructure.evaluate_SPS_gradient!(nlp.storage.sps, x, nlp.storage.tpl_g[other_index(nlp.storage)] )
      PartiallySeparableStructure.build_gradient!(nlp.storage.sps, nlp.storage.tpl_g[other_index(nlp.storage)], gx)
    end


    function NLPModels.hprod!(nlp :: SPS_Model{T}, x :: AbstractVector, v :: AbstractVector, Hv :: AbstractVector; obj_weight=1.0, y=Float64[]) where T
        struct_hess = PartiallySeparableStructure.struct_hessian(nlp.storage, x)
        return PartiallySeparableStructure.product_matrix_sps(nlp.storage, struct_hess, v )
    end


    using LinearOperators

    mutable struct SPS_LinearOperator{Y <: Number} <: AbstractLinearOperator{Y}
        l_o :: LinearOperator{T}
    end

    function SPS_LinearOperator(nlp :: SPS_Model{T,Y}) where T where Y <: Number
        n = nlp.storage.sps.n_var
        l_o(nlp) = LinearOperators.LinearOperator( n, n, true, true, y -> NLPModels.hprod(nlp, y) )
        return SPS_LinearOperator{Y}(l_o)
    end

    function LinearOperator.push!(sps_linear_op :: SPS_LinearOperator)

    end 
end



# PartiallySeparableStructure.product_matrix_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_matrix_sps(s_a.sps, s_a.B, x)
# PartiallySeparableStructure.product_vector_sps(s_a :: struct_algo{T, Y}, x :: Vector{Z}) where T where Y <: Number where Z <: Number = PartiallySeparableStructure.product_vector_sps(s_a.sps, s_a.g, x)
# PartiallySeparableStructure.update_SPS_SR1!(s_a :: struct_algo{T,Y}) where T where Y <: Number = PartiallySeparableStructure.update_SPS_SR1!(s_a.sps, s_a.B_k, s_a.B_k1, PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y), s_a.x_k1 - s_a.x_k)
