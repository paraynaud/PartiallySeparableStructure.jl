module implementation_tree

    import ..abstract_tree.ab_tree, ..abstract_tree.create_tree

    import ..interface_tree._get_node, ..interface_tree._get_children


    mutable struct type_node{T} <: ab_tree
        field :: T
        children :: Vector{type_node{T}}
    end

    create_tree( field :: T, children :: Vector{type_node{T}}) where T = type_node{T}(field,children)
    create_tree( field :: T, children :: Array{Any,1}) where T = type_node{T}(field,children)

    _get_node(tree :: type_node{T}) where T = tree.field

    _get_children(tree :: type_node{T} ) where T = tree.children


end  # module implementation_tree
