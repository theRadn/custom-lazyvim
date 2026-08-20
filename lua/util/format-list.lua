-- lua/util/format_list.lua
local M = {}

function M.expand_inline_list()
  local line = vim.api.nvim_get_current_line()

  -- Extract original line indentation and trim for pattern matching
  local indent = line:match("^(%s*)") or ""
  local trimmed_line = line:match("^%s*(.*)$")

  -- Match prefix, container opening/closing, contents, and allow optional trailing commas/whitespace
  local prefix, open_char, content, close_char = trimmed_line:match("^(.-)(%[)(.-)(%])%s*,?%s*$")
  if not content then
    -- Fixed: added %s*,?%s*$ here so it handles trailing commas/spaces for parentheses too
    prefix, open_char, content, close_char = trimmed_line:match("^(.-)(%()(.-)(%))%s*,?%s*$")
  end
  if not content then
    prefix, open_char, content, close_char = trimmed_line:match("^(.-)({)(.-)(})%s*,?%s*$")
  end

  if not content then
    vim.notify("No container found on this line to format", vim.log.levels.WARN)
    return
  end

  -- Split content by commas while respecting nested brackets, braces, parentheses, and quotes
  local items = {}
  local current_item = ""
  local in_quotes = false
  local quote_char = nil
  local bracket_depth = 0
  local brace_depth = 0
  local paren_depth = 0

  for i = 1, #content do
    local char = content:sub(i, i)

    if in_quotes then
      if char == quote_char then
        -- Handle escaped quotes (e.g., \" or \')
        local escaped = false
        if i > 1 and content:sub(i - 1, i - 1) == "\\" then
          local b_count = 0
          local j = i - 1
          while j >= 1 and content:sub(j, j) == "\\" do
            b_count = b_count + 1
            j = j - 1
          end
          if b_count % 2 ~= 0 then
            escaped = true
          end
        end
        if not escaped then
          in_quotes = false
          quote_char = nil
        end
      end
      current_item = current_item .. char
    else
      if char == '"' or char == "'" then
        in_quotes = true
        quote_char = char
        current_item = current_item .. char
      elseif char == "[" then
        bracket_depth = bracket_depth + 1
        current_item = current_item .. char
      elseif char == "]" then
        bracket_depth = bracket_depth - 1
        current_item = current_item .. char
      elseif char == "{" then
        brace_depth = brace_depth + 1
        current_item = current_item .. char
      elseif char == "}" then
        brace_depth = brace_depth - 1
        current_item = current_item .. char
      elseif char == "(" then
        paren_depth = paren_depth + 1
        current_item = current_item .. char
      elseif char == ")" then
        paren_depth = paren_depth - 1
        current_item = current_item .. char
      elseif char == "," and bracket_depth == 0 and brace_depth == 0 and paren_depth == 0 then
        -- Only split if we are at the top level (depth 0 and not in quotes)
        local trimmed = current_item:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
          table.insert(items, trimmed)
        end
        current_item = ""
      else
        current_item = current_item .. char
      end
    end
  end

  -- Catch the last item after the final comma
  local final_trimmed = current_item:match("^%s*(.-)%s*$")
  if final_trimmed ~= "" then
    table.insert(items, final_trimmed)
  end

  if #items == 0 then
    vim.notify("No items found inside the container", vim.log.levels.WARN)
    return
  end

  -- Determine indentation spacing based on Neovim's shiftwidth configuration
  local sw = vim.fn.shiftwidth()
  if sw == 0 then sw = 4 end
  local inner_indent = indent .. string.rep(" ", sw)

  -- Build the multiline structure with proper indentation alignment
  local formatted = { indent .. prefix .. open_char }
  for _, item in ipairs(items) do
    table.insert(formatted, string.format("%s%s,", inner_indent, item))
  end
  table.insert(formatted, indent .. close_char)

  -- Replace the current line with the new multiline block
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, formatted)
end

return M
