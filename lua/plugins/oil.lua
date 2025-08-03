return {
  "stevearc/oil.nvim",
  opts = {
    buf_options = {
      buflisted = true,
      bufhidden = "show",
    },
    view_options = { show_hidden = true },
  },
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
}
