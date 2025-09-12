---@diagnostic disable: missing-fields
require("config.neovim-config")
-- LAZY SETUP ---[[ - ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- PLUGINS CONFIG --
require("lazy").setup({
  { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme "tokyonight" end },
  { import = "plugins" },
})

local wk = require("which-key")
local keymaps = require("config.keymap-config")
local lsp_keymaps = require("config.lsp-keymaps")

wk.add(keymaps)
wk.add(lsp_keymaps)
