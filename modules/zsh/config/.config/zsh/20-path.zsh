# Add command directories in priority order without adding nonexistent entries.
# Zsh keeps only the first occurrence of each directory in the path array.
typeset -U path

# Collect candidate directories before modifying the active PATH.
typeset -a path_entries
typeset -a existing_path_entries
path_entries=(
  "$HOME/.bin"
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/opt/homebrew/opt/coreutils/libexec/gnubin"
  "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
  "/opt/homebrew/opt/grep/libexec/gnubin"
  "/opt/homebrew/opt/python/libexec/bin"
  "/opt/homebrew/opt/ruby/bin"
  "/opt/homebrew/opt/postgresql@16/bin"
  "/usr/local/bin"
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
