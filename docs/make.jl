push!(LOAD_PATH, "../src/")

import Eglob

using Documenter

makedocs()

open("build/index.md") do input
    open("index.md", "w") do output
        println(output, readstring(input))
    end
end


