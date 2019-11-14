module implementation_type_expr

    import ..interface_type_expr._is_constant, ..interface_type_expr._is_linear, ..interface_type_expr._is_quadratic, ..interface_type_expr._is_more_than_quadratic
    import ..interface_type_expr._type_product

    @enum t_type_expr_basic constant=0 linear=1 quadratic=2 more=3

    function _is_constant(t :: t_type_expr_basic)
        return t <= constant
    end

    function _is_linear(t :: t_type_expr_basic)
        return t <= linear
    end

    function _is_quadratic(t :: t_type_expr_basic)
        return t <= quadrtic
    end

    function _is_more_than_quadratic(t :: t_type_expr_basic)
        return t <= more
    end

    function _type_product(a  :: t_type_expr_basic,b :: t_type_expr_basic)
        if _is_constant(a)
            return b
        elseif _is_linear(a)
            if _is_constant(b)
                return linear
            elseif _is_linear(b)
                return quadratic
            else
                return more
            end
        elseif _is_quadratic(a)
            if _is_constant(b)
                return quadratic
            else
                return more
            end
        end
    end



end  # module implementation_type_expr
