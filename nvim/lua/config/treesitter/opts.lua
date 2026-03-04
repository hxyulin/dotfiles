--- Treesitter configuration
---@type TSConfig
return {
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "c",
    "cpp",
    "rust",
    "markdown",
    "markdown_inline",
    "json",
    "yaml",
    "toml",
    "bash",
  },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },
}
