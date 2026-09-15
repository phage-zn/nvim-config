local treesitter_config = require("nvim-treesitter.config")
local logger = require("utilities.logger")
local M = {}

function M.get_ignored()
  local ignore_path = treesitter_config.get_install_dir("parser-ignore")
  local ignored = {}

  for f in vim.fs.dir(ignore_path) do
    ignored[string.gsub(f, "%.ignore$", "")] = true
  end

  return vim.tbl_keys(ignored)
end

function M.complete_ignored(arglead)
  return vim.tbl_filter(
  --- @param v string
    function(v)
      return v:find(arglead) ~= nil
    end,
    M.get_ignored()
  )
end

function M.ignore_lang(lang)
  local ignore_path = vim.fs.joinpath(treesitter_config.get_install_dir("parser-ignore"), lang .. ".ignore")
  local ok, err = pcall(vim.fn.writefile, {}, ignore_path)
  if not ok then
    logger.error("Could not write '" .. lang .. ".ignore' to ignore_path: " .. err)
  else
    logger.info("Wrote '" .. lang .. ".ignore' to ignore_path")
  end
end

function M.clear_ignored(args)
  local ignore_path = treesitter_config.get_install_dir("parser-ignore")
  if not vim.uv.fs_stat(ignore_path) then
    logger.info(ignore_path .. " does not exist")
    return
  end
  local to_delete = {}

  for _, lang in ipairs(args.fargs) do
    if vim.tbl_contains(M.get_ignored(), lang) then
      to_delete[#to_delete + 1] = vim.fs.joinpath(ignore_path, lang .. ".ignore")
    end
  end

  local function delete(path, flags)
    local ok, err = pcall(vim.fn.delete, path, flags)
    if not ok then
      logger.error("Unable to delete " .. path .. "\n\t\t" .. err)
    end
  end

  if #to_delete == 0 then
    delete(ignore_path, "rf")
  end

  for i = 1, #to_delete do
    delete(to_delete[i], "")
  end
end

function M.autoinstall(args)
  local treesitter = require("nvim-treesitter")
  local installed = treesitter.get_installed()
  local available = treesitter.get_available()
  local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)

  if vim.list_contains(installed, lang) then
    return
  end

  if vim.tbl_contains(M.get_ignored(), lang) then
    return
  end

  if not vim.list_contains(available, lang) then
    return
  end

  local ok, response = pcall(vim.fn.confirm, "Parser available for '" .. lang .. "', install?", "&Yes\n&No\n&Ignore", 1,
    "Question")

  if not ok or response == 2 then
    return
  end

  if response == 1 then
    pcall(treesitter.install, lang)
  elseif response == 3 then
    M.ignore_lang(lang)
  end
end

return M
