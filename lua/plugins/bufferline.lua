return {
  "akinsho/bufferline.nvim",
  cond = function()
    return not vim.g.vscode
  end,
  enabled = true,
}
