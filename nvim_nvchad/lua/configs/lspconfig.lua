require("nvchad.configs.lspconfig").defaults()

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

local lspconfig = require("lspconfig")
lspconfig['rust_analyzer'].setup({
  settings = read_rust_analyzer_config(),
})
