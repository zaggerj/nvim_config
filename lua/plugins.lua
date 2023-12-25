-- config = true 等于 require('foo').setup({})
-- 如果同时指定了 opts 和 config，则需要在 config 中显式调用 setup
-- 非 lua 插件，除了 basic.vim 之外的配置需要写在 init 中
-- lua 插件如果存在非 opts 的选项，则需要在 config 中初始化，写在 init 中如果存在 require() 会导致 lazy 失效 e.g ufo 的配置

local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too
vim.opt.updatetime = 100

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
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line { full = true } end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      })
    end,
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
  {
    'nvim-telescope/telescope.nvim',
    version = "~0.1.0",
    event = "VeryLazy",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false
          }
        }
      },
      pickers = {
        live_grep = {
          debounce = 500,
          glob_pattern = { '!*.{bundle,min}.{js,css}', '!*-lock.*', '!{view-front,built,lib,plugin,*vnc,rdp,node_modules}/' }
        }
      }
    }
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
        enable = true
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
