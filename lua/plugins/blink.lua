return {
  "saghen/blink.cmp",
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
      documentation = { auto_show = true, auto_show_delay_ms = 10 },
      menu = {
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", "source_name", gap = 1 },
          },
        },
      },
    },
    snippets = {
      preset = "luasnip",
    },
    cmdline = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        snippets = {
          score_offset = 100,
          override = {
            get_trigger_characters = function()
              return { "#", ";", "@", "!", "." }
            end,
          },
        },
        lsp = {
          score_offset = 0,
        },
        buffer = {
          score_offset = 0,
        },
      },
    },
  },
}
