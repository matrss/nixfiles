require('packer').startup {
    function(use)

        use 'tpope/vim-vinegar'

        use 'airblade/vim-rooter'

        use 'editorconfig/editorconfig-vim'

        use {
            'rmagatti/auto-session',
            config = function()
                require('auto-session').setup {
                    auto_session_suppress_dirs = { "~/" },
                }
            end,
        }

        use {
            'folke/which-key.nvim',
            config = function ()
                require('which-key').setup {}
            end,
        }

        use {
            'RRethy/nvim-base16',
            config = function()
                vim.cmd('colorscheme base16-eighties')
            end,
        }

        use {
            'nvim-treesitter/nvim-treesitter',
            run = function()
                vim.cmd('TSUpdate')
            end,
            config = function()
                require('nvim-treesitter.configs').setup {
                    ensure_installed = 'all',
                    highlight = { enable = true }
                }
            end,
        }

        use 'nvim-treesitter/nvim-treesitter-textobjects'

        use {
            'lervag/vimtex',
            opt = true,
            ft = 'tex',
            config = function()
                vim.g.vimtex_view_general_viewer = 'evince'
                vim.g.vimtex_compiler_method = 'latexrun'
                vim.g.vimtex_fold_enabled = 1
            end,
        }
    end
}


local g = vim.g
local o = vim.o
local bo = vim.bo
local wo = vim.wo

g.mapleader = [[ ]]
g.maplocalleader = [[\]]

o.mouse = 'a'

o.backup = false
o.swapfile = false
o.writebackup = false

o.undofile = true

o.termguicolors = true

o.timeoutlen = 500

o.ignorecase = true
o.smartcase = true

o.hlsearch = false
o.incsearch = true

o.hidden = true

o.splitright = true
o.splitbelow = true

o.completeopt = 'menuone,noselect'

o.spelllang = 'de,en'

bo.tabstop = 4
bo.shiftwidth = 4
bo.expandtab = true

bo.copyindent = true

wo.number = true
wo.relativenumber = true
wo.signcolumn = 'auto'


-- Remember the view state, e.g. open and closed folds
-- vim.opt.viewoptions = vim.opt.viewoptions - { 'options' }
-- vim.cmd([[
-- augroup remember_view
--     autocmd! BufWinLeave * mkview
--     autocmd! BufWinEnter * silent! loadview
-- augroup end
-- ]])

-- Reasonable way to get back into normal mode
vim.api.nvim_set_keymap('t', '<leader><esc>', [[<c-\><c-n>]], { noremap = true })

-- Set undo points when writing a long bit of prose
vim.api.nvim_set_keymap('i', '.', '.<c-g>u', { noremap = true })
vim.api.nvim_set_keymap('i', '!', '!<c-g>u', { noremap = true })
vim.api.nvim_set_keymap('i', '?', '?<c-g>u', { noremap = true })
vim.api.nvim_set_keymap('i', ':', ':<c-g>u', { noremap = true })
