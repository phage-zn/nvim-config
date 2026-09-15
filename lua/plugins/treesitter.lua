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
    init = function ()
      vim.g.no_plugin_maps = true
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      select = {
        lookahead = true,
        lookbehind = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },
      move = {
        set_jumps = true,
        goto_next_start = {
          ["gm"] = "@function.outer",
          ["go"] = "@class.outer",
        },
        goto_next_end = {
          ["gw"] = "@function.outer",
          ["]C"] = "@class.outer",
        },
        goto_previous_start = {
          ["gM"] = "@function.outer",
          ["gO"] = "@class.outer",
        },
        goto_previous_end = {
          ["gW"] = "@function.outer",
          ["[C"] = "@class.outer",
        },
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
