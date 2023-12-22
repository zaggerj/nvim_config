-- config = true 等于 require('foo').setup({})
-- 如果同时指定了 opts 和 config，则需要在 config 中显式调用 setup
-- 非 lua 插件，除了 basic.vim 之外的配置需要写在 init 中
-- lua 插件如果存在非 opts 的选项，则需要在 config 中初始化，写在 init 中如果存在 require() 会导致 lazy 失效 e.g ufo 的配置

local HEIGHT_RATIO = 0.8  -- You can change this
local WIDTH_RATIO = 0.5   -- You can change this too

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
        }
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
        'nvim-orgmode/orgmode',
        ft = 'org',
        config = function(_, opts)
            require('orgmode').setup_ts_grammar()
            require('orgmode').setup(opts)
        end,
        opts = {
            org_agenda_files = { 'E:\\working\\todo\\orgs\\agenda\\*' },
            org_default_notes_file = 'E:\\working\\todo\\main.org',
            mappings = {
                org = {
                    org_toggle_checkbox = '<C-Enter>',
                }
            }
        },
        dependencies = {
            {
                'akinsho/org-bullets.nvim',
                opts = {
                    concealcursor = false
                }
            }
        }
    },
    {
        'kyazdani42/nvim-tree.lua',
        cmd = "NvimTreeFindFileToggle",
        opts = {
            disable_netrw = true,
            open_on_tab = false,
            sync_root_with_cwd = true,
            -- :cd 时自动切换树
            update_cwd = true,
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
                enable = false,
                update_cwd = false,
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
        'numToStr/Comment.nvim',
        event = 'VeryLazy',
        config = true
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
                    glob_pattern = { '!*.{bundle,min}.{js,css}', '!*-lock.*', '!{view-front,built,libs,plugin,*vnc,rdp,node_modules}/' }
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
        main = 'nvim-treesitter.configs',
        event = 'VeryLazy',
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
    }
})
