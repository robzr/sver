# sver/tests
Unit tests for sver

## Coverage
Test data is in [tests.yaml](tests.yaml), references to keys below are in this file.

### `bump (major|minor|patch)`
See top level `.bump`.

### Comparisons (`equals`, `greater_than` & `less_than`)
Indirectly tested during `bump` and `sort` tests.

### `complete`
No test coverage.

### `constraint`
TODO

### `get (major|minor|patch|prerelease|build)`
See top level `.get`.

### `json` 
Tested against valid and invalid example versions, see top level `.examples`.

### `sort`
Tested against valid versions, see top level `.examples.sorted`. Pre-sorted
input is unsorted both with a fixed reverse sort, as well as 5 random "sorts",
then sorted by sver, and the output is then compared to the pre-sorted input.

### `filter`

### `validate`
Tested against valid and invalid example versions, see top level `.examples`.

### `yaml` 
Tested against valid and invalid example versions, see top level `.examples`.


