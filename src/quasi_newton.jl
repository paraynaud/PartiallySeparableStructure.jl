module Quasi_Newton_update

using Test
using LinearAlgebra, SparseArrays

# using Test, BenchmarkTools, ProfileView, InteractiveUtils


"""
    update_BFGS(Δx, y, B, B_1 )
function that builde the next approximation of the Hessian, which will be stored in B_1. The result is based from Δx, y and B; respectively the difference
between 2 points, the difference of the gradient of the associate points, and the previous approximation of the Hessian. The approximation is made according
to the SR1 update method.
"""
    function update_SR1!(Δx :: AbstractVector{Y},
                        y :: AbstractVector{Y},
                        B :: AbstractArray{Y,2}, B_1 :: AbstractArray{Y,2}) where Y <: Number
        n = length(Δx)
        ω = 1e-8
        @inbounds @fastmath v = y - B * Δx :: Vector{Y}

        @fastmath @inbounds cond_left = abs( Δx' * v )
        @fastmath @inbounds cond_right = ω * norm(Δx,2) * norm(v,2)
        @fastmath @inbounds cond = (cond_left > cond_right) :: Bool

        if cond
            @fastmath @inbounds num = Array{Y,2}( v * v')
            @fastmath @inbounds den = (v' * Δx) :: Y
            @fastmath num_den = num/den
            @fastmath @inbounds B_1[:] = (B + num_den) :: Array{Y,2}
        else
            @inbounds B_1[:] = B :: Array{Y,2}
            # print("1")
        end
    end

    function update_SR1!(x :: Vector{Y}, x_1 :: Vector{Y},
                        g :: Vector{Y}, g_1 :: Vector{Y},
                        B :: Array{Y,2}, B_1 :: Array{Y,2}) where Y <: Number
        update_SR1!( x_1 - x, g_1 - g, B, B_1)
    end


"""
    update_BFGS(Δx, y, B, B_1 )
function that builde the next approximation of the Hessian, which will be stored in B_1. Rhe result is based from Δx, y and B; respectively the difference
between 2 points, the difference of the gradient of the associate points, and the previous approximation of the Hessian. The approximation is made according
to the BFGS update method.
"""
    function update_BFGS!(Δx :: AbstractVector{Y}, #difference between to points
                        y :: AbstractVector{Y}, #diffrence of the gradient between each point
                        B :: AbstractArray{Y,2}, #current approcimation of the Hessian
                        B_1 :: AbstractArray{Y,2}) where Y <: Number #Array that will store the next approximation of the Hessian

        if (Δx' * y > 0 ) && (Δx' * B * Δx > 0 )
            @fastmath @inbounds α = 1 / (y' * Δx)
            @fastmath @inbounds β = - (1 / (Δx' * B * Δx) )
            @fastmath @inbounds u = y * y'
            @fastmath @inbounds v = B * Δx
            @fastmath @inbounds terme1 = (α * u * u')
            @fastmath @inbounds terme2 = (β * v * v')
            @fastmath @inbounds B_1[:] = (B + terme1 + terme2) :: Array{Y,2}
            # @show norm(B_1* Δx- y,2)
        else
            # println("on ne satisfait pas le test Δxᵀy > 0 ")
            # @inbounds B_1[:] = B :: Array{Y,2}
            # print("2")
            @inbounds B_1[:] = B :: Array{Y,2}
        end
    end

    function update_BFGS!(x :: AbstractVector{Y}, x_1 :: AbstractVector{Y},
                        g :: AbstractVector{Y}, g_1 :: AbstractVector{Y},
                        B :: AbstractArray{Y,2}, B_1 :: AbstractArray{Y,2}) where Y <: Number
        update_BFGS!(x_1 - x, g_1 - g, B, B_1)
    end


# exemple de code montrant les limites numériques
# x = Vector{Float64}([1, 1])
# x_1 = Vector{Float64}([2, 2])
# g = Vector{Float64}([1, 1])
# g_1 = Vector{Float64}([1, 1.000000000000001])
# B = Array{Float64,2}([2 0 ; 0 2])
# B_1 = Array{Float64,2}(undef,2,2)
# # update_SR1!(x ,x_1, g, g_1, B, B_1)
# B_BFGS = update_BFGS!(x ,x_1, g, g_1, B, B_1)
# B_SR1 = update_SR1!(x ,x_1, g, g_1, B, B_1)
#
#
# n = 5
# x_SR1_0 = rand(n)
# x_SR1_1 = rand(n)
# g_SR1_0 = rand(n)
# g_SR1_1 = rand(n)
# B_SR1_0 = Array(sparse([1:n;], [1:n;], ones(n)))
# B_SR1_1 = Array{Float64,2}(undef,n,n)
#
# update_SR1!(x_SR1_0 , x_SR1_1, g_SR1_0, g_SR1_1, B_SR1_0, B_SR1_1)
#
# @testset "tests des résultats sur les approximations simple" begin
#  @test norm(B_SR1 * (x_1 - x) - (g_1-g),2) < 10^-5
#  @test norm(B_BFGS * (x_1 - x) - (g_1-g),2) < 10^-5
#  @test norm( B_SR1_1 * (x_SR1_1 - x_SR1_0) - (g_SR1_1 - g_SR1_0) ) < 10^-5
# end

# bench_SR1_4 = @benchmark update_SR1!(x_SR1_0 , x_SR1_1, g_SR1_0, g_SR1_1, B_SR1_0, B_SR1_1)

#typé correctement indépendamment des tests
# @code_warntype update_SR1!(x ,x_1, g, g_1, B, B_1)
# @code_warntype update_BFGS!(x ,x_1, g, g_1, B, B_1)
# @profview (@benchmark update_BFGS!(x ,x_1, g, g_1, B, B_1))
# bench_BFGS4 = @benchmark update_BFGS!(x ,x_1, g, g_1, B, B_1)

end

# """ Evolution de Benchmark sur update SR1
# n = 5
# Avec @fastmaths
#     BenchmarkTools.Trial:
#       memory estimate:  1.64 KiB
#       allocs estimate:  9
#       --------------
#       minimum time:     477.041 ns (0.00% GC)
#       median time:      895.413 ns (0.00% GC)
#       mean time:        1.007 μs (0.00% GC)
#       maximum time:     3.291 μs (0.00% GC)
#       --------------
#       samples:          10000
#       evals/sample:     196
#
# avec @inbounds
#     BenchmarkTools.Trial:
#       memory estimate:  1.64 KiB
#       allocs estimate:  9
#       --------------
#       minimum time:     493.934 ns (0.00% GC)
#       median time:      889.399 ns (0.00% GC)
#       mean time:        1.018 μs (0.00% GC)
#       maximum time:     3.396 μs (0.00% GC)
#       --------------
#       samples:          10000
#       evals/sample:     198
#
# sans les @inbounds
#     BenchmarkTools.Trial:
#       memory estimate:  1.64 KiB
#       allocs estimate:  9
#       --------------
#       minimum time:     515.099 ns (0.00% GC)
#       median time:      952.078 ns (0.00% GC)
#       mean time:        1.038 μs (0.00% GC)
#       maximum time:     3.443 μs (0.00% GC)
#       --------------
#       samples:          10000
#       evals/sample:     192
# """


# a utiliser setproperty!, get_property, getindex, set_index!.
