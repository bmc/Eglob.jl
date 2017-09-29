push!(LOAD_PATH, "../src/")

import Eglob

using Documenter

makedocs()

open("build/index.md") do input
    open("index.md", "w") do output
        for line in readlines(input)
            m = match(r"^(<a.*\>)\#</a>", line)
            if m != nothing
                line = "$(m.captures[1])\u00a7</a>"
            end
            println(output, line)
        end
    end
end
