local jar_path = vim.api.nvim_buf_get_name(0)

-- Guard: if this buffer is inside an already-extracted _src dir, do nothing
if jar_path:match("_src/") then
  return
end

local jar_dir = vim.fn.fnamemodify(jar_path, ":h")
local jar_name = vim.fn.fnamemodify(jar_path, ":t:r")
local dest = jar_dir .. "/" .. jar_name .. "_src"
local extract_dir = dest .. "/src"

-- Cache check: if already extracted, just open it
if vim.fn.isdirectory(extract_dir) == 1 and #vim.fn.glob(extract_dir .. "/**/*.java", false, true) > 0 then
  vim.notify("Opening cached decompilation of " .. jar_name, vim.log.levels.INFO)
  require("oil").open(extract_dir)
  return
end

vim.fn.mkdir(dest, "p")
vim.fn.mkdir(extract_dir, "p")

local fernflower = vim.fn.glob("$MASON/packages/jdtls/**/*java-decompiler-engine*.jar")

local java21 = vim.fn.expand("$HOME/.sdkman/candidates/java/21.0.2-open/bin/java")

local cmd = {
  java21,
  "-jar",
  fernflower,
  jar_path,
  dest,
}

vim.notify("Decompiling " .. jar_name .. "...", vim.log.levels.INFO)
vim.system(cmd, { text = true }, function(result)
  vim.schedule(function()
    if result.code ~= 0 then
      vim.notify("Decompile failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
      return
    end

    -- Fernflower outputs a jar with the same name into dest/
    local out_jar = dest .. "/" .. jar_name .. ".jar"

    if vim.fn.filereadable(out_jar) == 0 then
      vim.notify("Decompiled JAR not found at: " .. out_jar, vim.log.levels.ERROR)
      return
    end

    -- Extract the decompiled (source) jar into extract_dir
    vim.system({ "jar", "xf", out_jar }, { cwd = extract_dir, text = true }, function(ex)
      vim.schedule(function()
        -- Remove the intermediate jar so Oil doesn't re-trigger on it
        vim.fn.delete(out_jar)

        if ex.code ~= 0 then
          vim.notify("Extraction failed, falling back to zipfile view", vim.log.levels.WARN)
          vim.cmd("edit zipfile:" .. out_jar)
        else
          vim.notify("Decompiled " .. jar_name .. " — opening in Oil", vim.log.levels.INFO)
          require("oil").open(extract_dir)
        end
      end)
    end)
  end)
end)
