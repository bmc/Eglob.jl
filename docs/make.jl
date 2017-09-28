push!(LOAD_PATH, "../src/")

import Eglob

using Documenter

makedocs()
cp("build/index.md", "index.md")

