--- @since 25.12.29

-- myazin-fzf-flat.yazi — fzf over the current directory, depth-capped.
--
-- The built-in `fzf` plugin bound to `Z` walks the whole subtree, which is the
-- wrong tool when the wanted entry is known to sit in or just below the
-- directory already on screen and the subtree is large. This one feeds fzf a
-- single `fd` listing capped at a shallow depth and reveals the pick.
--
-- The depth comes from the first argument and defaults to 1, so `plugin
-- myazin-fzf-flat` lists the directory itself and `plugin myazin-fzf-flat 2`
-- also lists one level below it.
--
-- Dependencies:
--   fzf — required
--   fd  — required; Debian names the binary `fdfind`, which is handled below

local shell = os.getenv("SHELL"):match(".*/(.*)")
local get_cwd = ya.sync(function() return cx.active.current.cwd end)
local fail = function(s, ...)
	ya.notify { title = "fzf-flat", content = string.format(s, ...), timeout = 5, level = "error" }
end

-- `--no-ignore` keeps the list in step with the file panel, which shows
-- gitignored entries too; `--hidden` does the same for dotfiles. Both are
-- listed regardless of Yazi's own hidden-files toggle, so a `.env` stays
-- reachable while the panel hides it.
local function list_cmd(depth)
	return table.concat({
		'f=fd; command -v "$f" >/dev/null 2>&1 || f=fdfind',
		'"$f" --max-depth ' .. depth .. " --hidden --no-ignore --strip-cwd-prefix --color=never",
	}, "; ")
end

local function fzf_cmd(depth)
	return table.concat({
		"fzf",
		"--layout=reverse",
		"--no-multi",
		"--prompt='flat:" .. depth .. "> '",
	}, " ")
end

local function entry(_, job)
	-- A non-numeric or absent argument means the plain, single-directory
	-- listing rather than an error: the keymap is the only caller.
	local depth = math.floor(tonumber(job.args[1]) or 1)
	if depth < 1 then
		return fail("`%s` is not a usable depth", tostring(job.args[1]))
	end

	local _permit = ui.hide()
	local cwd = get_cwd()

	local child, err = Command(shell)
		:arg({ "-c", list_cmd(depth) .. " | " .. fzf_cmd(depth) })
		:cwd(tostring(cwd))
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Failed to spawn shell, error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read command output, error: %s", err)
	elseif output.status.code == 130 then -- interrupted with <ctrl-c> or <esc>
		return
	elseif output.status.code == 1 then -- no match
		return ya.notify { title = "fzf-flat", content = "No file selected", timeout = 5 }
	elseif output.status.code ~= 0 then
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	-- fd marks directories with a trailing slash, which `reveal` would take as
	-- part of the name.
	local target = output.stdout:gsub("\n$", ""):gsub("/$", "")
	if target == "" then
		return
	end

	-- `reveal` rather than `cd`: it hovers a file and enters the directory that
	-- holds it, which is the useful outcome whether the pick is a file or a
	-- directory, and `<Enter>` still descends afterwards.
	local url = Url(target)
	if not url.is_absolute then
		url = cwd:join(url)
	end
	ya.emit("reveal", { url })
end

return { entry = entry }
