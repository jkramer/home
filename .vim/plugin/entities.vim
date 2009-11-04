" ****************************************************************************
" File:             entities.vim
" Author:           Jonas Kramer
" Version:          0.1
" Last Modified:    2009-08-20
" Copyright:        Copyright (C) 2009 by Jonas Kramer. Published under the
"                   terms of the Artistic License 2.0.
" ****************************************************************************
" Installation: Copy this script into your plugin folder.
" Usage: ...
" ****************************************************************************

if exists('g:loadedEntities')
	finish
endif

let s:savedOptions = &cpoptions
set cpoptions&vim


fu! entities#EscapeHTML(rb, re)
	call entities#EscapeGerman(rb, re)
	" ...
endf


fu! entities#EscapeHTMLSpecial(rb, re)
	silent! exe ":" . a:rb . "," . a:re . "s#Ä#\\&Auml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#Ö#\\&Ouml;#g"
endf


fu! entities#EscapeGerman(rb, re)
	silent! exe ":" . a:rb . "," . a:re . "s#Ä#\\&Auml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#Ö#\\&Ouml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#Ü#\\&Uuml;#g"

	silent! exe ":" . a:rb . "," . a:re . "s#ä#\\&auml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#ö#\\&ouml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#ü#\\&uuml;#g"

	silent! exe ":" . a:rb . "," . a:re . "s#ß#\&szlig;#g"
endf

command! -bar -range EscapeHTML call entities#EscapeHTML(<line1>, <line2>)
command! -bar -range EscapeGerman call entities#EscapeGerman(<line1>, <line2>)

let &cpoptions = s:savedOptions
unlet s:savedOptions

let g:loadedEntities = 1
