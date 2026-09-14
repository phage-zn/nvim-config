return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      copilot_node_command = vim.fn.expand("$HOME") .. "/.config/nvm/versions/node/v24.16.0/bin/node",
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    lazy = true,
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  }
}
