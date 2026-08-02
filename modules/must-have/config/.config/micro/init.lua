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
