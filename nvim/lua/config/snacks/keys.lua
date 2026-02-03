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
  -- Git Integration
  {
    "<leader>gg",
    function()
      Snacks.lazygit()
    end,
    desc = "LazyGit",
  },
  {
    "<leader>gb",
    function()
      Snacks.gitbrowse()
    end,
    desc = "Git browse (open in browser)",
  },
  {
    "<leader>gf",
    function()
      Snacks.lazygit.log_file()
    end,
    desc = "LazyGit current file history",
  },
  {
    "<leader>gL",
    function()
      Snacks.lazygit.log()
    end,
    desc = "LazyGit log",
  },
  -- Terminal
  {
    "<leader>h",
    function()
      Snacks.terminal()
    end,
    desc = "Toggle terminal",
    mode = { "n", "t" },
  },
  -- Scratch Buffers
  {
    "<leader>n",
    function()
      Snacks.scratch()
    end,
    desc = "Open scratch buffer",
  },
  {
    "<leader>N",
    function()
      Snacks.scratch.select()
    end,
    desc = "Select scratch buffer",
  },
  -- Notifications
  {
    "<leader>un",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Dismiss all notifications",
  },
  {
    "<leader>nh",
    function()
      Snacks.notifier.show_history()
    end,
    desc = "Show notification history",
  },
}
