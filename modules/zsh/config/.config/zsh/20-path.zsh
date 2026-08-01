# Add command directories in priority order without adding nonexistent entries.
# Zsh keeps only the first occurrence of each directory in the path array.
typeset -U path

# Homebrew's root differs by architecture: /opt/homebrew on Apple silicon,
# /usr/local on Intel and on Linuxbrew's default layout. Resolve it from the
# brew binary that is actually present rather than by calling `brew --shellenv`,
# which forks a process on every shell start. Exported because formulas and
# scripts read it, and the paths below are built from it.
for homebrew_candidate in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [[ -x "$homebrew_candidate/bin/brew" ]]; then
    export HOMEBREW_PREFIX="$homebrew_candidate"
    break
  fi
done
unset homebrew_candidate

# Collect candidate directories before modifying the active PATH.
typeset -a path_entries
typeset -a existing_path_entries
path_entries=(
  "$HOME/.bin"
  "$HOME/bin"
  "$HOME/.local/bin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/bin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/sbin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/coreutils/libexec/gnubin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/gnu-sed/libexec/gnubin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/grep/libexec/gnubin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/python/libexec/bin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/ruby/bin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/postgresql@16/bin"
  "/usr/local/bin"
  "/usr/local/sbin"
  "/usr/sbin"
  "/usr/bin"
  "/sbin"
  "/bin"
)

# Keep only directories that are present on the current machine.
for path_entry in "${path_entries[@]}"; do
  [[ -d "$path_entry" ]] && existing_path_entries+=("$path_entry")
done

# Prepend valid entries so they take precedence over inherited system paths.
path=("${existing_path_entries[@]}" "${path[@]}")

# Remove helper variables and export the resulting PATH to child processes.
unset path_entries existing_path_entries path_entry
export PATH
