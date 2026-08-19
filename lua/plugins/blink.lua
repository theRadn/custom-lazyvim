return {
  "saghen/blink.cmp",
  dependencies = {
    "giuxtaposition/blink-cmp-copilot",
  },
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
      ghost_text = { enabled = false },
      trigger = {
        show_on_blocked_trigger_characters = { " ", "\n", "\t", ";" },
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
      ["<A-1>"] = {
        function(cmp)
          cmp.accept({ index = 1 })
        end,
      },
      ["<A-2>"] = {
        function(cmp)
          cmp.accept({ index = 2 })
        end,
      },
      ["<A-3>"] = {
        function(cmp)
          cmp.accept({ index = 3 })
        end,
      },
      ["<A-4>"] = {
        function(cmp)
          cmp.accept({ index = 4 })
        end,
      },
      ["<A-5>"] = {
        function(cmp)
          cmp.accept({ index = 5 })
        end,
      },
      ["<A-6>"] = {
        function(cmp)
          cmp.accept({ index = 6 })
        end,
      },
      ["<A-7>"] = {
        function(cmp)
          cmp.accept({ index = 7 })
        end,
      },
      ["<A-8>"] = {
        function(cmp)
          cmp.accept({ index = 8 })
        end,
      },
      ["<A-9>"] = {
        function(cmp)
          cmp.accept({ index = 9 })
        end,
      },
      ["<A-0>"] = {
        function(cmp)
          cmp.accept({ index = 10 })
        end,
      },
      ["<Tab>"] = {
        function(cmp)
          if vim.b[vim.api.nvim_get_current_buf()].nes_state then
            cmp.hide()
            return (
              require("copilot-lsp.nes").apply_pending_nes()
              and require("copilot-lsp.nes").walk_cursor_end_edit()
            )
          end
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        "snippet_forward",
        "fallback",
      },
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
        ["<A-1>"] = {
          function(cmp)
            cmp.accept({ index = 1 })
          end,
        },
        ["<A-2>"] = {
          function(cmp)
            cmp.accept({ index = 2 })
          end,
        },
        ["<A-3>"] = {
          function(cmp)
            cmp.accept({ index = 3 })
          end,
        },
        ["<A-4>"] = {
          function(cmp)
            cmp.accept({ index = 4 })
          end,
        },
        ["<A-5>"] = {
          function(cmp)
            cmp.accept({ index = 5 })
          end,
        },
        ["<A-6>"] = {
          function(cmp)
            cmp.accept({ index = 6 })
          end,
        },
        ["<A-7>"] = {
          function(cmp)
            cmp.accept({ index = 7 })
          end,
        },
        ["<A-8>"] = {
          function(cmp)
            cmp.accept({ index = 8 })
          end,
        },
        ["<A-9>"] = {
          function(cmp)
            cmp.accept({ index = 9 })
          end,
        },
        ["<A-0>"] = {
          function(cmp)
            cmp.accept({ index = 10 })
          end,
        },
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
