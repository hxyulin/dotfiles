return {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },

    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require "configs.treesitter"
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require "configs.mason"
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        config = function()
            require("configs.cmp")
        end,
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
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({})
        end,
        lazy = false,
    },
}
