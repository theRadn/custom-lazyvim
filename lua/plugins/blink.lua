return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      list = {
        selection = {
          preselect = function()
            return not vim.tbl_contains({ "txt", "text", "markdown" }, vim.bo.filetype)
          end,
          auto_insert = false,
        },
      },
    },
  },
}
