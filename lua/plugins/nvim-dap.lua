return {
  "mfussenegger/nvim-dap",
  lazy = true,
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
      "<leader>db",
      "<cmd>DapToggleBreakpoint<cr>",
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dc",
      "<cmd>DapContinue<cr>",
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
      "<cmd>DapPause<cr>",
      desc = "Pause",
    },
    {
      "<leader>ds",
      function()
        require("dap").close()
      end,
      desc = "Stop",
    },
    {
      "<leader>dT",
      "<cmd>DapTerminate<cr>",
      desc = "Terminate",
    },
  },
}
