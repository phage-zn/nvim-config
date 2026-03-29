return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  config = function()
    require("dap").configurations.java = {
      {
        type = "java",
        request = "attach",
        name = "Debug (Attach)",
        hostName = "127.0.0.1",
        port = 5005,
      },
      {
        type = "java",
        request = "launch",
        name = "Debug (Launch)",
        hostName = "127.0.0.1",
        port = 5005,
      },
      {
        type = "java",
        request = "launch",
        name = "Debug (Launch with args)",
        hostName = "127.0.0.1",
        args = function()
          return vim.fn.input("Program arguments: ")
        end,
        port = 5005,
      },
    }
  end,
  keys = {
    {
      "<leader>d",
      group = "DAP",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle Breakpoint",
    },

    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },

    {
      "<leader>dC",
      function()
        require("dap").run_to_cursor()
      end,
      desc = "Run to Cursor",
    },

    {
      "<leader>dp",
      function()
        require("dap").pause()
      end,
      desc = "Pause",
    },

    {
      "<leader>ds",
      function()
        require("dap").stop()
      end,
      desc = "Stop",
    },

    {
      "<leader>dT",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },
  },
}
