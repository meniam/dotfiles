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
local config = {
	style = "dark", -- glow --style: a built-in name or a path to a JSON theme
	ascii = false, -- mermaid-ascii --ascii: plain ASCII instead of box drawing
	padding_x = nil, -- mermaid-ascii --paddingX; nil keeps its own default
	padding_y = nil, -- mermaid-ascii --paddingY; nil keeps its own default
	glow_timeout = 15, -- wall-clock cap for glow, seconds
	mermaid_timeout = 10, -- wall-clock cap for one mermaid-ascii render, seconds
	read_limit_mb = 8, -- refuse to preview files larger than this
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

local function append_indented(out, indent, text)
	for _, line in ipairs(lines_of(text)) do
		out[#out + 1] = (line == "") and "" or (indent .. line)
	end
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

-- Replace every mermaid fence with rendered art wrapped in a plain fence, so
-- glow prints it verbatim in a code block instead of trying to highlight the
-- box-drawing characters as mermaid source.
local function preprocess(content, render)
	local out = {}
	local body, indent = nil, nil

	for _, line in ipairs(lines_of(content)) do
		if body then
			local ind, info = fence_parts(line)
			if ind and info == "" then
				local art, reason = render(table.concat(body, "\n"))
				if art then
					out[#out + 1] = indent .. "```"
					append_indented(out, indent, art)
					out[#out + 1] = indent .. "```"
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
	return table.concat(out, "\n")
end

-- ==========================================================================
-- Rendering pipeline with an on-disk cache
-- ==========================================================================

-- glow decides its colour profile from isatty(stdout). Capturing stdout makes
-- it a pipe, which silently downgrades the output to bold-only with no colour
-- at all; CLICOLOR_FORCE tells termenv to keep the full ANSI palette anyway.
local function run_glow(path, width)
	local out, err = run("glow", {
		"--style",
		tostring(config.style),
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
local function cache_key(path, size, content, width)
	return hash(table.concat({ path, tostring(size), content, tostring(width), tostring(config.style) }, "\0"))
end

local function render_markdown(path, size, content, width)
	local cache_file = PREFIX .. cache_key(path, size, content, width) .. ".ans"
	local cached = read_file(cache_file)
	if cached and #cached > 0 then
		return cached, nil
	end

	local document = content
	if has_mermaid_ascii() then
		document = preprocess(content, render_diagram)
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
		-- diagram; clipping a too-wide diagram is the lesser problem.
		return show(job, art, ui.Wrap.NO)
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
