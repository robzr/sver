#!/bin/bash -eo pipefail
#set -x

SVER_BIN="$(git rev-parse --show-toplevel)/sver"
TESTS_JSON=$(mktemp)
TESTS_YAML=tests/tests.yaml
TESTS_YAML_FULL="$(git rev-parse --show-toplevel)/${TESTS_YAML}"
yq @json "$TESTS_YAML_FULL" > "$TESTS_JSON"

EXAMPLES_VALID=$(
  jq -r '
    .examples.valid |
    split("\n")[] |
    select(
      test("^\\s*$") or test("^\\s*#") |
      not
    )
    ' "$TESTS_JSON"
)

EXAMPLES_INVALID=$(
  jq -r '
    .examples.invalid |
    split("\n")[] |
    select(
      test("^\\s*$") or test("^\\s*#") |
      not
    )
    ' "$TESTS_JSON"
)

TESTS_FAILED=0

echo -n 'Testing filter '
EXAMPLES_VALID_AND_INVALID="${EXAMPLES_VALID}
${EXAMPLES_INVALID}"
sum_filtered=$($SVER_BIN filter <<< "$EXAMPLES_VALID_AND_INVALID" | sum)
sum_valid=$(sum <<< "$EXAMPLES_VALID")
if [ "$sum_filtered" = "$sum_valid" ] ; then
  echo '- passed.'
else
  echo '- failed!'
  ((TESTS_FAILED++))
fi

echo -n 'Testing sort '

echo 'Testing valid example versions'
while read -r line ; do
  TESTS_FAILED_BEFORE=$TESTS_FAILED
  echo -n "- checking \"${line}\" - validate"
  if ! $SVER_BIN validate "$line" ; then
    ((TESTS_FAILED++))
  fi
  echo -n ', yaml'
  if ! $SVER_BIN yaml "$line" | yq . >/dev/null; then
    ((TESTS_FAILED++))
  fi
  echo -n ', json'
  if ! $SVER_BIN json "$line" | jq . >/dev/null; then
    ((TESTS_FAILED++))
  fi
  if [ $TESTS_FAILED -gt $TESTS_FAILED_BEFORE ] ; then
    echo ' - failed!'
  else
    echo ' - passed.'
  fi
done <<< "$EXAMPLES_VALID"

echo 'Testing invalid example versions'
while read -r line ; do
  TESTS_FAILED_BEFORE=$TESTS_FAILED
  echo -n "- checking \"${line}\" - validate"
  if $SVER_BIN validate "$line" 2>/dev/null ; then
    ((TESTS_FAILED++))
  fi
  echo -n ', yaml'
  if $SVER_BIN yaml "$line" 2>/dev/null | yq . >/dev/null; then
    ((TESTS_FAILED++))
  fi
  echo -n ', json'
  if $SVER_BIN json "$line" 2>/dev/null | jq . >/dev/null; then
    ((TESTS_FAILED++))
  fi
  if [ $TESTS_FAILED -gt $TESTS_FAILED_BEFORE ] ; then
    echo ' - failed!'
  else
    echo ' - passed.'
  fi
done <<< "$EXAMPLES_INVALID"

for command in bump get ; do
  for subcommand in $(jq -r ".${command} | keys | .[]" "$TESTS_JSON") ; do
    echo "Testing ${command} ${subcommand}"
    for argument in $(jq -r ".${command}.${subcommand} | keys | .[]" "$TESTS_JSON") ; do
      EXPECTED_VALUE=$(jq -r ".${command}.${subcommand}[\"${argument}\"]" "$TESTS_JSON")
      echo -n "- checking \"${argument}\""
      VALUE="$($SVER_BIN ${command} ${subcommand} "${argument}")"
      if [ "$VALUE" = "$EXPECTED_VALUE" ] ; then
        echo ' - passed.'
      else
        ((TESTS_FAILED++))
        echo " - failed (expected \"${EXPECTED_VALUE}\" got \"${VALUE}\")\!"
      fi
    done
  done
done

rm "$TESTS_JSON"

echo
if [ "$TESTS_FAILED" -gt 0 ] ; then
  echo "Found ${TESTS_FAILED} failures."
  exit -1
else
  echo "All tests passed."
  exit 0
fi

