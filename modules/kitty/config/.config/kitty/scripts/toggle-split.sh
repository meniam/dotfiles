#!/bin/bash
# Toggle split: create vsplit if alone, else switch to neighbor.

to_addr="${KITTY_LISTEN_ON:-unix:/tmp/kitty}"

json=$(kitten @ --to "$to_addr" ls --match-tab state:active 2>>/tmp/kitty-toggle-split.log) || {
  echo "kitty @ ls failed" >>/tmp/kitty-toggle-split.log
  exit 1
}

if command -v jq &>/dev/null; then
  count=$(echo "$json" | jq -r '.[0].tabs[0].windows | length // 0' 2>/dev/null)
else
  count=$(echo "$json" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(len(d[0]['tabs'][0]['windows']) if d and d[0].get('tabs') else 0)
except: print(0)
" 2>/dev/null)
fi

if [[ -z "$count" || "$count" -le 1 ]]; then
  kitten @ --to "$to_addr" launch --location=vsplit --cwd=current
else
  kitten @ --to "$to_addr" focus-window --match recent:1
fi
