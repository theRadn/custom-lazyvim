return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
  },
  config = function()
    local dap = require("dap")
    dap.adapters.cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = "~/.local/share/nvim/mason/bin/OpenDebugAD7",
    }
    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        -- program = function()
        --   return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        -- end,
        program = vim.fn.expand("%:t:r"),
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
      },
    }
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp

    dap.adapters["pwa-node"] = {
      type = "server",
      host = "127.0.0.1",
      port = 9229,
      executable = {
        command = "js-debug-adapter",
        args = {
          "9229",
        },
      },
    }
    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    }
  end,
}
