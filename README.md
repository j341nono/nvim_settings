# My Neovim Configuration

これは私の個人的なNeovim設定です。Python開発を中心に、モダンで快適な編集体験を目指しています。



---

## ✨ 特徴 (Features)

### 🐍 Python開発機能 (Pylance相当)
- ✅ 自動補完（関数、変数、モジュール）
- ✅ 型チェック・型ヒント表示
- ✅ 定義へジャンプ (`gd`)
- ✅ 参照検索 (`gr`)
- ✅ ホバー情報（型・ドキュメント表示）(`K`)
- ✅ リネーム (`<Space>rn`)
- ✅ コードアクション (`<Space>ca`)
- ✅ エラー・警告の診断表示
- ✅ インポート自動補完

### 📁 ファイル操作
- ✅ ファイルツリー（起動時自動表示、`<Space>e`で切替）
- ✅ ファジーファイル検索 (`<Space>ff`)
- ✅ 文字列検索（grep） (`<Space>fg`)
- ✅ バッファ一覧 (`<Space>fb`)

### ✍️ 編集機能
- ✅ `nvim-treesitter`による高速なシンタックスハイライト
- ✅ コメント切り替え (`gcc`で行、`gc`でビジュアル選択）
- ✅ 括弧や引用符の自動ペアリング
- ✅ インデントガイド線
- ✅ 88文字目にカラムガイド（Python）

### 🌿 Git機能
- ✅ 行ごとのGit差分表示（左側のサイン列）
- ✅ Git blame情報の表示

### 🚀 ナビゲーション
- ✅ バッファ（タブ）間の移動 (`Tab` / `Shift+Tab`)
- ✅ 分割ウィンドウ (`<Space>sv` 垂直, `<Space>sh` 水平)
- ✅ ウィンドウ間の移動 (`Ctrl+h/j/k/l`)

---

## 🧩 インストール済みプラグイン (Installed Plugins)

### コア機能
- **[lazy.nvim](https://github.com/folke/lazy.nvim)** - プラグインマネージャー
- **[catppuccin](https://github.com/catppuccin/nvim)** - カラースキーム（Mocha）

### UI・インターフェース
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)** - ステータスライン
- **[barbar.nvim](https://github.com/romgrk/barbar.nvim)** - タブバー
- **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)** - ファイルツリー
- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)** - アイコン表示
- **[noice.nvim](https://github.com/folke/noice.nvim)** - コマンドライン・メッセージUI改善
- **[nvim-notify](https://github.com/rcarriga/nvim-notify)** - 通知システム
- **[nui.nvim](https://github.com/MunifTanjim/nui.nvim)** - UI部品ライブラリ
- **[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)** - インデントガイド線

### LSP（言語サーバー）
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** - LSP設定の基盤
- **[mason.nvim](https://github.com/williamboman/mason.nvim)** - LSPサーバー管理ツール
- **[mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)** - MasonとLSPの連携
- **Pyright** - Python用LSP

### 補完システム
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** - 補完エンジン
- **cmp-nvim-lsp** - LSP補完ソース
- **cmp-buffer** - バッファ内テキスト補完
- **cmp-path** - ファイルパス補完
- **cmp-cmdline** - コマンドライン補完
- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)** - スニペットエンジン
- **cmp_luasnip** - LuaSnipとcmpの連携

### 検索・ナビゲーション
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** - ファジーファインダー
- **[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)** - Lua関数ライブラリ（Telescope依存）

### コード編集支援
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** - シンタックスハイライト・構文解析
- **[Comment.nvim](https://github.com/numToStr/Comment.nvim)** - コメント切り替え
- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)** - 括弧自動閉じ

### Git統合
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** - Git差分表示
- **[blamer.nvim](https://github.com/APZelos/blamer.nvim)** - Git blame表示

### Python開発専用
- **[venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim)** - 仮想環境切り替え

### デバッグ（オプション）
- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)** - デバッグアダプタープロトコル
- **[nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)** - Python用デバッグ
- **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)** - デバッグUI
- **[nvim-nio](https://github.com/nvim-neotest/nvim-nio)** - 非同期IO（DAP依存）

---

## ⌨️ 主要キーバインド一覧 (`<Space>` はリーダーキー)

### 一般操作
| キー | 説明 |
|:---|:---|
| `<Space>w` | 保存 |
| `<Space>q` | 終了 |
| `<Space>e` | ファイルツリー切替 |
| `<Space>sv` | 垂直分割 |
| `<Space>sh` | 水平分割 |
| `Ctrl`+`h/j/k/l` | ウィンドウ間移動 |

### 検索
| キー | 説明 |
|:---|:---|
| `<Space>ff` | ファイル検索 (Telescope) |
| `<Space>fg` | 文字列検索 (grep) |
| `<Space>fb` | バッファ一覧 |

### LSP機能
| キー | 説明 |
|:---|:---|
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gi` | 実装へジャンプ |
| `gr` | 参照を表示 |
| `K` | ホバー情報（型・ドキュメント） |
| `<Space>rn` | リネーム |
| `<Space>ca` | コードアクション |
| `<Space>f` | フォーマット |
| `[d` | 前の診断へ移動 |
| `]d` | 次の診断へ移動 |
| `<Space>d` | 診断を一覧表示 |

### 編集
| キー | 説明 |
|:---|:---|
| `gcc` | 行コメント切替 |
| `gc` (ビジュアル) | 選択範囲コメント切替 |

### バッファ
| キー | 説明 |
|:---|:---|
| `Tab` | 次のバッファへ |
| `Shift`+`Tab` | 前のバッファへ |
| `<Space>x` | バッファを閉じる |

### 補完（挿入モード）
| キー | 説明 |
|:---|:---|
| `Ctrl`+`Space` | 補完メニューを表示 |
| `Tab` / `Shift`+`Tab` | 候補を選択 |
| `Enter` | 補完を確定
