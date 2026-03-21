local ts_config = require("config.treesitter-config")
return {
  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(ts_config.treesitter.languages)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup(ts_config.textobjects)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
