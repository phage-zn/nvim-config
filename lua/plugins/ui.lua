return {
  {
    'goolord/alpha-nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local theme = require("config.alpha-theme")
      local function command_exists(cmd)
        local handle = io.popen("which " .. cmd .. " 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          return result ~= ""
        end
        return false
      end

      local logo = [[
 ██████   █████ ██████████    ███████    █████   █████ █████ ██████   ██████
░░██████ ░░███ ░░███░░░░░█  ███░░░░░███ ░░███   ░░███ ░░███ ░░██████ ██████
 ░███░███ ░███  ░███  █ ░  ███     ░░███ ░███    ░███  ░███  ░███░█████░███
 ░███░░███░███  ░██████   ░███      ░███ ░███    ░███  ░███  ░███░░███ ░███
 ░███ ░░██████  ░███░░█   ░███      ░███ ░░███   ███   ░███  ░███ ░░░  ░███
 ░███  ░░█████  ░███ ░   █░░███     ███   ░░░█████░    ░███  ░███      ░███
 █████  ░░█████ ██████████ ░░░███████░      ░░███      █████ █████     █████
░░░░░    ░░░░░ ░░░░░░░░░░    ░░░░░░░         ░░░      ░░░░░ ░░░░░     ░░░░░
      ]]
      local function get_fortune()
        if command_exists("fortune") and command_exists("cowsay") then
          local handle = io.popen("fortune -s | cowsay")
          if handle then
            local result = handle:read("*a")
            handle:close()
            return result
          end
        end
        return ""
      end
      theme.section.header.val = vim.split(logo, "\n")
      -- startify.section.footer.val = vim.split(get_fortune(), "\n")
      require("alpha").setup(theme.config)
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin-macchiato"
    end
  },
  -- { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme "tokyonight" end },
  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim"
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require("gitsigns").setup(require("config.gitsigns-config"))
    end
  },
  {
    'stevearc/dressing.nvim', opts = {},
  },
  {
    'b0o/incline.nvim',
    config = function()
      require('incline').setup()
    end,
    -- Optional: Lazy load Incline
    event = 'VeryLazy',
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      vim.o.laststatus = vim.g.lualine_laststatus
      require('lualine').setup(require("config.lualine-config"))
    end
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = "helix",
    }
  },
  {
    'folke/todo-comments.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    opts = {
      signs = true
    }
  },
  {
    'folke/trouble.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {},
  }
}
