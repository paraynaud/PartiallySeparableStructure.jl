module Solver_SPS

    using ..trait_expr_tree, ..implementation_expr_tree
    using ..PartiallySeparableStructure

    function alloc_struct_algo(obj_Expr :: Expr, n :: Int, type=Float64 :: DataType )
        # transformation de l'Expr donné par JuMP en expr_tree plus rapide à traiter
        obj = trait_expr_tree.transform_to_expr_tree(obj_Expr)

        # détéction de la structure partiellement séparable
        sps = PartiallySeparableStructure.deduct_partially_separable_structure(obj,n)

        # construction des structure de données nécessaire pour le gradient à l'itération k/k+1 et le différence des gradients
        construct_element_grad = (y :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_gradient{type}(Vector{type}(zeros(type, length(y.used_variable)) )) )
        g_k = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        g_k1 = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )
        y = PartiallySeparableStructure.grad_vector{type}( construct_element_grad.(sps.structure) )

        # constructions des structures de données nécessaires pour le Hessien ou son approximation
        construct_element_hess = ( elm_fun :: PartiallySeparableStructure.element_function{implementation_expr_tree.t_expr_tree} -> PartiallySeparableStructure.element_hessian{type}( Array{type,2}(undef, length(elm_fun.used_variable), length(elm_fun.used_variable) )) )
        B_k = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))
        B_k1 = PartiallySeparableStructure.Hess_matrix{type}(construct_element_hess.(sps.structure))

        #définition des 2 points xk et x_k1
        x_k = Vector{type}(undef, n)
        x_k1 = Vector{type}(undef, n)

        #finally a real sized gradient
        grad = Vector{type}(undef, n)

        # allocation de la structure de donné contenant tout ce dont nous avons besoin pour l'algorithme
        algo_struct = PartiallySeparableStructure.struct_algo(sps, B_k, B_k1, g_k, g_k1, y, x_k, x_k1, grad)

        return algo_struct
    end


    function init_struct_algo!( s_a :: PartiallySeparableStructure.struct_algo{T,Y},
                                x_k :: AbstractVector{Y}, x_k1 :: AbstractVector{Y},
                                g_k :: PartiallySeparableStructure.grad_vector{Y},
                                g_k1 :: PartiallySeparableStructure.grad_vector{Y},
                                y :: PartiallySeparableStructure.grad_vector{Y},
                                grad :: AbstractVector{Y},
                                B_k :: PartiallySeparableStructure.Hess_matrix{Y},
                                B_k1 :: PartiallySeparableStructure.Hess_matrix{Y}) where T where Y <: Number

        s_a.x_k = x_k
        s_a.x_k1 = x_k1
        s_a.g_k = g_k
        s_a.g_k1 = g_k1
        s_a.y = y
        s_a.grad = grad
        s_a.B_k = B_k
        s_a.B_k1 = B_k1
    end


    function init_struct_algo!( s_a :: PartiallySeparableStructure.struct_algo{T,Y},
                                x_k :: AbstractVector{Y}, x_k1 :: AbstractVector{Y}) where T where Y <: Number
        s_a.x_k = x_k
        s_a.x_k1 = x_k1

        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.x_k, s_a.g_k)
        PartiallySeparableStructure.evaluate_SPS_gradient!(s_a.sps, s_a.x_k1, s_a.g_k1)
        PartiallySeparableStructure.minus_grad_vec!(s_a.g_k1, s_a.g_k, s_a.y)
        PartiallySeparableStructure.build_gradient!(s_a.sps, s_a.y, s_a.grad)
        PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k, s_a.B_k)
        PartiallySeparableStructure.struct_hessian!(s_a.sps, s_a.x_k1, s_a.B_k1)
    end


    function determine_xk1(s_a :: PartiallySeparableStructure.struct_algo{T,Y}) where T where Y <: Number


    end




end
