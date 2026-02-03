--- Treesitter configuration
---@type TSConfig
return {
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
  },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },
}
