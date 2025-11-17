return {
  "stevearc/oil.nvim",
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  opts = {
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, bufnr)
        local hidden_extensions = { ".class", ".exe", ".o", ".jar" }
        for _, ext in ipairs(hidden_extensions) do
          if vim.endswith(name, ext) then
            return true
          end
        end
      end,
    },
    skip_confirm_for_simple_edits = true,
  },
}
