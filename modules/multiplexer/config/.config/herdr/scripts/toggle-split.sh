#!/bin/bash
# Toggle split: create a right split when the tab has one pane, otherwise
# focus a neighboring pane. Herdr runs this from a [[keys.command]] binding
# and exports HERDR_ACTIVE_TAB_ID, HERDR_ACTIVE_PANE_ID and HERDR_BIN_PATH.

set -u

herdr="${HERDR_BIN_PATH:-herdr}"
tab="${HERDR_ACTIVE_TAB_ID:-}"
pane="${HERDR_ACTIVE_PANE_ID:-}"

if [[ -z "$tab" || -z "$pane" ]]; then
  current=$("$herdr" pane current) || exit 1
  tab=$(printf '%s' "$current" | jq -r '.result.pane.tab_id')
  pane=$(printf '%s' "$current" | jq -r '.result.pane.pane_id')
fi

count=$("$herdr" pane list | jq -r --arg tab "$tab" \
  '[.result.panes[] | select(.tab_id == $tab)] | length') || count=0

if [[ "${count:-0}" -le 1 ]]; then
  exec "$herdr" pane split --pane "$pane" --direction right
fi

for direction in right left down up; do
  out=$("$herdr" pane focus --pane "$pane" --direction "$direction") || continue
  printf '%s' "$out" | grep -q '"no_neighbor"' || exit 0
done
