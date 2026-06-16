return {
  "rcarriga/nvim-dap-ui",
  opts = {},
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
    "nvim-neotest/nvim-nio",
  },
}
