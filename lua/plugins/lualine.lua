local utils = require("utilities.utils")
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    tabline = {
      lualine_a = {
        {
          'tabs',
          mode = 1,
          path = 0,
          use_mode_colors = true,
        },
      },
      lualine_x = {},
      lualine_z = {
        {
          "branch",
          on_click = utils.toggle_lazygit,
        },
      }
    },
    options = {
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
      disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {},
      lualine_c = {
        {
          "filetype",
          icon_only = true,
          separator = "",
          padding = { left = 1, right = 0 },
        },
        {
          "filename",
          on_click = function()
            vim.cmd(":Oil")
          end,
        },
        {
          "diagnostics",
          on_click = function()
            vim.cmd(":Trouble diagnostics toggle filter.buf=0")
          end,
        },
      },
      lualine_x = {
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
        },
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
        },
      },
      lualine_y = {
        {
          "branch",
          on_click = utils.toggle_lazygit,
        },
        {
          "diff",
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },
      lualine_z = {
        { "progress", separator = "",                   padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 1 } },
      },
    },
    extensions = { "lazy", "oil", "quickfix", "symbols-outline", "nvim-dap-ui", "toggleterm" },
  },
  config = function(_, opts)
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus
    require("lualine").setup(opts)
  end,
}
