local M = {}

local function get_files_from_path(path)
  local fullpath = vim.fn.fnamemodify(path, ":p")
  local stat = vim.uv.fs_stat(fullpath)
  if not stat then
    return {}
  end

  local files = {}
  if stat.type == "file" then
    table.insert(files, fullpath)
  elseif stat.type == "directory" then
    -- Recursively find all files inside the directory
    local glob_pattern = fullpath:gsub("/+$", "") .. "/**/*"
    local all_entries = vim.fn.glob(glob_pattern, false, true)
    for _, entry in ipairs(all_entries) do
      if vim.fn.filereadable(entry) == 1 then
        table.insert(files, entry)
      end
    end
  end
  return files
end

-- Function to handle the list of paths
function M.copy_paths_to_clipboard(selected_items)
  local paths = {}
  local seen = {}

  for _, sel in ipairs(selected_items) do
    local raw_path = sel.file or sel.path or (sel.cwd and sel.text and (sel.cwd .. "/" .. sel.text)) or sel.text
    if raw_path then
      local expanded_files = get_files_from_path(raw_path)
      for _, fullpath in ipairs(expanded_files) do
        -- Prevent duplicate entries
        if not seen[fullpath] then
          seen[fullpath] = true
          -- Use relative path for cleaner output list
          local display_path = vim.fn.fnamemodify(fullpath, ":.")
          table.insert(paths, display_path)
        end
      end
    end
  end

  if #paths == 0 then
    vim.notify("No paths to copy!", vim.log.levels.WARN)
    return false
  end

  local final_output = table.concat(paths, "\n")
  vim.fn.setreg("+", final_output)
  vim.fn.setreg("*", final_output)
  vim.notify(
    string.format("Copied paths of %d file(s) to clipboard!", #paths),
    vim.log.levels.INFO,
    { title = "Snacks Picker" }
  )
  return true
end

-- The integration function that calls the path clipboard logic
function M.copy_selected_paths(picker, should_close)
  if type(picker) ~= "table" or not picker.selected then
    local pickers = require("snacks").picker.get()
    picker = vim.iter(pickers):find(function(p) return p:is_focused() end) or pickers[#pickers]
  end

  if not picker then
    vim.notify("No active picker found!", vim.log.levels.WARN, { title = "Snacks Picker" })
    return
  end

  -- Get all explicitly selected items
  local selected = picker:selected()

  -- Fallback: If no items are selected, grab the item currently under the cursor
  if #selected == 0 then
    local current = picker:current()
    if current then
      table.insert(selected, current)
    end
  end

  -- If still nothing, exit early
  if #selected == 0 then
    vim.notify("No file or directory selected or highlighted!", vim.log.levels.WARN, { title = "Snacks Picker" })
    return
  end

  -- Call the path-specific function
  local success = M.copy_paths_to_clipboard(selected)

  if success and should_close then
    picker:close()
  end
end

return M
