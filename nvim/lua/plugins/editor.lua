-- @type lazy.PluginSpec[]
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function()
      return require("config.snacks.opts")
    end,
    keys = function()
      return require("config.snacks.keys")
    end,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({})
      vim.cmd.colorscheme("cyberdream")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return require("config.lualine.opts")
    end,
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    lazy = false,
  },
  {
    "XXiaoA/atone.nvim",
    cmd = "Atone",
    opts = {},
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      return require("config.harpoon.keys")
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
    lazy = false,
  },
  {
    "dzfrias/arena.nvim",
    event = "BufWinEnter",
    keys = {
      {
        "<leader>j",
        function()
          require("arena").toggle()
        end,
        desc = "Toggle Arena",
      },
    },
    opts = function()
      return require("config.arena.opts")
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      return require("config.todo-comments.keys")
    end,
    opts = {}
  }
}
