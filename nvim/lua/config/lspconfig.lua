--- LSP configuration with blink.cmp integration

require("lazydev").setup({})

---@type lsp.ClientCapabilities
local capabilities = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")

-- Clangd executable selector
local clangd_executables = { "clangd", "st-arm-clangd" }
local clangd_cmd = { "clangd" }

local function select_clangd()
  local items = vim.list_extend({}, clangd_executables)
  table.insert(items, "Custom...")
  vim.ui.select(items, { prompt = "Select clangd executable:" }, function(choice)
    if not choice then
      return
    end
    if choice == "Custom..." then
      vim.ui.input({ prompt = "Clangd executable path: " }, function(input)
        if input and input ~= "" then
          clangd_cmd = { input }
          vim.cmd("LspRestart clangd")
        end
      end)
    else
      clangd_cmd = { choice }
      vim.cmd("LspRestart clangd")
    end
  end)
end

vim.api.nvim_create_user_command("ClangdSelect", select_clangd, { desc = "Select clangd executable" })

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "clangd", "rust_analyzer" },
  handlers = {
    ---@param server_name string
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
      })
    end,
    ["clangd"] = function()
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = clangd_cmd,
      })
    end,
  },
})
