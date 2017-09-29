
<a id='The-Eglob-Module-1'></a>

# The `Eglob` Module



<a id='Eglob' href='#Eglob'>§</a>
**`Eglob`** &mdash; *Module*.



```
import Eglob: eglob, eglobt
```

`Eglob` provides extended globbing functions that support a recursive `**` wildcard pattern, similar to the `**` supported by the [Bash](https://www.gnu.org/software/bash/) (version 4+) `globstar` option and by [Zsh](http://www.zsh.org/). This package is built on top of [Glob.lj](https://github.com/vtjnash/Glob.jl).

  * `eglob()`: An extended globbing function that supports leading `~` expansion and a recursive `**` wildcard pattern
  * `eglobt()`: A Task- and Channel-based version of `eglob()`.

See the docs for the individual functions for more information.


<a target='_blank' href='https://github.com/bmc/Eglob.jl/tree/5029888468ded762a0e9657521fe71e1e4ff7ea9/src/Eglob.jl#L4-L18' class='documenter-source'>source</a><br>

<a id='Eglob.eglob' href='#Eglob.eglob'>§</a>
**`Eglob.eglob`** &mdash; *Function*.



```
eglob(pattern)
```

An extended globbing function that supports all the wildcards of the `glob()` function, plus:

  * a leading `~`, signifying the user's home directory (`~user` isn't supported)
  * a special `**` wildcard that recursively matches any directory.

`eglob()` is just a convenience front-end. It is exactly equivalent to:

```
[match for match in eglobt(pattern)]
```

**Parameters:**

  * `pattern`: The wildcard pattern

**Returns** an array of expanded path names, which might be empty. If the original path contains no wildcards, the result will be a 1-element array containing the original path.

**Note:** This function expands the entire pattern before returning. If you're expanding a pattern in a deeply-nested directory tree, `eglob()` can take awhile to return. If you want to process the results in a way that allows you to stop before seeing all of them, use `eglobt()`.


<a target='_blank' href='https://github.com/bmc/Eglob.jl/tree/5029888468ded762a0e9657521fe71e1e4ff7ea9/src/Eglob.jl#L44-L69' class='documenter-source'>source</a><br>

<a id='Eglob.eglobt' href='#Eglob.eglobt'>§</a>
**`Eglob.eglobt`** &mdash; *Function*.



```
eglobt(pattern)
```

An extended, Task- and Channel-based globbing function that supports all the wildcards of the `glob()` function, plus:

  * a leading `~`, signifying the user's home directory (`~user` isn't supported)
  * a special `**` wildcard that recursively matches any directory.

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


<a target='_blank' href='https://github.com/bmc/Eglob.jl/tree/5029888468ded762a0e9657521fe71e1e4ff7ea9/src/Eglob.jl#L74-L123' class='documenter-source'>source</a><br>

