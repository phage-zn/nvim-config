local dap = require("dap")
return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
      dap.configurations.java = {
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
          dap.toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },

      {
        "<leader>dc",
        function()
          dap.continue()
        end,
        desc = "Continue",
      },

      {
        "<leader>dC",
        function()
          dap.run_to_cursor()
        end,
        desc = "Run to Cursor",
      },

      {
        "<leader>dp",
        function()
          dap.pause()
        end,
        desc = "Pause",
      },

      {
        "<leader>ds",
        function()
          dap.stop()
        end,
        desc = "Stop",
      },

      {
        "<leader>dT",
        function()
          dap.terminate()
        end,
        desc = "Terminate",
      },

      {
        "<leader>da",
        function()
          dap.attach()
        end,
        desc = "Attach",
      },
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    config = true,
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    config = true,
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Dap UI",
      },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
  },
}
