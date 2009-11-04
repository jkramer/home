" description:	a simple line-based commenting toggler
"  maintainer:	kamil.stachowski@gmail.com
"     license:	gpl 3+
"     version:	0.2 (2008.11.11)

" changelog:
"		0.2:	2008.11.11
"				improved whitespace handling
"				added languages: apache, asterisk, c, cfg, clean, cmake, css, d, debcontrol, diff, dtml, euphoria, foxpro, groovy, grub, htmldjango, htmlm4, lex, lhaskell, lilo, make, natural, nemerle, objc, objcpp, ,plsql, rexx, sas, scala, sed, sieve, sgml, xf86conf, xhtml, xquery, xsd, yacc, xhtml (total 93)
"		0.1:	2008.11.08
"				initial version
"
" TODO: do sth about block comments
" TODO: better guessing for undefined languages
" TODO: add support for scheme's multiple ;'s



" ===============================================================================================================================

" make sure the plugin hasn't been loaded yet and save something
if exists("g:loaded_commentToggle") || &cp
	finish
endif
let g:loaded_commentToggle = "v0.2"
let s:cpoSave = &cpo
set cpo&vim

" -------------------------------------------------------------------------------------------------------------------------------

" assign a shortcut
if !hasmapto('<Plug>CommentToggle')
	map <unique> <Leader>c <Plug>CommentToggle
endif
noremap <silent> <unique> <script> <Plug>CommentToggle :call <SID>CommentToggle()<CR>
noremenu <script> Plugin.Add\ CommentToggle <SID>CommentToggle

" and a command just in case
if !exists(":commentToggle")
command -nargs=1 CommentToggle :call s:CommentToggle()
endif

" ===============================================================================================================================

" all languages are defined as a list with the comment opening string in position 0 and the closing string in position 1
" languages which support single line comments simply have an empty string in position 1
let s:commStrings = {"abap":['\*',''], "abc":['%',''], "ada":['--',''], "apache":['#',''], "asterisk":[';',''], "awk":['#',''], "basic":['rem',''], "bcpl":['//',''], "c":['//',''], "cecil":['--',''], "cfg":['#',''], "clean":['//',''], "cmake":['#',''], "cobol":['\*',''], "cpp":['//',''], "cs":['//',''], "css":['/\*','\*/'], "d":['//',''], "debcontrol":['#',''], "diff":['#',''], "dtml":['<!--','-->'], "dylan":['//',''], "e":['#',''], "eiffel":['--',''], "erlang":['%',''], "euphora":['--',''], "forth":['\',''], "fortan":['C ',''], "foxpro":['\*',''], "fs":['//',''], "groovy":['//',''], "grub":['#',''], "icon":['#',''], "io":['#',''], "j":['NB.',''], "java":['//',''], "javascript":['//',''], "haskell":['--',''], "html":['<!--','-->'], "htmldjango":['<!--','-->'], "htmlm4":['<!--','-->'], "lex":['//',''], "lhaskell":['%',''], "lilo":['#',''], "lisp":[';',''], "logo":[';',''], "lua":['--',''], "make":['#',''], "matlab":['%',''], "maple":['#',''], "merd":['#',''], "mma":['(\*','\*)'], "modula3":['(\*','\*)'], "mumps":[';',''], "natural":['\*',''], "nemerle":['//',''], "objc":['//',''], "objcpp":['//',''], "ocaml":['(\*','\*)'], "oz":['%',''], "pascal":['{','}'], "perl":['#',''], "php":['//',''], "pike":['//',''], "pliant":['#',''], "plsql":['--',''], "postscr":['%',''], "prolog":['%',''], "python":['#',''], "rebol":[';',''], "rexx":['/\*','\*/'], "ruby":['#',''], "sas":['/\*','\*/'], "sather":['--',''], "scala":['//',''], "scheme":[';',''], "sed":['#',''], "sgml":['<!--','-->'], "sh":['#',''], "sieve":['#',''], "simula":['--',''], "sql":['--',''], "st":['"','"'], "tcl":['#',''], "tex":['%',''], "vhdl":['--',''], "vim":['"',''], "xf86conf":['#',''], "xhtml":['<!--','-->'], "xml":['<!--','-->'], "xquery":['<!--','-->'], "xsd":['<!--','-->'], "yacc":['//',''], "yaml":['#',''], "ycp":['//',''], "yorick":['//','']}

" ===============================================================================================================================

" check if line aLineNr begins with string
function! s:CommentCheckCommented(aLineNr, aCommStr)
	" check if the line begins with the comment opening string, ignoring whitespace
	return match(getline(a:aLineNr), '^\s*' . a:aCommStr[0]) == ""
endfunction

" -------------------------------------------------------------------------------------------------------------------------------

" find the comment string for syntax aSynCurr
function! s:CommentCheckString(aSynCurr)
	if has_key(s:commStrings, a:aSynCurr)
		" if we have the comment strings for the current syntax defined, take those
		return s:commStrings[a:aSynCurr]
	else
		" TODO:	doesn't work for all syntaxes
		"	i don't know how to properly extract the comment string for the current syntax; &comments is probably not the way
		" check &comments and extract the one without any flags; alas, it's not always the string we're looking for
		let s:result = ""
		for s:tmp in split(&comments, ",")
			if s:tmp[0] == ":"
				let s:result = s:tmp[1:-1]
				break
			endif
		endfor
		return [s:result, ""]
	endif
endfunction

" -------------------------------------------------------------------------------------------------------------------------------

" the main part
" 	finds the comment string for the current syntax, and if the current line is already commented;
" 	if it is, it uncomments it; if it's not, it uncomments it
function! s:CommentToggle()
	let s:commStr = s:CommentCheckString(&syntax)
	let s:commed = s:CommentCheckCommented(line("."), s:commStr)
	if match(getline(line(".")), '\S') != -1						" no point commenting empty lines
		call s:CommentToggleHelper(line("."), s:commStr, s:commed)
	endif
endfunction

" -------------------------------------------------------------------------------------------------------------------------------

" toggles comment on line aLineNr with string aCommStr depending on whether the line is already commented (aCommed)
function! s:CommentToggleHelper(aLineNr, aCommStr, aCommed)
	if a:aCommed
		let s:tmpToBeSubsted = '\(\s*\)' . a:aCommStr[0] . '\(\s*\)\(.\{-}\)\(\s*\)' . a:aCommStr[1]
		let s:tmpToSubst = '\1\3'							" remove the comment string(s) and all superfluous whitespace (hence greedy match in \3)
	else
		let s:tmpToBeSubsted='\(\s*\)\(.*\)'" leave the whitespace in the beginning untouched
		let s:tmpToSubst = '\1' . a:aCommStr[0] . ' \2'		"	add extra spaces inside the comment string
		if a:aCommStr[1] != ""								"	but not after it in case the language supports single line comments
			let s:tmpToSubst = s:tmpToSubst . ' ' . a:aCommStr[1]
		endif
	endif
	call setline(a:aLineNr, substitute(getline(a:aLineNr), s:tmpToBeSubsted, s:tmpToSubst, ""))
endfunction


" ===============================================================================================================================


let &cpo = s:cpoSave
unlet s:cpoSave
