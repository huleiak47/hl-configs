-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Sarasa Fixed SC")
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

config.default_prog = { "zsh.exe" }
config.default_cwd = "."

config.initial_cols = 130
config.initial_rows = 35

-- 透明背景
-- config.window_background_opacity = 0.70
-- 取消 Windows 原生标题栏
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- 滚动条尺寸为 15
config.window_padding = { left = 10, right = 15, top = 10, bottom = 0 }
-- 启用滚动条
config.enable_scroll_bar = true

-- 启动菜单的一些启动项
config.launch_menu = {
	{ label = "Git Zsh", args = { "zsh.exe" } },
	{ label = "192.168.8.141", args = { "ssh.exe", "hul@192.168.8.141" } },
	{ label = "IPython", args = { "ipython.exe" } },
	{ label = "Git Bash", args = { "C:/Users/osr/scoop/shims/bash.exe" } },
	{ label = "CMD", args = { "cmd.exe" } },
	{ label = "WSL", args = { "wsl.exe" } },
	--{ label = 'CMDEX',           args = { 'cmdex.exe' }, },
	{ label = "PowerShell", args = { "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" } },
}

config.disable_default_key_bindings = false

config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "LEADER|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	{ key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
	{ key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

	{ key = ",", mods = "LEADER", action = "ShowLauncher" },
	{ key = "b", mods = "LEADER", action = "ShowTabNavigator" },
	{ key = "f", mods = "LEADER", action = "QuickSelect" },
	{ key = "\t", mods = "LEADER", action = "ActivateLastTab" },
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
	{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = 8 }) },
	{ key = "p", mods = "LEADER", action = wezterm.action.PaneSelect },
	{ key = "&", mods = "LEADER|SHIFT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
	{ key = "x", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
	{ key = "C", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	{ key = "Tab", mods = "LEADER", action = wezterm.action({ ActivateTabRelative = 1 }) },
	--{ key = 'P', mods = 'CTRL', action = wezterm.action.ActivateCommandPalette, },
	{ key = "v", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.ScrollToTop },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.ScrollToBottom },
}
-- and finally, return the configuration to wezterm
return config
