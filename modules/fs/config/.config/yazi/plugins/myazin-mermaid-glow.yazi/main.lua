-- myazin-mermaid-glow.yazi — Markdown previews with inline Mermaid diagrams.
--
-- The preview is plain styled text: every ```mermaid fence is replaced with
-- ASCII/Unicode art from `mermaid-ascii`, and the resulting document is piped
-- through `glow`. Nothing here needs an image protocol, a network round trip,
-- or a Node toolchain, so previews behave the same locally, over SSH, and
-- inside tmux, and the diagrams scroll together with the surrounding prose.
--
-- Dependencies:
--   glow          — required; without it the preview reports the failure
--   mermaid-ascii — optional; missing means mermaid fences stay as source
--   gtimeout/timeout — optional; caps a wedged child process

local M = {}

-- Defaults. M:setup(opts) merges user overrides on top, so init.lua can do:
--
--   require("myazin-mermaid-glow"):setup({ style = "auto", ascii = true })
-- The theme the shell's `glow` alias uses, so a preview and a terminal render
-- look alike. It is the default rather than a `setup()` call in init.lua because
-- a previewer runs in Yazi's async isolate, which does not necessarily see the
-- configuration applied in the sync one. glow runs with Yazi's cwd, so the path
-- has to be absolute; style_arg() falls back to a built-in name if it is missing.
--
-- Both candidates are tried rather than only the first that is set, so an
-- XDG_CONFIG_HOME pointing somewhere without a theme still finds the usual one.
local function default_style()
	local xdg, home = os.getenv("XDG_CONFIG_HOME"), os.getenv("HOME")
	local candidates = {}
	if xdg and xdg ~= "" then
		candidates[#candidates + 1] = xdg .. "/glow/theme.json"
	end
	if home and home ~= "" then
		candidates[#candidates + 1] = home .. "/.config/glow/theme.json"
	end
	for _, path in ipairs(candidates) do
		local f = io.open(path, "r")
		if f then
			f:close()
			return path
		end
	end
	return "dark"
end

local config = {
	style = default_style(), -- glow --style: a built-in name or a path to a JSON theme
	ascii = false, -- mermaid-ascii --ascii: plain ASCII instead of box drawing
	padding_x = nil, -- mermaid-ascii --paddingX; nil keeps its own default
	padding_y = nil, -- mermaid-ascii --paddingY; nil keeps its own default
	glow_timeout = 15, -- wall-clock cap for glow, seconds
	mermaid_timeout = 10, -- wall-clock cap for one mermaid-ascii render, seconds
	read_limit_mb = 16, -- refuse to preview files larger than this
}

function M:setup(opts)
	if type(opts) == "table" then
		for k, v in pairs(opts) do
			config[k] = v
		end
	end
end

-- ==========================================================================
-- Small helpers
-- ==========================================================================

-- Prefer TMPDIR over /tmp. On macOS it is a per-user directory with mode 0700,
-- so the predictable cache filenames below cannot be pre-created by another
-- user. On Linux it is usually unset and /tmp is the normal answer anyway.
local TMP = (os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "")
local PREFIX = TMP .. "/myazin-mermaid-glow-"

local function hash(s)
	if _G.ya and type(ya.hash) == "function" then
		return ya.hash(s)
	end
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % 4294967296
	end
	return string.format("%08x", h)
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function lines_of(text)
	local out = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		out[#out + 1] = line
	end
	return out
end

local function file_exists(path)
	local f = io.open(path, "r")
	if not f then
		return false
	end
	f:close()
	return true
end

-- Entropy for temporary filenames. Two preview isolates can reach the same
-- code path in the same second with identically seeded RNGs, so mix in real
-- randomness; the fallback deliberately avoids math.random for that reason.
local function entropy()
	local f = io.open("/dev/urandom", "rb")
	if f then
		local bytes = f:read(4)
		f:close()
		if type(bytes) == "string" and #bytes == 4 then
			local x = 0
			for i = 1, 4 do
				x = x * 256 + bytes:byte(i)
			end
			return string.format("%08x", x)
		end
	end
	-- Table addresses differ per VM thanks to ASLR, and os.clock is
	-- high-resolution and per-process.
	return string.format("%s%f", tostring({}):match("0x(%w+)") or "0", os.clock()):gsub("%.", "")
end

local function scratch_path(suffix)
	return string.format("%sscratch-%d-%s%s", PREFIX, os.time(), entropy(), suffix)
end

local function write_file(path, text)
	local f = io.open(path, "w")
	if not f then
		return false
	end
	f:write(text)
	f:close()
	return true
end

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local text = f:read("*all")
	f:close()
	return text
end

-- ==========================================================================
-- Process execution
-- ==========================================================================

-- Detect a timeout wrapper once. Only a positive result is memoised on disk:
-- caching "none" would survive a later `brew install coreutils` and keep the
-- caps disabled forever, while re-running two `command -v` calls costs little
-- and only happens on a cache miss.
local timeout_cmd_memo = nil
local function detect_timeout_cmd()
	if timeout_cmd_memo ~= nil then
		return timeout_cmd_memo ~= false and timeout_cmd_memo or nil
	end

	local marker = PREFIX .. "timeout-cmd"
	local cached = read_file(marker)
	if cached then
		cached = cached:gsub("%s+", "")
		if cached == "gtimeout" or cached == "timeout" then
			timeout_cmd_memo = cached
			return cached
		end
	end

	local function has(bin)
		local out = Command("sh"):arg({ "-c", "command -v " .. bin }):stdout(Command.PIPED):output()
		return out and out.status and out.status.success
	end

	local picked = (has("gtimeout") and "gtimeout") or (has("timeout") and "timeout") or nil
	if picked then
		write_file(marker, picked)
	end
	timeout_cmd_memo = picked or false
	return picked
end

-- Run a program with its output captured, optionally under a wall-clock cap.
-- Returns the yazi output table, or nil plus a message when the spawn failed.
local function run(bin, args, timeout_s, env)
	local program, argv = bin, args
	local wrapper = detect_timeout_cmd()
	if wrapper then
		program = wrapper
		argv = { tostring(timeout_s), bin }
		for _, a in ipairs(args) do
			argv[#argv + 1] = a
		end
	end

	local cmd = Command(program):arg(argv):stdout(Command.PIPED):stderr(Command.PIPED)
	for k, v in pairs(env or {}) do
		cmd = cmd:env(k, v)
	end

	local out, err = cmd:output()
	if err then
		return nil, string.format("cannot run %s (%s)", bin, tostring(err))
	end
	return out, nil
end

-- mermaid-ascii is optional, so its absence must stay cheap. A positive
-- result is memoised both in this isolate and on disk; a negative result is
-- memoised in the isolate only, which means installing the binary takes
-- effect after the next Yazi restart rather than needing a cache wipe.
local mermaid_ascii_memo = nil
local function has_mermaid_ascii()
	if mermaid_ascii_memo ~= nil then
		return mermaid_ascii_memo
	end
	if file_exists(PREFIX .. "have-mermaid-ascii") then
		mermaid_ascii_memo = true
		return true
	end

	local out = Command("sh"):arg({ "-c", "command -v mermaid-ascii" }):stdout(Command.PIPED):output()
	local ok = (out and out.status and out.status.success) or false
	if ok then
		write_file(PREFIX .. "have-mermaid-ascii", "yes")
	end
	mermaid_ascii_memo = ok
	return ok
end

-- ==========================================================================
-- Mermaid rendering
-- ==========================================================================

-- logrus writes fatals as `time="..." level=fatal msg="..."`; the msg field is
-- the only part worth showing. Fall back to the first non-empty stderr line.
local function explain(stderr)
	local detail = (stderr or ""):match('msg="([^"]*)"')
	if not detail then
		for _, line in ipairs(lines_of(stderr or "")) do
			if trim(line) ~= "" then
				detail = trim(line)
				break
			end
		end
	end
	detail = trim(detail or "")
	if detail == "" then
		return "mermaid-ascii failed"
	end
	if #detail > 160 then
		detail = detail:sub(1, 160) .. "..."
	end
	return detail
end

-- Render one diagram. Returns the art on success, or nil plus a reason.
-- mermaid-ascii accepts stdin via `-f -`, but yazi's Child write API is more
-- moving parts than a scratch file for no gain, and the file also keeps the
-- failure path free of partial-write ambiguity.
local function render_diagram(source)
	local input = scratch_path(".mmd")
	if not write_file(input, source) then
		return nil, "cannot write the mermaid source to " .. TMP
	end

	local args = { "-f", input }
	if config.ascii then
		args[#args + 1] = "--ascii"
	end
	if config.padding_x then
		args[#args + 1] = "--paddingX"
		args[#args + 1] = tostring(config.padding_x)
	end
	if config.padding_y then
		args[#args + 1] = "--paddingY"
		args[#args + 1] = tostring(config.padding_y)
	end

	local out, err = run("mermaid-ascii", args, config.mermaid_timeout)
	os.remove(input)

	if not out then
		return nil, err
	end
	if not out.status or not out.status.success then
		return nil, explain(out.stderr)
	end

	local art = (out.stdout or ""):gsub("%s+$", "")
	if art == "" then
		return nil, "mermaid-ascii produced no output"
	end
	return art, nil
end

-- ==========================================================================
-- Markdown preprocessing
-- ==========================================================================

-- Recognise a fence delimiter, returning its indent and info string. Both an
-- opening ```mermaid and a bare closing ``` come back through here; the caller
-- tells them apart by the info string. Indented fences matter because a
-- diagram nested in a list item must keep its indent to stay in that list.
local function fence_parts(line)
	local indent, info = line:match("^([ \t]*)```+%s*(.-)%s*$")
	if not indent then
		return nil
	end
	return indent, info
end

local function is_mermaid_open(info)
	local word = info:match("^(%S+)")
	return word ~= nil and word:lower() == "mermaid"
end

-- Emit the diagram source unchanged so a fence we could not render still shows
-- its content, prefixed with the reason when there is one worth reporting.
local function append_source(out, indent, body, reason)
	if reason then
		out[#out + 1] = indent .. "> mermaid-ascii: " .. reason
		out[#out + 1] = ""
	end
	out[#out + 1] = indent .. "```mermaid"
	for _, line in ipairs(body) do
		out[#out + 1] = line
	end
	out[#out + 1] = indent .. "```"
end

-- Handing the art to glow does not work. A code block is wrapped to --width,
-- which folds a wide diagram onto the next row and interleaves it with itself.
-- And chroma guesses a lexer from the content of a fence with no language, then
-- paints whatever it cannot tokenise with the theme's `error` style, which in
-- glow's own `dark` is white on red — box drawing becomes solid slabs. So each
-- fence becomes a marker word that survives glow untouched, and splice() puts
-- the art back afterwards.
local SLOT_PREFIX = "MMGSLOT"

local function preprocess(content, render)
	local out, slots = {}, {}
	local body, indent = nil, nil
	local count = 0

	-- A document that already contains the marker would have that line eaten by
	-- the splice, so salt the prefix when the bytes say it might.
	local prefix = SLOT_PREFIX
	if content:find(prefix, 1, true) then
		prefix = prefix .. hash(content)
	end

	local function append_slot(art)
		count = count + 1
		local token = string.format("%s%04dZ", prefix, count)
		slots[token] = lines_of(art)
		-- Its own paragraph, so glow neither merges the marker into neighbouring
		-- prose nor reflows it; the indent keeps a nested diagram in its list item.
		out[#out + 1] = ""
		out[#out + 1] = indent .. token
		out[#out + 1] = ""
	end

	for _, line in ipairs(lines_of(content)) do
		if body then
			local ind, info = fence_parts(line)
			if ind and info == "" then
				local art, reason = render(table.concat(body, "\n"))
				if art then
					append_slot(art)
				else
					append_source(out, indent, body, reason)
				end
				body, indent = nil, nil
			else
				body[#body + 1] = line
			end
		else
			local ind, info = fence_parts(line)
			if ind and is_mermaid_open(info) then
				body, indent = {}, ind
			else
				out[#out + 1] = line
			end
		end
	end

	-- An unterminated fence is a broken document, not a diagram; pass what we
	-- collected through untouched rather than dropping the tail of the file.
	if body then
		append_source(out, indent, body, nil)
	end
	return table.concat(out, "\n"), slots
end

local function strip_ansi(s)
	return (s:gsub("\27%[[%d;?]*[%a]", ""))
end

-- Columns a line occupies. Box drawing is single-width, so counting codepoints
-- is right here and much cheaper than a real wcwidth table.
local function display_width(s)
	return (utf8 and utf8.len(s)) or #s
end

-- Leftmost marker in a line, if any. Markers are plain ASCII words, so a
-- literal find over the still-coloured line is enough.
local function find_slot(line, slots)
	local at, found
	for token in pairs(slots) do
		local i = line:find(token, 1, true)
		if i and (not at or i < at) then
			at, found = i, token
		end
	end
	return at, found
end

-- Art wider than the pane is clipped by the widget rather than wrapped, so say
-- so: mermaid-ascii lays relationship labels out horizontally and an ER diagram
-- easily runs three times the width of a pane, with no flag to compress it.
local function append_art(out, lead, art, width)
	local widest = 0
	for _, line in ipairs(art) do
		out[#out + 1] = (line == "") and "" or (lead .. line)
		widest = math.max(widest, #lead + display_width(line))
	end
	if width > 0 and widest > width then
		out[#out + 1] = string.format("%s… %d columns wide, %d shown", lead, widest, width)
	end
end

-- Put the art back where its marker landed, keeping the left margin glow gave
-- the line so the diagram lines up with the prose around it. A marker is its
-- own paragraph in the input, but glow flattens a list item onto a single line,
-- so one can also turn up mid-line between the text it was written between —
-- hence splitting the line rather than only accepting a marker sitting alone.
local function splice(text, slots, width)
	if next(slots) == nil then
		return text
	end

	local out = {}
	for _, line in ipairs(lines_of(text)) do
		local at, token = find_slot(line, slots)
		if not at then
			out[#out + 1] = line
		else
			local lead = strip_ansi(line):match("^(%s*)") or ""
			local rest = line
			while at do
				local before = rest:sub(1, at - 1)
				if trim(strip_ansi(before)) ~= "" then
					-- Reset, so the art does not inherit the colour of the prose it
					-- was cut out of.
					out[#out + 1] = before .. "\27[0m"
				end
				append_art(out, lead, slots[token], width)
				rest = rest:sub(at + #token)
				at, token = find_slot(rest, slots)
			end
			if trim(strip_ansi(rest)) ~= "" then
				out[#out + 1] = lead .. "\27[0m" .. trim(rest)
			end
		end
	end
	return table.concat(out, "\n")
end

-- ==========================================================================
-- Rendering pipeline with an on-disk cache
-- ==========================================================================

-- glow decides its colour profile from isatty(stdout). Capturing stdout makes
-- it a pipe, which silently downgrades the output to bold-only with no colour
-- at all; CLICOLOR_FORCE tells termenv to keep the full ANSI palette anyway.
-- A style that names a file glow cannot find is fatal to it, which would turn
-- every Markdown preview into an error message. Fall back to a built-in name
-- when the theme has not been stowed yet, or was moved.
local function style_arg()
	local style = tostring(config.style)
	if style:find("/", 1, true) and not file_exists(style) then
		return "dark"
	end
	return style
end

local function run_glow(path, width)
	local out, err = run("glow", {
		"--style",
		style_arg(),
		"--width",
		tostring(width),
		path,
	}, config.glow_timeout, { CLICOLOR_FORCE = "1" })

	if not out then
		return nil, err
	end
	if not out.status or not out.status.success then
		local detail = trim(out.stderr or "")
		if detail == "" then
			detail = "glow exited unsuccessfully or timed out"
		end
		return nil, detail:sub(1, 200)
	end
	return out.stdout or "", nil
end

-- Write through a unique scratch file and rename, so a concurrent preview
-- isolate can never read a half-written cache entry.
local function store(cache_file, text)
	local tmp = scratch_path(".ans")
	if not write_file(tmp, text) then
		return
	end
	if not os.rename(tmp, cache_file) then
		os.remove(tmp)
	end
end

-- The cache key covers everything that changes the output: which file, its
-- full size (so an edit past the read limit still invalidates), the bytes we
-- actually read, the pane width glow wrapped to, and the theme.
--
-- Availability of mermaid-ascii is deliberately not part of the key. Including
-- it would cost a `command -v` on every scroll tick, and the only cost of
-- leaving it out is that entries cached before the binary was installed stay
-- stale until they age out or the file changes.
-- The style is keyed as the one actually used rather than as configured, so
-- entries rendered while the theme file was missing are not served afterwards.
local function cache_key(path, size, content, width)
	return hash(table.concat({ path, tostring(size), content, tostring(width), style_arg() }, "\0"))
end

local function render_markdown(path, size, content, width)
	local cache_file = PREFIX .. cache_key(path, size, content, width) .. ".ans"
	local cached = read_file(cache_file)
	if cached and #cached > 0 then
		return cached, nil
	end

	local document, slots = content, {}
	if has_mermaid_ascii() then
		document, slots = preprocess(content, render_diagram)
	end

	-- glow reads a file rather than stdin here for the same reason as
	-- render_diagram, and the extension keeps its markdown detection happy.
	local scratch = scratch_path(".md")
	if not write_file(scratch, document) then
		return nil, "cannot write the preprocessed document to " .. TMP
	end
	local text, err = run_glow(scratch, width)
	os.remove(scratch)

	if not text then
		return nil, err
	end
	text = splice(text, slots, width)
	-- A failed or timed-out run must not be cached, or the next peek would
	-- serve the broken output forever instead of retrying.
	store(cache_file, text)
	return text, nil
end

local function render_diagram_file(path, size, content)
	local cache_file = PREFIX .. cache_key(path, size, content, 0) .. ".art"
	local cached = read_file(cache_file)
	if cached and #cached > 0 then
		return cached, nil
	end

	if not has_mermaid_ascii() then
		return nil, "mermaid-ascii is not installed"
	end
	local art, reason = render_diagram(content)
	if not art then
		return nil, reason
	end
	store(cache_file, art)
	return art, nil
end

-- ==========================================================================
-- Previewer entry points
-- ==========================================================================

local function show(job, text, wrap)
	local lines = lines_of(text)
	local total = #lines
	local requested = math.max(0, job.skip or 0)
	-- Stop scrolling once the last line is on screen rather than once it is the
	-- only line on screen, so the end of a document is a full page instead of a
	-- single row above an empty pane.
	local skip = math.min(requested, math.max(0, total - job.area.h))
	if skip ~= requested then
		-- Hand the clamped position back so the next scroll continues from the
		-- end of the document instead of from wherever the overshoot landed.
		ya.emit("peek", { skip, only_if = job.file.url, upper_bound = true })
	end

	local visible = {}
	for i = skip + 1, math.min(total, skip + job.area.h) do
		visible[#visible + 1] = lines[i]
	end
	ya.preview_widget(job, ui.Text.parse(table.concat(visible, "\n")):area(job.area):wrap(wrap))
end

local function fail(job, text)
	ya.preview_widget(job, ui.Text.parse(text):area(job.area):wrap(ui.Wrap.YES))
end

function M:peek(job)
	local path = tostring(job.file.url)

	local f, open_err = io.open(path, "rb")
	if not f then
		return fail(job, "myazin-mermaid-glow: cannot open the file (" .. tostring(open_err) .. ")")
	end
	local size = f:seek("end") or 0
	f:seek("set", 0)
	local limit = math.max(1, config.read_limit_mb or 8) * 1024 * 1024
	local content = f:read(limit)
	f:close()

	if size > limit then
		return fail(
			job,
			string.format(
				"myazin-mermaid-glow: the file is larger than %d MB, so it is not previewed.",
				limit // (1024 * 1024)
			)
		)
	end
	if not content or content == "" then
		return fail(job, "myazin-mermaid-glow: the file is empty")
	end

	local ext = path:match("%.([^%.]+)$")
	ext = ext and ext:lower() or ""

	if ext == "mmd" or ext == "mermaid" then
		local art, reason = render_diagram_file(path, size, content)
		if not art then
			return fail(job, "myazin-mermaid-glow: " .. tostring(reason))
		end
		-- Wrapping would fold the box drawing onto the next row and destroy the
		-- diagram; clipping a too-wide diagram is the lesser problem, and
		-- append_art notes when that happened.
		local lines = {}
		append_art(lines, "", lines_of(art), job.area.w)
		return show(job, table.concat(lines, "\n"), ui.Wrap.NO)
	end

	local text, err = render_markdown(path, size, content, job.area.w)
	if not text then
		return fail(job, "myazin-mermaid-glow: " .. tostring(err))
	end
	-- glow already wrapped the prose to job.area.w, and re-wrapping here would
	-- only ever hit the diagrams, which must not be wrapped.
	return show(job, text, ui.Wrap.NO)
end

function M:seek(job)
	local current = (cx.active.preview and cx.active.preview.skip) or 0
	ya.emit("peek", { math.max(0, current + (job.units or 0)), only_if = job.file.url })
end

return M
