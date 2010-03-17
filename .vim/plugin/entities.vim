" ****************************************************************************
" File:             entities.vim
" Author:           Jonas Kramer
" Version:          0.1
" Last Modified:    2010-03-08
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


fu! entities#EscapeGerman(rb, re)
	silent! exe ":" . a:rb . "," . a:re . "s#Ä#\\&Auml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#Ö#\\&Ouml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#Ü#\\&Uuml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#ä#\\&auml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#ö#\\&ouml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#ü#\\&uuml;#g"
	silent! exe ":" . a:rb . "," . a:re . "s#ß#\\&szlig;#g"
endf

fu! entities#UnescapeGerman(rb, re)
	silent! exe ":" . a:rb . "," . a:re . "s#&Auml;#Ä#g"
	silent! exe ":" . a:rb . "," . a:re . "s#&Ouml;#Ö#g"
	silent! exe ":" . a:rb . "," . a:re . "s#&Uuml;#Ü#g"
	silent! exe ":" . a:rb . "," . a:re . "s#&auml;#ä#g"
	silent! exe ":" . a:rb . "," . a:re . "s#&ouml;#ö#g"
	silent! exe ":" . a:rb . "," . a:re . "s#&uuml;#ü#g"
	silent! exe ":" . a:rb . "," . a:re . "s#&szlig;#ß#g"
endf

command! -bar -range EscapeGerman call entities#EscapeGerman(<line1>, <line2>)
command! -bar -range UnescapeGerman call entities#UnescapeGerman(<line1>, <line2>)

let &cpoptions = s:savedOptions
unlet s:savedOptions

let g:loadedEntities = 1
