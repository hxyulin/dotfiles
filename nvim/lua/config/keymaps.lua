---@type fun(mode: string|string[], lhs: string, rhs: string|function, opts?: vim.keymap.set.Opts)
local map = vim.keymap.set

-- Use ; to start commands in normal
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Open oil.nvim directory explorer
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Stay in indent mode when using > or <
map("v", "<", "<gv", { desc = "Indent left and stay in visual" })
map("v", ">", ">gv", { desc = "Indent right and stay in visual" })
