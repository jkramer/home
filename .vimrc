
set tabstop=4 shiftwidth=4
set autoindent modeline
set backspace=indent,eol,start
set ignorecase smartcase fdm=marker

set nobackup

syntax enable

colorscheme xoria256

filetype plugin on
filetype indent on

set mouse=v
set diffopt=filler,vertical

" Map CTRL+c on ESC - easier/faster to type.
map <C-c> <esc>

" gc shows/hides the tag list.
map gc :TlistToggle<cr>

" CTRL+b opens buffer explorer.
map <C-b> <esc>:BufExplorer<cr>

" gz deletes current buffer, gb and gB jump to the next/previous buffer.
map gz :Bclose<cr>
map gb :bnext<cr>
map gB :bprev<cr>

" gt/gT jump to the next/previous tag. Who needs tabs, anyway?
map gt :tnext<cr>zz
map gT :tprev<cr>zz

" Jump to last location before tag jump.
map <C-p> :pop<cr>

" Unhighlight search matches.
map <C-h> <esc>:nohlsearch<cr>
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Fix for jumping to Perl modules with gf when theres a method call
" (Package::Name->foo) appended.
set isfname-=-
set iskeyword-=:

set hidden cot=preview

au BufRead,BufNewFile COMMIT_EDITMSG setf git

" RST setup. \[Ee] and g[eE] jump to the next/previous match.
set grepprg=rst\ -c
map <Leader>e :cn<cr>
map <Leader>E :cp<cr>
map ge :cn<cr>zz
map gE :cp<cr>zz

" Enable 256 colors.
if $TERM == "rxvt-unicode" || $TERM == "screen-bce"
	set t_Co=256
endif

" Enable closetag plugin for HTML and XML.
au Filetype html,xml,xsl source ~/.vim/ftplugin/closetag.vim
let g:closetag_html_style=1 


" Get VCS Command key maps out of the way.
let VCSCommandMapPrefix = '<Leader>vv'
nnoremap <Leader>vd :VCSVimDiff<CR>
nnoremap <Leader>vo :VCSGotoOriginal!<CR>

" Jump to next/previous difference in a diffed buffer.
nnoremap cd ]czz
nnoremap cD [czz

set nofoldenable

" FuzzyFinder setup.
let g:fuf_abbrevMap = { ' ' : ['*']}
map <leader>f :FufTag!<cr>
map <leader>F :FufFile!<cr>
map <leader>m :FufMruFile<cr>

let omni_sql_no_default_maps = 1

" Spaces at the end of a line are errors (or at least editing fails - mostly
" from eclipse users...).
highlight ExtraWhitespace ctermbg=88
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/


" Use tags file from the project root (works best with a local .zshrc file -
" check ~/.zsh/func/magic). Also source another local .vimrc if available.
if exists("$BASE") && $BASE != $HOME
	set tags=$BASE/tags

	if filereadable($BASE . "/.vimrc")
		source $BASE/.vimrc
	endif
endif


autocmd BufNewFile,BufRead *.p6 setf perl6
