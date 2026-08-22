return {
  "saghen/blink.cmp",
  dependencies = {
    "giuxtaposition/blink-cmp-copilot",
  },
  version = "1.*",
  opts = {
    completion = {
      keyword = { range = "full", },
      list = {
        selection = {
          -- preselect = function()
          --   return not vim.tbl_contains({ "txt", "text", "markdown" }, vim.bo.filetype)
          -- end,
          preselect = true,
          auto_insert = false,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        window = {
          min_width = 1,
          max_width = 80,
          max_height = 20,
        },
      },
      menu = {
        auto_show = false,
        max_height = 10,
        draw = {
          columns = {
            { "item_idx", gap = 0 },
            { "kind_icon", "kind", "source_name", gap = 0 },
            { "label", "label_description", gap = 1 },
          },
          components = {
            item_idx = {
              text = function(ctx)
                return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
              end,
            },
            label = {
              width = {
                fill = true,
                max = 9999,
              },
            },
          },
        },
      },
      ghost_text = {
        enabled = true,
        show_with_menu = true,
        show_without_menu = true,
      },
      trigger = {
        prefetch_on_insert = true,
        show_in_snippet = true,
        show_on_backspace = true,
        show_on_backspace_in_keyword = true,
        show_on_backspace_after_accept = true,
        show_on_backspace_after_insert_enter = true,
        show_on_keyword = true,
        show_on_trigger_character = true,
        show_on_blocked_trigger_characters = { "\n", "\t", ";" },
      },
    },
    signature = {
      enabled = false,
      trigger = { enabled = false },
      window = {
        min_width = 1,
        max_width = 40,
        max_height = 5,
        show_documentation = false,
      },
    },
    keymap = {
      preset = "none",
      ["<Tab>"] = {
        function(cmp)
          if vim.b[vim.api.nvim_get_current_buf()].nes_state then
            cmp.hide()
            return (
              require("copilot-lsp.nes").apply_pending_nes()
              and require("copilot-lsp.nes").walk_cursor_end_edit()
            )
          end
        end,
        "fallback",
      },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-space>"] = { "show", "hide" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-y>"] = { "select_and_accept", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      ["<CR>"] = { "select_and_accept", "fallback" }
    },
    snippets = {
      preset = "luasnip",
    },
    cmdline = {
      enabled = true,
      completion = { menu = { auto_show = true } },
      keymap = {
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "copilot" },
      providers = {
        snippets = {
          -- score_offset = 100,
          override = {
            get_trigger_characters = function()
              return { "#", "." }
            end,
          },
        },
        lsp = {
          -- score_offset = 0,
        },
        buffer = {
          -- score_offset = 0,
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(function(bufnr)
                return vim.bo[bufnr].buftype == ""
              end, vim.api.nvim_list_bufs())
            end,
          },
        },
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
}
