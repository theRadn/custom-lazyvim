-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.wo.number = true -- Enable absolute line numbers

vim.opt.tabstop = 4 -- Number of visual spaces per TAB
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 4 -- Number of spaces a <Tab> counts for while editing
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.keymap.set("i", "<C-H>", "<C-w>", { noremap = true })

vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

vim.keymap.set("v", "j", "gj", { noremap = true })
vim.keymap.set("v", "k", "gk", { noremap = true })

vim.opt.clipboard:remove("unnamedplus")
