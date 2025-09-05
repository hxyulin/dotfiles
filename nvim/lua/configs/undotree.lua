local opt = vim.opt -- for conciseness

-- Undo history
opt.undofile = true           -- Enable persistent undo
-- Create a directory for undo files inside your nvim config
opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undodir"
