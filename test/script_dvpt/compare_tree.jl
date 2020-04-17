module test_tree


    abstract type t_node end

    mutable struct plus_node <: t_node
        children :: Vector{t_node}
    end

    mutable struct power_node <: t_node
        child :: t_node
        pow :: Float64
    end

    mutable struct var_node <: t_node
        name :: Symbol
        index :: Int
    end

    mutable struct minus_node <: t_node
        children :: Vector{t_node}
    end

    mutable struct times_node <: t_node
        children :: Vector{t_node}
    end

    mutable struct plus_node2 <: t_node
        children :: Vector{t_node}
    end

    mutable struct minus_node2 <: t_node
        children :: Vector{t_node}
    end

    mutable struct times_node2 <: t_node
        children :: Vector{t_node}
    end


    get_node(t :: plus_node) =  [:+]
    # get_node(t :: times_node2) =  [:*]
    # get_node(t :: minus_node2) =  [:-]
    # get_node(t :: plus_node2) =  [:+]
    # get_node(t :: times_node) =  [:*]
    # get_node(t :: minus_node) =  [:-]
    get_node(t :: power_node) =  [:^, t.pow]
    get_node(t :: var_node) = [:x, t.index]

    get_children(t :: plus_node) = t.children
    # get_children(t :: times_node) = t.children
    # get_children(t :: minus_node) = t.children
    # get_children(t :: plus_node2) = t.children
    # get_children(t :: times_node2) = t.children
    # get_children(t :: minus_node2) = t.children
    get_children(t :: power_node) = [t.child]
    get_children(t :: var_node) = []


    @inline eval_node( t :: power_node, x :: AbstractVector{Y}) where Y <: Number = @fastmath eval_node(t.child,x)^(t.pow) :: Y
    @inline eval_node( t :: var_node, x :: AbstractVector{Y}) where Y <: Number = @inbounds x[t.index] :: Y
    # @inline eval_node( t :: plus_node, x :: AbstractVector{Y}) where Y <: Number = @fastmath @inbounds mapreduce(y :: t_node -> eval_node(y,x) :: Y , +, t.children ) :: Y
    function eval_node( t :: plus_node, x :: AbstractVector{Y}) where Y <: Number
        res = 0.0 :: Y
        @inbounds @simd for i in t.children
            @fastmath res += eval_node(i :: t_node ,x) :: Y
        end
        return res
    end

    @inline eval_node( t :: times_node, x :: AbstractVector{Y}) where Y <: Number = mapreduce(y -> eval_node(y,x), *, t.children )
    @inline eval_node( t :: minus_node, x :: AbstractVector{Y}) where Y <: Number = mapreduce(y -> eval_node(y,x), -, append!(t.children, [0]) )
    @inline eval_node( t :: plus_node2, x :: AbstractVector{Y}) where Y <: Number = mapreduce(y -> eval_node(y,x), +, t.children )
    @inline eval_node( t :: times_node2, x :: AbstractVector{Y}) where Y <: Number = mapreduce(y -> eval_node(y,x), *, t.children )
    @inline eval_node( t :: minus_node2, x :: AbstractVector{Y}) where Y <: Number = mapreduce(y -> eval_node(y,x), -, append!(t.children, [0]) )
    @inline eval_node( t :: var_node)= x[t.index]
    @inline eval_node( x :: Y) where Y <: Number = 4
    @inline eval_node( x :: Y) where Y <: Real = 5
    @inline eval_node( x :: t_node) where Y <: Real = 5

    function printer_tree(tree, deepth = 0 )
        ident = "\t"^deepth
        nd = get_node(tree)
        println(ident, nd... )
        ch = get_children(tree)
        printer_tree.(ch, deepth + 1)
    end


    function create_tree(n :: Int)
        ch_plus = map(i -> power_node(plus_node( [var_node(:x, i) , var_node(:x, i+1), var_node(:x, i+2), var_node(:x, i+3), var_node(:x, i+4) ]), 3) , [1:(n-4);])
        return plus_node(ch_plus)
    end

end

module test_tree


    abstract type t_node end

    mutable struct plus_node <: t_node
        children :: Tuple
    end

    mutable struct power_node <: t_node
        child :: t_node
        pow :: Float64
    end

    mutable struct var_node <: t_node
        name :: Symbol
        index :: Int
    end

    get_node(t :: plus_node) =  [:+]
    get_node(t :: power_node) =  [:^, t.pow]
    get_node(t :: var_node) = [:x, t.index]

    get_children(t :: plus_node) = t.children
    get_children(t :: power_node) = [t.child]
    get_children(t :: var_node) = []


    @inline eval_node( t :: power_node, x :: AbstractVector{Y}) where Y <: Number = @fastmath eval_node(t.child,x)^(t.pow) :: Y
    @inline eval_node( t :: var_node, x :: AbstractVector{Y}) where Y <: Number = @inbounds x[t.index] :: Y
    # @inline eval_node( t :: plus_node, x :: AbstractVector{Y}) where Y <: Number = @fastmath @inbounds mapreduce(y :: t_node -> eval_node(y,x) :: Y , +, t.children ) :: Y
    function eval_node( t :: plus_node, x :: AbstractVector{Y}) where Y <: Number
        res = 0.0 :: Y
        @inbounds @simd for i in t.children
            @fastmath res += eval_node(i :: t_node ,x) :: Y
        end
        return res
    end


    function printer_tree(tree, deepth = 0 )
        ident = "\t"^deepth
        nd = get_node(tree)
        println(ident, nd... )
        ch = get_children(tree)
        printer_tree.(ch, deepth + 1)
    end


    function create_tree(n :: Int)
        ch_plus = map(i -> power_node(plus_node( (var_node(:x, i) , var_node(:x, i+1), var_node(:x, i+2), var_node(:x, i+3), var_node(:x, i+4) )), 3) , [1:(n-4);])
        return plus_node(ch_plus)
    end

end


using .test_tree


using JuMP, MathOptInterface, LinearAlgebra, SparseArrays
using Test, BenchmarkTools, ProfileView, InteractiveUtils


include("../../src/ordered_include.jl")

using ..PartiallySeparableStructure
using ..implementation_expr_tree
using ..M_evaluation_expr_tree


println("\n\n Début script de dvpt\n\n")

n = 10000
m = Model()
@variable(m, x[1:n])
@NLobjective(m, Min, sum( (x[j] + x[j+1] + x[j+2] + x[j+3] + x[j+4])^3 for j in 1:n-4 ))
evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])

obj = MathOptInterface.objective_expr(evaluator)
obj2 = trait_expr_tree.transform_to_expr_tree(obj)
SPS = PartiallySeparableStructure.deduct_partially_separable_structure(obj2, n)


tree_test = test_tree.create_tree(n) :: test_tree.plus_node
tree_test2 = test_tree.create_tree2(n) :: test_tree.plus_node
# test_tree.printer_tree(tree_test)
x = ones(n)
error("fin")
bench_eval_test = @benchmark test_tree.eval_node(tree_test, x)
bench_eval_SPS = @benchmark PartiallySeparableStructure.evaluate_SPS(SPS,x)

@code_warntype test_tree.eval_node(tree_test, x)
# @code_lowered test_tree.eval_node(tree_test, x)
# @code_llvm  test_tree.eval_node(tree_test, x)
