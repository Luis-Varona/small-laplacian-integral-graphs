# Copyright 2025 Luis M. B. Varona
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

include("utils.jl")
using .Utils

function main()
    geng_func, dest, min_order, max_order, chunk_size = parse_cli_args()
    buf = IOBuffer()

    for n in min_order:max_order
        geng = geng_func(n)
        li_graphs = canonize_graph6_strings(
            filter_geng_to_laplacian_integral(geng, chunk_size, n)
        )
        write(buf, "# Order $n ($(length(li_graphs)))\n")
        write(buf, join(li_graphs, "\n"))
        write(buf, "\n")
    end

    open(dest, "w") do file
        write(file, take!(buf))
        return nothing
    end

    return nothing
end

function parse_cli_args()
    num_args = length(ARGS)

    if num_args != 5
        throw(
            ArgumentError(
                "Expected five args, got $num_args: $(join(map(arg -> "'$arg'", ARGS), ", "))",
            ),
        )
    end

    cat = ARGS[1]
    dest = ARGS[2]
    min_order = parse(Int, ARGS[3])
    max_order = parse(Int, ARGS[4])
    chunk_size = parse(Int, ARGS[5])

    if ispath(dest)
        throw(ArgumentError("Destination already exists: '$dest'"))
    else
        mkpath(dirname(dest))
    end

    if min_order < 1
        throw(ArgumentError("Minimum graph order must be at least 1, got $min_order"))
    end

    if max_order < min_order
        throw(
            ArgumentError("Maximum graph order must be at least $min_order, got $max_order")
        )
    end

    if chunk_size < 1
        throw(ArgumentError("Chunk size must be a positive integer, got $chunk_size"))
    end

    if cat == "con"
        geng_func = geng_connected
    elseif cat == "con_reg"
        geng_func = geng_connected_regular
    elseif cat == "con_bip"
        geng_func = geng_connected_bipartite
    else
        throw(
            ArgumentError(
                "Graph category must be one of 'con', 'con_reg', or 'con_bip', got '$cat'"
            ),
        )
    end

    return geng_func, dest, min_order, max_order, chunk_size
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
