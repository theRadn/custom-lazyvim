return {
  {
    "mfussenegger/nvim-lint",
    cond = function()
      return not vim.g.vscode
    end,
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = false,
      },
    },
  },
}
