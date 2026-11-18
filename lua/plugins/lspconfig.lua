return {
  {
    "neovim/nvim-lspconfig",
    cond = function()
      return not vim.g.vscode
    end,
    opts = {
      inlay_hints = {
        enabled = false,
      },
    },
  },
}
