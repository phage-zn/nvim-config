return {
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'nvim-mini/mini.ai',
    version = '*',
    config = function()
      local miniConfig = require("config.mini-config");
      require("mini.ai").setup(miniConfig.ai)
    end
  },
  {
    'nvim-mini/mini.surround',
    version = '*',
    config = function()
      require("mini.surround").setup()
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {}
  },
}
