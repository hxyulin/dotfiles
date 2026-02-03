---@type snacks.Config
return {
  -- EXISTING features
  animate = {
    enabled = true,
    duration = 50,
  },
  bigfile = { enabled = true },
  dashboard = { example = "files" },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  picker = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
    style = "compact",
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },

  -- NEW: Git Integration
  lazygit = {
    enabled = true,
    configure = true, -- Auto-configure colorscheme
  },
  gitbrowse = { enabled = true },

  -- NEW: Terminal Management
  terminal = {
    enabled = true,
    win = {
      position = "bottom",
      border = "rounded",
    },
  },

  -- NEW: Utilities
  toggle = { enabled = true },
  scratch = {
    enabled = true,
    root = vim.fs.joinpath(vim.fn.stdpath("data"), "scratch"),
  },
}
