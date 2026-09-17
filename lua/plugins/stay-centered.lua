return {
  "arnamak/stay-centered.nvim",
  cond = function()
    return not vim.g.vscode
  end,
  opts = {
    skip_filetypes = {},
    enabled = true,
    allow_scroll_move = true,
    disable_on_mouse = true,
  },
}
