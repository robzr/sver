#!/bin/bash
# shellcheck disable=SC2155
set -o errexit -o pipefail

SVER_BIN="$(git rev-parse --show-toplevel)/sver"
TESTS_YAML=tests/tests.yaml

_get_sha() {
  local sha=$(shasum)
  echo "${sha:0:6}"
}

_get_split_json() {
  jq --arg key "$2" \
    --arg key2 "$3" \
    -r '
      .[$key][$key2] |
      split("\n")[] |
      select(
        test("^\\s*$") or test("^\\s*#") |
        not
      )
    ' "$1"
}

test_sort() {
  local presorted presorted_sha sorted sorted_sha unsorted unsorted_sha
  local random=$([ "$1" = "-r" ] && echo true || echo false)
  local sort_status=0

  presorted=$(sed 's/\+.*//') # filter out build metadata as it is not sorted
  presorted_sha=$(_get_sha <<<"$presorted")

  if $random; then
    unsorted=$(sort -R -t. -k1 -k2 -k3 <<<"$presorted")
  else
    unsorted=$(sort -rn -t. -k1 -k2 -k3 <<<"$presorted")
  fi

  unsorted_sha=$(_get_sha <<<"$unsorted")
  sorted=$($SVER_BIN sort <<<"$unsorted")
  sorted_sha=$(_get_sha <<<"$sorted")

  if [ "$sorted_sha" != "$presorted_sha" ]; then
    sort_status=1
    cat >"sort-unsorted-${unsorted_sha}.txt" <<<"$unsorted"
    cat >"sort-sorted-${sorted_sha}.txt" <<<"$sorted"
  fi

  printf -- \
    '- checking sort %s (%s) - %s\n' \
    "$($random && echo "random" || echo "fixed")" \
    "$unsorted_sha" \
    "$([ "$sort_status" -eq 0 ] && echo 'passed.' || echo "failed ($sorted_sha)!")"

  return $sort_status
}

TESTS_JSON=$(mktemp)
TESTS_YAML_FULL="$(git rev-parse --show-toplevel)/${TESTS_YAML}"
yq @json "$TESTS_YAML_FULL" >"$TESTS_JSON"

EXAMPLES_SORTED=$(_get_split_json "$TESTS_JSON" examples sorted)
EXAMPLES_VALID=$(_get_split_json "$TESTS_JSON" examples valid)
EXAMPLES_INVALID=$(_get_split_json "$TESTS_JSON" examples invalid)

TESTS_FAILED=0

echo -n 'Testing filter '
EXAMPLES_VALID_AND_INVALID="${EXAMPLES_VALID}
${EXAMPLES_INVALID}"
sum_filtered=$($SVER_BIN filter <<<"$EXAMPLES_VALID_AND_INVALID" | sum)
sum_valid=$(sum <<<"$EXAMPLES_VALID")
if [ "$sum_filtered" = "$sum_valid" ]; then
  echo '- passed.'
else
  echo '- failed!'
  ((TESTS_FAILED++))
fi

echo 'Testing sorts'
sort_output=$(mktemp)
test_sort <<<"$EXAMPLES_SORTED" &
for ((x = 0; x < 5; x++)); do
  (
    test_sort -r <<<"$EXAMPLES_SORTED"
    echo $? >"${sort_output}.${x}"
  ) &
done
wait
for ((x = 0; x < 5; x++)); do
  REPLY=$(cat "${sort_output}.${x}")
  if [ "$REPLY" != 0 ]; then ((TESTS_FAILED++)); fi
done

echo 'Testing valid example versions'
while read -r line; do
  echo -n "- checking \"${line}\" - validate"
  if ! $SVER_BIN validate "$line"; then
    ((TESTS_FAILED++))
    echo ' - failed!'
  else
    echo ' - passed.'
  fi

  echo -n "- checking \"${line}\" - yaml"
  if ! $SVER_BIN yaml "$line" | yq . >/dev/null; then
    ((TESTS_FAILED++))
    echo ' - failed!'
  else
    echo ' - passed.'
  fi

  echo -n "- checking \"${line}\" - json"
  if ! $SVER_BIN json "$line" | jq . >/dev/null; then
    ((TESTS_FAILED++))
    echo ' - failed!'
  else
    echo ' - passed.'
  fi
done <<<"$EXAMPLES_VALID"

echo 'Testing invalid example versions'
while read -r line; do
  echo -n "- checking \"${line}\" - validate"
  if $SVER_BIN validate "$line" 2>/dev/null; then
    ((TESTS_FAILED++))
    echo ' - failed!'
  else
    echo ' - passed.'
  fi
done <<<"$EXAMPLES_INVALID"

for command in bump get; do
  for subcommand in $(jq -r ".${command} | keys | .[]" "$TESTS_JSON"); do
    echo "Testing ${command} ${subcommand}"
    for argument in $(jq -r ".${command}.${subcommand} | keys | .[]" "$TESTS_JSON"); do
      EXPECTED_VALUE=$(jq -r ".${command}.${subcommand}[\"${argument}\"]" "$TESTS_JSON")
      echo -n "- checking \"${argument}\""
      VALUE="$($SVER_BIN ${command} "${subcommand}" "${argument}")"
      if [ "$VALUE" = "$EXPECTED_VALUE" ]; then
        echo ' - passed.'
      else
        ((TESTS_FAILED++))
        echo " - failed (expected \"${EXPECTED_VALUE}\" got \"${VALUE}\")!"
      fi
    done
  done
done

# shellcheck disable=SC2043
for command in constraint; do
  while read -r constraint; do
    echo "Testing ${command} \"${constraint}\""
    for version in $(jq -r ".${command}[\"${constraint}\"] | keys | .[]" "$TESTS_JSON"); do
      EXPECTED_VALUE=$(jq -r ".${command}[\"${constraint}\"][\"${version}\"]" "$TESTS_JSON")
      echo -n "- checking \"${version}\""
      VALUE=false
      if $SVER_BIN "$command" "$version" "$constraint" >/dev/null; then
        VALUE=true
      fi
      if [ "$VALUE" = "$EXPECTED_VALUE" ]; then
        echo ' - passed.'
      else
        ((TESTS_FAILED++))
        echo " - failed (expected \"${EXPECTED_VALUE}\" got \"${VALUE}\")!"
      fi
    done
  done <<<"$(jq -r ".${command} | keys | .[]" "$TESTS_JSON")"
done

echo -n 'Testing max'
VALUE=$($SVER_BIN max <<<"$EXAMPLES_VALID")
EXPECTED_VALUE=$(jq -r .examples.valid_max "$TESTS_JSON")
if [ "$VALUE" = "$EXPECTED_VALUE" ]; then
  echo ' - passed.'
else
  ((TESTS_FAILED++))
  echo " - failed (expected \"${EXPECTED_VALUE}\" got \"${VALUE}\")!"
fi

echo -n 'Testing min'
VALUE=$($SVER_BIN min <<<"$EXAMPLES_VALID")
EXPECTED_VALUE=$(jq -r .examples.valid_min "$TESTS_JSON")
if [ "$VALUE" = "$EXPECTED_VALUE" ]; then
  echo ' - passed.'
else
  ((TESTS_FAILED++))
  echo " - failed (expected \"${EXPECTED_VALUE}\" got \"${VALUE}\")!"
fi

rm "$TESTS_JSON"

echo
if [ "$TESTS_FAILED" -gt 0 ]; then
  echo "Found ${TESTS_FAILED} failures."
  exit 1
else
  echo "All tests passed."
  exit 0
fi
