# sver
Comprehensive Semantic Version (SemVer) parsing & utility script/function library/GitHub Action

## Overview
**sver** is a [cli tool](#command-line), [function library](#function-library) and [GitHub Action](#github-action) implementing a [Semantic Versioning 2](https://semver.org) compliant parser, utilities and version constraint matching.

Written in optimized, portable, pure Bash (v3+) for simplicity & speed, **sver** is a single file that can also be used as a function library in Bash or Busybox Dash/Ash.

### Features
- get or bump version identifiers (major, minor, patch, prerelease, build\_metadata)
- filter/min/max/sort lists of versions for valid versions with optional constraint matching
- output json/yaml objects with parsed version identifiers
- precedence comparisons (sort/equals/greater\_than/less\_than/min/max) strictly implement SemVer spec (unlike `sort -V` and most other utilities)
- version constraint evaluation using common constraint syntax with chaining (multiple constraints)
- Bash command line completion function & injector built in
- uses Bash primitives & builtins exclusively for speed & portability with minimal subshells (zero looped subshells)
- sort routine written with pure bash builtins and uses no subshells
- single small (< 20kB) script usable as a CLI or mixin Bash/Dash/Ash function library
- always formatted with [shfmt](https://github.com/patrickvane/shfmt)
- always checked with [shellcheck](https://github.com/koalaman/shellcheck) static analysis tool
- always unit tested with [comprehensive test](./tests) coverage
- compatible with Bash v3 for us poor macOS users

## GitHub Action
A composite GitHub Action is included in the repo, which makes for a very convenient way to run **sver** within your workflows.

Usage is simple, with the `command` input using the same syntax as the [command line interface](#command-line-usage).
```yaml
- uses: robzr/sver@v1
  with:
    command: version
```
The `output` output will contain the result, regardless of type (string,
boolean, JSON, YAML).
```yaml
- id: sver
  uses: robzr/sver@v1
  with:
    command: version

- if: steps.sver.outputs.output == 'v1.2.3'
  ...
```
Commands that return a boolean will return a boolean-as-string.
```yaml
- id: sver
  uses: robzr/sver@v1
  with:
    command: constraint "${VERSION}" '~> v1.0, !pre'

- if: steps.sver.outputs.output == 'true'
  ...
```
For commands that take input on stdin, like `filter`, `max`, `min`, or `sort`,
the `input` input can be specified.
```yaml
- id: sver
  uses: robzr/sver@v1
  with:
    command: max
    input: |
      v1.0.1
      v2.2.2
      ...

- if: steps.sver.outputs.output == env.VERSION
  ...
```
The `input-command` input is also available, and will run the provided command,
and use the command's output as input for **sver**.
```yaml
- uses: robzr/sver@v1
  with:
    command: max '< v1, !pre'
    input-command: git tag -l
```

## Command Line
### Installation
**sver** is a self contained Bash script, so you can clone the repo and run it directly,
or use one of the other convenient ways to install it.

#### asdf
The [asdf-sver](https://github.com/robzr/asdf-sver) plugin enables version management for **sver**. A [PR](https://github.com/asdf-vm/asdf-plugins/pull/965) has been opened for
inclusion into the asdf plugin registry; in the meantime you can manually specify the asdf plugin repo.
```bash
asdf plugin add sver https://github.com/robzr/asdf-sver.git
asdf install sver latest
asdf global sver latest
```

#### curl
You can simply curl a version directly.
```bash
curl -LO https://github.com/robzr/sver/releases/download/v1.2.3/sver
```

#### Homebrew
The [homebrew-sver](https://github.com/robzr/homebrew-sver) tap is maintained which tracks the latest release.
```bash
brew tap robzr/sver
brew install sver
```

### Command line usage
See `sver help` for documentation.
```text
sver v1.2.1 (https://github.com/robzr/sver) self contained cli tool and function
library implementing a Semantic Versioning 2 compliant parser and utilities.
Written in optimized, portable, pure Bash (v3)+ for simplicity & speed.

Usage: sver <command> [<sub_command>] [<version>] [(<constraint>|<option>|<version>) ...]

Commands:
  bump major <version>
  bump minor <version>
  bump patch <version>
  complete -- Bash command completion, use: . /dev/stdin <<< "$(sver complete)"
  constraint <version> <constraint(s)> -- version constraint evaluation - if
                              version matches constraint(s) ? exit 0 : exit 1
  equals <version1> <version2> -- version1 == version2 ? exit 0 : exit 1
  filter [constraint] -- filters stdin list, returns only valid SemVers
  greater_than <version1> <version2> -- version1 > version2 ? exit 0 : exit 1
  get major <version>
  get minor <version>
  get patch <version>
  get prerelease <version>
  get build_metadata <version>
  help
  json <version> -- displays JSON map of components
  less_than <version1> <version2> -- version1 < version2 ? 0 : exit 1
  max [constraint] -- returns max value from stdin list
  min [constraint] -- returns min value from stdin list
  sort [-r] [constraint] -- sorts stdin list of SemVers (-r for reverse sort)
  validate <version> -- version is valid ? exit 0 : exit 1
  version
  yaml <version> -- displays YAML map of components

Versions:
  Semantic Versioning 2 (https://semver.org) compliant versions, with an
  optional "v" prefix tolerated on input.

Constraints:
  Multiple comma-delimited constraints can be chained together (boolean AND) to
  form a single constraint expression. Commands that take a list of versions on
  stdin and take a constraint will filter the input for versions matching the
  constraint expression. Version substrings can be used, and are especially
  useful with the pessimistic constraint operator. Supported operators:
    = <version_substring> -- equal (default if no operator specified)
    > <version_substring> -- greater than
    >= <version_substring> -- greater than or equal to
    < <version_substring> -- less than
    <= <version_substring> -- less than or equal to
    ~> <version_substring> -- pessimistic constraint operator - least significant
       (rightmost) identifier specified in the constraint matched with >=, but 
       more significant (further left) identifiers must be equal
    !pre[release] -- does not contain a prerelease (ie: "stable")
    !bui[ild_metadata] -- does not contain build_metadata
  Examples: "~> v1.2, != 1.3", "> 1, <= v2.5, != v2.4.4", "v1, !pre"
```

### Command line completion
Command completion is available for Bash users. Simply add the following to your
`~/.bashrc`:
```
. /dev/stdin <<< "$(sver complete)"
```

## Function Library
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
all of the core **sver** functions can be used, although the `sort` function
differs from the Bash implementation by using a shell call to Busybox `sort`
and does not fully sort prereleases according to SemVer spec. Every other
function is identical. To use **sver** in Dash, the Bash specific syntax needs
to first be stripped out, which can be done with the following command (even
with Busybox):
```
sed -n '/# bash-only-begin/,/# bash-only-end/!p' sver > sver.dash
. sver.dash
```

## License
Permissive [Creative Commons - CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)
license - same as Semantic Versioning itself.
