local M = {}

local is_win = vim.fn.has("win32") == 1

-- Platform-aware shell quoting
local function quote(s)
  if is_win then
    -- PowerShell: Escape single quotes by doubling them
    return "'" .. tostring(s):gsub("'", "''") .. "'"
  else
    -- Bash: Escape single quotes by closing the string, escaping the quote, and reopening
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
  end
end

local function join_args(args)
  local out = {}
  for i, arg in ipairs(args) do
    if i == 1 then
      out[#out + 1] = arg
    else
      out[#out + 1] = quote(arg)
    end
  end
  return table.concat(out, " ")
end

local function get_win_shell()
  return vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell.exe"
end

local function runner_for(ft, file)
  local basename = vim.fn.fnamemodify(file, ":t:r")
  local exe = basename .. (is_win and ".exe" or "")
  
  local q_file = quote(file)
  local q_exe = quote(exe)
  local q_basename = quote(basename)

  local runners = {
    lua = { "lua", file },
    python = { "python", file },
    javascript = { "node", file },
    javascriptreact = { "node", file },
    typescript = { "node", file },
    typescriptreact = { "node", file },
    go = { "go", "run", file },
    sh = { "bash", file },
    zsh = { "zsh", file },
    ps1 = { is_win and get_win_shell() or "pwsh", "-File", file },
    powershell = { is_win and get_win_shell() or "pwsh", "-File", file },
  }

  if is_win then
    runners.c = "gcc " .. q_file .. " -g -o " .. q_exe .. "; ./" .. q_exe
    runners.cpp = "g++ " .. q_file .. " -g -o " .. q_exe .. "; ./" .. q_exe
    runners.java = "javac " .. q_file .. "; java " .. q_basename
  else
    runners.c = "gcc " .. q_file .. " -g -o " .. q_exe .. " && ./" .. q_exe
    runners.cpp = "g++ " .. q_file .. " -g -o " .. q_exe .. " && ./" .. q_exe
    runners.java = "javac " .. q_file .. " && java " .. q_basename
  end

  return runners[ft]
end

function M.run()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  vim.cmd("write")

  local ft = vim.bo.filetype
  local cmd = runner_for(ft, file)

  if not cmd then
    vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local cwd = vim.fs.root(0, { ".git", "Cargo.toml", "go.mod", "package.json" }) or vim.fn.getcwd()
  
  local cmd_str = type(cmd) == "table" and join_args(cmd) or cmd
  local terminal_cmd

  if is_win then
    local ps_cmd = string.format("& { Set-Location %s; %s }", quote(cwd), cmd_str)
    terminal_cmd = {
      get_win_shell(),
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      ps_cmd,
    }
  else
    local bash_cmd = string.format("cd %s && %s", quote(cwd), cmd_str)
    terminal_cmd = {
      "bash",
      "-c",
      bash_cmd,
    }
  end

  local terminal_opts = {
    cwd = cwd,
    auto_close = false,
  }

  if type(Snacks) == "table" and Snacks.terminal then
    if type(Snacks.terminal.open) == "function" then
      Snacks.terminal.open(terminal_cmd, terminal_opts)
      return
    elseif type(Snacks.terminal) == "function" then
      Snacks.terminal(terminal_cmd, terminal_opts)
      return
    end
  end

  vim.notify("Snacks terminal is not available", vim.log.levels.ERROR)
end

return M
