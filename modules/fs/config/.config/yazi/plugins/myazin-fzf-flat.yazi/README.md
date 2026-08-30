# myazin-fzf-flat.yazi

fzf over a depth-capped listing of the current directory instead of its whole
subtree.

Yazi's built-in `fzf` plugin — bound to `Z` in this configuration — searches
everything below the current directory. That is the wrong shape when the wanted
entry is known to sit in or just below the directory already on screen and the
subtree is large enough that the recursive walk buries it. This plugin lists the
directory once, at the requested depth, and hands that list to fzf.

The depth is the first argument and defaults to 1:

```toml
run = "plugin myazin-fzf-flat"    # the directory itself
run = "plugin myazin-fzf-flat 2"  # and one level below it
```

The fzf prompt reads `flat:1>` or `flat:2>`, so the two bindings stay apparent
once the picker is up.

## Behaviour

The listing comes from `fd --hidden --no-ignore`, so it matches what the file
panel shows: dotfiles and gitignored entries are candidates, and directories are
listed alongside files. The pick is revealed rather than entered, so the cursor
moves onto it — entering the subdirectory that holds it when the depth is
2 — and `<Enter>` still opens or descends as usual. Cancelling with `<Esc>` or
`<C-c>` leaves the cursor where it was.

## Keys

| Key | Action |
|---|---|
| `\` | Search the current directory (fzf, no subdirectories) |
| `ё` | The same, for the Russian layout |
| `\|` | Search the current directory and one level below it |
| `Ё` | The same, for the Russian layout |

## Dependencies

- `fzf` — required.
- `fd` — required. Debian installs the binary as `fdfind`; the plugin falls back
  to that name when `fd` is absent.

## Configuration

None. The plugin takes no `setup()` call and no arguments.
