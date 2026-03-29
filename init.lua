---@diagnostic disable: missing-fields
require("config.neovim-config")
local logger = require("utilities.logger")
require("config.lazy")

vim.api.nvim_create_user_command("UserShowLog", function()
  logger.show_logs()
end, {
  nargs = 0,
  desc = "Show users log",
})
