-- config = true 等于 require('foo').setup({})
-- 如果同时指定了 opts 和 config，则需要在 config 中显式调用 setup
-- 非 lua 插件，除了 basic.vim 之外的配置需要写在 init 中
-- lua 插件如果存在非 opts 的选项，则需要在 config 中初始化，写在 init 中如果存在 require() 会导致 lazy 失效 e.g ufo 的配置

local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too
vim.opt.updatetime = 300

vim.g.mapleader = ' '
require('lazy').setup({
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      current_line_blame = true,
      signcolumn = true,
      linehl = false,
      current_line_blame_opts = {
        delay = 1000
      }
    },
    -- config = function()
    --   require('gitsigns').setup({
    --     on_attach = function(bufnr)
    --       local gs = package.loaded.gitsigns
    --
    --       local function map(mode, l, r, opts)
    --         opts = opts or {}
    --         opts.buffer = bufnr
    --         vim.keymap.set(mode, l, r, opts)
    --       end
    --
    --       -- navigation
    --       map('n', ']c', function()
    --         if vim.wo.diff then return ']c' end
    --         vim.schedule(function() gs.next_hunk() end)
    --         return '<ignore>'
    --       end, { expr = true })
    --
    --       map('n', '[c', function()
    --         if vim.wo.diff then return '[c' end
    --         vim.schedule(function() gs.prev_hunk() end)
    --         return '<ignore>'
    --       end, { expr = true })
    --
    --       -- actions
    --       map('n', '<leader>hs', gs.stage_hunk)
    --       map('n', '<leader>hr', gs.reset_hunk)
    --       map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    --       map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    --       map('n', '<leader>hs', gs.stage_buffer)
    --       map('n', '<leader>hu', gs.undo_stage_hunk)
    --       map('n', '<leader>hr', gs.reset_buffer)
    --       map('n', '<leader>hp', gs.preview_hunk)
    --       map('n', '<leader>hb', function() gs.blame_line { full = true } end)
    --       map('n', '<leader>tb', gs.toggle_current_line_blame)
    --       map('n', '<leader>hd', gs.diffthis)
    --       map('n', '<leader>hd', function() gs.diffthis('~') end)
    --       map('n', '<leader>td', gs.toggle_deleted)
    --
    --       -- text object
    --       map({ 'o', 'x' }, 'ih', ':<c-u>gitsigns select_hunk<cr>')
    --     end
    --   })
    -- end,
  },
  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    opts = {},
    config = function(_, opts)
      local ufo = require('ufo')

      ufo.setup(opts)

      vim.o.foldcolumn = '0'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      vim.keymap.set('n', 'zR', ufo.openAllFolds)
      vim.keymap.set('n', 'zM', ufo.closeAllFolds)
    end,
    dependencies = {
      { 'kevinhwang91/promise-async' }
    }
  },
  {
    'nvim-lua/plenary.nvim',
    lazy = true
  },
  {
    'NTBBloodbath/rest.nvim',
    ft = 'http',
    opts = {
      highlight = {
        enable = true,
        timeout = 150,
      },
      jump_to_request = true
    }
  },
  {
    'neoclide/coc.nvim',
    branch = 'release',
    build = ':CocUpdate',
    event = 'VeryLazy',
    init = function()
      -- vim.o 则是字符串
      vim.opt.shortmess:append('c')
      vim.o.signcolumn = 'number'
    end,
    dependencies = {
      {
        -- Vista 插件，生成vscode大纲
        'liuchengxu/vista.vim',
        init = function()
          vim.g.vista_cursor_delay = 60
          vim.g.vista_sidebar_position = "vertical botright"
          vim.g.vista_default_executive = "coc"
        end
      }
    }
  },
  { 'fatih/vim-go',       ft = 'go' },
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    cmd = "Neorg",
    ft = "norg",
    opts = {
      load = {
        ["core.defaults"] = {},    -- Loads default behaviour
        ["core.concealer"] = {},   -- Adds pretty icons to your documents
        ["core.ui.calendar"] = {}, -- Adds pretty icons to your documents
        ["core.dirman"] = {        -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/Desktop/备忘录",
            },
          },
        },
      },
    },
  },
  {
    'kyazdani42/nvim-tree.lua',
    cmd = "NvimTreeFindFileToggle",
    opts = {
      disable_netrw = true,
      open_on_tab = false,
      -- :cd 时自动切换树
      sync_root_with_cwd = true,
      view = {
        adaptive_size = true,
        -- float = {
        --   enable = true,
        --   open_win_config = function()
        --     local screen_w = vim.opt.columns:get()
        --     local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        --     local window_w = screen_w * WIDTH_RATIO
        --     local window_h = screen_h * HEIGHT_RATIO
        --     local window_w_int = math.floor(window_w)
        --     local window_h_int = math.floor(window_h)
        --     local center_x = (screen_w - window_w) / 2
        --     local center_y = ((vim.opt.lines:get() - window_h) / 2)
        --                      - vim.opt.cmdheight:get()
        --     return {
        --       border = 'rounded',
        --       relative = 'editor',
        --       row = center_y,
        --       col = center_x,
        --       width = window_w_int,
        --       height = window_h_int,
        --     }
        --     end,
        -- },
        -- width = function()
        --   return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
        --   end,
      },
      update_focused_file = {
        -- 切换到buffer时跟踪显示
        enable = true,
        update_root = false,
        ignore_list = {},
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      }
    }
  },
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      -- 自定义 Logo (使用简洁的 Neovim Logo)
      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        [[                                                    ]],
      }

      -- 快捷操作按钮
      dashboard.section.buttons.val = {
        dashboard.button("f", "🔍  查找文件", ":Telescope find_files<CR>"),
        dashboard.button("g", "🔎  全局搜索", ":Telescope live_grep<CR>"),
        dashboard.button("r", "📁  最近文件", ":Telescope oldfiles<CR>"),
        dashboard.button("c", "⚙️   配置文件", ":e $MYVIMRC<CR>"),
        dashboard.button("t", "📚  启动教程", ":Tutor zh<CR>"),
        dashboard.button("l", "💤  插件管理", ":Lazy<CR>"),
        dashboard.button("q", "🚪  退出", ":qa<CR>"),
      }

      -- 页脚信息
      local function footer()
        local total_plugins = #vim.tbl_keys(require('lazy').plugins())
        local datetime = os.date(" %Y-%m-%d   %H:%M:%S")
        local version = vim.version()
        local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

        return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version_info
      end

      dashboard.section.footer.val = footer()

      -- 设置高亮
      dashboard.section.header.opts.hl = "Include"
      dashboard.section.buttons.opts.hl = "Keyword"
      dashboard.section.footer.opts.hl = "Type"

      -- 布局配置
      dashboard.config.opts.noautocmd = true

      alpha.setup(dashboard.config)

      -- 自动刷新页脚 (显示最新时间)
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          dashboard.section.footer.val = footer()
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
  {
    'mrjones2014/legendary.nvim',
    event = 'VeryLazy',
    dependencies = { 'kkharji/sqlite.lua' },
    opts = {
      -- 集成 which-key
      extensions = {
        which_key = {
          auto_register = true,
          do_binding = false,
        },
      },
      -- 搜索选项
      select_prompt = ' 命令面板 ',
      -- 包含的项目类型
      include_builtin = true,
      include_legendary_cmds = true,
      -- 排序优先级
      sort = {
        frecency = {
          db_root = vim.fn.stdpath('data') .. '/legendary',
          max_timestamps = 10,
        },
      },
    },
    config = function(_, opts)
      require('legendary').setup(opts)
      
      -- 添加自定义命令到 legendary
      require('legendary').commands({
        { ':Lazy', description = '打开插件管理器' },
        { ':Lazy sync', description = '同步插件' },
        { ':Lazy update', description = '更新插件' },
        { ':NvimTreeFindFileToggle', description = '切换文件树' },
        { ':Vista!!', description = '切换代码大纲' },
        { ':Tutor zh', description = '启动中文教程' },
        { ':Tutor', description = '启动英文教程' },
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'auto',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        globalstatus = true
      },
      sections = {
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', newfile_status = true, path = 1 } },
        lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
        lualine_y = { '%2p%%❆ %-3L' },
        lualine_z = { '%3l:%-2c' }
      },
      inactive_sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {},
        lualine_y = { '%2p%%❆ %-3L', '%3l:%-2c' }
      },
      tabline = {
        lualine_a = { {
          'buffers',
          mode = 4,
          use_mode_colors = true,
          buffers_color = {
            -- active = 'lualine_a_normal',
            inactive = 'lualine_b_normal',
          }
        } },
        lualine_z = { {
          'tabs',
          mode = 1,
          tabs_color = {
            active = 'lualine_a_normal',
            inactive = 'lualine_b_normal',
          }
        } }
      },
      extensions = {
        'fugitive',
        'nvim-tree',
        'quickfix',
        'lazy'
      }
    },
    config = function(_, opts)
      require('lualine').setup(opts)
      vim.opt.showmode = false
      vim.opt.laststatus = 2
      vim.opt.showtabline = 2
    end,
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = true
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      -- 插件配置选项
      plugins = {
        marks = true,       -- 显示标记
        registers = true,   -- 显示寄存器
        spelling = {
          enabled = true,   -- 拼写建议
          suggestions = 20,
        },
        presets = {
          operators = true,    -- 操作符帮助 (d, y, c 等)
          motions = true,      -- 移动命令帮助
          text_objects = true, -- 文本对象帮助 (iw, aw 等)
          windows = true,      -- 窗口命令
          nav = true,          -- 导航命令
          z = true,            -- z 开头的命令
          g = true,            -- g 开头的命令
        },
      },
      -- 窗口配置
      window = {
        border = "rounded",       -- 边框样式: none, single, double, rounded
        position = "bottom",      -- 位置: bottom, top
        margin = { 1, 0, 1, 0 }, -- 外边距 [上, 右, 下, 左]
        padding = { 1, 2, 1, 2 }, -- 内边距
        winblend = 0,            -- 透明度 (0-100)
      },
      layout = {
        height = { min = 4, max = 25 }, -- 窗口高度
        width = { min = 20, max = 50 }, -- 窗口宽度
        spacing = 3,                     -- 列间距
        align = "left",                  -- 对齐方式
      },
      -- 触发延迟 (毫秒)
      triggers_delay = 200,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      
      -- 注册快捷键分组说明
      wk.register({
        ["<leader>f"] = { name = "🔍 查找 (Find)" },
        ["<leader>g"] = { name = "🔀 Git 操作" },
        ["<leader>h"] = { name = "🔧 Git Hunk 操作" },
        ["<leader>t"] = { name = "🎯 切换 (Toggle)" },
        ["<leader>b"] = { name = "📦 缓冲区 (Buffer)" },
        ["<leader>w"] = { name = "🪟 窗口 (Window)" },
        ["<leader>c"] = { name = "💻 代码 (Code)" },
        ["<leader>d"] = { name = "🐛 调试 (Debug)" },
        ["<leader>s"] = { name = "🔎 搜索 (Search)" },
        ["<leader>n"] = { name = "📝 笔记 (Notes)" },
        ["<leader>?"] = { name = "❓ 帮助 (Help)" },
      })
      
      -- 注册具体的快捷键说明 (根据您的实际配置调整)
      wk.register({
        -- Telescope 相关
        ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "查找文件" },
        ["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "全局搜索" },
        ["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "查找缓冲区" },
        ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "查找帮助文档" },
        ["<leader>fr"] = { "<cmd>Telescope oldfiles<cr>", "最近文件" },
        
        -- NvimTree
        ["<leader>e"] = { "<cmd>NvimTreeFindFileToggle<cr>", "文件树" },
        
        -- Vista (大纲)
        ["<leader>v"] = { "<cmd>Vista!!<cr>", "代码大纲" },
        
        -- Git 相关 (如果您配置了 gitsigns 快捷键)
        ["<leader>gb"] = { "Git Blame" },
        ["<leader>gd"] = { "Git Diff" },
        
        -- 折叠相关
        ["zR"] = { "打开所有折叠" },
        ["zM"] = { "关闭所有折叠" },
        
        -- 帮助和教程
        ["<leader>?t"] = { "<cmd>Tutor zh<cr>", "📚 Vim 教程 (中文)" },
        ["<leader>?e"] = { "<cmd>Tutor<cr>", "📚 Vim Tutorial (English)" },
        ["<leader>?h"] = { "<cmd>Telescope help_tags<cr>", "📖 搜索帮助文档" },
        ["<leader>?k"] = { "<cmd>Telescope keymaps<cr>", "⌨️  查看所有快捷键" },
        ["<leader>?c"] = { "<cmd>Telescope commands<cr>", "🔧 搜索命令" },
        
        -- 命令面板
        ["<leader><leader>"] = { "<cmd>Legendary<cr>", "🎯 命令面板" },
      })
    end,
  },
  {
    'fmoralesc/vim-tutor-mode',
    cmd = 'Tutor',
    init = function()
      -- 设置教程语言 (可选: 'zh', 'en', 'es', 'fr', 'de', 'it', 'ja', 'ko', 'pt', 'ru')
      vim.g.tutor_default_language = 'zh'
      -- 启用教程进度保存
      vim.g.tutor_save_progress = 1
    end,
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = function()
      require('Comment').setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  -- 注意微信输入法开启自动添加空格的功能时，输入中文时，会自动带入一个空格。
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    event = "VeryLazy",
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    opts = {
      defaults = {
        -- 配置 ripgrep 参数
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob=!.git/',
          '--pcre2', -- 核心项：保持中文搜索支持
        },
        -- 全局文件忽略模式
        file_ignore_patterns = {
          "node_modules/",
          ".git/",
          "dist/",
          "build/",
          "built/",
          "lib/",
          "%.min%.js$",
          "%.min%.css$",
          "%.bundle%.js$",
          "%.bundle%.css$",
          "%-lock%.json$",
          "package%-lock%.json$",
          "yarn%.lock$",
          "pnpm%-lock%.yaml$",
          -- 性能优化：忽略二进制和资源
          "%.jpg$", "%.jpeg$", "%.png$", "%.gif$", "%.svg$", "%.ico$",
          "%.mp4$", "%.webm$", "%.ogg$", "%.mp3$", "%.wav$", "%.flac$",
          "%.pdf$", "%.zip$", "%.tar%.gz$", "%.tgz$", "%.rar$", "%.7z$",
          "%.woff$", "%.woff2$", "%.ttf$", "%.eot$",
          "%.db$", "%.sqlite$", "%.sqlite3$",
          "%.log$", "%.cache$",
          -- 编译器与中间产物
          "%.o$", "%.a$", "%.obj$", "%.exe$", "%.dll$", "%.so$", "%.dylib$",
          -- 常见开发缓存目录
          "%.next/", "%.nuxt/", "%.svelte-kit/", "%.yarn/", "%.pnpm-store/",
          "%.sass-cache/", "%.swp$", "%.tmp$", "%.DS_Store",
        },
        mappings = {
          i = {
            ["<C-u>"] = false
          }
        }
      },
      pickers = {
        live_grep = {
          debounce = 100, -- 恢复极速响应
        },
        find_files = {
          hidden = true,
        }
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        }
      }
    },
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      -- 安全加载 fzf 扩展，防止编译失败导致整个 Telescope 崩溃
      pcall(telescope.load_extension, 'fzf')
    end
  },
  {
    'justinmk/vim-sneak',
    event = 'VeryLazy',
    init = function()
      vim.g['sneak#label'] = 1
    end
  },
  { 'kyazdani42/nvim-web-devicons', lazy = true },
  { 'sainnhe/forest-night',         lazy = true },
  { 'folke/tokyonight.nvim',        lazy = true },
  { 'olimorris/onedarkpro.nvim',    lazy = true },
  { 'catppuccin/nvim',              name = 'catppuccin', lazy = true },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'VeryLazy',
    config = function(_, opts)
      -- 高级选项，巨幅提升 parser 下载速度
      -- 要求 curl, tar, 且可以在非 admin 下创建 SymbolicLink
      -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#how-will-the-parser-be-downloaded
      require("nvim-treesitter.install").prefer_git = false

      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      ensurse_installed = {
        "c", "lua", "go",
        "typescript", "tsx",
        "html", "http", "javascript", "jsdoc", "json", "vue"
      },
      highlight = {
        enable = true,
        -- 核心优化：大文件保护。当文件超过 100KB 时禁用 Treesitter 高亮，防止打字卡随
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = {
        enable = true,
        disable = {
          "javascript"
        }
      }
    },
    dependencies = {
      {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = true
      },
      {
        'nvim-treesitter/nvim-treesitter-context',
        config = true
      },
      {
        'windwp/nvim-ts-autotag',
        config = true
      }
    }
  },
})
