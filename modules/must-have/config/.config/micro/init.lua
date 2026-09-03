-- Quit on a double Escape. The first press only arms the exit and says so in
-- the infobar; the second one within the window below runs Quit, which still
-- prompts for an unsaved buffer. A single stray Escape therefore cannot end an
-- editing session.
--
-- bindings.json puts this last in the Escape chain, after the actions that
-- cancel something, so it is reached only when Escape had nothing to cancel.

local micro = import("micro")
local time = import("time")

local quit_window = 750 * time.Millisecond

-- True between the first Escape and the end of the window. It is a file-local
-- flag rather than per-pane state because the hint it goes with is global too.
local armed = false

function quitOnSecondEscape(bp)
    if armed then
        armed = false
        micro.InfoBar():Message("")
        bp:Quit()
        return true
    end

    armed = true
    micro.InfoBar():Message("Press Esc again to quit")

    -- The timer runs off the event loop, so it only drops the flag and the
    -- hint it wrote itself; anything the user did meanwhile is left alone.
    micro.After(quit_window, function()
        if armed then
            armed = false
            micro.InfoBar():Message("")
        end
    end)

    return true
end

-- Open a file picked in fzf. The fzf plugin's own command opens the pick in
-- place of the current buffer and closes that buffer without asking about
-- unsaved changes, so this one opens a new tab instead, unless the current
-- buffer is an empty unnamed one that costs nothing to replace.
--
-- fzf runs in the real terminal with micro's screen suspended, not in the
-- embedded terminal the plugin prefers. That emulator shows fzf without any
-- colour: fzf writes every style as `ESC[;...m`, with an empty first
-- parameter, and the emulator's CSI parser stops at a parameter it cannot
-- convert to a number and drops the whole sequence. It also cannot render
-- 24-bit colour, bold, or reverse. The real terminal has none of these limits,
-- so fzf looks as it does at the shell prompt, and FZF_DEFAULT_OPTS from the
-- zsh module applies unchanged.

local shell = import("micro/shell")
local buffer = import("micro/buffer")
local strings = import("strings")

function fzfOpen(bp)
    -- The error is ignored on purpose: fzf exits 1 when nothing matched and
    -- 130 on Escape, and both simply mean there is nothing to open.
    local output, _ = shell.RunInteractiveShell("fzf", false, true)
    local path = strings.TrimSpace(output)
    if path == "" then
        return true
    end

    local buf, err = buffer.NewBufferFromFile(path)
    if err ~= nil then
        micro.InfoBar():Error(err)
        return true
    end

    local current = bp.Buf
    if current.Path == "" and not current:Modified() then
        bp:OpenBuffer(buf)
    else
        bp:AddTab()
        micro.CurPane():OpenBuffer(buf)
    end
    return true
end
