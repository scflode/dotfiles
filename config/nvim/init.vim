filetype off                  " required

" post installation hooks{{{
function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction
" }}} thanks fntlnz

" Install plugin manager
let shouldInstallBundles = 0

if !filereadable($HOME . "/.config/nvim/autoload/plug.vim")
  echo "~≥ Installing vim-plug \n"
  silent !curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !mkdir -p $HOME/.vim && ln -nsf $HOME/.config/nvim/autoload $HOME/.vim/autoload
  let shouldInstallBundles = 1
endif

call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-sensible'             " Sane defaults

Plug 'pgdouyon/vim-yin-yang'
Plug 'vim-airline/vim-airline'        " Status bar
Plug 'vim-airline/vim-airline-themes' " Themes for airline

Plug 'scrooloose/nerdtree'            " File browser
Plug 'Xuyuanp/nerdtree-git-plugin'    " Git integration for nerdtree
Plug 'airblade/vim-gitgutter'         " Git inline changes
Plug 'christoomey/vim-tmux-navigator' " Tmux integration
Plug 'christoomey/vim-tmux-runner'    " Tmux integration commamd runner
Plug 'moll/vim-bbye'                  " Close buffers but not windows

Plug 'editorconfig/editorconfig-vim'

Plug 'tpope/vim-fugitive'             " Git integration
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'               " Fuzzy search

Plug 'junegunn/goyo.vim'              " Distraction free writing
Plug 'jeetsukumaran/vim-indentwise'

Plug 'tpope/vim-projectionist'        " Relate patterns of files together

Plug 'tpope/vim-surround'
"Plug 'terryma/vim-expand-region'

Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

Plug 'janko-m/vim-test'               " Testing plugin for various languages

Plug 'othree/html5.vim'               " HTML 5 support
Plug 'mattn/emmet-vim'                " Emmet support

Plug 'neoclide/coc.nvim', {'branch': 'release'} " CoC
Plug 'yaegassy/coc-tailwindcss',  {'do': 'npm install && npm run build', 'branch': 'feat/support-v3-and-use-server-pkg'}

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Treesitter

call plug#end()

if shouldInstallBundles == 1
  echo "~> Installing plugs\n"
  :PlugInstall
endif

" General setup {{{
let mapleader=","
let g:maplocalleader='\\'

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set fillchars+=vert:\
set number
set relativenumber
" set ignorecase
set noswapfile
set hidden " Hidden buffers

" Enable persistent undo
let $VIMHOME=expand("<sfile>:p:h")
set undodir=$VIMHOME/.undo//
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
nnoremap <silent> <leader>cc :set colorcolumn=<C-R>=&colorcolumn != 0 ? 0 : 80<CR><CR>
nnoremap <silent> <leader><CR> :nohl<CR>
nnoremap <silent> <leader>cl :%s/ *$//g <bar> :nohl<CR>

inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))
" }}}

" Colorschemes {{{
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

set t_8b=[48;2;%lu;%lu;%lum
set t_8f=[38;2;%lu;%lu;%lum

set background=dark
"set background=light
"let g:one_allow_italics = 1
colorscheme yin

" Custom colors for one colorscheme
"call one#highlight('Normal', '', 'none', 'none')
"call one#highlight('nonText', '', 'none', 'none')
"call one#highlight('Comment', '', 'none', 'italic')
" }}}

" Airline setup {{{
let g:airline_theme = 'minimalist'
" }}}

" NERDTree setup {{{
map <leader>n :NERDTreeToggle<CR>
map <leader>l :NERDTreeFind<CR>

let g:NERDTreeWinPos = "right"
let g:NERDTreeWinSize = 48
let g:NERDTreeMinimalUI = 1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" }}}

" FZF setup {{{
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :GFiles?<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>s :Rg<CR>
let g:fzf_action = {
      \ 'ctrl-d': 'wall | bdelete',
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit' }
" }}}

" For conceal markers.
if has('conceal')
  set conceallevel=0 concealcursor=niv
endif
" }}}

" vim-markdown {{{
let g:vim_markdown_folding_disabled = 1
" }}}

" autoformat setup {{{
nnoremap <leader>ff :Autoformat<CR>
" }}}

" goyo setup {{{
nnoremap <leader>za :Goyo 120x120<CR>
nnoremap <leader>zd :Goyo<CR>
autocmd! User GoyoLeave silent! source $HOME/.vimrc
"}}}

" projectionist setup {{{
nnoremap <leader>aa :A<CR>
" }}}

" vim-test setup {{{
if has('nvim')
  let test#strategy = "neovim"
  let test#neovim#term_position = "belowright"

  tmap <C-o> <C-\><C-n>
endif

nnoremap <leader>r :w<CR>\|:TestNearest<CR>
nnoremap <leader>t :w<CR>\|:TestFile<CR>

nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>
" }}}

" open changed files setup {{{
function! OpenChangedFiles()
  only " Close all windows, unless they're modified
  let status = system('git status -s | grep "^ \?\(M\|A\|UU\)" | sed "s/^.\{3\}//"')
  let filenames = split(status, "\n")
  exec "edit " . filenames[0]
  for filename in filenames[1:]
    exec "sp " . filename
  endfor
endfunction
command! OpenChangedFiles :call OpenChangedFiles()
" }}}


" Rolodex setup {{{
"This function turns Rolodex Vim on or off for the current tab
"If turning off, it sets all windows to equal height
function! ToggleRolodexTab()
  if exists("t:rolodex_tab") > 0
    unlet t:rolodex_tab
    call ClearRolodexSettings()
    execute "normal \<C-W>="
  else
    let t:rolodex_tab = 1
    call SetRolodexSettings()
  endif
endfunction

"This function clears the Rolodex Vim settings and restores the previous values
function! ClearRolodexSettings()
  "Assume if one exists they all will
  if exists("g:remember_ea") > 0
    let &equalalways=g:remember_ea
    let &winheight=g:remember_wh
    let &winminheight=g:remember_wmh
    let &helpheight=g:remember_hh
  endif
endfunction

"This function set the Rolodex Vim settings and remembers the previous values for later
function! SetRolodexSettings()
  if exists("t:rolodex_tab") > 0
    let g:remember_ea=&equalalways
    let g:remember_wh=&winheight
    let g:remember_wmh=&winminheight
    let g:remember_hh=&helpheight
    set noequalalways winminheight=0 winheight=9999 helpheight=9999
  endif
endfunction

"These two autocmds make Vim change the settings whenever a new tab is selected
"We have to use TabLeave to always clear them.  If we try and turn them off
"in TabEnter, it is too late ( I think, since WinEnter has already been called and triggered the display)
au TabLeave * call ClearRolodexSettings()
au TabEnter * call SetRolodexSettings()

"With this mapping, it toggles a tab to be Rolodex style
noremap <leader>z :call ToggleRolodexTab()<CR>
" }}}

" CoC setup {{{

let g:coc_global_extensions = [
\ 'coc-ultisnips',
\ 'coc-json',
\ 'coc-tsserver',
\ 'coc-html',
\ 'coc-css',
\ 'coc-yaml',
\ 'coc-elixir',
\ 'coc-prettier',
\ 'coc-flutter',
\ 'coc-phpls',
\ 'coc-pyright',
\ ]

let g:coc_filetype_map = {
  \ 'twig': 'html',
  \ }
autocmd BufEnter *.html.twig :set ft=html

" Scroll floating window
nnoremap <expr><C-f> coc#float#has_float() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <expr><C-b> coc#float#has_float() ? coc#float#scroll(0) : "\<C-b>"

set completeopt=longest,menuone,preview,noinsert

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
"autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>ff  <Plug>(coc-format-selected)
nmap <leader>ff  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  "autocmd! BufWritePre * Format
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

imap <c-s>       <Plug>(coc-snippets-expand)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <C-d> <Plug>(coc-range-select)
xmap <silent> <C-d> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Coc Prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" }}}

" Emmet settings {{{
let g:user_emmet_leader_key='<Leader>x'
" }}}

" Custom filetypes {{{
" Set the filetype based on the file's extension, overriding any
" 'filetype' that has already been set
au BufRead,BufNewFile *.sface set filetype=eelixir
" }}}

" Treesitter {{{
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  highlight = {
    enable = true,              -- false will disable the whole extension
    additional_vim_regex_highlighting = true, -- Fix indentation for PHP
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "+",
      scope_incremental = "grc",
      node_decremental = "-",
    },
  },
}
EOF
" }}}
