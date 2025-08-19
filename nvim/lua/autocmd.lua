-- Remove Default Global Key Mappings
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "gO")

-- Diagnostic Keymaps
vim.keymap.set("n", "<leader>gl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

-- Craete Keymapping
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function (args)
        local keymap = vim.keymap
        local lsp = vim.lsp
        local bufopts = { noremap = true, silent = true }

        keymap.set("n", "gr", lsp.buf.references, bufopts)
        keymap.set("n", "gd", lsp.buf.definition, bufopts)
        keymap.set("n", "<F2>", lsp.buf.rename, bufopts)
        keymap.set("n", "K", lsp.buf.hover, bufopts)
        keymap.set("n", "<F3>", function()
            vim.lsp.buf.format({ async = true })
        end, bufopts)
    end
})
