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

local function choose_clangd()
  -- prefer explicit name; vim.fn.executable returns 1 if on PATH
  if vim.fn.executable("starm-clangd") == 1 then
    return {"starm-clangd",
      "--query-driver=/opt/ST/STM32CubeCLT_1.19.0/GNU-tools-for-STM32/bin/,/opt/ST/STM32CubeCLT_1.19.0/st-arm-clang/bin/"}
  end
  -- fallback to whatever (mason clangd or system clangd)
  return {"clangd"}
end

vim.lsp.config('clangd', {
  cmd = choose_clangd(),
})

vim.lsp.config('rust_analyzer', {
  settings = read_rust_analyzer_config()
})

vim.lsp.enable('rust_analyzer')
