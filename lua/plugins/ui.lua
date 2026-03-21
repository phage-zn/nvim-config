return {
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
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
        local result = "Nothing going on here..."
        if command_exists("fortune") then
          local handle = io.popen("fortune -s")
          if handle then
            result = handle:read("*a")
            handle:close()
          end
        end
        if command_exists("cowthink") then
          local handle = io.popen('cowthink -f $(find /usr/share/cowsay -type f | shuf -n 1) "' .. result .. '"')
          if handle then
            result = handle:read("*a")
            handle:close()
          end
        end
        return result
      end
      theme.section.header.val = vim.split(logo, "\n")
      theme.section.footer.val = vim.split(get_fortune(), "\n")
      require("alpha").setup(theme.config)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup(require("config.gitsigns-config"))
    end,
  },
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  {
    "b0o/incline.nvim",
    config = function()
      require("incline").setup()
    end,
    -- Optional: Lazy load Incline
    event = "VeryLazy",
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      vim.o.laststatus = vim.g.lualine_laststatus
      require("lualine").setup(require("config.lualine-config"))
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      signs = true,
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
