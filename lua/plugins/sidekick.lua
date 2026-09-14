local copilot_on = false

local function copilot_toggle()
  copilot_on = not copilot_on
  if copilot_on then
      require("lazy").load({ plugins = { "copilot.lua", "copilot-cmp" } })
    vim.cmd("Copilot enable")
    vim.lsp.enable("copilot")
    vim.notify("Copilot: ON", vim.log.levels.INFO)
  else
    vim.cmd("Copilot disable")
    vim.lsp.enable("copilot", false)
    vim.notify("Copilot: OFF", vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command("CopilotToggle", copilot_toggle, {})
vim.keymap.set("n", "<leader>aa", copilot_toggle, { desc = "Toggle Copilot" })

return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = true },
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
        tools = {
          copilot = {},
        }
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function() require("sidekick.cli").focus() end,
        desc = "Sidekick Focus",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select({ filter = { installed = true }}) end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<leader>ac",
        function() require("sidekick.cli").toggle({ name = "copilot", focus = true }) end,
        desc = "Sidekick Toggle Copilot",
      },
    },
  }
}
