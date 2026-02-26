vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.completeopt = 'menuone,noselect'
vim.o.showmode = false
vim.o.scrolloff = 20
vim.o.breakindent = true
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.fillchars ="vert:║,horiz:═,vertright:╠,vertleft:╣,horizup:╩,horizdown:╦,verthoriz:╬,eob: "

vim.opt.foldmethod = 'marker'

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Tab stop defaults
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Case insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Window spit defaults
vim.o.inccommand = 'split'
vim.o.splitright = true
vim.o.splitbelow = true

-- whitespace
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Highlight on search
vim.o.hlsearch = true

local diagnostic_config = {
  float = { source = "always" },
}

vim.diagnostic.config(diagnostic_config)
