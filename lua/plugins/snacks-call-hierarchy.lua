return {
  "dfrommi/snacks-call-hierarchy.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    max_depth = 5, -- maximum depth fetched from LSP
    auto_expand_depth = 1, -- depth expanded automatically on open
    max_open_requests = 50, -- maximum child LSP requests during initial expansion
    win = {
      input = {
        keys = {
          ["<Right>"] = { "call_hierarchy_toggle_expanded", mode = { "n", "i" }, desc = "Toggle expand/collapse" },
          ["<Left>"] = { "call_hierarchy_toggle_expanded", mode = { "n", "i" }, desc = "Toggle expand/collapse" },
        },
      },
    },
  },
}
