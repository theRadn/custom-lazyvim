return {
  {
    "neovim/nvim-lspconfig",
    cond = function()
      return not vim.g.vscode
    end,
    opts = {
      autoformat = false,
      inlay_hints = {
        enabled = false,
      },
    },
  },
}
