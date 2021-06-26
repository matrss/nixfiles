require('packer').startup {
    function(use)
        use 'tpope/vim-vinegar'
        use 'airblade/vim-rooter'
        use 'editorconfig/editorconfig-vim'
        use 'freitass/todo.txt-vim'
        use {
            'sudormrfbin/cheatsheet.nvim',
            requires = {
                -- 'nvim-telescope/telescope.nvim',
            },
            after = {
                'telescope.nvim',
            },
        }

        use 'vim-pandoc/vim-pandoc'
        use 'vim-pandoc/vim-pandoc-syntax'

        use {
            'TimUntersberger/neogit',
            requires = {
                -- 'nvim-lua/plenary.nvim',
            },
            after = {
                'plenary.nvim',
            },
        }

        use {
            'neovim/nvim-lspconfig',
            ft = { 'lua', 'rust', 'python', 'c', 'cpp', 'nix', 'sh', 'bash', },
            cmd = { 'LspStart', 'LspRestart', },
            config = function()
                local lspc = require('lspconfig')
                lspc.sumneko_lua.setup {
                    cmd = { "lua-language-server" },
                    settings = {
                        Lua = {
                            runtime = {
                                version = 'LuaJIT',
                                path = vim.split(package.path, ';'),
                            },
                            diagnostics = {
                                globals = {'vim'},
                            },
                            workspace = {
                                library = {
                                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                                },
                            },
                        },
                    },
                }
                lspc.rust_analyzer.setup {}
                -- lspc.fortls.setup {}
                lspc.pyright.setup {}
                lspc.clangd.setup {}
                lspc.rnix.setup {}
                lspc.bashls.setup {}
            end,
        }
        -- use {
        --     -- 'kabouzeid/nvim-lspinstall',
        --     'matrss/nvim-lspinstall',
        --     branch = 'fix-absolute-paths',
        --     requires = {
        --         -- 'neovim/nvim-lspconfig',
        --     },
        --     config = function()
        --         local function setup_servers()
        --             local lspi = require('lspinstall')
        --             lspi.setup {}
        --             local servers = lspi.installed_servers()
        --             for _, server in pairs(servers) do
        --                 require('lspconfig')[server].setup {}
        --             end
        --         end
        --         setup_servers()
        --         require('lspinstall').post_install_hook = function ()
        --             -- reload installed servers
        --             setup_servers()
        --             -- this triggers the FileType autocmd that starts the server
        --             vim.cmd("bufdo e")
        --         end
        --     end,
        -- }

        use {
            'hrsh7th/nvim-compe',
            config = function()
                require('compe').setup {
                    enabled = true,
                    autocomplete = false,
                    debug = false,
                    min_length = 0,
                    preselect = 'enable',
                    -- throttle_time = 80,
                    -- source_timeout = 200,
                    -- incomplete_delay = 400,
                    -- max_abbr_width = 100,
                    -- max_kind_width = 100,
                    -- max_menu_width = 100,
                    documentation = true,

                    source = {
                        nvim_lsp = {
                            priority = 5,
                            sort = true,
                        },
                        nvim_lua = {
                            priority = 4,
                            sort = true,
                        },
                        path = {
                            priority = 3,
                            sort = true,
                        },
                        nvim_treesitter = {
                            priority = 2,
                            sort = true,
                        },
                        buffer = {
                            priority = 1,
                            sort = true,
                        },
                    },
                }
                vim.api.nvim_set_keymap('i', '<c-space>', [[compe#complete()]], { noremap = true, expr = true, silent = true })
            end,
        }

        use {
            'rmagatti/auto-session',
            config = function()
                require('auto-session').setup {
                    auto_session_suppress_dirs = { "~" },
                }
            end,
        }
        use {
            'rmagatti/session-lens',
            requires = {
                'rmagatti/auto-session',
                -- 'nvim-telescope/telescope.nvim',
            },
            after = {
                'auto-session',
                'telescope.nvim',
            },
        }
        -- use {
        --     'glepnir/galaxyline.nvim',
        --     branch = 'main',
        --     config = function()
        --         require('galaxyline_settings')
        --     end,
        -- }
        -- use {
        --     'megalithic/zk.nvim',
        --     requires = {
        --         -- 'nvim-telescope/telescope.nvim'
        --     },
        --     config = function()
        --         require('zk').setup {
        --             fuzzy_finder = 'telescope',
        --         }
        --     end,
        -- }
        -- use {
        --     'oberblastmeister/neuron.nvim',
        --     requires = {
        --         'nvim-lua/plenary.nvim',
        --         -- 'nvim-telescope/telescope.nvim',
        --     },
        --     config = function()
        --         require('neuron').setup {
        --             neuron_dir = "~/Sync/neuron",
        --         }
        --     end,
        -- }
        use {
            'nvim-telescope/telescope.nvim',
            requires = {
                'nvim-lua/popup.nvim',
                'nvim-lua/plenary.nvim',
            },
            after = {
                'popup.nvim',
                'plenary.nvim',
            },
            config = function()
                require('telescope').setup {
                    defaults = {
                        layout_strategy = "bottom_pane",
                        layout_defaults = {
                            vertical = {
                                mirror = true,
                            },
                        },
                        border = true,
                        borderchars = {'▄', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
                    },
                }
            end,
        }
        use {
            'nvim-telescope/telescope-symbols.nvim',
            requires = {
                -- 'nvim-telescope/telescope.nvim',
            },
            after = {
                'telescope.nvim',
            },
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
                    ensure_installed = 'maintained',
                    highlight = { enable = true }
                }
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


-- Set nix filetype, somehow that does not happen automatically...
vim.cmd([[
augroup nix_filetype
    autocmd! BufNewFile,BufFilePre,BufRead *.nix set filetype=nix
augroup end
]])

-- Remember the view state, e.g. open and closed folds
vim.opt.viewoptions = vim.opt.viewoptions - { 'options' }
vim.cmd([[
augroup remember_view
    autocmd! BufWinLeave * mkview
    autocmd! BufWinEnter * silent! loadview
augroup end
]])

-- Unmap help on <f1> so that it does not open when using neovide and switching
-- virtual desktops
-- TODO: somehow it still opens sometimes
vim.api.nvim_set_keymap('n', '<f1>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('i', '<f1>', '<nop>', { noremap = true })

-- Reasonable way to get back into normal mode
vim.api.nvim_set_keymap('t', '<leader><esc>', [[<c-\><c-n>]], { noremap = true })
