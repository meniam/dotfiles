#!/usr/bin/env bash
# Interactive module picker. UI is written to stderr; stdout returns names.
# shellcheck disable=SC2154

pick_modules() {
  local preselected="$1"
  shift
  local names=("$@")
  local count="${#names[@]}" index cursor=0
  local checked=()

  for ((index = 0; index < count; index++)); do
    case " $preselected " in
      *" ${names[index]} "*) checked[index]=1 ;;
      *) checked[index]=0 ;;
    esac
  done

  if ! { [ -t 0 ] && [ -t 2 ]; }; then
    local output=""
    for ((index = 0; index < count; index++)); do
      [ "${checked[index]}" -eq 1 ] && output="$output ${names[index]}"
    done
    printf '%s' "${output# }"
    return 0
  fi

  local lines=$((count + 3)) drawn=0
  draw_picker() {
    [ "$drawn" -eq 1 ] && printf '\033[%dA' "$lines" >&2
    drawn=1
    printf '\033[K%sSelect modules%s\n' "$c_bold" "$c_reset" >&2
    printf '\033[K%sUp/Down or j/k: move | Space: toggle | a: all | d: none | Enter: confirm | q: cancel%s\n' "$c_dim" "$c_reset" >&2
    printf '\033[K\n' >&2
    for ((index = 0; index < count; index++)); do
      local checkbox='[ ]' pointer='  '
      [ "${checked[index]}" -eq 1 ] && checkbox='[x]'
      [ "$index" -eq "$cursor" ] && pointer='> '
      if [ "$index" -eq "$cursor" ]; then
        printf '\033[K%s%s%s %-12s%s %s%s%s\n' \
          "$c_blue" "$pointer" "$checkbox" "${names[index]}" "$c_reset" "$c_dim" "$(module_description "${names[index]}")" "$c_reset" >&2
      else
        printf '\033[K%s%s %-12s %s%s%s\n' \
          "$pointer" "$checkbox" "${names[index]}" "$c_dim" "$(module_description "${names[index]}")" "$c_reset" >&2
      fi
    done
  }

  draw_picker
  local key rest
  while true; do
    IFS= read -rsn1 key || break
    if [ "$key" = $'\033' ]; then
      IFS= read -rsn2 rest 2>/dev/null || rest=''
      key="$key$rest"
    fi
    case "$key" in
      $'\033[A'|k) cursor=$(((cursor - 1 + count) % count)) ;;
      $'\033[B'|j) cursor=$(((cursor + 1) % count)) ;;
      ' ') checked[cursor]=$((1 - checked[cursor])) ;;
      a|A) for ((index = 0; index < count; index++)); do checked[index]=1; done ;;
      d|D) for ((index = 0; index < count; index++)); do checked[index]=0; done ;;
      ''|$'\n'|$'\r') break ;;
      q|Q) printf '\n' >&2; die "Selection cancelled." ;;
    esac
    draw_picker
  done
  printf '\n' >&2

  local output=""
  for ((index = 0; index < count; index++)); do
    [ "${checked[index]}" -eq 1 ] && output="$output ${names[index]}"
  done
  printf '%s' "${output# }"
}
