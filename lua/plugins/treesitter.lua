local ts_config = require("config.treesitter-config")
local logger = require("utilities.logger")
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      local autoinstall = require("utilities.treesitter-autoinstall")
      treesitter.install(ts_config.treesitter.languages)

      vim.api.nvim_create_user_command("TSUserClearIgnore", autoinstall.clear_ignored, {
        desc = "Remove language(s) from the ignore_path to allow for install prompts",
        force = true,
        nargs = "*",
        complete = autoinstall.complete_ignored,
      })


      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          autoinstall.autoinstall(args)
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
