# Include this file to conditionally include the helpers.

# Pull in helpers if they're not already there. Allows the file to be run
# by itself, as well as part of the entire suite of tests.
try
    findshell
catch UndefVarError
    include("helpers.jl")
end
