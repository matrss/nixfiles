if &compatible
  set nocompatible
endif

nnoremap <space> <nop>
let mapleader = " " " space as leader
let maplocalleader = "," " double space as local leader
set updatetime=100
if has('mouse') | set mouse=a | endif " mouse support
set wildoptions+=pum

" more natural splits
set splitbelow
set splitright

" set spelllang=de_20,en_us
" set spell

set termguicolors
colorscheme base16-eighties
" colorscheme onedark

set hidden " allow unsaved buffers in background

set undofile                " Save undos after file closes
set undodir=$HOME/.cache/nvim/undo " where to save undo histories
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo
set autoread
set autowrite

" Never use <esc> again
inoremap jk <ESC>
inoremap kj <ESC>

" number of visual spaces per TAB
set tabstop=4

" remove trailing whitespaces
" augroup whitespaces
" 	autocmd!
" 	autocmd FileType c,cpp,java,php,rust,python autocmd BufWritePre <buffer> %s/\s\+$//e
" augroup END

" Indenting
let fortran_do_enddo=1

" UI
set number          " show line numbers
set relativenumber  " line numbers relative to current line
set showcmd         " show last command in bottom bar
set wildmenu        " zsh-like autocomplete
set lazyredraw      " redraw only when needed
set showmatch       " highlight matching [{()}]
set scrolloff=5
" set colorcolumn=81

" show spaces and tabs and stuff
" set list
" set listchars=tab:›\ ,eol:¬,trail:⋅

" Searching
set ignorecase
set smartcase
set incsearch       " search as characters are entered
" set hlsearch        " highlighting
" nnoremap <leader>nh :nohlsearch<CR> " turn off highlighting

" terminal stuff
tnoremap <Esc> <C-\><C-n>
" tnoremap <silent> <C-h> <C-\><C-n>:wincmd h<CR>
" tnoremap <silent> <C-j> <C-\><C-n>:wincmd j<CR>
" tnoremap <silent> <C-k> <C-\><C-n>:wincmd k<CR>
" tnoremap <silent> <C-l> <C-\><C-n>:wincmd l<CR>

" " vimwiki
" let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
" let g:vimwiki_folding = 'list'
" let g:vimwiki_key_mappings = { 'global': 0 }

" lightline
let g:lightline = {
  \ 'colorscheme': 'base16_eighties',
  \ 'active': {
  \   'left': [
  \     [ 'mode', 'paste' ],
  \     [ 'gitbranch', 'readonly', 'filename', 'modified', 'cocstatus' ]
  \   ],
  \   'right':[
  \     [ 'lineinfo' ],
  \     [ 'percent' ],
  \     [ 'fileformat', 'fileencoding', 'filetype' ],
  \   ],
  \ },
  \ 'component_function': {
  \   'gitbranch': 'fugitive#head',
  \ },
\ }

" vimtex
let g:vimtex_quickfix_autoclose_after_keystrokes=1

" coc
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? coc#_select_confirm() :
"       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()

" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" let g:coc_snippet_next = '<tab>'

" xmap <silent> <Tab> <Plug>(coc-snippets-select)

" " coc
" nmap <silent> <leader>gd <Plug>(coc-definition)
" nmap <silent> <leader>gi <Plug>(coc-implementation)
" nmap <silent> <leader>gt <Plug>(coc-type-definition)
" nmap <silent> <leader>gc <Plug>(coc-declaration)
" nmap <silent> <leader>gr <Plug>(coc-references)

" nmap <silent> <leader>ca <Plug>(coc-codeaction)
" nmap <silent> <leader>cl <Plug>(coc-codelens-action)

" nmap <silent> <leader>rn <Plug>(coc-rename)
" nmap <silent> <leader>rf <Plug>(coc-refactor)

" latex
let g:tex_flavor = "latex"

" " sneak
" map f <Plug>Sneak_f
" map F <Plug>Sneak_F
" map t <Plug>Sneak_t
" map T <Plug>Sneak_T

" Goyo and Limelight
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" which-key
call which_key#register('<Space>', "g:which_key_map")
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :WhichKeyVisual '<Space>'<CR>
nnoremap <silent> <localleader> :WhichKey ','<CR>
vnoremap <silent> <localleader> :WhichKeyVisual ','<CR>
let g:which_key_map = {}
" By default timeoutlen is 1000 ms
set timeoutlen=250

" buffer shortcuts
nnoremap <silent> <leader>bn :bnext<CR>
nnoremap <silent> <leader>bp :bprevious<CR>
nnoremap <silent> <leader>bd :bdelete<CR>

let g:which_key_map.b = {
      \ 'name': '+buffer',
      \ 'n': 'next',
      \ 'p': 'previous',
      \ 'd': 'delete',
      \ }

" window manipulation
noremap <silent> <C-h> :wincmd h<CR>
noremap <silent> <C-j> :wincmd j<CR>
noremap <silent> <C-k> :wincmd k<CR>
noremap <silent> <C-l> :wincmd l<CR>
noremap <silent> <leader>wh :wincmd h<CR>
noremap <silent> <leader>wj :wincmd j<CR>
noremap <silent> <leader>wk :wincmd k<CR>
noremap <silent> <leader>wl :wincmd l<CR>
noremap <silent> <leader>wq :wincmd q<CR>
noremap <silent> <leader>wc :wincmd c<CR>
noremap <silent> <leader>ww :wincmd w<CR>

let g:which_key_map.w = {
      \ 'name': '+window',
      \ 'h': 'left',
      \ 'l': 'right',
      \ 'j': 'down',
      \ 'k': 'up',
      \ 'w': 'other',
      \ 'c': 'close',
      \ 'q': 'quit',
      \ }

" indentLine
let g:indentLine_char = '│'

" " nvim-treesitter
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

" telescope.nvim
" local full_theme = {
"   winblend = 20;
"   width = 0.8;
"   show_line = false;
"   prompt_prefix = 'TS Symbols>';
"   prompt_title = '';
"   results_title = '';
"   preview_title = '';
"   borderchars = {
"     prompt = {'▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' };
"     results = {'▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' };
"     preview = {'▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' };
"   };
" }

" nnoremap <leader>tele <cmd>lua require'telescope.builtin'.builtin{}<CR>
nnoremap <leader>ff <cmd>lua require'telescope.builtin'.find_files{}<CR>
nnoremap <leader>fg <cmd>lua require'telescope.builtin'.live_grep{}<CR>
nnoremap <leader>ft <cmd>lua require'telescope.builtin'.treesitter{}<CR>
nnoremap <leader>fb <cmd>lua require'telescope.builtin'.buffers{}<CR>

let g:which_key_map.f = {
      \ 'name': '+find',
      \ 'f': 'files',
      \ 'g': 'grep',
      \ 't': 'treesitter',
      \ 'b': 'buffers',
      \ }

" jupytext.vim
" let g:jupytext_command = 'notedown'
" let g:jupytext_fmt = 'markdown'
" let g:jupytext_to_ipynb_opts = '--to=notebook'

" nvim-lsp
nnoremap <silent> <leader>gd <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <leader>gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <leader>gr <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>

let g:which_key_map.g = {
      \ 'name': '+goto',
      \ 'd': 'declaration',
      \ 'i': 'implementation',
      \ 'r': 'references',
      \ }

" nvim-lspconfig
lua <<EOF
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.pyls_ms.setup{cmd={"python-language-server"}}
EOF

" completion-nvim
let g:completion_chain_complete_list = [
      \   {'complete_items' : ['lsp', 'path']},
      \   {'mode' : '<c-p>'},
      \   {'mode' : '<c-n>'}
      \ ]
      " \'vim' : [
"       \  {'complete_items': ['snippet']},
"       \  {'mode' : 'cmd'}
"       \  ],
"       \'rust' : [
"       \  {'complete_items': ['ts']}
"       \  ],
"       \'python' : [
"       \  {'complete_items': ['ts']}
"       \  ],
"       \'lua' : [
"       \  {'complete_items': ['ts']}
"       \  ],
"       \}

autocmd BufEnter * lua require'completion'.on_attach()

"" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

"" Avoid showing message extra message when using completion
set shortmess+=c

" nvim-treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
}
EOF

" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

" autocmd Syntax * normal zR

" set colorscheme
" lua << EOF
" local base16 = require 'base16'
" base16(base16.themes.eighties, true)
" EOF
