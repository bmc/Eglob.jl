push!(LOAD_PATH, "../src/")

import Eglob

using Documenter

makedocs()

open("build/index.md") do input
    open("index.md", "w") do output
        println(output, "----")
        println(output, "title: Eglob.jl, an extended Julia globber")
        println(output, "layout: withTOC")
        println(output, "----")
        println()
        println(output, readstring(input))
    end
end


