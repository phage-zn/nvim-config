local M = {}

M.Result = {
  SUCCESS = {},
  FAIL = {},
  CANCEL = {},
}

function M.delete(buf, force)
  if not vim.api.nvim_buf_is_valid(buf) then
    return M.Result.FAIL
  end

  if vim.bo[buf].modified and not force then
    local name = vim.fn.bufname(buf)
    local ok, choice = pcall(vim.fn.confirm, "Save changes to '" .. name == "" and "Untitled" or name .. "'?",
      "&Yes\n&No\n&Cancel")
    if not ok or choice == 0 then
      return M.Result.FAIL
    end
    if choice == 3 then
      return M.Result.CANCEL
    end
    if choice == 1 then
      vim.api.nvim_buf_call(buf, vim.cmd.write)
    end
  end

  vim.api.nvim_buf_delete(buf, { force = true })
  return M.Result.SUCCESS
end

function M.write(buf, filename)
  if not (vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified) then
    return M.Result.FAIL
  end
  local buf_info = vim.fn.getbufinfo(buf)[1]
  if buf_info.name == "" then
    vim.notify(buf_info.name .. " is nothing")
    local response = vim.fn.input("Save as: ", './', "dir_in_path")
    if response == "" then
      return M.Result.FAIL
    end
    vim.cmd("sav ++p" .. response)
  else
    vim.api.nvim_buf_call(buf, vim.cmd.write)
  end

  return M.Result.SUCCESS
end

return M
