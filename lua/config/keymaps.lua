-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.wo.number = true -- Enable absolute line numbers

vim.opt.tabstop = 4 -- Number of visual spaces per TAB
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 4 -- Number of spaces a <Tab> counts for while editing
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.keymap.set("i", "<C-H>", "<C-w>", { noremap = true })
vim.keymap.set("i", "<C-j>", "<Esc>", { noremap = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

vim.keymap.set("v", "<C-c>", '"+y', { noremap = true })

vim.keymap.set('n', '<C-j>', '}', { noremap = true })
vim.keymap.set('n', '<C-k>', '{', { noremap = true })
vim.keymap.set('v', '<C-j>', '}', { noremap = true })
vim.keymap.set('v', '<C-k>', '{', { noremap = true })

-- oil
vim.keymap.set("n", "'", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>'", "<cmd>cd %:p:h<cr>", { desc = "Change directory to current file" })

-- code-runner
vim.keymap.set("n", "<leader>rr", ":RunCode<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false })

vim.keymap.set("n", "<leader>ut", "<cmd>ToggleBufferline<CR>", { desc = "Toggle Bufferline", noremap = true, silent = true })
