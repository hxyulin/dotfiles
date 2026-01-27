require("lazydev").setup({})

local capabilities = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls" },
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
      })
    end,
  },
})
