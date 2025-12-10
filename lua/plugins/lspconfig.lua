return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      autoformat = false, -- Disables auto-formatting on save
    },
    servers = {
      jdtls = {},
    },
    setup = {
      jdtls = function()
        return true -- avoid duplicate servers
      end,
    },
  },
}
