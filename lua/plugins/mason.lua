return {
  "mason-org/mason.nvim",
  cond = function()
    return not vim.g.vscode
  end,
  opts = {
    ensure_installed = {
      "stylua",
      "shfmt",
    },
  },
}
