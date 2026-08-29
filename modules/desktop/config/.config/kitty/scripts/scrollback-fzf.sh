#!/bin/sh
# Pick lines out of the scrollback kitty pipes in on stdin and put them on the
# clipboard: the overlay window dies with fzf, so printing the selection would
# lose it. Mirrors the WezTerm binding in ../../wezterm/wezterm.lua.
#
# --ansi renders the formatting --stdin-add-formatting emits instead of printing
# it literally, --no-preview drops the bat preview FZF_DEFAULT_OPTS adds for file
# names, --no-mouse leaves mouse reporting to kitty so dragging selects text, and
# --multi marks several lines with Tab.

# GUI-launched kitty inherits launchd's minimal PATH, which excludes Homebrew.
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH

picked=$(fzf --ansi --reverse --no-preview --no-mouse --multi) || exit 0

# Esc leaves the selection empty; copying it would wipe the clipboard.
[ -n "$picked" ] && printf %s "$picked" | pbcopy
