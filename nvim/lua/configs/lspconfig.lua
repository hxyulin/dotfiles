-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local mason_lspconfig = require "mason-lspconfig"

local nvlsp = require "nvchad.configs.lspconfig"
local map = vim.keymap.set

local function on_attach(_, butnr)
    local opts = { noremap = true, buffer = butnr }
    map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
    map("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    map({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", opts)
    map("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
end


mason_lspconfig.setup_handlers({
    function(client)
        lspconfig[client].setup {
            on_attach = on_attach,
            on_init = nvlsp.on_init,
            capabilities = nvlsp.capabilities,
        }
    end
})

-- if clangd exists in path
if vim.fn.executable "clangd" then
    lspconfig.clangd.setup {
        on_attach = on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    }
end
-- if rust_analyzer exists in path
if vim.fn.executable "rust-analyzer" then
    lspconfig.rust_analyzer.setup {
        on_attach = on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_dir = lspconfig.util.root_pattern("Cargo.toml"),
    }
end
