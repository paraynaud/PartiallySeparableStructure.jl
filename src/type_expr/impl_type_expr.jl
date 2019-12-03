module implementation_type_expr

    import ..interface_type_expr._is_constant, ..interface_type_expr._is_linear, ..interface_type_expr._is_quadratic, ..interface_type_expr._is_more_than_quadratic
    import ..interface_type_expr._type_product, ..interface_type_expr._type_power


############## définition du type ###################
    @enum t_type_expr_basic constant=0 linear=1 quadratic=2 more=3


############## définition des fonctions de l'interface ###################
    _is_constant(t :: t_type_expr_basic) = (t == constant)

    _is_linear(t :: t_type_expr_basic) = ( t == linear)

    _is_quadratic(t :: t_type_expr_basic) = (t == quadratic)

    _is_more_than_quadratic(t :: t_type_expr_basic) = (t == more)

    return_constant() = t_type_expr_basic(0)

    return_linear() = t_type_expr_basic(1)

    return_quadratic() = t_type_expr_basic(2)

    return_more() = t_type_expr_basic(3)


############## définition de fonctions nécessaires dans des algorithmes ###################

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

    function _type_power(index_power :: Number, b :: t_type_expr_basic)
        if index_power == 0
            return constant
        elseif index_power == 1
            return b
        else
            if _is_constant(b)
                return constant
            elseif _is_linear(b)
                if index_power == 2
                    return quadratic
                else
                    return more
                end
            else
                return more
            end
        end
    end



end  # module implementation_type_expr
