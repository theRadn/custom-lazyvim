return {
  {
    "NMAC427/guess-indent.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    opts = {},
  },
}
