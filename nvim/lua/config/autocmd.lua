-- Remove Default Global Key Mappings
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "gO")

-- Diagnostic Keymaps
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

--- LSP keybindings and diagnostics configuration

---@param args {buf: integer, id: integer, group?: integer, match: string, event: string, file: string, data: table}
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")

    -- Info
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

    -- Actions (leader-l prefix)
    map("n", "<leader>lr", vim.lsp.buf.rename, "Rename Symbol")
    map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format Document")
    map("n", "<leader>li", "<cmd>LspInfo<cr>", "LSP Info")
    map("n", "<leader>lR", "<cmd>LspRestart<cr>", "Restart LSP")
    map("n", "<leader>lc", "<cmd>ClangdSelect<cr>", "Select Clangd Executable")

    -- Legacy keybinds (kept for muscle memory)
    map("n", "<F2>", vim.lsp.buf.rename, "Rename Symbol")
    map("n", "<F3>", function()
      vim.lsp.buf.format({ async = true })
    end, "Format Document")
  end,
})
