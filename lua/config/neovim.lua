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

vim.o.number = true
vim.o.relativenumber = true

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.inccommand = "split"
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.hlsearch = true

vim.diagnostic.config({
  float = { source = true },
})

vim.api.nvim_create_user_command("UserShowLog", function()
  require("utilities.logger").show_logs()
end, {
  nargs = 0,
  desc = "Show users log",
})
