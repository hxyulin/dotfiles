--- Generic LSP binary selector
--- Allows swapping any LSP server's binary at runtime with per-machine overrides.

local M = {}

--- Default configuration for LSP servers with alternative binaries.
--- Each entry maps a server name to { default = "...", alternatives = { ... } }.
local defaults = {
  clangd = {
    default = "clangd",
    alternatives = { "clangd", "st-arm-clangd" },
  },
}

--- Merged config (defaults + local overrides).
local config = {} ---@type table<string, { default: string, alternatives: string[] }>

--- Mutable single-element cmd tables passed by reference to lspconfig.
local cmd_tables = {} ---@type table<string, string[]>

--- Load and merge config from defaults and optional lsp_local.lua.
local function load_config()
  -- Start with a copy of defaults
  config = {}
  for server, cfg in pairs(defaults) do
    config[server] = { default = cfg.default, alternatives = vim.list_extend({}, cfg.alternatives) }
  end

  -- Attempt to load local overrides
  local ok, local_cfg = pcall(require, "config.lsp_local")
  if ok and type(local_cfg) == "table" then
    for server, overrides in pairs(local_cfg) do
      if config[server] then
        -- Per-server shallow merge: local values replace defaults
        if overrides.default then
          config[server].default = overrides.default
        end
        if overrides.alternatives then
          config[server].alternatives = overrides.alternatives
        end
      else
        -- New server from local config
        config[server] = {
          default = overrides.default or server,
          alternatives = overrides.alternatives or { server },
        }
      end
    end
  elseif not ok and local_cfg then
    -- Distinguish file-not-found (silent) from syntax errors (notify)
    local msg = tostring(local_cfg)
    if not msg:match("module 'config.lsp_local' not found") then
      vim.notify("lsp_local.lua error: " .. msg, vim.log.levels.ERROR)
    end
  end

  -- Initialize mutable cmd tables
  for server, cfg in pairs(config) do
    cmd_tables[server] = { cfg.default }
  end
end

--- Get the mutable cmd table for a server (passed to lspconfig).
---@param server string
---@return string[]|nil
function M.get_cmd(server)
  return cmd_tables[server]
end

--- Get the alternatives list for a server.
---@param server string
---@return string[]
function M.get_alternatives(server)
  local cfg = config[server]
  return cfg and cfg.alternatives or {}
end

--- Show a picker to select a binary for a server, then restart it.
---@param server string
local function select_binary(server)
  local alts = M.get_alternatives(server)
  local items = vim.list_extend({}, alts)
  table.insert(items, "Custom path...")

  vim.ui.select(items, { prompt = "Select " .. server .. " binary:" }, function(choice)
    if not choice then
      return
    end
    if choice == "Custom path..." then
      vim.ui.input({ prompt = server .. " executable path: " }, function(input)
        if input and input ~= "" then
          cmd_tables[server][1] = input
          vim.cmd("LspRestart " .. server)
        end
      end)
    else
      cmd_tables[server][1] = choice
      vim.cmd("LspRestart " .. server)
    end
  end)
end

--- Auto-detect the server from the current buffer's attached LSP clients.
--- If multiple configurable servers are attached, prompt the user to pick one.
---@param arg string|nil Explicit server name, or nil to auto-detect
local function resolve_server(arg)
  if arg and arg ~= "" then
    if not config[arg] then
      vim.notify("No binary config for server: " .. arg, vim.log.levels.WARN)
      return
    end
    select_binary(arg)
    return
  end

  -- Auto-detect from attached clients
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local configurable = {} ---@type string[]
  for _, client in ipairs(clients) do
    if config[client.name] then
      table.insert(configurable, client.name)
    end
  end

  if #configurable == 0 then
    vim.notify("No configurable LSP servers attached to this buffer", vim.log.levels.WARN)
  elseif #configurable == 1 then
    select_binary(configurable[1])
  else
    vim.ui.select(configurable, { prompt = "Select server:" }, function(choice)
      if choice then
        select_binary(choice)
      end
    end)
  end
end

--- Register the :LspSelectBinary command with tab completion.
function M.setup()
  load_config()

  vim.api.nvim_create_user_command("LspSelectBinary", function(opts)
    resolve_server(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(config)
    end,
    desc = "Select LSP server binary",
  })
end

return M
