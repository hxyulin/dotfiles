-- @module lazy
-- @type PluginSpec[]
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = function()
      return require("config.treesitter.opts")
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {},
  },
  { "github/copilot.vim" },
}
