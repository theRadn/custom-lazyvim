return {
  "obsidian-nvim/obsidian.nvim",
  opts = {
    legacy_commands = false,
    ui = {
        enable = false,
    },
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian-vaults/personal",
      },
    },
  },
}
