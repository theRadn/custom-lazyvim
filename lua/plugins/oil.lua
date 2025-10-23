return {
  "stevearc/oil.nvim",
  dependencies = { { "mini-nvim/mini.icons", opts = {} } },
  lazy = false,
  opts = {
    view_options = {
      show_hidden = true,
    },
    skip_confirm_for_simple_edits = true,
  },
}
