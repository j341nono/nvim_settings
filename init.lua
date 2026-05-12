-- =============================================================================
-- 1. Lazy.nvim のセットアップ (プラグインマネージャー)
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
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

-- =============================================================================
-- 2. プラグイン一覧
-- =============================================================================
require("lazy").setup({
  "folke/tokyonight.nvim",

  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "romgrk/barbar.nvim",
  "folke/noice.nvim",
  "MunifTanjim/nui.nvim",

  "lewis6991/gitsigns.nvim",
  "APZelos/blamer.nvim",

  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  "nvim-treesitter/nvim-treesitter-textobjects",

  "numToStr/Comment.nvim",
  "windwp/nvim-autopairs",
  "kylechui/nvim-surround",
  "toppair/peek.nvim",
  "johmsalas/text-case.nvim",

  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "L3MON4D3/LuaSnip",

  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  "j-hui/fidget.nvim",
  "folke/trouble.nvim",
  "ray-x/lsp_signature.nvim",

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          highlight_git = true,
          icons = {
            show = { git = true, folder = true, file = true, folder_arrow = true },
          },
        },
        filters = { dotfiles = false },
        actions = { open_file = { quit_on_open = false } },
      })
    end,
  },
})

-- =============================================================================
-- 3. 基本設定
-- =============================================================================
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.termguicolors = true
vim.g.mapleader = " "

-- ⚠️ リモート環境なので unnamedplus は使わない
-- vim.o.clipboard = "unnamedplus"

-- =============================================================================
-- 4. プラグイン設定
-- =============================================================================
require("nvim-autopairs").setup({})
require("Comment").setup({})
require("nvim-surround").setup({})
require("gitsigns").setup({})
require("lualine").setup({ options = { theme = "tokyonight" } })
require("barbar").setup({})

require("noice").setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },
})

require("fidget").setup({})
require("telescope").setup({})
require("trouble").setup({ icons = false })

require("lsp_signature").setup({
  bind = true,
  handler_opts = { border = "rounded" },
  floating_window = true,
  hint_prefix = "💡 ",
})

-- =============================================================================
-- 5. Treesitter
-- =============================================================================
require("nvim-treesitter.configs").setup({
  ensure_installed = { "python", "lua", "javascript", "typescript", "json", "yaml", "markdown" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- =============================================================================
-- 6. LSP
-- =============================================================================
require("mason").setup({})
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "lua_ls", "ts_ls" },
  handlers = {
    function(server)
      lspconfig[server].setup({ capabilities = capabilities })
    end,
  },
})

-- =============================================================================
-- 7. 補完
-- =============================================================================
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- =============================================================================
-- 8. テーマ
-- =============================================================================
vim.o.termguicolors = true

require("tokyonight").setup({
  transparent = true,
})

vim.cmd("colorscheme tokyonight-night")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

local bg_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "EndOfBuffer",

  "NvimTreeNormal",
  "NvimTreeNormalNC",
  "NvimTreeEndOfBuffer",
  "NvimTreeVertSplit",

  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopeResultsNormal",
  "TelescopePreviewNormal",

  "NeoTreeNormal",
  "NeoTreeNormalNC",
}

for _, group in ipairs(bg_groups) do
  vim.api.nvim_set_hl(0, group, { bg = "none" })
end


-- =============================================================================
-- 9. キーマップ
-- =============================================================================
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- =============================================================================
-- 10. OSC52 クリップボード（★一番最後に設定★）
-- =============================================================================
pcall(function()
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "OSC52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
      },
    }
  end
end)

