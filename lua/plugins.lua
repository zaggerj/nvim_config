-- (treesitter)
require('nvim-treesitter.configs').setup {
    ensurse_installed = {
        "c","lua", "go",
        "typescript", "tsx",
        "html", "http", "javascript", "jsdoc", "json"
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = {'org', 'vue', 'lua', 'html'}
    },
    indent = {
        enable = true,
        disable = {
            "go", "typescriptreact",
            "http", "json", "html",
            "javascript"
        }
    }
}

-- (tree)
require('nvim-tree').setup({
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
})

-- (rest)
-- 仅 fvim 需要，别的 gui 可以启用 icon
require('rest-nvim').setup({
    highlight = {
        enable = true,
        timeout = 150,
    },
    jump_to_request = true
})

-- (lualine)
vim.opt.showmode = false
vim.opt.laststatus = 2
vim.opt.showtabline = 2
require('lualine').setup({
    options = {
        -- theme = vim.g.colors_name,
        theme = 'ayu_light'
    },
    sections = {
        lualine_b = {'branch', 'diff'},
        lualine_c = {{'filename', newfile_status = true, path = 1}},
        lualine_x = {'diagnostics', 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'%2p%% ﭾ %-3L'},
        lualine_z = {'%3l:%-2c'}
    },
    inactive_sections = {
        lualine_c = {{'filename', path = 1}},
        lualine_x = {},
        lualine_y = {'%2p%% ﭾ %-3L', '%3l:%-2c'}
    },
    tabline = {
        lualine_a = {{'buffers', buffers_color = {
        active = 'lualine_a_normal',
        inactive = 'lualine_b_normal',
      }}},
        lualine_z = {{ 'tabs', mode = 2, tabs_color = {
        active = 'lualine_a_normal',
        inactive = 'lualine_b_normal',
      }}}
    },
    extensions = {
        'fugitive',
        'nvim-tree',
        'quickfix'
    }
})

-- gitsigns
require('gitsigns').setup({
    current_line_blame = true,
    signcolumn = true,
    linehl = false,
    current_line_blame_opts = {
        delay = 1000
    }
})

-- indentLine
require("indent_blankline").setup({show_current_context = true})

-- Telescope
require('telescope').setup{
    defaults = {
        mappings = {
            i = {
                ["<C-u>"] = false
            }
        }
    }
}

-- (Commenter)
require('Comment').setup()

-- (org-mode)
require('orgmode').setup_ts_grammar()
require('orgmode').setup({
    org_agenda_files = {'E:\\working\\todo\\orgs\\agenda\\*'},
    org_default_notes_file = 'E:\\working\\todo\\main.org',
    mappings = {
        org = {
            org_toggle_checkbox = '<C-Enter>',
        }
    }
})
require('org-bullets').setup({
    concealcursor = false
})
