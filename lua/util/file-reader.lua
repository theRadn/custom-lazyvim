local M = {}

function M.format_copy(selected_items)
  local compiled_content = {}
  for _, sel in ipairs(selected_items) do
    local file_path = sel.file or sel.path or sel.name
    if file_path then
      local fullpath = vim.fn.fnamemodify(file_path, ":p")
      local f = io.open(fullpath, "r")

      if f then
        local content = f:read("*a")
        f:close()

        table.insert(compiled_content, string.format("--- FILE: %s ---\n%s", file_path, content))
      else
        vim.notify("Failed to open file: " .. fullpath, vim.log.levels.WARN)
      end
    end
  end
  return compiled_content
end

function M.copy_to_clipboard(compiled_content)
  if #compiled_content == 0 then
    vim.notify("No files to copy!", vim.log.levels.WARN)
    return
  end
  local final_output = table.concat(compiled_content, "\n\n")
  vim.fn.setreg("+", final_output)
  vim.fn.setreg("*", final_output)
  vim.notify(string.format("Copied content of %d file(s) to clipboard!", #compiled_content), vim.log.levels.INFO)
end

function M.copy_picker_file_content()
  local ok, picker = pcall(require, "snacks.picker")
  if not ok then
    vim.notify("Snacks.nvim picker is not available", vim.log.levels.ERROR)
    return
  end

  picker.files({
    title = "Copy Files Content (Multi-select with <Tab>)",
    confirm = function(picker_instance, item)
      local selected_items = picker_instance:selected()

      picker_instance:close()

      if not selected_items or #selected_items == 0 then
        selected_items = { item }
      end

      if not selected_items or #selected_items == 0 then
        vim.notify("No files selected!", vim.log.levels.WARN)
        return
      end

      local compiled_content = M.format_copy(selected_items)

      M.copy_to_clipboard(compiled_content)
    end,
  })
end

function M.copy_explorer_files_content()
  local pickers = Snacks.picker.get({ source = "explorer" })
  if #pickers == 0 then
    vim.notify("No active explorer found", vim.log.levels.WARN)
    return {}
  end

  local picker = pickers[1]
  local selected_items = picker:selected()

  if #selected_items == 0 then
    local current_item = picker:current()
    if current_item then
      selected_items = { current_item }
    end
  end

  if #selected_items == 0 then
    vim.notify("No files or folders selected in explorer!", vim.log.levels.WARN)
    return
  end

  -- Helper function to recursively collect files
  local expanded_items = {}
  local seen = {}

  local function walk(path)
    local stat = vim.uv.fs_stat(path)
    if not stat then
      return
    end

    if stat.type == "file" then
      if not seen[path] then
        seen[path] = true
        table.insert(expanded_items, { file = path, path = path })
      end
    elseif stat.type == "directory" then
      local handle = vim.uv.fs_scandir(path)
      if handle then
        while true do
          local name, _ = vim.uv.fs_scandir_next(handle)
          if not name then
            break
          end
          walk(path .. "/" .. name)
        end
      end
    end
  end

  -- Process all selected items (files or folders)
  for _, item in ipairs(selected_items) do
    local path = item.file or item.path
    if path then
      walk(path)
    end
  end

  if #expanded_items == 0 then
    vim.notify("No files found in the selection!", vim.log.levels.WARN)
    return
  end

  local compiled_content = M.format_copy(expanded_items)
  M.copy_to_clipboard(compiled_content)
end

return M
