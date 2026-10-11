return {
  {
    "stevearc/conform.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    opts = {
      formatters_by_ft = {
        blade = { "blade-formatter" },
      },
    },
  },
}
