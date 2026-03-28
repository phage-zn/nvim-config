local M = {}

---@enum log_level
local log_level = {
  debug = "DEBUG",
  info = "INFO",
  warn = "WARNING",
  error = "ERROR",
}

local log_dir = vim.fn.stdpath("log")
local log_name = "_user.log"

local function get_log_file()
  local log_file = log_dir .. log_name
  if not vim.uv.fs_stat(log_file) then
    local ok, err = pcall(vim.fn.writefile, {}, log_file)
    if not ok then
      vim.notify("Could not create log file: " .. err)
      return ""
    end
  end
  return log_file
end

local function log(msg, level)
  local log_file = get_log_file()
  if log_file == "" then
    vim.notify("[" .. level .. "]: " .. msg)
    return
  end

  local ok, err = pcall(vim.fn.writefile, {
    "[" .. level .. "]:\t" .. msg,
  }, log_file, "a")

  if not ok then
    vim.notify("Error writing to log file: " .. err)
  end
end

---@param msg string
function M.error(msg)
  log(msg, log_level.error)
end

---@param msg string
function M.info(msg)
  log(msg, log_level.info)
end

---@param msg string
function M.warn(msg)
  log(msg, log_level.warn)
end

---@param msg string
function M.debug(msg)
  log(msg, log_level.debug)
end

function M.show_logs()
  vim.cmd(([[tabnew %s]]):format(get_log_file()))
end

return M
