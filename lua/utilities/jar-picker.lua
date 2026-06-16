local M = {}
local util = require('jdtls.util')
local jdtls = require('jdtls')

local INDEX_TTL = 7 * 24 * 60 * 60 -- 7 days in seconds
local function index_dir(workspace_dir)
  return workspace_dir .. "/.jar-index"
end

---@param val string
---@return string
local function sha1(val)
  local cmd = {
    vim.fn.executable("python3") == 1 and "python3" or "python",
    "-c",
    string.format("from hashlib import sha1; print(sha1(b'%s').hexdigest())", val)
  }
  return vim.trim(vim.system(cmd):wait().stdout)
end

---@return string?
local function tempdir()
  local candidates = {
    os.getenv("TMPDIR"),
    os.getenv("TEMP"),
    os.getenv("TMP"),
    "/tmp"
  }
  for _, candidate in pairs(candidates) do
    if candidate and vim.uv.fs_stat(candidate) then
      return candidate
    end
  end
  return nil
end

local function index_path(workspace_dir) return index_dir(workspace_dir) .. "/index.tsv" end
local function hash_path(workspace_dir)  return index_dir(workspace_dir) .. "/deps.hash"  end

local function uv_readable(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil
end

---@return string?, vim.lsp.Client?
local function extract_data_dir(bufnr)
  -- Prefer client from current buffer, in case there are multiple jdtls clients (multiple projects)
  local clients = util.get_clients({ name = "jdtls", bufnr = bufnr })
  if not next(clients) then
    -- Fallback to other active `jdtls` clients - in case the user is in a different
    -- buffer like the quickfix list
    clients = util.get_clients({ name = "jdtls" })
  end

  local client
  if #clients > 1 then
    ---@diagnostic disable-next-line: cast-local-type
    client = require('jdtls.ui').pick_one(
      clients,
      'Multiple jdtls clients found, pick one: ',
      function(c) return c.config.root_dir end
    )
  else
    client = clients[1]
  end

  if client and client.config and client.config.cmd then
    local cmd = client.config.cmd
    if type(cmd) == "table" then
      for i, part in pairs(cmd) do
        -- jdtls helper script uses `--data`, java jar command uses `-data`.
        if part == '-data' or part == '--data' then
          return client.config.cmd[i + 1], client
        end
      end
      if cmd[1] == "jdtls" or vim.endswith(cmd[1], "/jdtls") then
        -- The jdtls script defaults to `tmpdir/jdtls- + sha1(cwd_name)`
        local tmp = tempdir()
        if tmp then
          local cwd_basename = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          local datadir = vim.fs.joinpath(tmp, "jdtls-" .. sha1(cwd_basename))
          if vim.uv.fs_stat(datadir) then
            return datadir, client
          end
        end
      end
    end
  end

  return nil, nil
end

local function uv_mkdir_p(path)
  local parts = {}
  local p = path
  while p and p ~= "/" and p ~= "" do
    table.insert(parts, 1, p)
    local parent = p:match("^(.+)/[^/]+$")
    if not parent or parent == p then break end
    p = parent
  end
  for _, part in ipairs(parts) do
    local stat = vim.uv.fs_stat(part)
    if not stat then
      vim.uv.fs_mkdir(part, 493) -- 0755
    end
  end
end

local function uv_read(path)
  local fd = vim.uv.fs_open(path, "r", 438)
  if not fd then return nil end
  local stat = vim.uv.fs_fstat(fd)
  if not stat then vim.uv.fs_close(fd); return nil end
  local data = vim.uv.fs_read(fd, stat.size, 0)
  vim.uv.fs_close(fd)
  return data
end

local function uv_write(path, data)
  local fd = vim.uv.fs_open(path, "w", 420) -- 0644
  if not fd then return false end
  vim.uv.fs_write(fd, data, 0)
  vim.uv.fs_close(fd)
  return true
end

local function is_stale(workspace_dir)
  local hp = hash_path(workspace_dir)
  local ip = index_path(workspace_dir)
  if not uv_readable(hp) or not uv_readable(ip) then return true end
  local stat = vim.uv.fs_stat(hp)
  if stat and (os.time() - stat.mtime.sec) > INDEX_TTL then return true end
  return false
end

local function get_classpath(project_root, cb)
  local pom = project_root .. "/pom.xml"
  if not uv_readable(pom) then
    vim.schedule(function()
      vim.notify("[jar-index] No pom.xml found at: " .. pom, vim.log.levels.WARN)
    end)
    cb(nil); return
  end

  local tmp = vim.fn.tempname() .. ".txt"

  vim.system(
    { "mvn", "-f", pom, "dependency:build-classpath", "-q",
      "-DincludeScope=runtime", "-Dmdep.outputFile=" .. tmp },
    { text = true },
    function(result)
      if result.code ~= 0 then
        vim.schedule(function()
          vim.notify("[jar-index] mvn dependency:build-classpath failed (exit "
            .. result.code .. "):\n" .. (result.stderr or ""), vim.log.levels.WARN)
        end)
        cb(nil); return
      end

      local raw = uv_read(tmp)
      vim.uv.fs_unlink(tmp, function() end)

      if not raw or raw == "" then
        vim.schedule(function()
          vim.notify("[jar-index] classpath output was empty", vim.log.levels.WARN)
        end)
        cb(nil); return
      end

      local jars = {}
      for jar in raw:gmatch("[^:\n]+") do
        if jar:match("%.jar$") then table.insert(jars, jar) end
      end
      cb(jars, raw)
    end
  )
end

-- ─── Hash (async, uv writes) ──────────────────────────────────────────────────

local function compute_and_store_hash(classpath_raw, hp, cb)
  local tmp = os.tmpname()
  uv_write(tmp, classpath_raw)

  vim.system({ "sha256sum", tmp }, { text = true }, function(result)
    vim.uv.fs_unlink(tmp, function() end)
    if result.code ~= 0 then if cb then cb(nil) end; return end
    local hash = result.stdout:match("^(%S+)")
    if not hash then if cb then cb(nil) end; return end
    uv_write(hp, hash)
    if cb then cb(hash) end
  end)
end

-- ─── Indexer ──────────────────────────────────────────────────────────────────

local function build_index(workspace_dir, group_filter, jars, classpath_raw, on_done)
  local filtered = {}
  for _, jar in ipairs(jars) do
    for _, prefix in ipairs(group_filter) do
      if jar:find(prefix, 1, true) then
        table.insert(filtered, jar); break
      end
    end
  end

  if #filtered == 0 then
    vim.schedule(function()
      vim.notify("[jar-index] No JARs matched group filter: "
        .. vim.inspect(group_filter), vim.log.levels.WARN)
    end)
    if on_done then on_done() end
    return
  end

  vim.schedule(function()
    vim.notify("[jar-index] Indexing " .. #filtered .. " JARs...", vim.log.levels.INFO)
  end)

  local lines   = {}
  local pending = #filtered

  for _, jar in ipairs(filtered) do
    vim.system({ "jar", "tf", jar }, { text = true }, function(result)
      if result.code == 0 and result.stdout then
        for entry in result.stdout:gmatch("[^\n]+") do
          if entry:match("%.class$") and not entry:match("%$") then
            for _, prefix in ipairs(group_filter) do
              local slash_prefix = prefix:gsub("%.", "/")
              if entry:sub(1, #slash_prefix) == slash_prefix then
                local fqcn = entry:gsub("%.class$", ""):gsub("/", ".")
                table.insert(lines, fqcn .. "\t" .. jar)
                break
              end
            end
          end
        end
      end

      pending = pending - 1
      if pending == 0 then
        local idir = index_dir(workspace_dir)
        uv_mkdir_p(idir)
        uv_write(index_path(workspace_dir), table.concat(lines, "\n"))
        compute_and_store_hash(classpath_raw, hash_path(workspace_dir), nil)
        vim.schedule(function()
          vim.notify("[jar-index] Indexed " .. #lines .. " classes across "
            .. #filtered .. " JARs", vim.log.levels.INFO)
        end)
        if on_done then on_done() end
      end
    end)
  end
end

-- ─── Public: trigger indexing (called from jdtls on_attach, main thread) ──────

function M.ensure_index(project_root, workspace_dir, group_filter, force)
  if not project_root or project_root == "" then
    vim.notify("[jar-index] ensure_index called with no root", vim.log.levels.ERROR)
    return
  end

  if not force and not is_stale(workspace_dir) then return end

  get_classpath(project_root, function(jars, raw)
    if not jars then return end

    if not force then
      local stored = uv_read(hash_path(workspace_dir))
      if stored then stored = stored:match("^(%S+)") end

      local tmp = os.tmpname()
      uv_write(tmp, raw)
      vim.system({ "sha256sum", tmp }, { text = true }, function(res)
        vim.uv.fs_unlink(tmp, function() end)
        local current = res.code == 0 and res.stdout:match("^(%S+)") or nil
        if current and current == stored then return end
        build_index(workspace_dir, group_filter, jars, raw, nil)
      end)
    else
      build_index(workspace_dir, group_filter, jars, raw, nil)
    end
  end)
end

-- ─── URI builder — mirrors class.lua exactly ─────────────────────────────────

local function make_jdt_uri(fqcn, jar_path, project)
  local pkg        = fqcn:match("^(.+)%.[^.]+$") or ""
  local class_name = fqcn:match("[^.]+$") .. ".class"
  local jar_name   = jar_path:match("([^/]+)$")
  local encoded_jar = jar_path:gsub("/", "%%5C/")
  local source_ref  = "%%3C" .. pkg .. "(" .. class_name
  return "jdt://contents/" .. jar_name .. "/" .. pkg .. "/" .. class_name
    .. "?=" .. project
    .. "/" .. encoded_jar
    .. "=/"
    .. source_ref
end

-- ─── Decompile via jdtls, call cb(lines_table, err) ──────────────────────────

local function decompile(fqcn, jar_path, project, cb)
  local client = vim.lsp.get_clients({ name = "jdtls" })[1]
  if not client then cb(nil, "jdtls not attached"); return end
  local uri = make_jdt_uri(fqcn, jar_path, project)
  client:request("java/classFileContents", { uri = uri }, function(err, result)
    if err or not result then cb(nil, vim.inspect(err)); return end
    cb(vim.split(result, "\n"), nil)
  end, 0)
end

-- ─── Open class in a new buffer ───────────────────────────────────────────────

local function open_class(fqcn, jar_path, project)
  decompile(fqcn, jar_path, project, function(result_lines, err)
    if not result_lines then
      vim.schedule(function()
        vim.notify("[jar-picker] classFileContents failed: " .. (err or "?"), vim.log.levels.WARN)
      end)
      return
    end
    vim.schedule(function()
      local buf = vim.api.nvim_create_buf(true, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, result_lines)
      vim.api.nvim_buf_set_name(buf, fqcn .. " [decompiled]")
      vim.bo[buf].filetype   = "java"
      vim.bo[buf].modifiable = false
      vim.bo[buf].readonly   = true
      vim.api.nvim_set_current_buf(buf)
    end)
  end)
end

-- ─── Pickers ──────────────────────────────────────────────────────────────────

function M.pick_class()
  local data_dir, client = extract_data_dir(vim.api.nvim_get_current_buf())
  if not data_dir or not client then
    vim.notify(
      "Data directory wasn't detected. " ..
      "You must call `start_or_attach` at least once and the cmd must include a `-data` parameter (or `--data` if using the official `jdtls` wrapper)")
    return
  end

  local ip = index_path(data_dir)
  if not uv_readable(ip) then
    vim.notify("[jar-picker] Index not ready yet — try again in a moment", vim.log.levels.WARN)
    return
  end

  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local sorters      = require("telescope.sorters")

  pickers.new({}, {
    prompt_title = "Dep Classes  (<CR> open · <C-y> yank FQCN)",
    finder = finders.new_job(
      function(prompt)
        if not prompt or prompt == "" then return { "cat", ip } end
        return { "rg", "-i", "--no-line-number", prompt, ip }
      end,
      function(line)
        if not line or line == "" then return nil end
        local fqcn, jar = line:match("^([^\t]+)\t(.+)$")
        if not fqcn then return nil end
        return { value = { fqcn = fqcn, jar = jar }, display = fqcn, ordinal = fqcn }
      end,
      nil, nil
    ),
    sorter = sorters.get_substr_matcher(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local sel = action_state.get_selected_entry()
        if sel then
          open_class(sel.value.fqcn, sel.value.jar)
          -- jdtls.open_classfile()
        end
      end)
      map("i", "<C-y>", function()
        local sel = action_state.get_selected_entry()
        if sel then
          vim.fn.setreg("+", sel.value.fqcn)
          vim.notify("Yanked: " .. sel.value.fqcn, vim.log.levels.INFO)
        end
      end)
      return true
    end,
  }):find()
end

function M.grep_deps()
  local data_dir, client = extract_data_dir(vim.api.nvim_get_current_buf())
  if not data_dir or not client then
    vim.notify(
      "Data directory wasn't detected. " ..
      "You must call `start_or_attach` at least once and the cmd must include a `-data` parameter (or `--data` if using the official `jdtls` wrapper)")
    return
  end

  local ip = index_path(data_dir)
  if not uv_readable(ip) then
    vim.notify("[jar-picker] Index not ready", vim.log.levels.WARN)
    return
  end

  local raw = uv_read(ip)
  if not raw then return end

  local src_dirs = {}
  local seen     = {}
  for line in raw:gmatch("[^\n]+") do
    local _, jar = line:match("^([^\t]+)\t(.+)$")
    if jar and not seen[jar] then
      seen[jar] = true
      local base = jar:match("^(.+)%.jar$")
      if base then
        local src = base .. "_src/src"
        if vim.uv.fs_stat(src) then table.insert(src_dirs, src) end
      end
    end
  end

  require("telescope.builtin").live_grep({
    prompt_title  = "Grep Dep Sources",
    search_dirs   = #src_dirs > 0 and src_dirs or { vim.fn.stdpath("data") .. "/site/java" },
  })
end

return M
