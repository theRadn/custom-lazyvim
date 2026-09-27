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
    notifier = {
      enabled = true,
      style = "compact",
      timeout = 2000,
      width = { min = 20, max = 50 },
      height = { min = 1, max = 5 },
      margin = { top = 0, right = 1, bottom = 0 },
      gap = 1,
    },
  },
}
