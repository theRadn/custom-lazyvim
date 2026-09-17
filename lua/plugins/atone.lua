return {
  "XXiaoA/atone.nvim",
  cond = function()
    return not vim.g.vscode
  end,
  cmd = "Atone",
  ---@module "atone"
  ---@type AtoneConfig
  opts = {},
}
