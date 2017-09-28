__precompile__()


"""
    import Eglob: eglob, eglobt

`Eglob` provides extended globbing functions that support a recursive `**`
wildcard pattern, similar to the `**` supported by the
[Bash](https://www.gnu.org/software/bash/) (version 4+) `globstar` option
and by [Zsh](http://www.zsh.org/). This package is built on top of
[Glob.lj](https://github.com/vtjnash/Glob.jl).

* `eglob()`: An extended globbing function that supports leading `~` expansion
  and a recursive `**` wildcard pattern
* `eglobt()`: A Task- and Channel-based version of `eglob()`.

See the docs for the individual functions for more information.
"""
module Eglob

export eglob, eglobt

using Glob: glob

pathsep = Base.Filesystem.path_separator

#     _pathsplit(path)
# 
# Split a path into an array of path components, using the file separator
# ('/' on POSIX systems, '\' on Windows) that's appropriate for the
# underlying operating system. Does not take drive letters into account.
# If there's a Windows drive letter in the path, it'll end up with the
# first component.
# 
# **Parameters**
# 
# * `path`: path to split. Can be relative or absolute
# 
# **Returns** an array of path components
function _pathsplit(path::AbstractString)
    split(path, Base.Filesystem.path_separator_re, keep=false)
end

"""
    eglob(pattern)

An extended globbing function that supports all the wildcards of the `glob()`
function, plus:

- a leading `~`, signifying the user's home directory (`~user` isn't supported)
- a special `**` wildcard that recursively matches any directory.

`eglob()` is just a convenience front-end. It is exactly equivalent to:

    [match for match in eglobt(pattern)]

**Parameters:**

* `pattern`: The wildcard pattern

**Returns** an array of expanded path names, which might be empty. If the
original path contains no wildcards, the result will be a 1-element array
containing the original path.

**Note:** This function expands the entire pattern before returning. If you're
expanding a pattern in a deeply-nested directory tree, `eglob()` can take
awhile to return. If you want to process the results in a way that allows
you to stop before seeing all of them, use `eglobt()`.
"""
function eglob(pattern::AbstractString)
    [match for match in eglobt(pattern)]
end

"""
    eglobt(pattern)

An extended, Task- and Channel-based globbing function that supports all the
wildcards of the `glob()` function, plus:

- a leading `~`, signifying the user's home directory (`~user` isn't supported)
- a special `**` wildcard that recursively matches any directory.

**Parameters:**

* `pattern`: The wildcard pattern

**Returns** the channel to which results will be written.

**Examples**

Example 1:

```julia-repl
julia> import Glob: eglobt
julia> c = eglobt("**/*.csv") # find all CSV files below the current directory
julia> match1 = take!(c)
julia> match2 = take!(c)
```

Example 2:

```julia
# We only want three of them, but there might not be that many, so handle
# a prematurely empty channel.
import Glob: eglobt
c = eglobt("src/**/*.scala")
matches = []
for (i, match) in enumerate(c)
    if i > 3
        break
    end
    append!(matches, [match])
end
```

Example 3:

```julia
# Consume all matches. This is exactly what eglob() does.
matches = [match for match in eglobt("test/**/*.py")]
```

"""
function eglobt(pattern::AbstractString)

    dotslash = ".$(pathsep)"

    function putmatch!(channel::Channel, match::String)
        # Matching artifact: The code adds "./" to the beginning of matches
        # for things like "**/*.c". Remove it, if necessary.
        m = if startswith(match, dotslash) && !startswith(pattern, dotslash)
            match[3:end]
        else
            match
        end
        put!(channel, m)
    end

    function handle_recursive_glob(channel, directory, pieces)
        last = length(pieces) == 1
        remaining_pieces = last ? [] : @views pieces[2:end]
        for (root, dirs, files) in walkdir(directory, topdown=true)
            if last
                # At the end of a pattern, "**" just recursively matches
                # directories.
                putmatch!(channel, root)
            else
                # Recurse downward, trying to match the rest of the
                # pattern.
                if length(remaining_pieces) > 0
                    do_glob(channel, remaining_pieces, root)
                end
            end
        end
    end

    function handle_non_recursive_glob(channel, directory, piece, pieces)
        last = length(pieces) == 1
        path = joinpath(directory, piece)
        matches = glob(path)
        if length(matches) > 0
            if last
                # Save the last set of matches, and stop.
                for m in matches
                    putmatch!(channel, m)
                end
            else
                # Have to continue recursing.
                remaining_pieces = @views pieces[2:end]
                for m in filter(f -> isdir(f), matches)
                    do_glob(channel, remaining_pieces, m)
                end
            end
        end
    end

    function do_glob(channel, pieces, directory)
        if length(pieces) == 0
            return
        end

        piece = pieces[1]

        if piece == "**"
            handle_recursive_glob(channel, directory, pieces)
        else
            # It's just a regular (non-recursive) glob pattern.
            handle_non_recursive_glob(channel, directory, piece, pieces)
        end
    end

    function split_windows_eglob_pattern(pattern::AbstractString)
        drive, path = splitdrive(pattern)
        if (drive, path) == ("", "")
            (".", ".")
        elseif drive == ""
            (path, ".")
        elseif path == ""
            (".", drive)
        else
            # Hack: Can't handle non-absolute paths in a drive. Pretend a
            # drive letter means "absolute". Note that "drive" can be empty
            # here, which is fine.
            path2 = path[1] == '\\' ? path[2:end] : path
            (path2, drive * '\\')
        end
    end

    function split_posix_eglob_pattern(pattern::AbstractString)
        if length(pattern) == 0
            (".", ".")
        elseif pattern[1] == '/'
            (pattern[2:end], "/")
        else
            (pattern, ".")
        end
    end

    function main(channel::Channel)
        eglob_pattern_splitter = (is_windows() ? split_windows_eglob_pattern
                                               : split_posix_eglob_pattern)

        # Main eglob() logic.

        # First, account for leading "~"
        adjusted_pattern =
            if length(pattern) == 0
                "."
            elseif pattern[1] == '~'
                normpath(expanduser(pattern))
            else
                pattern
            end

        # Determine leading directory, which is different per OS (because of
        # Windows' stupid drive letters).
        relative_pattern, directory = eglob_pattern_splitter(adjusted_pattern)

        # Do the actual globbing.
        pieces = _pathsplit(relative_pattern)
        do_glob(channel, pieces, directory)
    end

    # Kick it off
    Channel(main)
end

end
