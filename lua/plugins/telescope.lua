return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      {
        "nvim-telescope/telescope-ui-select.nvim",
      },
    },
    config = function()
      local telescopeConfig = {
        pickers = {
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          undo = {},
        },
      }
      require("telescope").setup(telescopeConfig)
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "undo")
    end,
  },
}
