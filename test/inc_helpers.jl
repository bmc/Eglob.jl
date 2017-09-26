# Include this file to conditionally include the helpers.

# Pull in helpers if they're not already there. Including this file in
# test files allows the test files to be run separately, without causing
# duplicate definition or "replacing docs" warnings when the whole suite is
# run.
try
    _HELPERS_INCLUDED_
catch UndefVarError
    include("helpers.jl")
end
