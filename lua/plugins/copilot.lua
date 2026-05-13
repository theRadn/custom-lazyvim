return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 200
      end,
    },
  },
  enabled = true,
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      auto_trigger = true,
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
