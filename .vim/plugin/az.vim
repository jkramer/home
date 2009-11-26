
" Check for AZ24 directories when opening something.
au BufWinEnter * call AZ24Mode()

" Check if we're somewhere below an 'allianz' directory and set appropriate
" options.
function! AZ24Mode()
	let path = expand("%:p")

	if stridx(path, "/allianz/") != -1
		" Follow indentation style guide.
		set expandtab
		set tabstop=2
		set shiftwidth=2

		" Always use ISO-8859-1?
		" set fileencoding=iso-8859-1
	endif


	" Detect Mason files.
	if stridx(path, "/bll/templates/") != -1 || stridx(path, "/tpl/") != -1
		set filetype=mason
	endif


	" .txt files in web/conf/default/konfig are actually Perl code (giant
	" hashes).
	if stridx(path, "/web/conf/default/konfig") != -1
		if bufname("%") =~ '.txt' 
			set filetype=perl
		endif
	endif
endf
