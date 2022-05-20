-- (treesitter)
require('nvim-treesitter.configs').setup {
    ensurse_installed = {
        "c","lua", "go",
        "typescript", "tsx", "vue",
        "html", "http", "javascript", "jsdoc", "json"
    },
    highlight = { enable = true },
    indent = {
        enable = true,
        disable = {
            "go", "tsx", "vue",
            "html", "http", "json"
        }
    }
}

-- (tree)
require('nvim-tree').setup {
    open_on_tab = false,
    -- :cd 时自动切换树
    update_cwd = true,
    update_focused_file = {
        -- 切换到buffer时跟踪显示
        enable = true,
        update_cwd = false,
        ignore_list = {},
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
    ignore_ft_on_setup = {}
}

-- (rest)
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
    sections = {
        lualine_b = {'branch', 'diff'},
        lualine_x = {'diagnostics', 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'%2p%%/%-3L'},
        lualine_z = {'%3l ﭾ %-2c'}
    },
    inactive_sections = {
        lualine_x = {},
        lualine_y = {'%2p%%/%-3L', '%3l ﭾ %-2c'}
    },
    tabline = {
        lualine_a = {'buffers'},
        lualine_z = {'tabs'}
    },
    extensions = {
        'fugitive',
        'nvim-tree'
    }
})
