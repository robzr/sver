# sver
Semantic Version parsing and utility script and function library in pure bash

## Overview
`sver` is a self contained cli tool and function library implementing a Semantic
Versioning 2 [Semantic Versioning 2](https://semver.org) compliant parser and
utilities. Written in optimized, portable, pure bash for simplicity & speed.

### Features
- bump or get version identifiers (major, minor, patch, prerelease, build_metadata)
- precedence comparison functions strictly implement SemVer spec
- version constraint evaluation using common constraint syntax with chaining
- deconstruct semver identifiers and output in json or yaml
- validate a version or filter a list of versions for valid versions within
- sort versions based on precedence using sort routine written with portable, builtin bash functions
- bash command line completion function & injector built in
- uses bash primitives and builtins wherever possible 
- sub shell calls are minimized and use only standard POSIX commands
- single script usable as a CLI or mixin bash function library (documentation in source)

# License
Permissive [Creative Commons - CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) license - same as Semantic Versioning itself.

# TODO
- need to complete version substring handling in comparison functions
- redo constraint comparisons to work with version substrings
- write pessimistic constraint operator handling
- asdf plugin
- homebrew plugin
- github action
