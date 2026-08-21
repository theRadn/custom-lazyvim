return {
  "snacks.nvim",
  opts = {
    scroll = {
      enabled = false,
      animate = {
        duration = { step = 10, total = 50 },
        easing = "linear",
      },
    },
    picker = {
      win = {
        input = {
          keys = {
            ["<C-h>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
          },
        },
      },
    },
  },
}
