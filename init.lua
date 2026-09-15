vim.g.mapleader = " "
vim.g.maplocalleader = " "


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


require("lazy").setup({
  "folke/tokyonight.nvim",

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

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },

    opts = {
      word_diff = true,

      attach_to_untracked = true,

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

        map("n", "<leader>hp", gitsigns.preview_hunk, "変更をポップアップ表示")
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, "変更をインライン表示")

        map("n", "<leader>hs", gitsigns.stage_hunk, "変更をステージ")
        map("n", "<leader>hu", gitsigns.undo_stage_hunk, "直前のステージを戻す")
        map("n", "<leader>hr", gitsigns.reset_hunk, "変更を破棄")

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

        map("n", "<leader>hS", gitsigns.stage_buffer, "ファイル全体をステージ")
        map("n", "<leader>hR", gitsigns.reset_buffer, "ファイル全体の変更を破棄")

        map("n", "<leader>hb", function()
          gitsigns.blame_line({
            full = true,
          })
        end, "現在行のGit Blame")

        map("n", "<leader>hd", gitsigns.diffthis, "現在ファイルの差分")
        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, "現在ファイルと親コミットの差分")

        map("n", "<leader>hq", gitsigns.setqflist, "現在ファイルの変更一覧")

        map("n", "<leader>hQ", function()
          gitsigns.setqflist("all")
        end, "リポジトリ全体の変更一覧")

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
        layout = "side-by-side",

        jump_to_first_change = true,

        compact = false,

        cycle_next_hunk = true,

        cycle_next_file = true,

        disable_inlay_hints = true,
      },

      explorer = {
        position = "left",
        width = 40,

        auto_refresh = true,

        visible_groups = {
          staged = true,
          unstaged = true,
          conflicts = true,
        },
      },
    },
  },

  {
    "folke/sidekick.nvim",

    enabled = vim.fn.has("nvim-0.11.2") == 1,

    opts = {
      nes = {
        enabled = false,
      },

      cli = {
        picker = "telescope",

        mux = {
          enabled = false,
        },

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

      {
        "<C-.>",
        function()
          require("sidekick.cli").focus()
        end,
        mode = { "n", "t", "i", "x" },
        desc = "Coding Agentへフォーカス",
      },

      {
        "<leader>af",
        function()
          require("sidekick.cli").send({
            msg = "{file}",
          })
        end,
        desc = "現在ファイルをCodexへ送る",
      },

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

      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Codex用プロンプトを選択",
      },

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

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

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


vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.o.termguicolors = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 200

vim.o.autoread = true

vim.o.splitright = true
vim.o.splitbelow = true


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
    if vim.bo.modified then
      return
    end

    vim.cmd("checktime")
  end,
})


require("nvim-autopairs").setup({})
require("Comment").setup({})
require("nvim-surround").setup({})

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


vim.keymap.set(
  "n",
  "<leader>e",
  "<cmd>NvimTreeToggle<CR>",
  {
    silent = true,
    desc = "ファイルツリーを開く／閉じる",
  }
)


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



