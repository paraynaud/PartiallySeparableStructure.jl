module implementation_tree1

    mutable struct type_node{T}
        field :: T
        children :: Vector{type_node{T}}
    end

    create_tree( field :: T, children :: Vector{type_node{T}}) where T = type_node{T}(field,children)
    create_tree( field :: T, children :: Array{Any,1}) where T = type_node{T}(field,children)

    _get_node(tree :: type_node{T}) where T = tree.field

    _get_children(tree :: type_node{T} ) where T = tree.children

    function evaluate_tree( t :: type_node{T}) where T <: Number
        children = _get_children(t)
        if isempty(children)
            return 0
        else
            return mapreduce(x -> evaluate_tree(x), + , children) + 10 * _get_node(t)
        end
    end


end  # module implementation_tree


module implementation_tree2

    mutable struct type_node2{T}
        field :: T
        children :: AbstractVector{type_node2{T}}
    end

    create_tree( field :: T, children :: AbstractVector{type_node2{T}}) where T = type_node2{T}(field,children)

    _get_node(tree :: type_node2{T}) where T = tree.field

    _get_children(tree :: type_node2{T} ) where T = tree.children

    function evaluate_tree( t :: type_node2{T}) where T <: Number
        children = _get_children(t)
        if isempty(children)
            return 0
        else
            return mapreduce(x -> evaluate_tree(x), + , children) + 10 * _get_node(t)
        end
    end

end  # module implementation_tree

module implementation_tree3

    using StaticArrays

    mutable struct type_node3{T,Y}
        field :: T
        children :: SArray{Tuple{Y},Main.implementation_tree3.type_node3{T,Y},1,Y}
    end

    create_tree( field :: T, children :: SArray{Tuple{Y},Main.implementation_tree3.type_node3{T,Y},1,Y}) where T where Y = type_node3{T,Y}(field,children)

    _get_node(tree :: type_node3{T,Y}) where T where Y = tree.field

    _get_children(tree :: type_node3{T,Y} ) where T where Y= tree.children

    function evaluate_tree( t :: type_node3{T,Y}) where T where Y <: Number
        children = _get_children(t)
        if isempty(children)
            return 0
        else
            return mapreduce(x -> evaluate_tree(x), + , children) + 10 * _get_node(t)
        end
    end

end  # module implementation_tree

# module implementation_tree4
#
#     using StaticArrays
#
#     mutable struct type_node4{T}
#         field :: T
#         children :: SVector{N, typenode4{T}}
#     end
#
#     create_tree( field :: T, children :: SVector{N, typenode4{T}}) where T = type_node4{T}(field,children)
#
#     _get_node(tree :: type_node4{T}) where T = tree.field
#
#     _get_children(tree :: type_node4{T} ) where T = tree.children
#
#     function evaluate_tree( t :: type_node4{T}) where T <: Number
#         children = _get_children(t)
#         if isempty(children)
#             return 0
#         else
#             return mapreduce(x -> evaluate_tree(x), + , children) + 10 * _get_node(t)
#         end
#     end
#
# end  # module implementation_tree

using StaticArrays, BenchmarkTools
using .implementation_tree1, .implementation_tree2, .implementation_tree3


function printer_tree_classic(tree, deepth = 0 )
    ident = "\t"^deepth
    nd = implementation_tree1._get_node(tree)
    println(ident, nd )
    ch = implementation_tree1._get_children(tree)
    printer_tree_classic.(ch, deepth + 1)
end

function printer_tree_new(tree, deepth = 0 )
    ident = "\t"^deepth
    nd = implementation_tree2._get_node(tree)
    println(ident, nd )
    ch = implementation_tree2._get_children(tree)
    printer_tree_new.(ch, deepth + 1)
end

function printer_tree_new2(tree, deepth = 0 )
    ident = "\t"^deepth
    nd = implementation_tree3._get_node(tree)
    println(ident, nd )
    ch = implementation_tree3._get_children(tree)
    printer_tree_new.(ch, deepth + 1)
end


function create_tree1( n :: Int)
    if n == 1
        fils_vide = Vector{implementation_tree1.type_node{Int}}([])
        return implementation_tree1.type_node{Int}(1,fils_vide)
    else
        temp = Vector{implementation_tree1.type_node{Int}}(undef,n)
        map!(x -> create_tree1(n-1),temp, [1:n;])
        return implementation_tree1.type_node{Int}(n, temp)
    end
end

function create_tree2( n :: Int)
    static_fils_vide = SVector{0,implementation_tree2.type_node2{Int}}([])
    if n == 1
        return implementation_tree2.type_node2{Int}(1,static_fils_vide)
    else
        pre_temp = Vector{implementation_tree2.type_node2{Int}}(undef,n)
        map!(x -> create_tree2(n-1), pre_temp, [1:n;])
        temp = SVector{n,implementation_tree2.type_node2{Int}}(pre_temp)
        return implementation_tree2.type_node2{Int}(n,temp)
    end
end

function create_tree3( n :: Int)
    if n == 1
        fils_vide = Vector{implementation_tree2.type_node2{Int}}([])
        return implementation_tree2.type_node2{Int}(1, fils_vide)
    else
        temp = Vector{implementation_tree2.type_node2{Int}}(undef,n)
        map!(x -> create_tree3(n-1), temp, [1:n;])
        return implementation_tree2.type_node2{Int}(n, temp)
    end
end

function create_tree4( n :: Int)
    if n == 1
        static_fils_vide = SVector{0,implementation_tree3.type_node3{Int}}([])
        @show typeof(static_fils_vide)
        temp = implementation_tree3.type_node3{Int}(1,static_fils_vide)
        return temp
    else
        pre_temp = Vector{implementation_tree3.type_node3{Int}}(undef,n)
        map!(x -> create_tree4(n-1), pre_temp, [1:n;])
        temp = SVector{n,implementation_tree3.type_node3{Int}}(pre_temp)
        return implementation_tree3.type_node3{Int}(n,temp)
    end
end

function create_tree5( n :: Int)
    if n == 1
        static_fils_vide = SVector{0,implementation_tree4.type_node4{Int}}([])
        @show typeof(static_fils_vide)
        temp = implementation_tree4.type_node4{Int}(1,static_fils_vide)
        return temp
    else
        # pre_temp = Vector{implementation_tree3.type_node3{Int}}(undef,n)
        # map!(x -> create_tree4(n-1), pre_temp, [1:n;])
        # temp = SVector{n,implementation_tree3.type_node3{Int}}(pre_temp)
        # return implementation_tree3.type_node3{Int}(n,temp)
    end
end



n = 7

bench_create1 = @benchmark create_tree1(n)
bench_create2 = @benchmark create_tree2(n)
bench_create3 = @benchmark create_tree3(n)
# bench_create4 = @benchmark create_tree4(n)
#
tree1 = create_tree1(n)
tree2 = create_tree2(n)
tree3 = create_tree3(n)
# tree4 = create_tree4(n)
# tree5 = create_tree5(n)
#
# error("test")

printer_tree_classic(tree1)
printer_tree_new(tree2)
# printer_tree_new(tree3)
# printer_tree_new3(tree4)

res1 = implementation_tree1.evaluate_tree(tree1)
res2 = implementation_tree2.evaluate_tree(tree2)
res3 = implementation_tree2.evaluate_tree(tree3)
# res4 = implementation_tree2.evaluate_tree(tree3)
# @show res1 == res2 && res1 == res3 && res1 == res4

bench_eval1 = @benchmark implementation_tree1.evaluate_tree(tree1)
bench_eval2 = @benchmark implementation_tree2.evaluate_tree(tree2)
bench_eval3 = @benchmark implementation_tree2.evaluate_tree(tree3)
# bench_eval4 = @benchmark implementation_tree3.evaluate_tree(tree4)

@show typeof(implementation_tree2._get_children(tree2))
@show typeof(implementation_tree2._get_children(tree3))
@show typeof(implementation_tree3._get_children(tree4))
