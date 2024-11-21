require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- LSP mappings
map({ "n", "v" }, "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "LSP rename" })
map({ "n", "v" }, "<F3>", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "LSP format" })
map({ "n", "v" }, "<F4>", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "LSP code action" })

-- DAP
map("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>", { desc = "DAP continue" })
map("n", "<F10>", "<cmd>lua require'dap'.step_over()<CR>", { desc = "DAP step over" })
map("n", "<F11>", "<cmd>lua require'dap'.step_into()<CR>", { desc = "DAP step into" })
map("n", "<F12>", "<cmd>lua require'dap'.step_out()<CR>", { desc = "DAP step out" })
map("n", "<leader>dbt", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "DAP toggle breakpoint" })
map("n", "<leader>dbl", "<cmd>lua require'dap'.list_breakpoints()<CR>", { desc = "DAP list breakpoints" })
map("n", "<leader>dl", "<cmd>lua require'dap'.continue()<CR>", { desc = "DAP run" })
map("n", "<leader>ds", "<cmd>lua require'dap'.terminate()<CR>", { desc = "DAP stop" })
map("n", "<leader>dt", "<cmd>lua require'dap'.toggle()<CR>", { desc = "DAP toggle" })
map("n", "<leader>di", "<cmd>lua require'dap.ui.variables'.hover()<CR>", { desc = "DAP hover" })
map("n", "<leader>dui", "<cmd>lua require'dapui'.toggle()<CR>", { desc = "DAP UI toggle" })
map("n", "<leader>duh", "<cmd>lua require'dapui'.toggle()<CR>", { desc = "DAP UI hover" })
map("n", "<leader>duf", "<cmd>lua require'dapui'.float_element()<CR>", { desc = "DAP UI float" })
map("n", "<leader>dwt", "<cmd>lua require'dap'.repl.toggle()<CR>", { desc = "DAP watch toggle" })
map("n", "<leader>dwr", "<cmd>lua require'dap'.repl.restart()<CR>", { desc = "DAP watch restart" })

-- Undotree
map("n", "<leader><F5>", "<cmd>UndotreeToggle<CR>", { desc = "Toggle undotree" })
