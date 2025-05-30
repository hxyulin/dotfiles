require "nvchad.autocmds"

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Enable LSP Keymaps",
  callback = function(event)
    local map = vim.keymap.set
    local opts = { buffer = event.buf, silent = true }

    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "go", vim.lsp.buf.type_definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gs", vim.lsp.buf.signature_help, opts)
    map("n", "gl", vim.diagnostic.open_float, opts)
    map("n", "<F2>", vim.lsp.buf.rename, opts)
    map({ "n", "x" }, "<F3>", function() vim.lsp.buf.format { async = true } end, opts)
    map("n", "<F4>", vim.lsp.buf.code_action, opts)
  end
})
