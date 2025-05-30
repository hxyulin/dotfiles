return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
      "mason-org/mason-lspconfig.nvim",
      lazy = false,
      opts = {},
      dependencies = {
          { "mason-org/mason.nvim", opts = {} },
          "neovim/nvim-lspconfig",
      },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {},
  },
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        config = function()
            require "configs.undotree"
        end,
    },

    {
        "mfussenegger/nvim-dap",
        config = function()
            require "configs.dap"
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    },
    {
        "theHamsta/nvim-dap-virtual-text",
    },

    {
        "wakatime/vim-wakatime",
        lazy = false,
    },
    {
        "editorconfig/editorconfig-vim",
        lazy = false,
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            require("configs.cmp")
        end,
    },
}
