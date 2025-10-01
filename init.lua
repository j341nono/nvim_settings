-- ===================================================================
-- Neovim設定ファイル - Python開発最適化版
-- ===================================================================

-- 基本設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 起動メッセージを抑制（警告を見たくない場合）
vim.opt.shortmess:append("I")

-- オプション設定
local opt = vim.opt

opt.number = true           -- 行番号表示
opt.relativenumber = true   -- 相対行番号
opt.mouse = "a"            -- マウス有効化
opt.clipboard = "unnamedplus" -- システムクリップボード連携
opt.expandtab = true       -- タブをスペースに
opt.shiftwidth = 4         -- インデント幅
opt.tabstop = 4           -- タブ幅
opt.smartindent = true     -- スマートインデント
opt.wrap = false          -- 折り返し無効
opt.ignorecase = true     -- 検索時大文字小文字無視
opt.smartcase = true      -- 大文字を含む場合は区別
opt.termguicolors = true  -- True color対応
opt.signcolumn = "yes"    -- サイン列常に表示
opt.updatetime = 300      -- 更新時間短縮
opt.scrolloff = 8         -- スクロール時の余白
opt.sidescrolloff = 8
opt.cursorline = true     -- カーソル行ハイライト

-- ===================================================================
-- Lazy.nvim セットアップ
-- ===================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===================================================================
-- プラグイン設定
-- ===================================================================
require("lazy").setup({
  -- カラースキーム
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- UI
  "nvim-tree/nvim-web-devicons",
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = "|",
          section_separators = "",
        },
      })
    end,
  },
  "romgrk/barbar.nvim",
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup()
    end,
  },
  "MunifTanjim/nui.nvim",
  "rcarriga/nvim-notify",

  -- ファイルエクスプローラー
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      -- netrwを無効化（NvimTreeと競合するため）
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
      })
      
      -- 起動時に自動でNvimTreeを開く
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("nvim-tree.api").tree.open()
        end,
      })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  "APZelos/blamer.nvim",

  -- Telescope（ファジーファインダー）
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "__pycache__", "*.pyc" },
        },
      })
    end,
  },

  -- Treesitter（シンタックスハイライト）
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "lua", "vim", "bash", "json", "yaml" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- コメント
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- ===================================================================
  -- LSP関連
  -- ===================================================================
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "lua_ls" },
      })
    end,
  },

  -- ===================================================================
  -- 補完関連
  -- ===================================================================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- ===================================================================
  -- Python専用プラグイン
  -- ===================================================================
  -- フォーマッター＆リンター統合
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- コメントアウト: システムにruff/black/isortがインストールされていれば有効化
          -- null_ls.builtins.formatting.black,
          -- null_ls.builtins.formatting.isort,
          -- null_ls.builtins.diagnostics.ruff,
        },
      })
    end,
  },

  -- 仮想環境セレクター
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    opts = {},
  },

  -- インデントガイド
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- 自動ペア
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- デバッグアダプター（オプション）
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      dapui.setup()
      require("dap-python").setup("python")
      
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  "rcarriga/nvim-dap-ui",
  "nvim-neotest/nvim-nio",
})

-- ===================================================================
-- LSP設定
-- ===================================================================
-- lspconfigの非推奨警告を抑制
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("lspconfig.*deprecated") then
    return
  end
  notify(msg, ...)
end

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Pyright（Pylanceの代替）
lspconfig.pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic", -- "off", "basic", "strict"
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        autoImportCompletions = true,
      },
    },
  },
})

-- Ruff（高速リンター・フォーマッター統合）
-- システムにruffがインストールされている場合のみ有効
local ruff_installed = vim.fn.executable("ruff") == 1
if ruff_installed then
  lspconfig.ruff.setup({
    capabilities = capabilities,
    init_options = {
      settings = {
        args = {},
      }
    }
  })
end

-- Lua LSP（Neovim設定用）
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- ===================================================================
-- キーマッピング
-- ===================================================================
local keymap = vim.keymap.set

-- 一般
keymap("n", "<leader>w", ":w<CR>", { desc = "保存" })
keymap("n", "<leader>q", ":q<CR>", { desc = "終了" })
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "検索ハイライト解除" })

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "ファイルツリー切替" })

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "ファイル検索" })
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "文字列検索" })
keymap("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "バッファ一覧" })
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "ヘルプ検索" })

-- LSP
keymap("n", "gd", vim.lsp.buf.definition, { desc = "定義へジャンプ" })
keymap("n", "gD", vim.lsp.buf.declaration, { desc = "宣言へジャンプ" })
keymap("n", "gi", vim.lsp.buf.implementation, { desc = "実装へジャンプ" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "参照を表示" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "ホバー情報" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "リネーム" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "コードアクション" })
keymap("n", "<leader>f", vim.lsp.buf.format, { desc = "フォーマット" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "前の診断" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "次の診断" })
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "診断を表示" })

-- Python仮想環境選択
keymap("n", "<leader>vs", ":VenvSelect<CR>", { desc = "仮想環境選択" })

-- デバッグ
keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "ブレークポイント切替" })
keymap("n", "<leader>dc", ":DapContinue<CR>", { desc = "デバッグ続行" })
keymap("n", "<leader>di", ":DapStepInto<CR>", { desc = "ステップイン" })
keymap("n", "<leader>do", ":DapStepOver<CR>", { desc = "ステップオーバー" })

-- バッファ移動
keymap("n", "<Tab>", ":BufferNext<CR>", { desc = "次のバッファ" })
keymap("n", "<S-Tab>", ":BufferPrevious<CR>", { desc = "前のバッファ" })
keymap("n", "<leader>x", ":BufferClose<CR>", { desc = "バッファを閉じる" })

-- 分割ウィンドウ
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "垂直分割" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "水平分割" })
keymap("n", "<C-h>", "<C-w>h", { desc = "左のウィンドウ" })
keymap("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウ" })
keymap("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウ" })
keymap("n", "<C-l>", "<C-w>l", { desc = "右のウィンドウ" })

-- ===================================================================
-- 自動コマンド
-- ===================================================================
-- Python用追加設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = "88" -- Black default
    vim.opt_local.textwidth = 88
  end,
})

-- 保存時自動フォーマット（オプション）
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ===================================================================
-- 診断表示設定
-- ===================================================================
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- 診断記号
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
