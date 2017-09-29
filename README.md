# An extended globbing package for Julia

[![Build Status](https://travis-ci.org/bmc/Eglob.jl.svg?branch=master)](https://travis-ci.org/bmc/Eglob.jl)

`Eglob` provides extended globbing functions that support a recursive `**`
wildcard pattern, similar to the `**` supported by the
[Bash](https://www.gnu.org/software/bash/) (version 4+) `globstar` option
and by [Zsh](http://www.zsh.org/). This package is built on top of
[Glob.lj](https://github.com/vtjnash/Glob.jl).

* `eglob()`: An extended globbing function that supports leading `~` expansion
  and a recursive `**` wildcard pattern
* `eglobt()`: A Task- and Channel-based version of `eglob()`.

## Documentation

[Here you go.](http://software.clapper.org/Eglob.jl/)

## Installation

```julia
Pkg.add("Eglob")
```
