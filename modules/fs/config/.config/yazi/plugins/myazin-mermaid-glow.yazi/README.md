# myazin-mermaid-glow.yazi

A Yazi previewer that renders Markdown through [glow][glow] after replacing
every ` ```mermaid ` fence with ASCII art from [mermaid-ascii][mermaid-ascii].

The preview is styled text and nothing else. There is no image protocol, no
network round trip, and no Node toolchain, so a diagram looks the same locally,
over SSH, and inside tmux, and it scrolls together with the prose around it.

The approach is borrowed from [`glowm`][glowm], a shell wrapper that pipes the
same two tools together; this is that idea as a previewer, with caching, output
slicing, and per-fence failure handling.

## Handled files

| Pattern | Behaviour |
| --- | --- |
| `*.md` | Mermaid fences become ASCII art, then the whole document goes through `glow`. |
| `*.mmd`, `*.mermaid` | The file is one diagram, so it is rendered directly without `glow`. |

## Dependencies

- `glow` is required. Without it the preview reports the failure instead of
  falling back to unstyled text.
- `mermaid-ascii` is optional. Without it every fence stays as Markdown source,
  which `glow` still prints as a highlighted code block.
- `gtimeout` (macOS, from `coreutils`) or `timeout` (Linux) is optional and
  caps a wedged child process. Detection is skipped once a wrapper is found.

`mermaid-ascii` supports `graph`/`flowchart`, `sequenceDiagram`, and
`erDiagram`. Anything else — `classDiagram` and `stateDiagram` among them —
fails to parse, and the fence then shows its own source with the parser's
reason above it:

```
> mermaid-ascii: unsupported graph type 'classDiagram'. Supported types: ...
```

## Configuration

Defaults work unconfigured. To override, call `setup` from `init.lua`:

```lua
require("myazin-mermaid-glow"):setup({
  style = "dark",       -- glow --style: a built-in name or a path to a JSON theme
  ascii = false,        -- true passes --ascii for plain ASCII instead of box drawing
  padding_x = nil,      -- mermaid-ascii --paddingX; nil keeps its own default
  padding_y = nil,      -- mermaid-ascii --paddingY; nil keeps its own default
  glow_timeout = 15,    -- wall-clock cap for glow, seconds
  mermaid_timeout = 10, -- wall-clock cap for one diagram, seconds
  read_limit_mb = 8,    -- larger files are not previewed
})
```

Register it in `yazi.toml`:

```toml
[plugin]
prepend_previewers = [
	{ url = "*.md", run = "myazin-mermaid-glow" },
	{ url = "*.mmd", run = "myazin-mermaid-glow" },
	{ url = "*.mermaid", run = "myazin-mermaid-glow" },
]
```

## Caching

Rendered output is cached under `$TMPDIR` (or `/tmp`), keyed by path, file
size, content, pane width, and theme. A cache hit spawns no processes at all,
which is what keeps scrolling responsive; a cold render of a document with four
diagrams costs roughly a quarter of a second. Failed runs are never cached, so
the next peek retries instead of serving broken output.

Whether `mermaid-ascii` is installed is deliberately left out of the cache key,
because checking it would cost a `command -v` on every scroll tick. The only
consequence is that entries cached before the binary was installed keep showing
Markdown source until the file changes or the cache is cleared:

```bash
rm -f "${TMPDIR:-/tmp}"/myazin-mermaid-glow-*
```

Rendering also writes short-lived `-scratch-` files, because both `glow` and
`mermaid-ascii` read a path rather than a stream. A completed render always
removes its own; a peek that Yazi cancels part-way through can leave one
behind, which the same command clears.

## Notes

- `glow` picks its colour profile from `isatty(stdout)`. A previewer always
  captures stdout, which would silently drop the output to bold-only with no
  colour, so the plugin sets `CLICOLOR_FORCE=1` on the child.
- Output is never re-wrapped. `glow` has already wrapped the prose to the pane
  width, and wrapping again would only affect the diagrams, folding their box
  drawing onto the next row. A diagram wider than the pane is clipped instead.
- A fence indented inside a list keeps its indent, so the diagram stays part of
  that list item.
- An unterminated fence is passed through verbatim rather than swallowing the
  rest of the file.

[glow]: https://github.com/charmbracelet/glow
[mermaid-ascii]: https://github.com/AlexanderGrooff/mermaid-ascii
[glowm]: https://gist.github.com/olavocarvalho/749053cb283642044064b93f183a056b
