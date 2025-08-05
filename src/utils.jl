# Copyright 2025 Luis M. B. Varona
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

module Utils

export geng_connected,
    geng_connected_regular,
    geng_connected_bipartite,
    filter_geng_to_laplacian_integral,
    canonize_graph6_strings

using Base.Threads
using LinearAlgebra: eigvals!

function is_laplacian_integral!(L::Matrix{Float64})
    return all(eigval -> isapprox(eigval, round(eigval); atol=1e-8, rtol=1e-5), eigvals!(L))
end

function write_graph6_to_laplacian!(L::Matrix{Float64}, bits::BitVector, g6::String)
    n = Int(g6[1]) - 63
    max_size = div(n * (n - 1), 2)

    bits .= false
    idx_bit = 0

    for c in g6[2:end]
        val = Int(c) - 63
        bit_pos = 6

        while (idx_bit < max_size && bit_pos > 0)
            @inbounds bits[idx_bit += 1] = (val >> (bit_pos -= 1)) & 1 == 1
        end
    end

    L .= 0
    idx_edge = 0

    @inbounds for j in 2:n, i in 1:(j - 1)
        if bits[idx_edge += 1]
            L[i, i] += 1
            L[j, j] += 1
            L[i, j] -= 1
            L[j, i] -= 1
        end
    end

    return L
end

function geng_connected(n::Int)
    io = open(`geng $n -q -c`)
    return Iterators.Stateful(eachline(io)), io
end

function geng_connected_regular(n::Int)
    if n <= 2
        k_min = n - 1
    else
        k_min = 2
    end

    step = n % 2 + 1
    k_reg_vals = k_min:step:(n - 1)

    cmds = map(k -> `geng $n -q -c -d$k -D$k`, k_reg_vals)
    ios = open.(cmds)
    lines = Iterators.flatten(eachline.(ios))

    return Iterators.Stateful(lines), ios
end

function geng_connected_bipartite(n::Int)
    io = open(`geng $n -q -c -b`)
    return Iterators.Stateful(eachline(io)), io
end

function filter_geng_to_laplacian_integral(
    geng::Tuple{Base.Iterators.Stateful,Any}, chunk_size::Int, n::Int
)
    L_bufs = map(_ -> Matrix{Float64}(undef, n, n), 1:nthreads())
    bits_bufs = map(_ -> BitVector(undef, div(n * (n - 1), 2)), 1:nthreads())

    iter, io = geng
    results = String[]
    results_lock = ReentrantLock()
    res = iterate(iter)

    while !isnothing(res)
        chunk = String[]
        chunk_length = 0

        while (!isnothing(res) && chunk_length < chunk_size)
            g6, state = res
            push!(chunk, g6)
            res = iterate(iter, state)
            chunk_length += 1
        end

        num_threads = nthreads()
        chunk_results = map(_ -> String[], 1:num_threads)

        @threads for i in 1:num_threads
            L = L_bufs[i]
            bits = bits_bufs[i]
            thread_results = chunk_results[i]

            start = div((i - 1) * chunk_length, num_threads) + 1
            stop = div(i * chunk_length, num_threads)

            @inbounds for j in start:stop
                g6 = chunk[j]

                if is_laplacian_integral!(write_graph6_to_laplacian!(L, bits, g6))
                    push!(thread_results, g6)
                end
            end
        end

        lock(results_lock)

        try
            foreach(
                subchunk_results -> append!(results, subchunk_results),
                Iterators.filter(!isempty, chunk_results),
            )
        finally
            unlock(results_lock)
        end
    end

    if io isa AbstractVector
        close.(io)
    else
        close(io)
    end

    return results
end

function canonize_graph6_strings(g6_strings::Vector{String})
    return readlines(pipeline(IOBuffer(join(g6_strings, "\n") * "\n"), `labelg -q -g`))
end

end
