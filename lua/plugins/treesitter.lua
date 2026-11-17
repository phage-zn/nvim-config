return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      languages = {
        "lua",
        "c",
        "java",
        "typescript",
        "javascript",
        "rust",
        "zig",
        "vimdoc",
        "vim",
        "regex",
      },
    },
    config = function(_, opts)
      local ts_install = require("nvim-treesitter.install")
      local autoinstall = require("utilities.treesitter-autoinstall")
      ts_install.install(opts.languages)

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
    init = function()
      vim.g.no_plugin_maps = true
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      select = {
        lookahead = true,
        lookbehind = true,
      },
      move = {
        set_jumps = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
