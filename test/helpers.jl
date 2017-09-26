_HELPERS_INCLUDED_ = true

"""
    createfiles(dir, "foo/x.c", "bar/y.c")

Given a bunch of parent directories, create subdirectories and empty files
within it.
"""
function createfiles(dir::AbstractString, files...)
    filepaths = [joinpath(dir, f) for f in files]
    for path in filepaths
        dir = dirname(path)
        mkpath(dir)
        touch(path)
    end
end


"""
    withtempfiles("foo/x.c", "bar/y.c") do tempdir, files
        # your code
    end

Create a temporary directory, possibly fill it with some empty files,
call a supplied function, and then clean up the directory. Used for testing.
"""
function withtempfiles(f::Function, files::AbstractString...)
    tempdir = mktempdir()
    try
        createfiles(tempdir, files...)
        f(tempdir, files)
    finally
        rm(tempdir, force=true, recursive=true)
    end
end

"""
Find an appropriate shell that supports recursive globbing, to aid in
testing.
"""
function _findshell()
    shells = [
        # file   version arg  run args            version match            min
        ("bash", "--version", ["-O", "globstar"], r"bash,\s+version\s+(\d)", 4),
    ]

    function maybe_run(path, args)
        try
            if isfile(path)
                cmd = `$(path) $(args)`
                readlines(pipeline(cmd, stderr=DevNull))
            end
        catch e
            nothing
        end
    end

    if is_windows()
        nothing
    else
        path = split(ENV["PATH"], ":")
        found = nothing
        for (shell, versionarg, extraargs, re, minver) in shells, dir in path
            shell_path = joinpath(dir, shell)
            output = maybe_run(shell_path, versionarg)
            if output == nothing
                continue
            end

            possible_matches = [Base.match(re, line) for line in output]
            matches = filter(m -> m != nothing, possible_matches)
                
            if length(matches) == 0
                continue
            end

            match = matches[1]
            shell_version = parse(Int64, match.captures[1])
            if shell_version >= minver
                found = (shell_path, extraargs)
                break
            end
        end
        found
    end
end       

shell_and_args = _findshell()
if shell_and_args == nothing
    warn("No compatible shell found. Glob tests aren't possible.")
else
    let
        sh, args = shell_and_args
        args = join(args, " ")
        cmd = strip("$(sh) $(args)")
        info("""Using "$(cmd)" for shell wildcard expansion.""")
    end
end

"""
Uses Bash (v. 4 or better) to expand globs.
"""
function shellglob(pattern)
    if shell_and_args == nothing
        warn("shellglob: No compatible shell was found.")
        []
    else
        try
            (shell, args) = shell_and_args
            cmd = `$(shell) $(args) -c "echo $(pattern)"`
            res = split(chomp(readstring(pipeline(cmd, stderr=DevNull))), r"\s+")
            if (length(res) == 1) && (res[1] == pattern)
                []
            else
                res
            end
        catch e
            []
        end
    end
end
