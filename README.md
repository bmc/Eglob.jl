# An extended globbing package for Julia

[![Build Status](https://travis-ci.org/bmc/Eglob.jl.svg?branch=master)](https://travis-ci.org/bmc/Eglob.jl)

Provides extended globbing functions that support a recursive "**" wildcard
pattern. This package is built on top of
[Glob.lj](https://github.com/vtjnash/Glob.jl).

* `eglob()`: An extended globbing function that supports leading `~` expansion
  and a recursive `**` wildcard pattern
* `eglobt()`: A Task- and Channel-based version of `eglob()`.

## Installation

This package isn't yet registered. Until it is, use:

```julia
Pkg.clone("git://github.com/bmc/Eglob.jl.git")
```
