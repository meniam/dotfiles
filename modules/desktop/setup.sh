#!/usr/bin/env bash
# Install Hammerspoon, WezTerm, and Kitty using the platform's supported package
# source, then apply the macOS system defaults and default application handlers.
#
# Set DOTFILES_DRY_RUN=1 to report every system default this script would change
# without writing anything. macOS preferences are owned by cfprefsd and cannot be
# stowed as a payload, so a dry run is the only way to review them beforehand.
set -euo pipefail
. "$DOTFILES_DIR/lib/common.sh"
detect_os

if [ "$OS" = "mac" ] && [ ! -d /Applications/Hammerspoon.app ]; then
  step "Installing Hammerspoon with Homebrew" "*"
  brew_cask_install hammerspoon
fi

if ! command -v wezterm >/dev/null 2>&1; then
  case "$OS" in
    mac)
      step "Installing WezTerm with Homebrew" "*"
      brew install --cask wezterm
      ;;
    linux)
      if apt_has_candidate wezterm; then
        step "Installing WezTerm from configured APT sources" "*"
        apt_install wezterm
      else
        warn "WezTerm is unavailable from the configured APT sources."
        warn "Set up the official repository, then rerun this module: https://wezterm.org/install/linux.html"
      fi
      ;;
  esac
fi

if ! command -v kitty >/dev/null 2>&1; then
  case "$OS" in
    mac)
      step "Installing Kitty with Homebrew" "*"
      brew install --cask kitty
      ;;
    linux)
      step "Installing Kitty from configured APT sources" "*"
      apt_install kitty
      ;;
  esac
fi

# Everything below configures macOS itself.
[ "$OS" = "mac" ] || exit 0

dry_run="${DOTFILES_DRY_RUN:-}"
backup_root=""
backed_up_domains=""
restart_processes=""
changed_defaults=0

# Export a domain once, before the first value in it is modified. `defaults
# delete` restores Apple's default rather than the value that was there before,
# so importing this dump is the only real undo. Per-host values written with
# -currentHost live in a separate store and are not part of it.
backup_domain() {
  local domain="$1"

  case " $backed_up_domains " in
    *" $domain "*) return 0 ;;
  esac
  backed_up_domains="$backed_up_domains $domain"

  if [ -z "$backup_root" ]; then
    backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)-$$/defaults"
    mkdir -p "$backup_root"
  fi

  # A domain can be a path, as com.apple.LaunchServices/com.apple.launchservices.secure
  # is, so the dump needs its parent directory created first.
  mkdir -p "$(dirname "$backup_root/$domain.plist")"

  if defaults export "$domain" "$backup_root/$domain.plist" 2>/dev/null; then
    warn "Backed up $domain to $backup_root/$domain.plist"
  else
    warn "Could not export $domain; changing it without a backup."
  fi
}

# Write a preference only when the stored value differs from the wanted one, so
# a second run neither rewrites preferences nor restarts Finder and the Dock for
# nothing. Processes that have to reread their preferences are collected and
# restarted once, after every write.
#
# Usage: set_default [--current-host] <domain> <key> <type> <value> [process]
set_default() {
  local scope=""
  if [ "$1" = "--current-host" ]; then
    scope="-currentHost"
    shift
  fi

  local domain="$1" key="$2" type="$3" value="$4" process="${5:-}"
  local current expected

  # `defaults read` prints booleans as 0 and 1, so the wanted value has to be
  # reduced to the same form before the two can be compared.
  case "$type" in
    bool)
      case "$value" in
        true | yes | 1) expected=1 ;;
        *) expected=0 ;;
      esac
      ;;
    *) expected="$value" ;;
  esac

  # shellcheck disable=SC2086 # $scope is either empty or the single -currentHost flag.
  current="$(defaults $scope read "$domain" "$key" 2>/dev/null)" || current=""
  [ "$current" != "$expected" ] || return 0

  changed_defaults=$((changed_defaults + 1))

  # A dry run reports on stderr instead of going through log(), which the
  # installer silences unless it runs with --verbose: printing the pending
  # changes is the entire purpose of this mode.
  if [ -n "$dry_run" ]; then
    printf '   would set %s %s: %s -> %s\n' \
      "$domain" "$key" "${current:-<unset>}" "$expected" >&2
    return 0
  fi

  backup_domain "$domain"
  # shellcheck disable=SC2086 # As above.
  defaults $scope write "$domain" "$key" "-$type" "$value"
  log "$domain $key: ${current:-<unset>} -> $expected"

  [ -n "$process" ] || return 0
  case " $restart_processes " in
    *" $process "*) ;;
    *) restart_processes="$restart_processes $process" ;;
  esac
}

step "Applying macOS defaults" "*"

# Substitutions that are helpful in prose corrupt code and shell commands in
# every Cocoa text field: straight quotes become typographic ones, a double
# hyphen becomes an en dash, and the first word of a line is capitalised.
set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled bool false
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled bool false
set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false
set_default NSGlobalDomain NSAutomaticCapitalizationEnabled bool false
set_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool false

# Repeat a held key instead of opening the accent picker. Accented Latin
# characters then come from the Character Viewer; Cyrillic input is unaffected.
set_default NSGlobalDomain ApplePressAndHoldEnabled bool false

# Show every file extension, and let Tab reach buttons in dialogs rather than
# only text fields.
set_default NSGlobalDomain AppleShowAllExtensions bool true Finder
set_default NSGlobalDomain AppleKeyboardUIMode int 3

# Open save panels expanded, and keep new documents on the local disk.
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode bool true
set_default NSGlobalDomain NSDocumentSaveNewDocumentsToCloud bool false

# Finder: the full POSIX path in the window title, a status bar with the item
# count and free space, folders before files, search scoped to the current
# folder instead of the whole Mac, and no prompt when an extension changes.
set_default com.apple.finder _FXShowPosixPathInTitle bool true Finder
set_default com.apple.finder ShowStatusBar bool true Finder
set_default com.apple.finder _FXSortFoldersFirst bool true Finder
set_default com.apple.finder FXDefaultSearchScope string SCcf Finder
set_default com.apple.finder FXEnableExtensionChangeWarning bool false Finder

# Stop .DS_Store files from being written onto network shares and USB volumes,
# where they end up in someone else's backup or version control. Existing mounts
# keep their current behaviour until they are mounted again.
set_default com.apple.desktopservices DSDontWriteNetworkStores bool true
set_default com.apple.desktopservices DSDontWriteUSBStores bool true

# Collect screenshots in one directory instead of on the desktop, and drop the
# translucent shadow that otherwise surrounds every captured window.
screenshot_dir="$HOME/Screenshots"
[ -n "$dry_run" ] || mkdir -p "$screenshot_dir"
set_default com.apple.screencapture location string "$screenshot_dir" SystemUIServer
set_default com.apple.screencapture disable-shadow bool true SystemUIServer

# Dock: hide it, and remove the half-second delay before it slides back in.
# Recent applications no longer stretch it, and Spaces keep the order they were
# created in instead of being sorted by most recent use.
set_default com.apple.dock autohide bool true Dock
set_default com.apple.dock autohide-delay float 0 Dock
set_default com.apple.dock autohide-time-modifier float 0.2 Dock
set_default com.apple.dock show-recents bool false Dock
set_default com.apple.dock mru-spaces bool false Dock

# Tap to click, for the built-in trackpad and for a Magic Trackpad paired over
# Bluetooth. tapBehavior is written twice because the driver reads the per-host
# value while the global one is what System Settings displays. The built-in
# trackpad picks this up at the next login rather than immediately.
set_default com.apple.AppleMultitouchTrackpad Clicking bool true
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking bool true
set_default --current-host NSGlobalDomain com.apple.mouse.tapBehavior int 1
set_default NSGlobalDomain com.apple.mouse.tapBehavior int 1

if [ "$changed_defaults" -eq 0 ]; then
  log "Every macOS default already holds the value this module sets."
elif [ -n "$dry_run" ]; then
  success "$changed_defaults macOS defaults would change; nothing was written."
else
  success "Applied $changed_defaults macOS defaults."
fi

if [ -n "$restart_processes" ]; then
  # Intentional word splitting: restart_processes is a space-delimited list.
  # shellcheck disable=SC2086
  set -- $restart_processes
  for process in "$@"; do
    step "Restarting $process to reread its preferences" "*"
    killall "$process" >/dev/null 2>&1 || warn "$process was not running."
  done
fi

# Default application handlers. duti reapplies existing bindings without any
# effect, so this runs unconditionally, and the file it reads is the stowed
# payload rather than a list embedded here.
duti_settings="$HOME/.config/duti/settings.duti"
if [ -z "$dry_run" ] && [ -r "$duti_settings" ]; then
  if command -v duti >/dev/null 2>&1; then
    step "Applying default application handlers with duti" "*"
    duti "$duti_settings" || warn "duti could not apply every binding in $duti_settings."
  else
    warn "duti is unavailable; default application handlers are unchanged."
  fi
fi

# Extensions duti cannot bind, because macOS generates their type identifier from
# the extension and LaunchServices rejects a handler for a generated one with
# error -50. The binding Finder's `Change All…` writes is keyed by the extension
# instead, and that is what is added here.
launchservices_domain="com.apple.LaunchServices/com.apple.launchservices.secure"
launchservices_plist="$HOME/Library/Preferences/$launchservices_domain.plist"
handlers_file="$HOME/.config/launchservices/handlers.conf"

# Report the application currently bound to an extension, or nothing when the
# extension has no entry of its own.
extension_handler() {
  plutil -extract LSHandlers json -o - "$launchservices_plist" 2>/dev/null |
    jq -r --arg tag "$1" '
      .[] | select(.LSHandlerContentTag == $tag) | .LSHandlerRoleAll // empty
    ' 2>/dev/null | head -1
}

if [ -r "$handlers_file" ] && ! command -v jq >/dev/null 2>&1; then
  # Without jq an existing entry cannot be recognised, and appending a duplicate
  # for the same extension does nothing, so the file is skipped rather than
  # applied blindly. jq comes from the fs module this one depends on.
  warn "jq is unavailable; the filename extension handlers in $handlers_file are skipped."
elif [ -r "$handlers_file" ]; then
  handlers_changed=0

  while IFS="$(printf '\t')" read -r extension bundle_id; do
    case "$extension" in '' | '#'*) continue ;; esac
    [ -n "$bundle_id" ] || continue

    current_handler="$(extension_handler "$extension")"

    if [ -n "$current_handler" ]; then
      # An entry that already names another application was set in Finder or by
      # an earlier revision of this file. Overwriting it would silently undo a
      # deliberate choice, and appending a second entry for the same extension
      # has no effect, so it is reported instead.
      if [ "$current_handler" != "$bundle_id" ]; then
        warn ".$extension is bound to $current_handler; leaving it. Remove the entry in Finder to let $bundle_id take over."
      fi
      continue
    fi

    if [ -n "$dry_run" ]; then
      printf '   would bind .%s to %s\n' "$extension" "$bundle_id" >&2
      handlers_changed=$((handlers_changed + 1))
      continue
    fi

    backup_domain "$launchservices_domain"
    defaults write "$launchservices_domain" LSHandlers -array-add \
      "{LSHandlerContentTag = \"$extension\"; LSHandlerContentTagClass = \"public.filename-extension\"; LSHandlerRoleAll = \"$bundle_id\";}"
    log ".$extension -> $bundle_id"
    handlers_changed=$((handlers_changed + 1))
  done < "$handlers_file"

  if [ "$handlers_changed" -gt 0 ] && [ -z "$dry_run" ]; then
    # The LaunchServices daemon caches the handler table and only rereads it when
    # it is told to; without this the bindings appear to have had no effect.
    killall -HUP lsd >/dev/null 2>&1 || warn "lsd was not running; new extension bindings apply after the next login."
    success "Bound $handlers_changed filename extensions to an application."
  fi
fi
