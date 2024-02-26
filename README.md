# sver
Semver (Semantic Version) parsing & utility script/function library in pure bash

## Overview
**sver** is a self contained cli tool and function library implementing a
[Semantic Versioning 2](https://semver.org) compliant parser and utilities.
Written in optimized, portable, pure Bash (v3+) for simplicity & speed, and
can be even used as a function library in Busybox Dash/Ash.

### Features
- bump or get version identifiers (major, minor, patch, prerelease, build_metadata)
- precedence comparison functions strictly implement SemVer spec
- version constraint evaluation using common constraint syntax with chaining
- deconstruct SemVer identifiers and output in json or yaml
- filter list of versions for valid versions that match an optional filter
- sort versions w/ SemVer precedence using fully builtin sort routine
- Bash command line completion function & injector built in
- uses Bash primitives and builtins exclusively for speed & portability
- single script usable as a CLI or mixin Bash/Dash/Ash function library
- comprehensive [test](tests) coverage
- compatible with Bash v3 for us poor macOS users

## Usage
### Installation
It is a self contained Bash script, so you can clone the repo and run directly.
However, here are some other convenient ways to install it.

#### asdf
A [PR](https://github.com/asdf-vm/asdf-plugins/pull/965) has been opened to add **sver**
into the asdf plugin registry; until that happens, you can manually specify the asdf
plugin repo.
```bash
asdf plugin add sver https://github.com/robzr/asdf-sver.git
asdf install sver latest
asdf global sver 1.0.0
```

#### curl
You can simply curl a version directly.
```bash
curl -LO https://github.com/robzr/sver/releases/download/v1.0.0/sver
```

#### Homebrew
A Homebrew tap is available.
```bash
brew tap robzr/sver
brew install sver
```
If we can get enough momentum for this project on GitHub to meet Homebrew
criteria for a core formula, it will be added! This requires more than 75 stars,
30 forks or 30 watchers.

### Command line usage
See `sver help` for documentation.
```text
sver v1.1.0 (https://github.com/robzr/sver) self contained cli tool and function
library implementing a Semantic Versioning 2 compliant parser and utilities.
Written in optimized, portable, pure Bash (v3)+ for simplicity & speed.

Usage: sver <command> [<sub_command>] [<version>|<option> ...]

Commands:
  bump major <version>
  bump minor <version>
  bump patch <version>
  complete -- Bash command completion, use: . /dev/stdin <<< "$(sver complete)"
  constraint <version> <constraint(s)> -- version constraint evaluation - if
                              version matches constraint(s) ? exit 0 : exit 1
  equals <version1> <version2> -- version1 == version2 ? exit 0 : exit 1
  filter [filter] -- filters stdin list, returns only valid SemVers
  greater_than <version1> <version2> -- version1 > version2 ? exit 0 : exit 1
  get major <version>
  get minor <version>
  get patch <version>
  get prerelease <version>
  get build_metadata <version>
  help
  json <version> -- displays JSON map of components
  less_than <version1> <version2> -- version1 < version2 ? 0 : exit 1
  max [filter] -- returns max value from stdin list
  min [filter] -- returns min value from stdin list
  sort [-r] [filter] -- sorts stdin list of SemVers (-r for reverse sort)
  validate <version> -- version is valid ? exit 0 : exit 1
  version
  yaml <version> -- displays YAML map of components

Versions:
  Semantic Versioning 2 (https://semver.org) compliant versions, with an
  optional "v" prefix tolerated on input.

Filters:
  Some commands take an optional <filter> argument, which is a version substring
  that any output must match. Examples: "filter v5.0", "sort v1", "min v1.2.3-"

Constraints:
  Multiple comma-delimited constraints can be chained together (boolean AND).
  Version substrings can be used, and are especially useful with the pessimistic
  constraint operator. Supported operators:
    = <version_substring> -- equal
    > <version_substring> -- greater than
    >= <version_substring> -- greater than or equal to
    < <version_substring> -- less than
    <= <version_substring> -- less than or equal to
    ~> <version_substring> -- pessimistic constraint operator - least significant
       (rightmost) identifier specified in the constraint matched with >=, but
       more significant (further left) identifiers must be equal
  Examples: "~> v1.2, != v1.3", "> v1, <= v2.5, != v2.4.4"
```

### Bash function library
To use **sver** as a Bash function library, source it with the `SVER_RUN=false`
variable set.
```bash
SVER_RUN=false . "$(command -v sver)"
```
As the CLI is simply a mapping to the function library, the commands and syntax
are the same, with the functions naming pattern `sver_<command>[_<subcommand>]`,
ie: `sver_version`, `sver_bump_major`, etc. To avoid the use of subshells and 
redirection for returning string values, functions generally return values via
the global `REPLY` variable. Note that this is a reuse of the default response
variable used by Bash (and Dash) `read`.

### Dash/Ash function library
The command line completion and CLI command-to-function mapping depends on the
Bash builtin `compgen`, which is not available in Dash (commonly used as the
default shell in Alpine Linux and other compact distributions that use Busybox).
Therefore, as the script is written, it will not function in Dash. However,
all of the core **sver** functions can be used, although the `sort` function,
differs from the Bash implementation, by using a shell call to Busybox `sort`,
and does not fully sort prereleases according to SemVer spec. Every other
function is identical. To use **sver** in Dash, the Bash specific syntax needs
to first be stripped out, which can be done with the following command (even
with Busybox):
```
sed -n '/# bash-only-begin/,/# bash-only-end/!p' sver > sver.dash
. sver.dash
```

# License
Permissive [Creative Commons - CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)
license - same as Semantic Versioning itself.
