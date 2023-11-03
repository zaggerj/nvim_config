vim.g.mapleader = ' '
-- config = true 等于 require('foo').setup({})
-- 如果同时指定了 opts 和 config，则需要在 config 中显示调用 setup，否则应该使用 init
require('lazy').setup({
    { 'tpope/vim-fugitive',        event = 'VeryLazy' },
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
        build = 'CocUpdate',
        event = 'BufReadPre',
        init = function()
            -- vim.o 则是字符串
            vim.opt.shortmess:append('c')
            vim.o.signcolumn = 'number'
        end,
        dependencies = {
            'gpanders/editorconfig.nvim',
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
    { 'fatih/vim-go', ft = 'go' },
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
        init = function()
            vim.opt.showmode = false
            vim.opt.laststatus = 2
            vim.opt.showtabline = 2
        end,
        opts = {
            options = {
                -- theme = vim.g.colors_name,
                theme = 'auto'
            },
            sections = {
                lualine_b = { 'branch', 'diff' },
                lualine_c = { { 'filename', newfile_status = true, path = 1 } },
                lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
                lualine_y = { '%2p%% 󰚀 %-3L' },
                lualine_z = { '%3l:%-2c' }
            },
            inactive_sections = {
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = {},
                lualine_y = { '%2p%% 󰚀 %-3L', '%3l:%-2c' }
            },
            tabline = {
                lualine_a = { {
                    'buffers',
                    buffers_color = {
                        active = 'lualine_a_normal',
                        inactive = 'lualine_b_normal',
                    }
                } },
                lualine_z = { {
                    'tabs',
                    mode = 2,
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
        }
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
        tag = "0.1.0",
        cmd = "Telescope",
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
                    glob_pattern = { '!*.{bundle,min}.js', '!**/{libs,plugin,*vnc,rdp}/**' },
                    search_dirs = { 'src', 'css', 'js', 'views' }
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
    { 'sainnhe/forest-night',      lazy = true },
    { 'folke/tokyonight.nvim',     lazy = true },
    { 'olimorris/onedarkpro.nvim', lazy = true },
    { 'catppuccin/nvim',           name = 'catppuccin', lazy = true },
    {
        'nvim-treesitter/nvim-treesitter',
        build = 'TSUpdate',
        main = 'nvim-treesitter.configs',
        event = 'BufReadPre',
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
