-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_user_command('ToggleBufferline', function() 
  local current = vim.g.bufferline_enabled
  vim.g.bufferline_enabled = not current
  if vim.g.bufferline_enabled then
    require('bufferline').setup {}
  else
    vim.opt.showtabline = 0
  end
end, {})

