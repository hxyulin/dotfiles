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

local function read_rust_analyzer_config()
    local path = vim.fn.getcwd() .. "/rust-analyzer.json"

    local file = io.open(path, "r")
    if not file then
        return {}
    end

    local content = file:read("*a")
    file:close()

    local ok, result = pcall(vim.fn.json_decode, content)
    if ok and type(result) == "table" then
        return result
    else
        vim.notify("[rust-analyzer] Failed to parse rust-analyzer.json", vim.log.levels.WARN)
        return {}
    end
end

lspconfig.rust_analyzer.setup {
    on_attach = on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
    settings = read_rust_analyzer_config(),
}

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
