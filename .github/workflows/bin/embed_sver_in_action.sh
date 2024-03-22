#!/bin/bash

cd "$(git rev-parse --show-toplevel)"
tmp=$(mktemp)
sed -n '1,/#action-sver-begin/p' action.yaml >"${tmp}"
sed 's/^/        /' sver >>"${tmp}"
sed -n '/#action-sver-end$/,$p' action.yaml >>"${tmp}"
mv "$tmp" action.yaml
