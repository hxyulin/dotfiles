--- LSP configuration with blink.cmp integration

local lsp_binaries = require("config.lsp_binaries")
local lspconfig = require("lspconfig")

require("lazydev").setup({})
lsp_binaries.setup()

---@type lsp.ClientCapabilities
local capabilities = require("blink.cmp").get_lsp_capabilities()

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "clangd", "rust_analyzer" },
  handlers = {
    ---@param server_name string
    function(server_name)
      local opts = { capabilities = capabilities }
      local cmd = lsp_binaries.get_cmd(server_name)
      if cmd then
        opts.cmd = cmd
      end
      lspconfig[server_name].setup(opts)
    end,
    clangd = function()
      local cmd = lsp_binaries.get_cmd("clangd") or { "clangd" }
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = vim.list_extend(vim.list_extend({}, cmd), {
          "--query-driver=/opt/ST/STM32CubeCLT_*/GNU-tools-for-STM32/bin/arm-none-eabi-*,/opt/ST/STM32CubeCLT_*/st-arm-clang/bin/starm-*",
          "--header-insertion=never",
        }),
        init_options = {
          fallbackFlags = { "--target=arm-none-eabihf", "-std=c17" },
        },
      })
    end,
  },
})
