module trait_expr_node
    import ..abstract_expr_node.ab_ex_nd

    import ..interface_expr_node._node_is_plus, ..interface_expr_node._node_is_minus, ..interface_expr_node._node_is_power
    import ..interface_expr_node._node_is_times, ..interface_expr_node._node_is_constant, ..interface_expr_node._node_is_variable

    struct type_expr_node end
    struct type_not_expr_node end

""" partie sur les opérateurs """

    is_expr_node(a :: ab_ex_nd) = type_expr_node()
    is_expr_node(a :: Any) = type_not_expr_node()

    node_is_plus(a) = _node_is_plus(a, is_expr_node(a))
    _node_is_plus(a, ::type_expr_node) = _node_is_plus(a)
    _node_is_plus(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_times(a) = _node_is_times(a, is_expr_node(a))
    _node_is_times(a, ::type_expr_node) = _node_is_times(a)
    _node_is_times(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_minus(a) = _node_is_minus(a, is_expr_node(a))
    _node_is_minus(a, ::type_expr_node) = _node_is_minus(a)
    _node_is_minus(a, ::type_not_expr_node) = error("This node is not a expr node")

    node_is_power(a) = _node_is_power(a, is_expr_node(a))
    _node_is_power(a, ::type_expr_node) = _node_is_power(a)
    _node_is_power(a, ::type_not_expr_node) = error("This node is not a expr node")


""" partie sur les variables """

    node_is_variable(a) = _node_is_variable(a, is_expr_node(a))
    _node_is_variable(a, ::type_expr_node) = _node_is_variable(a)
    _node_is_variable(a, ::type_not_expr_node) = error("This node is not a expr node")


""" partie sur les constantes """

    node_is_constant(a) = _node_is_constant(a, is_expr_node(a))
    _node_is_constant(a, ::type_expr_node) = _node_is_constant(a)
    _node_is_constant(a, ::type_not_expr_node) = error("This node is not a expr node")


end  # module trait_expr_node
