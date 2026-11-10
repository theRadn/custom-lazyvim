local M = {}

function M.expand_all_folders(picker)
  local Tree = require("snacks.explorer.tree")
  local Actions = require("snacks.explorer.actions")
  picker = require("snacks").picker.get({ source = "explorer" })[1]
  local root = Tree:find(picker:cwd())

  Tree:walk(root, function(node)
    if node.dir then
      Tree:open(node.path)
      Tree:expand(node)
    end
  end, { all = true })

  Actions.update(picker, { refresh = true })
end

M.expand_selected_folder = function(picker)
  local Tree = require("snacks.explorer.tree")
  local Actions = require("snacks.explorer.actions")
  picker = require("snacks").picker.get({ source = "explorer" })[1]

  local item = picker:current()
  local root = Tree:find(item.file)

  Tree:walk(root, function(node)
    if node.dir then
      Tree:open(node.path)
      Tree:expand(node)
    end
  end, { all = true })

  Actions.update(picker, { refresh = true })
end

return M
