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

function M.format_copy(selected_items)
  local compiled_content = {}
  local seen = {}

  for _, sel in ipairs(selected_items) do
    local raw_path = sel.file or sel.path or (sel.cwd and sel.text and (sel.cwd .. "/" .. sel.text)) or sel.text
    if raw_path then
      local expanded_files = get_files_from_path(raw_path)
      for _, fullpath in ipairs(expanded_files) do
        -- Prevent duplicate entries if overlapping selections occur
        if not seen[fullpath] then
          seen[fullpath] = true
          local f = io.open(fullpath, "r")
          if f then
            local content = f:read("*a")
            f:close()
            -- Use relative path for cleaner headers
            local display_path = vim.fn.fnamemodify(fullpath, ":.")
            table.insert(compiled_content, string.format("--- FILE: %s ---\n%s", display_path, content))
          else
            vim.notify("Failed to open file: " .. fullpath, vim.log.levels.WARN)
          end
        end
      end
    end
  end
  return compiled_content
end

function M.copy_to_clipboard(compiled_content)
  if #compiled_content == 0 then
    vim.notify("No files to copy!", vim.log.levels.WARN)
    return false
  end
  local final_output = table.concat(compiled_content, "\n\n")
  vim.fn.setreg("+", final_output)
  vim.fn.setreg("*", final_output)
  vim.notify(
    string.format("Copied content of %d file(s) to clipboard!", #compiled_content),
    vim.log.levels.INFO,
    { title = "Snacks Picker" }
  )
  return true
end

function M.copy_selected_contents(picker, should_close)
  if type(picker) ~= "table" or not picker.selected then
    picker = require("snacks").picker.get()[1]
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

  local compiled = M.format_copy(selected)

  if #compiled > 0 then
    local success = M.copy_to_clipboard(compiled)
    if success and should_close then
      picker:close()
    end
  end
end

return M
