local large_file = require('large_file')
-- config = true 等于 require('foo').setup({})
-- 如果同时指定了 opts 和 config，则需要在 config 中显式调用 setup
-- 非 lua 插件，除了 basic.vim 之外的配置需要写在 init 中
-- lua 插件如果存在非 opts 的选项，则需要在 config 中初始化，写在 init 中如果存在 require() 会导致 lazy 失效 e.g ufo 的配置

local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too
vim.opt.updatetime = 300

vim.g.mapleader = ' '
vim.g.maplocalleader = ',' -- Neorg独立前缀，不覆盖全局反斜杠命令入口
require('lazy').setup({
  {
    'github/copilot.vim',
    branch = 'release',
    commit = 'a12fd5672110c8aa7e3c8419e28c96943ca179be',
    event = 'InsertEnter',
    cmd = 'Copilot',
    init = function() require('ai').init() end,
    config = function() require('ai').setup() end,
  },
  { 'luarocks/hererocks', lazy = true, build = function(plugin)
    require('bootstrap').build_rocks(plugin)
  end },
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  {
    'lewis6991/gitsigns.nvim',
    event = 'User NormalFile',
    opts = {
      max_file_length = large_file.max_lines,
      on_attach = function(buf)
        if large_file.is_large(buf) then return false end
        local gs = require('gitsigns')
        vim.keymap.set('n', '<leader>gb', function() gs.blame_line({ full = true }) end,
          { buffer = buf, desc = '查看当前行 Git blame' })
        vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame,
          { buffer = buf, desc = '切换行尾 Git blame' })
      end,
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
    event = 'User NormalFile',
    opts = {
      provider_selector = function(buf)
        if large_file.is_large(buf) then return '' end
        return { 'treesitter', 'indent' }
      end,
    },
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
    'rest-nvim/rest.nvim',
    dependencies = { 'luarocks/hererocks' },
    build = function(plugin)
      require('bootstrap').build_rocks(require('lazy.core.config').plugins.hererocks, plugin)
    end,
    config = function()
      local extension = vim.fn.has('win32') == 1 and 'dll' or 'so'
      local parser = vim.fn.stdpath('data') .. '/lazy-rocks/rest.nvim/lib/lua/5.1/parser/http.' .. extension
      -- LuaRocks 将 parser 安装在 lib/lua 中，Neovim 不会在此自动查找。
      vim.treesitter.language.add('http', { path = parser })
      require('rest_compat').setup()
    end,
    ft = 'http',
    init = function()
      vim.g.rest_nvim = {
        request = { skip_ssl_verification = false },
        highlight = { enable = true, timeout = 150 },
      }
    end,
  },
  {
    'neoclide/coc.nvim',
    branch = 'release',
    event = 'User NormalFile',
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
  { 'fatih/vim-go', ft = 'go', init = function()
    vim.g.go_code_completion_enabled = 0
    vim.g.go_gopls_enabled = 0 -- 语言服务交由 Coc，避免重复启动
    vim.g.go_def_mapping_enabled = 0
    vim.g.go_doc_keywordprg_enabled = 0
    vim.g.go_textobj_enabled = 0
  end, config = function() require('go_compat').setup() end },
  {
    "nvim-neorg/neorg",
    -- rockspec 的 specs 只是顶层声明；明确依赖关系，避免空首页启动整个依赖树。
    dependencies = {
      { 'nvim-neotest/nvim-nio', lazy = true },
      { 'nvim-neorg/lua-utils.nvim', lazy = true },
      { 'nvim-lua/plenary.nvim', lazy = true },
      { 'MunifTanjim/nui.nvim', lazy = true },
      { 'pysan3/pathlib.nvim', lazy = true },
    },
    build = function() require('neorg_setup').install() end,
    cmd = "Neorg",
    ft = "norg",
    config = require('neorg_setup').setup,
    opts = {
      load = {
        ["core.integrations.treesitter"] = { config = { install_parsers = false } },
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
    -- 指定文件启动时无需首页；保留空启动与显式 :Alpha。
    event = function() return vim.fn.argc(-1) == 0 and 'VimEnter' or nil end,
    cmd = 'Alpha',
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
    'nvim-lualine/lualine.nvim',
    -- 主题在启动设置层确定后再初始化，避免 ColorScheme 触发第二次 setup。
    event = 'VimEnter',
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
      vim.opt.laststatus = 3
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
      preset = "modern",  -- v3 新增: 使用现代化预设样式
      delay = 200,        -- 触发延迟 (毫秒)
      -- v3 已移除 window/layout 配置,改用 win 配置
      win = {
        border = "rounded",  -- 边框样式
        padding = { 1, 2 },  -- 内边距 [垂直, 水平]
      },
      -- 插件集成
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
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      
      -- v3 API: 使用 add() 替代 register(),采用 spec 数组格式
      wk.add({
        -- 分组说明
        { "<leader>f", group = "🔍 查找 (Find)" },
        { "<leader>g", group = "🔀 Git 操作" },
        { "<leader>h", group = "🔧 Git Hunk 操作" },
        { "<leader>t", group = "🎯 切换 (Toggle)" },
        { "<leader>b", group = "📦 缓冲区 (Buffer)" },
        { "<leader>w", group = "🪟 窗口 (Window)" },
        { "<leader>c", group = "💻 代码 (Code)" },
        { "<leader>d", group = "🐛 调试 (Debug)" },
        { "<leader>s", group = "🔎 搜索 (Search)" },
        { "<leader>n", group = "📝 笔记 (Notes)" },
        { "<leader>?", group = "❓ 帮助 (Help)" },
        
        -- Telescope 相关
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "全局搜索" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "查找缓冲区" },
        { "<leader>fh", "<cmd>FindFilesWithHidden<cr>", desc = "查找文件 (含隐藏)" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近文件" },
        { "<leader>ft", "<cmd>Telescope help_tags<cr>", desc = "查找帮助文档" },
        
        -- 文件树与大纲
        { "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", desc = "文件树" },
        { "<leader>v", "<cmd>Vista!!<cr>", desc = "代码大纲" },
        
        -- Git 相关
        { "<leader>gd", desc = "Git Diff" },
        
        -- 折叠相关
        { "zR", desc = "打开所有折叠" },
        { "zM", desc = "关闭所有折叠" },
        
        -- 帮助和教程
        { "<leader>?t", "<cmd>Tutor zh<cr>", desc = "📚 Vim 教程 (中文)" },
        { "<leader>?e", "<cmd>Tutor<cr>", desc = "📚 Vim Tutorial (English)" },
        { "<leader>?h", "<cmd>Telescope help_tags<cr>", desc = "📖 搜索帮助文档" },
        { "<leader>?k", "<cmd>Telescope keymaps<cr>", desc = "⌨️  查看所有快捷键" },
        { "<leader>?c", "<cmd>Telescope commands<cr>", desc = "🔧 搜索命令" },
        
        -- 命令面板
        { "<leader><leader>", "<cmd>Legendary<cr>", desc = "🎯 命令面板" },
      })
    end,
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    event = 'User NormalFile',
    init = function() vim.g.skip_ts_context_commentstring_module = true end,
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
    cmd = { 'Telescope', 'FindFilesWithHidden', 'FindFilesIgnored', 'GrepIgnored', 'GrepPCRE', 'SearchHealth' },
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    opts = require('search').options(),
    config = require('search').setup,
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
    branch = 'master', -- 保留兼容 Neovim 0.10 的 configs API
    event = 'User NormalFile',
    config = function(_, opts)
      -- 高级选项，巨幅提升 parser 下载速度
      -- 要求 curl, tar, 且可以在非 admin 下创建 SymbolicLink
      -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#how-will-the-parser-be-downloaded
      require("nvim-treesitter.install").prefer_git = false

      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      -- 使用 :ParserInstall 显式部署，首次打开代码不下载安装。
      ensure_installed = {},
      auto_install = false,
      highlight = {
        enable = true,
        disable = function(_, buf) return large_file.is_large(buf) end,
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
        opts = { exclude = { filetypes = { 'bigfile' } } }
      },
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = { on_attach = function(buf) return not large_file.is_large(buf) end }
      },
      {
        'windwp/nvim-ts-autotag',
        config = true
      }
    }
  },
}, require('bootstrap').lazy_options())
