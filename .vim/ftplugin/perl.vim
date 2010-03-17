
if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1


" Make sure the continuation lines below do not cause problems in
" compatibility mode.
let s:save_cpo = &cpo
set cpo-=C

let perl_fold = 1
let perl_nofold_packages = 1

" Automatically fold Perl source.
set foldmethod=syntax

" Search for Perl modules locally.
let perlpath = ".,,"
let &l:path=perlpath

set isfname+=:
setlocal iskeyword=48-57,_,A-Z,a-z,:

setlocal formatoptions+=crq
setlocal keywordprg=perldoc

setlocal comments=:#
setlocal commentstring=#%s

" Provided by Ned Konz <ned at bike-nomad dot com>
"---------------------------------------------
setlocal include=\\<\\(use\\\|require\\)\\>
setlocal includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','.pm','')
setlocal define=[^A-Za-z_]


" Restore the saved compatibility options.
let &cpo = s:save_cpo
