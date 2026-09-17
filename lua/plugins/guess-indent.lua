return {
  {
    "NMAC427/guess-indent.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    event = "BufReadPre",
    config = function()
      require("guess-indent").setup({})
    end,
  },
}
