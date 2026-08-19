return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
    },
  },
  enabled = true,
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = false,
      auto_trigger = true,
    },
    panel = {
      enabled = false,
    },
    nes = {
      move_count_threshold = 10,
      enabled = true,
      keymap = {
        accept_and_goto = "<leader>p",
        accept = false,
        dismiss = "<Esc>",
      },
    },
    server_opts_overrides = {
      settings = {
        telemetry = {
          telemetryLevel = "off",
        },
      },
    },
  },
}
