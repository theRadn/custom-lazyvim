-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "<C-H>", "<C-w>", { noremap = true })
vim.keymap.set("i", "<C-j>", "<Esc>", { noremap = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })

vim.keymap.set("v", "<C-c>", '"+y', { noremap = true })

-- vim.keymap.set("n", "<Up>", "10k", { noremap = true })
-- vim.keymap.set("n", "<Down>", "10j", { noremap = true })
-- vim.keymap.set("v", "<Up>", "10k", { noremap = true })
-- vim.keymap.set("v", "<Down>", "10j", { noremap = true })

vim.keymap.set("c", "<C-H>", "<C-w>", { noremap = true })

vim.keymap.set("i", "<C-Backspace>", "<C-W>", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<PageDown>", "<C-d>", { desc = "Half-page down" })
vim.keymap.set({ "n", "v" }, "<PageUp>", "<C-u>", { desc = "Half-page up" })

-- neovide
if vim.g.neovide then
  vim.keymap.set({ "n", "v", "s", "x", "o", "i", "l", "c", "t" }, "<C-S-V>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end, { noremap = true, silent = true })
  vim.keymap.set("n", "<C-->", function()
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1) * 0.9
  end)
  vim.keymap.set("n", "<C-=>", function()
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1) * 1.1
  end)
end

-- oil
vim.keymap.set("n", "'", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>'", "<cmd>cd %:p:h<cr>", { desc = "Change directory to current file" })
vim.keymap.set("n", "<leader>t", function()
  Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal in file directory" })

-- code-runner
-- vim.keymap.set("n", "<leader>rr", ":RunCode<CR>", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false })
-- vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false })

vim.keymap.set("n", "<leader>rr", function()
  require("util.run-code").run()
end, { desc = "Run Code in Snacks" })

vim.keymap.set("n", "<leader>fy", function()
  require("util.file-reader").copy_multiple_files_content()
end, { desc = "Copy Multiple File Contents to Clipboard" })

vim.keymap.set("n", "<leader>fl", function()
  require("util.format-list").expand_inline_list()
end, { desc = "Expand / format inline list" })

vim.keymap.set(
  "n",
  "<leader>ut",
  "<cmd>ToggleBufferline<CR>",
  { desc = "Toggle Bufferline", noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>st", function()
  Snacks.picker.treesitter()
end, { desc = "Search Treesitter Nodes" })

-- vim.keymap.set("n", "<leader>st", function()
--   local ft = vim.bo.filetype
--   Snacks.picker.treesitter({ filter = { [ft] = true } })
-- end, { desc = "Search All Treesitter Nodes" })

-- treewalker
-- movement
vim.keymap.set({ 'n', 'v' }, '<Up>', '<cmd>Treewalker Up<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<Down>', '<cmd>Treewalker Down<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<Left>', '<cmd>Treewalker Left<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<Right>', '<cmd>Treewalker Right<cr>', { silent = true })
-- swapping
vim.keymap.set('n', '<S-Up>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
vim.keymap.set('n', '<S-Down>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
vim.keymap.set('n', '<S-Left>', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
vim.keymap.set('n', '<S-Right>', '<cmd>Treewalker SwapRight<cr>', { silent = true })

-- copilot
vim.keymap.set("n", "<leader>ct", function()
  require("copilot.suggestion").toggle_auto_trigger()

  if vim.b.copilot_suggestion_auto_trigger then
    print("Copilot: Auto-Trigger ON")
  else
    print("Copilot: Auto-Trigger OFF")
  end
end, { desc = "Toggle Copilot Auto-Trigger with Message" })

-- terminal
vim.keymap.set({ "n", "t" }, "<M-o>", function()
  local current_file = vim.fn.expand("%:p")
  local cwd = (current_file ~= "" and vim.bo.buftype == "") 
    and vim.fn.fnamemodify(current_file, ":h") 
    or (vim.fs.root(0, { ".git", "Cargo.toml", "go.mod", "package.json" }) or vim.fn.getcwd())
  Snacks.terminal.open(nil, { 
    win = { position = "bottom", width = 0.4 }, 
    cwd = cwd 
  })
end, { desc = "New Terminal (Bottom)" })

vim.keymap.set({ "n", "t" }, "<M-i>", function()
  local current_file = vim.fn.expand("%:p")
  local cwd = (current_file ~= "" and vim.bo.buftype == "") 
    and vim.fn.fnamemodify(current_file, ":h") 
    or (vim.fs.root(0, { ".git", "Cargo.toml", "go.mod", "package.json" }) or vim.fn.getcwd())
  Snacks.terminal.open(nil, { win = { position = "right", width = 0.4 }, cwd = cwd })
end, { desc = "New Terminal (Right)" })

vim.keymap.set("t", "<C-d>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype == "terminal" then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  else
    vim.notify("Current buffer is not a terminal", vim.log.levels.WARN)
  end
end, { desc = "Kill Terminal Process & Close" })

-- vscode
if vim.g.vscode then
    local vscode = require('vscode')

    vim.keymap.set('n', '<leader><leader>', function()
        -- vscode.call('fzf-quick-open.runFzfFileProjectRoot')
        vscode.call('workbench.action.quickOpen')
    end)
    vim.keymap.set('n', '<leader>sg', function()
        -- vscode.call('fzf-quick-open.runFzfSearchProjectRoot')
        -- vscode.call('workbench.action.quickTextSearch')
        vscode.call('periscope.search')
    end)
    vim.keymap.set('n', '<leader>a', function()
        vscode.call('workbench.action.gotoSymbol')
    end)
    vim.keymap.set('n', '<leader>bd', function()
        vscode.call('workbench.action.closeActiveEditor')
    end)
    vim.keymap.set('n', '<leader>bo', function()
        vscode.call('workbench.action.closeOtherEditors')
    end)
    vim.keymap.set('n', "'", function()
        vscode.call('oil-code.open')
    end)
    vim.keymap.set('n', "<cr>", function()
        vscode.call('oil-code.select')
    end)
    vim.keymap.set('n', '<leader>rr', function()
        vscode.call('code-runner.run')
    end)
end
