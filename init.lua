-- =============================================================================
-- 0. Leaderキー
-- =============================================================================
-- lazy.nvimがキーマップを登録する前に設定する
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- =============================================================================
-- 1. Lazy.nvim のセットアップ（プラグインマネージャー）
-- =============================================================================
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


-- =============================================================================
-- 2. プラグイン一覧
-- =============================================================================
require("lazy").setup({
  -- ---------------------------------------------------------------------------
  -- テーマ
  -- ---------------------------------------------------------------------------
  "folke/tokyonight.nvim",

  -- ---------------------------------------------------------------------------
  -- UI
  -- ---------------------------------------------------------------------------
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = {
        enabled = true,
      },
    },
  },

  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "romgrk/barbar.nvim",
  "folke/noice.nvim",
  "MunifTanjim/nui.nvim",

  -- ---------------------------------------------------------------------------
  -- Git：ファイル内の変更確認
  -- ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },

    opts = {
      -- 行内の変更箇所も単語単位で強調する
      word_diff = true,

      -- 未追跡ファイルにもGitSignsを表示する
      attach_to_untracked = true,

      -- ファイル名変更後も追跡する
      watch_gitdir = {
        follow_files = true,
      },

      current_line_blame = false,

      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            silent = true,
            desc = desc,
          })
        end

        -- ---------------------------------------------------------------------
        -- 変更箇所の移動
        -- ---------------------------------------------------------------------
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({
              "]c",
              bang = true,
            })
          else
            gitsigns.nav_hunk("next")
          end
        end, "次のGit変更へ移動")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({
              "[c",
              bang = true,
            })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "前のGit変更へ移動")

        -- ---------------------------------------------------------------------
        -- Hunk単位の操作
        -- ---------------------------------------------------------------------
        map("n", "<leader>hp", gitsigns.preview_hunk, "変更をポップアップ表示")
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, "変更をインライン表示")

        map("n", "<leader>hs", gitsigns.stage_hunk, "変更をステージ")
        map("n", "<leader>hu", gitsigns.undo_stage_hunk, "直前のステージを戻す")
        map("n", "<leader>hr", gitsigns.reset_hunk, "変更を破棄")

        -- Visualモードで選択した行だけ操作する
        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({
            vim.fn.line("."),
            vim.fn.line("v"),
          })
        end, "選択範囲をステージ")

        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({
            vim.fn.line("."),
            vim.fn.line("v"),
          })
        end, "選択範囲の変更を破棄")

        -- ---------------------------------------------------------------------
        -- ファイル全体の操作
        -- ---------------------------------------------------------------------
        map("n", "<leader>hS", gitsigns.stage_buffer, "ファイル全体をステージ")
        map("n", "<leader>hR", gitsigns.reset_buffer, "ファイル全体の変更を破棄")

        -- ---------------------------------------------------------------------
        -- Diff・Blame
        -- ---------------------------------------------------------------------
        map("n", "<leader>hb", function()
          gitsigns.blame_line({
            full = true,
          })
        end, "現在行のGit Blame")

        map("n", "<leader>hd", gitsigns.diffthis, "現在ファイルの差分")
        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, "現在ファイルと親コミットの差分")

        -- ---------------------------------------------------------------------
        -- 変更一覧
        -- ---------------------------------------------------------------------
        map("n", "<leader>hq", gitsigns.setqflist, "現在ファイルの変更一覧")

        map("n", "<leader>hQ", function()
          gitsigns.setqflist("all")
        end, "リポジトリ全体の変更一覧")

        -- ---------------------------------------------------------------------
        -- 表示切り替え
        -- ---------------------------------------------------------------------
        map(
          "n",
          "<leader>tb",
          gitsigns.toggle_current_line_blame,
          "Git Blame表示を切り替え"
        )

        map(
          "n",
          "<leader>tw",
          gitsigns.toggle_word_diff,
          "単語単位の差分表示を切り替え"
        )

        -- ---------------------------------------------------------------------
        -- Hunkをテキストオブジェクトとして扱う
        -- vih：現在の変更箇所を選択
        -- dih：現在の変更箇所を削除
        -- ---------------------------------------------------------------------
        map(
          { "o", "x" },
          "ih",
          gitsigns.select_hunk,
          "Git変更箇所を選択"
        )
      end,
    },
  },

  "APZelos/blamer.nvim",

  -- ---------------------------------------------------------------------------
  -- Git：リポジトリ全体の差分レビュー
  -- ---------------------------------------------------------------------------
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",

    keys = {
      {
        "<leader>gd",
        "<cmd>CodeDiff<CR>",
        desc = "未コミット変更をレビュー",
      },
      {
        "<leader>gD",
        "<cmd>CodeDiff --staged<CR>",
        desc = "ステージ済み変更をレビュー",
      },
      {
        "<leader>gh",
        "<cmd>CodeDiff history<CR>",
        desc = "Git履歴をレビュー",
      },
    },

    opts = {
      diff = {
        -- 左右比較で表示
        layout = "side-by-side",

        -- 開いたとき最初の変更へ移動
        jump_to_first_change = true,

        -- 変更がない部分を最初から折り畳まない
        compact = false,

        -- 最後の変更から最初の変更へ循環する
        cycle_next_hunk = true,

        -- 最後のファイルから最初のファイルへ循環する
        cycle_next_file = true,

        -- Diff画面ではinlay hintsを無効化する
        disable_inlay_hints = true,
      },

      explorer = {
        position = "left",
        width = 40,

        -- Git indexが変わったとき自動更新する
        auto_refresh = true,

        -- ステージ済み・未ステージを両方表示
        visible_groups = {
          staged = true,
          unstaged = true,
          conflicts = true,
        },
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- Coding Agent：Codex CLI連携
  -- ---------------------------------------------------------------------------
  {
    "folke/sidekick.nvim",

    -- sidekick.nvimはNeovim 0.11.2以上が必要
    enabled = vim.fn.has("nvim-0.11.2") == 1,

    opts = {
      -- GitHub CopilotのNext Edit Suggestionsは使用しない
      -- Codex CLI連携だけを利用する
      nes = {
        enabled = false,
      },

      cli = {
        -- 既に導入されているTelescopeを選択画面に使用する
        picker = "telescope",

        -- tmux/zellijを使わずNeovim内のターミナルとして開く
        mux = {
          enabled = false,
        },

        -- Codexへ送る追加プロンプト
        prompts = {
          review_changes = table.concat({
            "現在のGit変更をレビューしてください。",
            "バグ、仕様違反、回帰、テスト不足を優先して確認してください。",
            "問題がある場合は、ファイル名と該当箇所を示してください。",
          }, "\n"),

          review_file = table.concat({
            "このファイルをレビューしてください。",
            "バグ、保守性、型安全性、エラーハンドリングを確認してください。",
            "{file}",
          }, "\n"),

          fix_diagnostics = table.concat({
            "このファイルのdiagnosticsを修正してください。",
            "無関係なリファクタリングは行わないでください。",
            "{file}",
            "{diagnostics}",
          }, "\n"),
        },
      },
    },

    keys = {
      -- Codexを直接開く
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({
            name = "codex",
            focus = true,
          })
        end,
        mode = { "n", "t" },
        desc = "Codexを開く／閉じる",
      },

      -- 利用するCoding Agentを選択する
      {
        "<leader>as",
        function()
          require("sidekick.cli").select({
            filter = {
              installed = true,
            },
          })
        end,
        desc = "Coding Agentを選択",
      },

      -- Sidekickのウィンドウへフォーカスする
      {
        "<C-.>",
        function()
          require("sidekick.cli").focus()
        end,
        mode = { "n", "t", "i", "x" },
        desc = "Coding Agentへフォーカス",
      },

      -- 現在ファイルをCodexへ送る
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({
            msg = "{file}",
          })
        end,
        desc = "現在ファイルをCodexへ送る",
      },

      -- 選択範囲をCodexへ送る
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({
            msg = "{selection}",
          })
        end,
        mode = "x",
        desc = "選択範囲をCodexへ送る",
      },

      -- カーソル位置または選択範囲を送る
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({
            msg = "{this}",
          })
        end,
        mode = { "n", "x" },
        desc = "現在位置をCodexへ送る",
      },

      -- プロンプト一覧を表示する
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Codex用プロンプトを選択",
      },

      -- 現在ファイルのdiagnosticsを送る
      {
        "<leader>ad",
        function()
          require("sidekick.cli").send({
            msg = table.concat({
              "以下のdiagnosticsを確認し、必要な修正を行ってください。",
              "無関係な変更は行わないでください。",
              "{file}",
              "{diagnostics}",
            }, "\n"),
          })
        end,
        desc = "DiagnosticsをCodexへ送る",
      },

      -- Git変更をレビューさせる
      {
        "<leader>ar",
        function()
          require("sidekick.cli").send({
            msg = table.concat({
              "現在のGit変更をレビューしてください。",
              "バグ、仕様違反、回帰、テスト不足を優先してください。",
              "修正はまだ行わず、まず問題点を報告してください。",
            }, "\n"),
          })
        end,
        desc = "CodexにGit変更をレビューさせる",
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- 検索
  -- ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- ---------------------------------------------------------------------------
  -- Treesitter
  -- ---------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  "nvim-treesitter/nvim-treesitter-textobjects",

  -- ---------------------------------------------------------------------------
  -- 編集支援
  -- ---------------------------------------------------------------------------
  "numToStr/Comment.nvim",
  "windwp/nvim-autopairs",
  "kylechui/nvim-surround",
  "toppair/peek.nvim",
  "johmsalas/text-case.nvim",

  -- ---------------------------------------------------------------------------
  -- 補完
  -- ---------------------------------------------------------------------------
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "L3MON4D3/LuaSnip",

  -- ---------------------------------------------------------------------------
  -- LSP
  -- ---------------------------------------------------------------------------
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  "j-hui/fidget.nvim",
  "folke/trouble.nvim",
  "ray-x/lsp_signature.nvim",

  -- ---------------------------------------------------------------------------
  -- ファイルツリー
  -- ---------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },

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

        git = {
          ignore = false,
        },

        filters = {
          dotfiles = false,
        },

        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
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
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.o.termguicolors = true

-- GitSignsなどの記号を常に表示できる領域を確保する
vim.o.signcolumn = "yes"

-- CursorHoldやGitSignsの更新を少し速くする
vim.o.updatetime = 200

-- Coding Agentが外部から編集したファイルを再読み込み可能にする
vim.o.autoread = true

-- 分割方向
vim.o.splitright = true
vim.o.splitbelow = true


-- =============================================================================
-- 4. Coding Agentによる外部変更の再読み込み
-- =============================================================================
local agent_reload_group =
  vim.api.nvim_create_augroup("AgentExternalFileReload", {
    clear = true,
  })

vim.api.nvim_create_autocmd({
  "FocusGained",
  "BufEnter",
  "CursorHold",
  "CursorHoldI",
}, {
  group = agent_reload_group,

  callback = function()
    -- 未保存の変更があるバッファは上書きしない
    if vim.bo.modified then
      return
    end

    vim.cmd("checktime")
  end,
})


-- =============================================================================
-- 5. プラグイン設定
-- =============================================================================
require("nvim-autopairs").setup({})
require("Comment").setup({})
require("nvim-surround").setup({})

-- gitsignsはlazy.nvimのプラグイン定義内で設定済み

require("lualine").setup({
  options = {
    theme = "tokyonight",
  },
})

require("barbar").setup({})

require("noice").setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },
})

require("fidget").setup({})
require("telescope").setup({})
require("trouble").setup({
  icons = false,
})

require("lsp_signature").setup({
  bind = true,

  handler_opts = {
    border = "rounded",
  },

  floating_window = true,
  hint_prefix = "💡 ",
})


-- =============================================================================
-- 6. Treesitter
-- =============================================================================
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "python",
    "lua",
    "javascript",
    "typescript",
    "json",
    "yaml",
    "markdown",
  },

  highlight = {
    enable = true,
  },

  indent = {
    enable = true,
  },
})


-- =============================================================================
-- 7. LSP
-- =============================================================================
require("mason").setup({})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "lua_ls",
    "ts_ls",
  },

  handlers = {
    function(server)
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end,
  },
})


-- =============================================================================
-- 8. 補完
-- =============================================================================
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({
      select = true,
    }),
  }),

  sources = {
    {
      name = "nvim_lsp",
    },
    {
      name = "buffer",
    },
    {
      name = "path",
    },
  },
})


-- =============================================================================
-- 9. テーマ
-- =============================================================================
require("tokyonight").setup({
  transparent = true,
})

vim.cmd("colorscheme tokyonight-night")

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
  vim.api.nvim_set_hl(0, group, {
    bg = "none",
  })
end


-- =============================================================================
-- 10. 通常キーマップ
-- =============================================================================
vim.keymap.set(
  "n",
  "<leader>e",
  "<cmd>NvimTreeToggle<CR>",
  {
    silent = true,
    desc = "ファイルツリーを開く／閉じる",
  }
)


-- =============================================================================
-- 11. OSC52 クリップボード（最後に設定）
-- =============================================================================
vim.o.clipboard = "unnamedplus"

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
        ["+"] = function()
          return {
            vim.fn.getreg('"'),
          }
        end,

        ["*"] = function()
          return {
            vim.fn.getreg('"'),
          }
        end,
      },
    }
  end
end)




