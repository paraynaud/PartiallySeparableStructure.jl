module implementation_expr_tree

    using ..abstract_expr_node, ..trait_expr_node
    using ..abstract_expr_tree
    using ..trait_tree

    import ..abstract_expr_tree.create_expr_tree, ..abstract_expr_tree.create_Expr, ..abstract_expr_tree.create_Expr2
    import ..interface_expr_tree._inverse_expr_tree

    import ..implementation_tree.type_node

    import ..interface_expr_tree._get_expr_node, ..interface_expr_tree._get_expr_children, ..interface_expr_tree._inverse_expr_tree
    import ..interface_expr_tree._get_real_node, ..interface_expr_tree._transform_to_expr_tree


    using StaticArrays

    t_expr_tree = type_node{ab_ex_nd}


    function create_Expr(t :: t_expr_tree)
        nd = trait_tree.get_node(t)
        ch = trait_tree.get_children(t)
        if isempty(ch)
            return trait_expr_node.node_to_Expr(nd)
        else
            children_Expr = create_Expr.(ch)
            node_Expr = trait_expr_node.node_to_Expr(nd)
            #défférenciation entre les opérateurs simple :+, :- et compliqué comme :^2
            #premier cas, les cas simple :+, :-
            if length(node_Expr) == 1
                return Expr(:call, node_Expr[1], children_Expr...)
            #les cas compliqués, pour le moment :^
            elseif length(node_Expr) == 2
                return Expr(:call, node_Expr[1], children_Expr..., node_Expr[2])
            else
                error("non traité")
            end
        end
    end

    function create_Expr2(t :: t_expr_tree)
        nd = trait_tree.get_node(t)
        ch = trait_tree.get_children(t)
        if isempty(ch)
            return trait_expr_node.node_to_Expr2(nd)
        else
            children_Expr = create_Expr2.(ch)
            node_Expr = trait_expr_node.node_to_Expr(nd)
            #défférenciation entre les opérateurs simple :+, :- et compliqué comme :^2
            #premier cas, les cas simple :+, :-
            if length(node_Expr) == 1
                return Expr(:call, node_Expr[1], children_Expr...)
            #les cas compliqués, pour le moment :^
            elseif length(node_Expr) == 2
                return Expr(:call, node_Expr[1], children_Expr..., node_Expr[2])
            else
                error("non traité")
            end
        end
    end

# a = rand(30)
# b = [ a[i] for i in 1:length(a) ]
# c =  @SVector [ a[i] for i in 1:length(a) ]


function create_expr_tree(field :: ab_ex_nd, children :: Vector{ type_node{ab_ex_nd}} )
    return t_expr_tree(field, children)
end

    function create_expr_tree(field :: ab_ex_nd )
        return t_expr_tree(field, [])
    end


    function _get_expr_node(t :: t_expr_tree)
        return trait_tree.get_node(t)
    end

    function _get_expr_children(t :: t_expr_tree)
        return trait_tree.get_children(t)
    end


    function _inverse_expr_tree(t :: t_expr_tree)
        op_minus = abstract_expr_node.create_node_expr(:-)
        new_node = abstract_expr_tree.create_expr_tree(op_minus, [t])
        return new_node
    end

    function _get_real_node(ex :: t_expr_tree)
        if isempty(_get_expr_children(ex))
            return ex.field
        else
            return _get_expr_node(ex)
        end
    end

    function _transform_to_expr_tree(ex :: t_expr_tree)
        return ex :: t_expr_tree
    end



    function Base.copy(ex :: t_expr_tree)
        nd = trait_tree.get_node(ex)
        ch = trait_tree.get_children(ex)
        if isempty(ch)
            leaf = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(nd))
            return leaf
        else
            res_ch = Base.copy.(ch)
            new_node = abstract_expr_node.create_node_expr(nd)
            # @show res_ch, ch, nd, new_node
            return create_expr_tree(new_node, res_ch)
        end
    end


    export t_expr_tree

end  # moduleimplementation_expr_tree
