local ts_config = require("config.treesitter-config")
local logger = require("utilities.logger")
return {
  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      local treesitter_config = require("nvim-treesitter.config")
      treesitter.install(ts_config.treesitter.languages)
      local function get_ignored()
        local ignore_path = treesitter_config.get_install_dir("parser-ignore")
        local ignored = {}

        for f in vim.fs.dir(ignore_path) do
          ignored[string.gsub(f, "%.ignore$", "")] = true
        end

        return vim.tbl_keys(ignored)
      end

      local function complete_ignored(arglead)
        return vim.tbl_filter(
        --- @param v string
          function(v)
            return v:find(arglead) ~= nil
          end,
          get_ignored()
        )
      end

      vim.api.nvim_create_user_command("TSUserClearIgnore", function(args)
        if not vim.uv.fs_stat(ts_config.ignore_path) then
          logger.info(ts_config.ignore_path .. " does not exist")
          return
        end
        local to_delete = {}

        for _, lang in ipairs(args.fargs) do
          if vim.tbl_contains(get_ignored(), lang) then
            to_delete[#to_delete + 1] = vim.fs.joinpath(ts_config.ignore_path, lang .. ".ignore")
          end
        end

        local function delete(path, flags)
          local ok, err = pcall(vim.fn.delete, path, flags)
          if not ok then
            logger.error("Unable to delete " .. path .. "\n\t\t" .. err)
          end
        end

        if #to_delete == 0 then
          delete(ts_config.ignore_path, "rf")
        end

        for i = 1, #to_delete do
          delete(to_delete[i], "")
        end
      end, {
        desc = "Remove language(s) from the ignore_path to allow for install prompts",
        force = true,
        nargs = "*",
        complete = complete_ignored,
      })

      local function ignore_lang(lang)
        local ignore_path = vim.fs.joinpath(treesitter_config.get_install_dir("parser-ignore"), lang .. ".ignore")
        local ok, err = pcall(vim.fn.writefile, {}, ignore_path)
        if not ok then
          logger.error("Could not write '" .. lang .. ".ignore' to ignore_path: " .. err)
        else
          logger.info("Wrote '" .. lang .. ".ignore' to ignore_path")
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local installed = treesitter.get_installed()
          local available = treesitter.get_available()
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)

          if not vim.list_contains(installed, lang) then
            if vim.tbl_contains(get_ignored(), lang) then
              return
            end

            if not vim.list_contains(available, lang) then
              return
            end

            local response = vim.fn.input("Parser available for '" .. lang .. "', install? (Y/n/[i]gnore)")
            if response == "" or response:lower() == "y" then
              pcall(treesitter.install, lang)
            else
              if response:lower() == "i" then
                ignore_lang(lang)
              end
            end
          end

          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup(ts_config.textobjects)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
