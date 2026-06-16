local client = vim.lsp.get_clients({ name = "jdtls" })[1]
if not client then return end

local buf_name = vim.api.nvim_buf_get_name(0)
local jar_path, class_path = buf_name:match("^zipfile://(.-)::(.+)$")
local jar_name = vim.fn.fnamemodify(jar_path, ":t")
local class_name = vim.fn.fnamemodify(class_path, ":t")
local package = vim.fn.fnamemodify(class_path, ":h"):gsub("/", ".")
local encoded_jar = jar_path:gsub("/", "%%5C/")
local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
local source_ref = "%3C" .. package .. "(" .. class_name

local uri = "jdt://contents/" .. jar_name .. "/" .. package .. "/" .. class_name
  .. "?=" .. project
  .. "/" .. encoded_jar
  .. "=/"
  .. source_ref
client.request("java/classFileContents", { uri = uri }, function(err, result)
  if err or not result then return end
  vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
    vim.bo[buf].filetype = "java"
    vim.bo[buf].modifiable = false
  end)
end)
