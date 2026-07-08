vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.showmode = false
vim.o.scrolloff = 20
vim.o.breakindent = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.fillchars = "vert:║,horiz:═,vertright:╠,vertleft:╣,horizup:╩,horizdown:╦,verthoriz:╬,eob: "

vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Tab stop defaults
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

-- Case insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Window split defaults
vim.o.inccommand = "split"
vim.o.splitright = true
vim.o.splitbelow = true

-- whitespace
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Highlight on search
vim.o.hlsearch = true

vim.o.exrc = true
local diagnostic_config = {
  float = {
    source = "always",
    style = "minimal",
    border = "rounded",
    header = "",
    prefix = "",
  },
}

vim.diagnostic.config(diagnostic_config)
vim.opt.backup = false
vim.opt.writebackup = false
vim.o.exrc = true
