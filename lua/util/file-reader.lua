local M = {}

function M.copy_multiple_files_content()
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

      local compiled_content = {}

      for _, sel in ipairs(selected_items) do
        if sel.file then
          local fullpath = vim.fn.fnamemodify(sel.file, ":p")
          local f = io.open(fullpath, "r")

          if f then
            local content = f:read("*a")
            f:close()

            table.insert(compiled_content, string.format("--- FILE: %s ---\n%s", sel.file, content))
          else
            vim.notify("Failed to open file: " .. fullpath, vim.log.levels.WARN)
          end
        end
      end

      if #compiled_content > 0 then
        local final_output = table.concat(compiled_content, "\n\n")

        vim.fn.setreg("+", final_output)
        vim.fn.setreg("*", final_output)

        vim.notify(string.format("Copied content of %d file(s) to clipboard!", #compiled_content), vim.log.levels.INFO)
      end
    end,
  })
end

return M
