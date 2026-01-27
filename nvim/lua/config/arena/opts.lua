--@meta

-- GitHub: https://github.com/dzfrias/arena.nvim
-- Custom types for Arena.nvim to enable IntelliSense

---@class arena.WindowConfig
---@field width integer Window width (default: 60)
---@field height integer Window height (default: 10)
---@field border string|string[] Border style (e.g., "rounded", "single", "double")
---@field opts table<string, any> Options to apply to the arena window

---@class arena.AlgorithmConfig
---@field recency_factor number Multiplies recency by factor. > 0. Smaller = less emphasis (default: 0.5)
---@field frequency_factor number Multiplies frequency by factor. > 0 (default: 1)

---@class arena.Config
---@field max_items integer|nil Max files in arena window, nil for unlimited (default: 5)
---@field always_context string[] Always show enclosing directory for these paths (default: {"mod.rs", "init.lua"})
---@field ignore_current boolean Ignore current buffer in listing (default: false)
---@field buf_opts table<string, any> Buffer options to set on arena buffers
---@field per_project boolean Filter buffers by project (default: false)
---@field devicons boolean Show nvim-web-devicons (default: false)
---@field window arena.WindowConfig Window styling and configuration
---@field keybinds table<string, function|string> Custom keybinds for the arena window
---@field renderers table Custom rendering functions
---@field algorithm arena.AlgorithmConfig Frecency algorithm settings
return {
  keybinds = {},
}
