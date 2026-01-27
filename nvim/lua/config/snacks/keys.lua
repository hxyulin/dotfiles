---@type LazyKeysSpec[]
return {
  {
    "<leader>ff",
    function()
      Snacks.picker.files()
    end,
    desc = "Find files",
  },
  {
    "<leader>fw",
    function()
      Snacks.picker.grep()
    end,
    desc = "Live grep",
  },
  {
    "<leader>fb",
    function()
      Snacks.picker.buffers()
    end,
    desc = "Buffers",
  },
  {
    "<leader>fh",
    function()
      Snacks.picker.help()
    end,
    desc = "Help tags",
  },
  {
    "<leader>fr",
    function()
      Snacks.picker.recent()
    end,
    desc = "Recent files",
  },
  {
    "<leader>fc",
    function()
      Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
    end,
    desc = "Find config files",
  },
  {
    "<leader>fg",
    function()
      Snacks.picker.git_files()
    end,
    desc = "Git files",
  },
  {
    "<leader>fs",
    function()
      Snacks.picker.lsp_symbols()
    end,
    desc = "LSP symbols",
  },
  {
    "<leader>fd",
    function()
      Snacks.picker.diagnostics()
    end,
    desc = "Diagnostics",
  },
  {
    "<leader>f/",
    function()
      Snacks.picker.grep_buffers()
    end,
    desc = "Grep open buffers",
  },
  -- Explorer
  {
    "<leader>e",
    function()
      Snacks.explorer()
    end,
    desc = "File explorer",
  },
}
