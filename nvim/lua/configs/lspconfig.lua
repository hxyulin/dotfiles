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

lspconfig['lua_ls'].setup({
    settings = {
        Lua = {
            -- The language server will infer the runtime environment.
            -- Using "LuaJIT" is common for Neovim.
            runtime = {
                version = "LuaJIT",
            },
            -- This is crucial for Neovim type awareness!
            -- `vim.api.nvim_get_runtime_file("", true)` gets all your Neovim
            -- runtime files (like built-in Lua modules, plugin files).
            -- Add the path to Lazy.nvim's data directory for its types.
            -- Add your own config directory for your personal types/globals.
            workspace = {
                checkThirdParty = false,                 -- Don't check external libraries in workspace
                library = {
                    -- vim.api.nvim_get_runtime_file("", true), -- Neovim's runtime files
                    vim.env.VIMRUNTIME,
                    -- Path to Lazy.nvim's types
                    -- This allows lua_ls to understand the structure of Lazy.nvim's setup table
                    vim.fn.expand("$HOME/.config/nvim/lazy/lazy.nvim/lua/lazy/init.lua"),
                    -- Add your own config directory as a library, so lua_ls can read your modules
                    -- and provide completion/diagnostics for them.
                    vim.fn.expand("$HOME/.config/nvim/lua"),
                },
            },
            -- Globals: Tell the language server about global variables
            -- that aren't explicitly defined in your code but are provided
            -- by Neovim or plugins.
            diagnostics = {
                globals = {},
                -- If you want more strict type checking:
                enable = true,
                -- Set to `true` to enable stricter type checking globally.
                -- This can be a bit noisy initially, but helps catch errors.
                -- Once you get used to it, you can disable it if it's too much.
                disable = { "missing-parameter", "cast-local-type" }, -- Example of disabling specific warnings
                -- Example of enabling strict mode for specific files
                group = {
                    ["@checkwidth"] = {
                        "check-width",
                        "deprecated-global",
                    },
                },
                -- Set to `true` to enable more aggressive type checking for some APIs.
                -- If you frequently use custom types and type annotations:
                -- [Requires more setup, see lua_ls docs for full typed Lua support]
                -- `strict_check = { enable = true }`
            },
            -- Enable type checking specifically. This is the "typed Lua" part.
            -- This will make `lua_ls` try to infer types and report type mismatches.
            -- For full typed Lua support, you'll want to use `@type` annotations.
            type = {
                -- If you use annotations like `@param`, `@return`, etc.
                -- This needs to be true for those to be effective.
                enable = true,
                -- This enables stricter type checking across the board.
                -- It can be quite verbose, so start without it and enable if you want more strictness.
                -- castNumberToInteger = true,
            },
            format = {
                enable = true,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
