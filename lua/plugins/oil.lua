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
    keymaps = {
      ["<leader>t"] = {
        function()
          local dir = require("oil").get_current_dir()
          if dir then
            Snacks.terminal(nil, { cwd = dir })
          else
            vim.notify("Not in a valid Oil directory", vim.log.levels.WARN)
          end
        end,
        desc = "Open Terminal in Current Oil Dir",
      },
      ["<M-o>"] = {
        function()
          local dir = require("oil").get_current_dir()
          if dir then
            Snacks.terminal.open(nil, { win = { position = "bottom", width = 0.4 }, cwd = dir })
          else
            vim.notify("Not in a valid Oil directory", vim.log.levels.WARN)
          end
        end,
        desc = "Open Terminal in Current Oil Dir",
      },
      ["<M-i>"] = {
        function()
          local dir = require("oil").get_current_dir()
          if dir then
            Snacks.terminal.open(nil, { win = { position = "right", width = 0.4 }, cwd = dir })
          else
            vim.notify("Not in a valid Oil directory", vim.log.levels.WARN)
          end
        end,
        desc = "Open Terminal in Current Oil Dir",
      },
    }
  },
}
