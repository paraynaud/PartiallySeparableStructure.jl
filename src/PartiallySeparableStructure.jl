module PartiallySeparableStructure

    using ..implementation_type_expr
    using ..algo_expr_tree


    struct element_function
        fun
        used_variable :: Vector{Int64}
        type :: implementation_type_expr.t_type_expr_basic
        U
    end

    struct SPS
        structure :: Vector{element_function}
    end

    

end # module
