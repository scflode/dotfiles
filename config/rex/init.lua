local terminal = "com.superlogical.terminal"

-- Restore saved sessions after the Rex server starts.
do local r = rex.exec({ [[/opt/homebrew/bin/rexurrect]], "auto-restore" }, { env = { REXURRECT_STATE_DIR = [[/Users/fsc/.local/state/rexurrect]], REXURRECT_CONFIG = [[/Users/fsc/.config/rexurrect/config.toml]] } }) if r then io.stderr:write(r.stderr) end end

-- Numbers tab titles to match Ctrl-a 1-9; installed by installer/rex. Missing module must not break the config.
local ok, err = pcall(require, "extensions.tab-numbers")
if not ok then rex.log("warn", "tab-numbers: " .. tostring(err)) end

-- Keep Ctrl-a a available for readline and nested tmux sessions.
rex.bind("ctrl+a>a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>,", "client.tab.rename")
rex.bind("ctrl+a>s", "session.switch")
rex.bind("ctrl+a>shift+4", "session.rename")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>o", "pane.focus_next")
rex.bind("ctrl+a>m", "pane.move_to_tab")
rex.bind("ctrl+a>shift+1", "pane.move_to_new_tab")
rex.bind("ctrl+a>shift+;", "client.palette.toggle")
rex.bind("ctrl+a>shift+/", "client.palette.toggle")
rex.bind("ctrl+a>[", "client.find.open")
rex.bind("ctrl+a>shift+r", "client.config.reload")
for index = 1, 9 do
  rex.bind("ctrl+a>" .. index, "client.tab.goto", { index = index })
end
rex.bind("ctrl+a>0", "client.tab.goto", { index = -1 })

local function call(method, args)
  local result, err = rex.block.call(terminal, method, args or {})
  if not result then error(err, 0) end
  return result
end

-- Explicit CSI-u matches Ghostty even when a program hasn't negotiated extended keys.
rex.bind("shift+enter", function() call("write", { data = "\27[13;2u" }) return true end)
rex.bind("ctrl+enter", function() call("write", { data = "\27[13;5u" }) return true end)
rex.bind("ctrl+a>ctrl+p", function() call("clear") return true end)

rex.mode("resize", { exclusive = true })
rex.bind("ctrl+a>r", "client.mode.enter", { name = "resize" })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/=", "pane.balance")
for _, direction in ipairs({ "left", "down", "up", "right" }) do
  rex.bind("ctrl+a>" .. direction, "pane.resize", { direction = direction })
  rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
end

-- Let editors, remote shells and nested multiplexers own their navigation keys.
local editors = { vim = true, nvim = true, view = true, vimdiff = true, nvimdiff = true }
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function()
    local process = rex.block.call(terminal, "process", {})
    if not (process and process.foreground) then return false end
    local name = process.foreground.name
    if editors[name] or name == "ssh" or name == "tmux" or name == "zellij"
      or (name == "fzf" and (key == "j" or key == "k")) then
      return false
    end
    local result, err = rex.session.focus_direction{ direction = direction, wrap = false }
    if not result then error(err, 0) end
    return true
  end)
end

-- User-invoked imports work without granting remote UI control to terminal processes.
rex.action{
  name = "dotfiles_themes",
  title = "Import Dotfiles Catppuccin Themes",
  run = function()
    local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
    for _, name in ipairs({ "catppuccin-latte", "catppuccin-mocha" }) do
      rex.client.queue("client.theme.import", { path = config .. "/rex/themes/" .. name })
    end
  end,
}
rex.bind("ctrl+a>shift+i", "dotfiles_themes")
