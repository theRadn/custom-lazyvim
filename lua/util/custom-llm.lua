local M = {}

M.config_collection = {
  {
    endpoint = "https://api.openai.com/v1/chat/completions",
    api_key = os.getenv("OPENAI_API_KEY") or "",
    model = "gpt-4o-mini",
  },
  {
    endpoint = "http://localhost:11434/v1/completions", -- Ollama local server
    api_key = "", -- Ollama does not require an API key for local usage
    model = "llama2",
  },
  {
    endpoint = "https://maas.qwencloudapi.com/compatible-mode/v1/chat/completions",
    api_key = os.getenv("QWEN_API_KEY") or "",
    model = "qwen3.7-flash",
  },
  {
    endpoint = "https://inference.celeris.ai/celeris-1/v1/chat/completions",
    api_key = os.getenv("CELERIS_API_KEY") or "",
    model = "celeris-1",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- Path to persist the last selected model (e.g. ~/.local/state/nvim/ai_chat_state.json)
local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "ai_chat_state.json")

local function save_selected_index(idx)
  local ok, encoded = pcall(vim.fn.json_encode, { selected_index = idx })
  if ok then
    vim.fn.writefile({ encoded }, state_file)
  end
end

local function load_selected_config()
  if vim.fn.filereadable(state_file) == 1 then
    local lines = vim.fn.readfile(state_file)
    local ok, data = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
    if ok and data and data.selected_index and M.config_collection[data.selected_index] then
      return vim.deepcopy(M.config_collection[data.selected_index])
    end
  end
  -- Fallback to #4 if no state file exists yet
  return vim.deepcopy(M.config_collection[4])
end

-- Default configuration (loads last saved choice, or falls back to #4)
M.config = load_selected_config()

function M.count_tokens(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local word_count = 0

  for _, line in ipairs(lines) do
    -- Skip role delimiter lines so only actual message content is counted
    if not line:match("{{ %% %a+ %% }}") then
      for _ in line:gmatch("%S+") do
        word_count = word_count + 1
      end
    end
  end

  vim.notify("Buffer word count: " .. word_count, vim.log.levels.INFO, { title = "Token Counter" })
  return word_count
end

function M.select_model()
  -- Build indexed list so we know which position in config_collection was picked
  local items = {}
  for idx, cfg in ipairs(M.config_collection) do
    table.insert(items, { idx = idx, cfg = cfg })
  end

  vim.ui.select(items, {
    prompt = "Select AI Model:",
    format_item = function(entry)
      local item = entry.cfg
      local active = (item.model == M.config.model and item.endpoint == M.config.endpoint) and " (active)" or ""
      return string.format("%s%s — %s", active, item.model, item.endpoint)
    end,
  }, function(choice)
    if not choice then
      return
    end

    M.config = vim.deepcopy(choice.cfg)
    save_selected_index(choice.idx)
    vim.notify("Switched model to " .. M.config.model, vim.log.levels.INFO)
  end)
end

local function append_text_to_buffer(bufnr, text)
  bufnr = bufnr or 0
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  -- vim_buf_set_lines requires a table of strings without embedded newlines
  local lines = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines)
end

-- Appends streaming text chunks inline to the very end of the buffer
local function append_stream_chunk(bufnr, text)
  if not text or text == "" or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local last_line_idx = vim.api.nvim_buf_line_count(bufnr) - 1
  local last_line = vim.api.nvim_buf_get_lines(bufnr, last_line_idx, last_line_idx + 1, false)[1] or ""
  local last_col = #last_line
  local lines = vim.split(text, "\n", { plain = true })

  vim.api.nvim_buf_set_text(bufnr, last_line_idx, last_col, last_line_idx, last_col, lines)
end

local function parse_buffer_content(bufnr)
  bufnr = bufnr or 0
  local buffer_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local chat_history = {}

  for _, line in ipairs(buffer_content) do
    if line:match("{{ %% System %% }}") then
      table.insert(chat_history, { role = "system", content = "" })
    elseif line:match("{{ %% User %% }}") then
      table.insert(chat_history, { role = "user", content = "" })
    elseif line:match("{{ %% Assistant %% }}") then
      table.insert(chat_history, { role = "assistant", content = "" })
    elseif #chat_history > 0 then
      local current = chat_history[#chat_history]
      if current.content == "" then
        current.content = line
      else
        current.content = current.content .. "\n" .. line
      end
    end
  end

  -- Trim trailing whitespace/newlines from parsed messages
  for _, msg in ipairs(chat_history) do
    msg.content = vim.trim(msg.content)
  end

  return chat_history
end

local function fetch_chat_completion_stream(messages, on_chunk, on_done)
  local payload = vim.fn.json_encode({
    model = M.config.model,
    messages = messages,
    stream = true,
  })

  local cmd = {
    "curl",
    "-s",
    "-N", -- Disable output buffering so chunks arrive immediately
    "-X",
    "POST",
    M.config.endpoint,
    "-H",
    "Content-Type: application/json",
    "-d",
    payload,
  }

  -- Only attach Authorization header if an API key is provided (optional for local endpoints like Ollama)
  if M.config.api_key and M.config.api_key ~= "" then
    table.insert(cmd, "-H")
    table.insert(cmd, "Authorization: Bearer " .. M.config.api_key)
  end

  local sse_buffer = ""

  vim.system(cmd, {
    text = true,
    stdout = function(err, data)
      if err or not data then
        return
      end

      -- Accumulate partial TCP packets until we have complete SSE lines
      sse_buffer = sse_buffer .. data
      while true do
        local newline_pos = sse_buffer:find("\n")
        if not newline_pos then
          break
        end

        local line = sse_buffer:sub(1, newline_pos - 1):gsub("\r$", "")
        sse_buffer = sse_buffer:sub(newline_pos + 1)

        if line:sub(1, 6) == "data: " then
          local json_str = line:sub(7)
          if json_str ~= "[DONE]" then
            vim.schedule(function()
              local ok, json_data = pcall(vim.fn.json_decode, json_str)
              if ok and json_data and json_data.choices and json_data.choices[1] then
                local delta = json_data.choices[1].delta
                if delta and delta.content then
                  on_chunk(delta.content)
                end
              end
            end)
          end
        end
      end
    end,
  }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("API Error: " .. (result.stderr or "Unknown error"), vim.log.levels.ERROR)
        return
      end
      if on_done then
        on_done()
      end
    end)
  end)
end

function M.get_chat_history()
  local history = parse_buffer_content(0)
  vim.notify(vim.inspect(history), vim.log.levels.INFO, { title = "Chat History" })
  return history
end

function M.setup_buffer()
  -- Open the buffer in a new tab
  vim.api.nvim_command("tabnew")
  append_text_to_buffer(0, "{{ % System % }}")
  append_text_to_buffer(0, "You are a helpful assistant that will assist the user.")
  append_text_to_buffer(0, "")
  append_text_to_buffer(0, "{{ % User % }}")
  append_text_to_buffer(0, "")
end

function M.send_chat()
  local bufnr = vim.api.nvim_get_current_buf()
  local messages = parse_buffer_content(bufnr)

  if #messages == 0 then
    vim.notify("No chat messages found in buffer.", vim.log.levels.WARN)
    return
  end

  vim.notify("Sending request to " .. M.config.model .. "...", vim.log.levels.INFO)

  -- Prepare the Assistant header immediately so chunks stream right beneath it
  append_text_to_buffer(bufnr, "")
  append_text_to_buffer(bufnr, "{{ % Assistant % }}")
  append_text_to_buffer(bufnr, "")

  fetch_chat_completion_stream(messages, function(chunk)
    append_stream_chunk(bufnr, chunk)
  end, function()
    append_text_to_buffer(bufnr, "")
    append_text_to_buffer(bufnr, "{{ % User % }}")
    append_text_to_buffer(bufnr, "")
    -- Defer slightly so buffer line updates don't overwrite the command-line message
    vim.defer_fn(function()
      vim.notify("Received response from " .. M.config.model, vim.log.levels.INFO)
    end, 50)
  end)
end

return M
