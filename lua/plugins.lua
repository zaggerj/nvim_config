-- (treesitter)
require('nvim-treesitter.configs').setup {
    ensurse_installed = {
        "c","lua", "go",
        "typescript", "tsx",
        "html", "http", "javascript", "jsdoc", "json"
    },
    highlight = { enable = true},
    indent = {
        enable = false,
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
    -- :cd 时自动切换树
    update_cwd = true,
    renderer = {
        highlight_git = true,
        icons = {
            show = {
                git = false
            }
        }
    },
    update_focused_file = {
        -- 切换到buffer时跟踪显示
        enable = true,
        update_cwd = false,
        ignore_list = {},
    },
    diagnostics = {
        enable = false,
        show_on_dirs = true,
    },
    ignore_ft_on_setup = {}
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
    theme = "tokyonight",
    sections = {
        lualine_b = {'branch', 'diff'},
        lualine_c = {{'filename', path = 1}},
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
    current_line_blame_opts = {
        delay = 500
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
