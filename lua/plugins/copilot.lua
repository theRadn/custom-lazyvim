return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
        vim.lsp.enable("copilot_ls")
      end,
      opts = {
        nes = {
          move_count_threshold = 9999,
        },
      },
    },
  },
  cond = function()
    return not vim.g.vscode
  end,
  enabled = true,
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
    },
    panel = {
      enabled = false,
    },
    nes = {
      enabled = false,
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
