#!/usr/bin/env bash
# Module manifests, dependency resolution, status probes, and profiles.

load_module_conf() {
  description=""
  platforms="mac linux"
  deps=""
  default="off"
  probe=""
  # module.conf is trusted repository code and runs in a subshell by callers.
  # shellcheck disable=SC1090
  [ -f "$MODULES_DIR/$1/module.conf" ] && . "$MODULES_DIR/$1/module.conf"
}

module_description() { ( load_module_conf "$1"; printf '%s' "$description"; ); }
module_platforms() { ( load_module_conf "$1"; printf '%s' "$platforms"; ); }
module_dependencies() { ( load_module_conf "$1"; printf '%s' "$deps"; ); }
module_default() { ( load_module_conf "$1"; printf '%s' "$default"; ); }
module_probe() { ( load_module_conf "$1"; printf '%s' "$probe"; ); }

module_exists() { [ -f "$MODULES_DIR/$1/module.conf" ]; }

list_modules() {
  local directory
  for directory in "$MODULES_DIR"/*; do
    [ -d "$directory" ] || continue
    [ -f "$directory/module.conf" ] || continue
    basename "$directory"
  done | sort
}

has_modules() { [ -n "$(list_modules)" ]; }

platform_ok() {
  local module_platforms
  module_platforms="$(module_platforms "$1")"
  case " $module_platforms " in
    *" $OS "*) return 0 ;;
    *) return 1 ;;
  esac
}

module_installed() {
  local installed_probe
  installed_probe="$(module_probe "$1")"
  [ -n "$installed_probe" ] || return 2
  sh -c "$installed_probe" >/dev/null 2>&1
}

default_modules() {
  local module output=""
  for module in $(list_modules); do
    platform_ok "$module" || continue
    [ "$(module_default "$module")" = "on" ] && output="$output $module"
  done
  printf '%s' "${output# }"
}

_dependency_seen=""
_dependency_visiting=""

resolve_one() {
  local module="$1" dependency
  module_exists "$module" || die "Unknown module: '$module'. Available modules: $(list_modules | tr '\n' ' ')"
  case " $_dependency_seen " in *" $module "*) return ;; esac
  case " $_dependency_visiting " in *" $module "*) die "Circular dependency detected at module '$module'." ;; esac

  _dependency_visiting="$_dependency_visiting $module"
  for dependency in $(module_dependencies "$module"); do
    resolve_one "$dependency"
  done
  _dependency_seen="$_dependency_seen $module"
}

resolve_deps() {
  local module
  _dependency_seen=""
  _dependency_visiting=""
  for module in "$@"; do
    resolve_one "$module"
  done
  printf '%s' "${_dependency_seen# }"
}

expand_profile() {
  local profile_file="$PROFILES_DIR/$1"
  [ -f "$profile_file" ] || die "Unknown profile '$1'. Available profiles: $(list_profiles | tr '\n' ' ')"
  awk '!/^[[:space:]]*(#|$)/ { print }' "$profile_file" | tr '\n' ' '
}

list_profiles() {
  local profile
  for profile in "$PROFILES_DIR"/*; do
    [ -f "$profile" ] || continue
    basename "$profile"
  done | sort
}
