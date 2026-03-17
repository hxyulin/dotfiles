---@diagnostic disable: missing-fields
--- Neovim options configuration
--- Sets up tab behavior, UI, and search preferences

--- Tab
-- number of visual spaces per tab
vim.opt.tabstop = 4
-- number of spaces in tab when editing
vim.opt.softtabstop = 4
-- insert 4 spaces on a tab
vim.opt.shiftwidth = 4
-- tabs are spaces
vim.opt.expandtab = true

--- UI Config
-- show line numbers
vim.opt.number = true
-- relative line numbers
vim.opt.relativenumber = true
-- 24-bit color
vim.opt.termguicolors = true
-- always show signcolumn to prevent layout shift
vim.opt.signcolumn = "yes"
-- keep lines visible above/below cursor
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
-- open new splits to right and below
vim.opt.splitright = true
vim.opt.splitbelow = true
-- sync with system clipboard
vim.opt.clipboard = "unnamedplus"
-- faster CursorHold / swap write
vim.opt.updatetime = 250
-- faster which-key popup
vim.opt.timeoutlen = 300

-- show substitution preview in a split
vim.opt.inccommand = "split"
-- highlight current line
vim.opt.cursorline = true
-- enable mouse in all modes
vim.opt.mouse = "a"
-- don't show mode in cmdline (lualine handles it)
vim.opt.showmode = false
-- enable smart indenting on new lines
vim.opt.smartindent = true
-- line wrapping off by default
vim.opt.wrap = false
-- minimum window width for number column
vim.opt.numberwidth = 4

--- Searching
-- search as characters are entered
vim.opt.incsearch = true
-- ignore case by default
vim.opt.ignorecase = true
-- make it case insensitive when caps are entered
vim.opt.smartcase = true

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.undofile = true
