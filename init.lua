local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ==============================
-- プラグイン一覧
-- ==============================
require("lazy").setup({
  -- UI
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "romgrk/barbar.nvim",
  "folke/noice.nvim",
  "MunifTanjim/nui.nvim",

  -- Git
  "lewis6991/gitsigns.nvim",
  "APZelos/blamer.nvim",

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- コメント
  "numToStr/Comment.nvim",

  -- 補完
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "L3MON4D3/LuaSnip",

  -- LSP
  "neovim/nvim-lspconfig",

  -- その他便利
  "windwp/nvim-autopairs",
  "kylechui/nvim-surround",
  "toppair/peek.nvim",  -- ← 修正版
  "johmsalas/text-case.nvim",

  -- 📂 ファイルツリー
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
          },
        },
        filters = { dotfiles = false },
        actions = {
          open_file = { quit_on_open = false }, -- ファイルを開いてもツリーを閉じない
        },
      })

      -- 起動時に自動でツリーを表示
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("nvim-tree.api").tree.open()
        end,
      })
    end,
  },
})

-- ==============================
-- 基本設定
-- ==============================
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.termguicolors = true

-- Leaderキー設定
vim.g.mapleader = " "

-- ==============================
-- プラグイン設定
-- ==============================
require("nvim-autopairs").setup({})
require("Comment").setup({})
require("nvim-surround").setup({})
require("gitsigns").setup({})
require("lualine").setup({})
require("barbar").setup({})
require("noice").setup({})

-- ==============================
-- LSP設定 (Neovim 0.11+ 新API)
-- ==============================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config["lua_ls"] = { capabilities = capabilities }
vim.lsp.config["pyright"] = { capabilities = capabilities }
vim.lsp.config["ts_ls"] = { capabilities = capabilities } -- tsserver → ts_ls

-- 有効化
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")

-- ==============================
-- 補完設定
-- ==============================
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ==============================
-- Telescope 設定
-- ==============================
require("telescope").setup({})

-- ==============================
-- キーマッピング
-- ==============================
-- 手動でトグルする場合は <Space>e
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

