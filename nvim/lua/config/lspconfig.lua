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
  },
})
