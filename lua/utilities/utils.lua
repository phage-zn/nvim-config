local utils = {}

---shortens path by turning apple/orange -> a/orange
---@param path string
---@param sep string path separator
---@param max_len integer maximum length of the full filename string
---@return string
function utils.shorten_path(path, sep, max_len)
  local len = #path
  if len <= max_len then
    return path
  end

  local segments = vim.split(path, sep)
  for idx = 1, #segments - 1 do
    if len <= max_len then
      break
    end

    local segment = segments[idx]
    local shortened = segment:sub(1, vim.startswith(segment, ".") and 2 or 1)
    segments[idx] = shortened
    len = len - (#segment - #shortened)
  end

  return table.concat(segments, sep)
end

function utils.get_file_name(path, sep)
  local segments = vim.split(path, sep)

  return segments[#segments]
end

function utils.command_exists(cmd)
  local handle = io.popen("which " .. cmd .. " 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
  end
  return false
end

function utils.get_fortune()
  local result = "Nothing going on here..."
  if utils.command_exists("fortune") then
    local handle = io.popen("fortune -s")
    if handle then
      result = handle:read("*a")
      handle:close()
    end
  end
  if utils.command_exists("cowthink") then
    local handle = io.popen('cowthink -f $(find /usr/share/cowsay -type f | shuf -n 1) "' .. result .. '"')
    if handle then
      result = handle:read("*a")
      handle:close()
    end
  end
  return result
end

function utils.toggle_lazygit()
  local terminal = require("toggleterm.terminal").Terminal
  local lazygit = terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
  lazygit:toggle()
end

return utils
