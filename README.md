# sver
Semver (Semantic Version) parsing & utility script/function library in pure bash

## Overview
`sver` is a self contained cli tool and function library implementing a [Semantic
Versioning 2](https://semver.org) compliant parser and utilities. Written in
optimized, portable, pure bash (v3+) for simplicity & speed.

### Features
- bump or get version identifiers (major, minor, patch, prerelease, build_metadata)
- precedence comparison functions strictly implement SemVer spec
- version constraint evaluation using common constraint syntax with chaining
- deconstruct semver identifiers and output in json or yaml
- validate a version or filter a list of versions for valid versions within
- sort versions w/ semver precedence using sort routine written with bash builtins
- bash command line completion function & injector built in
- uses bash primitives and builtins exclusively for speed & portability
- single script usable as a CLI or mixin bash function library (documentation in source)
- comprehensive [test](tests) coverage
- compatible with bash v3 for us poor macOS users

## Usage
### Installation
It is a self contained bash script, so you can clone the repo and run directly.
However, here are some other convenient ways to install it.
#### curl
You can simply curl a version directly.
```
curl -LO https://github.com/robzr/sver/releases/download/v1.0.0/sver
```

#### Homebrew
A Homebrew tap is available.
```
brew tap robzr/sver
brew installs ver
```
If we can get enough momentum for this project on GitHub, and meet Homebrew
criteria for a core formula, it will be added! This requires more than 75 stars,
30 forks or 30 watchers.

#### asdf
Coming soon, working on an asdf plugin.

### Command
See `sver help` for documentation.
```bash
sver v0.0.1 (https://github.com/robzr/sver) self contained cli tool and function
library implementing a Semantic Versioning 2 compliant parser and utilities.
Written in optimized, portable, pure bash (v3)+ for simplicity & speed.

Usage: sver <command> [<sub_command>] [<version>] [<constraint>]

Commands:
  bump major <version>
  bump minor <version>
  bump patch <version>
  complete -- bash command completion, use: . /dev/stdin <<< "$(sver complete)"
  constraint <version> <constraint(s)> -- version constraint evaluation - if
                              version matches constraint(s) ? exit 0 : exit 1
  equals <version1> <version2> -- version1 == version2 ? exit 0 : exit 1
  filter -- filters stdin list, returns only valid SemVers
  greater_than <version1> <version2> -- version1 > version2 ? exit 0 : exit 1
  get major <version>
  get minor <version>
  get patch <version>
  get prerelease <version>
  get build_metadata <version>
  help
  json <version> -- displays JSON map of components
  less_than <version1> <version2> -- version1 < version2 ? 0 : exit 1
  sort -- sorts stdin list of SemVers
  validate <version> -- version is valid ? exit 0 : exit 1
  version
  yaml <version> -- displays YAML map of components

Versions:
  Semantic Versioning 2 (https://semver.org) compliant versions, with an
  optional "v" prefix tolerated on input.

Constraints:
  Version constraint supports the following operators. Multiple comma-delimited
  constraints can be used. Abbreviated version substrings can be used, and are
  especially useful with pessimistic constraint.
    = <version_substring> -- equal
    > <version_substring> -- greater than
    >= <version_substring> -- greater than or equal to
    < <version_substring> -- less than
    <= <version_substring> -- less than or equal to
    ~> <version_substring> -- pessimistic constraint operator, allows the least
      significant (rightmost) identifier specified in the constraint to be
      incremented, but prevents more significant (further left) identifiers
      from being incremented.
  Examples: "~> v1.2, != v1.3", "> v1, <= v2.4.7, != v2.4.4"
```

### Bash function library
To use sver as a bash function library, source it with the `SVER_RUN=false` variable
set.
```bash
SVER_RUN=false . "$(command -v sver)"
```
The same commands and syntax are available as the CLI, but written as
functions, with the syntax `sver_<command>[_<subcommand>]`, ie: `sver_version`,
`sver_bump_major`, etc. See source for details.

# License
Permissive [Creative Commons - CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)
license - same as Semantic Versioning itself.

# TODO
- constraint testing
- asdf plugin
