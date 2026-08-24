return {
  "joshuadanpeterson/typewriter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("typewriter").setup({
      enable_with_zen_mode = true,
      enable_with_true_zen = true,
      keep_cursor_position = true,
      enable_notifications = true,
      enable_horizontal_scroll = true,
      horizontal_left_offset = 0,
      start_enabled = true,
      always_center = true,
      always_center_filetypes = {},
    })
  end,
  opts = {},
}
