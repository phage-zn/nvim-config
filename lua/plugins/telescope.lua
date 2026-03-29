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
    opts = {
      pickers = {
        colorscheme = {
          enable_preview = true,
        },
      },
      extensions = {
        ["ui-select"] = function()
          return {
            require("telescope.themes").get_dropdown(),
          }
        end,
        undo = {},
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "undo")
    end,
  },
}
