local alphautils = require("alpha.utils")
local utils = require("utilities.utils")
local target_width = 50
local btn_padding = 10

local path_ok, plenary_path = pcall(require, "plenary.path")
if not path_ok then
  return
end

local if_nil = vim.F.if_nil

local file_icons = {
  enabled = true,
  highlight = true,
  -- available: devicons, mini, to use nvim-web-devicons or mini.icons
  -- if provider not loaded and enabled is true, it will try to use another provider
  provider = "mini",
}

local function icon(fn)
  if file_icons.provider ~= "devicons" and file_icons.provider ~= "mini" then
    vim.notify(
      "Alpha: Invalid file icons provider: " .. file_icons.provider .. ", disable file icons",
      vim.log.levels.WARN
    )
    file_icons.enabled = false
    return "", ""
  end

  local ico, hl = alphautils.get_file_icon(file_icons.provider, fn)
  if ico == "" then
    file_icons.enabled = false
    vim.notify("Alpha: Mini icons or devicons get icon failed, disable file icons", vim.log.levels.WARN)
  end
  return ico, hl
end

local leader = "SPC"

--- @param shortcut string
--- @param txt string
--- @param keybind string? optional
--- @param keybind_opts table? optional
local function button(shortcut, txt, keybind, keybind_opts, align)
  local sc_ = shortcut:gsub("%s", ""):gsub(leader, "<leader>")

  local opts = {
    position = "center",
    shortcut = shortcut,
    cursor = 3,
    width = target_width + btn_padding,
    align_shortcut = align or "right",
    hl_shortcut = "Keyword",
  }
  if keybind then
    keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
    opts.keymap = { "n", sc_, keybind, keybind_opts }
  end

  local function on_press()
    local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
    vim.api.nvim_feedkeys(key, "t", false)
  end

  return {
    type = "button",
    val = txt,
    on_press = on_press,
    opts = opts,
  }
end

local function file_button(filepath, shortcut, autocd)
  local shortened_path = filepath
  if #shortened_path > target_width then
    -- target_width = #short_filename
    shortened_path = plenary_path.new(shortened_path):shorten(1, { -3, -2, -1 })
    if #shortened_path > target_width then
      shortened_path = plenary_path.new(shortened_path):shorten(1, { -1 })
    end
  end

  local ico_txt
  local fb_hl = {}

  if file_icons.enabled then
    local ico, hl = icon(filepath)
    local hl_option_type = type(file_icons.highlight)
    if hl_option_type == "boolean" then
      if hl and file_icons.highlight then
        table.insert(fb_hl, { hl, 0, #ico })
      end
    end
    if hl_option_type == "string" then
      table.insert(fb_hl, { file_icons.highlight, 0, #ico })
    end
    ico_txt = "  " .. ico .. "  "
  else
    ico_txt = ""
  end
  local cd_cmd = (autocd and " | cd %:p:h" or "")
  local file_button_el = button(
    shortcut,
    ico_txt .. shortened_path,
    "<cmd>e " .. vim.fn.fnameescape(filepath) .. cd_cmd .. " <CR>",
    nil,
    "left"
  )
  local fn_start = shortened_path:match(".*[/\\]")
  if fn_start ~= nil then
    table.insert(fb_hl, { "Comment", #ico_txt - 2, #fn_start + #ico_txt })
  end
  file_button_el.opts.hl = fb_hl
  return file_button_el
end

local default_mru_ignore = { "gitcommit" }

local get_recent_files_opts = {
  ignore = function(path, ext)
    return (string.find(path, "COMMIT_EDITMSG")) or (vim.tbl_contains(default_mru_ignore, ext))
  end,
  autocd = false,
}

--- @param start number
--- @param cwd string? optional
--- @param items_number number? optional number of items to generate, default = 10
local function get_recent_files(start, cwd, items_number, opts)
  opts = opts or get_recent_files_opts
  items_number = if_nil(items_number, 10)

  local oldfiles = {}
  for _, v in pairs(vim.v.oldfiles) do
    if #oldfiles == items_number then
      break
    end
    local cwd_cond
    if not cwd then
      cwd_cond = true
    else
      cwd_cond = vim.startswith(v, cwd)
    end
    local ignore = (opts.ignore and opts.ignore(v, alphautils.get_extension(v))) or false
    if (vim.fn.filereadable(v) == 1) and cwd_cond and not ignore then
      oldfiles[#oldfiles + 1] = v
    end
  end

  local tbl = {}
  for i, filepath in ipairs(oldfiles) do
    local short_filepath
    if cwd then
      short_filepath = vim.fn.fnamemodify(filepath, ":.")
    else
      short_filepath = vim.fn.fnamemodify(filepath, ":~")
    end
    local shortcut = tostring(i + start - 1)

    local file_button_el = file_button(short_filepath, shortcut, opts.autocd)
    tbl[i] = file_button_el
  end
  return {
    type = "group",
    val = tbl,
    opts = {},
  }
end

local header = {
  type = "text",
  val = require("config.logo").val,
  opts = {
    position = "center",
    hl = "Type",
  },
}

local section_mru = {
  type = "group",
  val = {
    {
      type = "text",
      val = "Recent files",
      opts = {
        hl = "SpecialComment",
        shrink_margin = false,
        position = "center",
      },
    },
    { type = "padding", val = 1 },
    {
      type = "group",
      val = function()
        return { get_recent_files(0, vim.fn.getcwd()) }
      end,
      opts = { shrink_margin = false },
    },
  },
}

local buttons = {
  type = "group",
  val = {
    { type = "text",    val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
    { type = "padding", val = 1 },
    button("e", "  New file", "<cmd>ene<CR>"),
    button("SPC f f", "󰈞  Find file"),
    button("SPC f s", "󰊄  Find string"),
    button("c", "  Configuration", "<cmd>exe 'cd' stdpath('config')<CR>"),
    button("u", "  Update plugins", "<cmd>Lazy sync<CR>"),
    button("q", "󰅚  Quit", "<cmd>qa<CR>"),
  },
  position = "center",
}

local footer = {
  type = "text",
  val = vim.split(utils.get_fortune(), "\n"),
  opts = {
    position = "center",
    hl = "Number",
  },
}

local section = {
  header = header,
  buttons = buttons,
  footer = footer,
  mru = get_recent_files,
}

local config = {
  layout = {
    { type = "padding", val = 2 },
    section.header,
    { type = "padding", val = 2 },
    section_mru,
    { type = "padding", val = 2 },
    section.buttons,
    { type = "padding", val = 2 },
    section.footer,
  },
  opts = {
    margin = 5,
    setup = function()
      vim.api.nvim_create_autocmd("DirChanged", {
        pattern = "*",
        group = "alpha_temp",
        callback = function()
          require("alpha").redraw()
          vim.cmd("AlphaRemap")
        end,
      })
    end,
  },
}

return config
