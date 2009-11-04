" AlignMaps:   Alignment maps based upon <Align.vim>
" Maintainer:  Dr. Charles E. Campbell, Jr. <Charles.Campbell@gsfc.nasa.gov>
" Date:        Mar 06, 2008
" Version:     39
"
" NOTE: the code herein needs vim 6.0 or later
"                       needs <Align.vim> v6 or later
"                       needs <cecutil.vim> v5 or later
" Copyright:    Copyright (C) 1999-2007 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               AlignMaps.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Usage: {{{1
" Use 'a to mark beginning of to-be-aligned region,   Alternative:  use v
" move cursor to end of region, and execute map.      (visual mode) to mark
" The maps also set up marks 'y and 'z, and retain    region, execute same map.
" 'a at the beginning of region.                      Uses 'a, 'y, and 'z.
"
" Although the comments indicate the maps use a leading backslash,
" actually they use <Leader> (:he mapleader), so the user can
" specify that the maps start how he or she prefers.
"
" Note: these maps all use <Align.vim>.
"
" Romans 1:20 For the invisible things of Him since the creation of the {{{1
" world are clearly seen, being perceived through the things that are
" made, even His everlasting power and divinity; that they may be
" without excuse.
" ---------------------------------------------------------------------

" Load Once: {{{1
if exists("g:loaded_alignmaps") || &cp
 finish
endif
let g:loaded_alignmaps = "v39"
let s:keepcpo          = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" WS: wrapper start map (internal)  {{{1
" Produces a blank line above and below, marks with 'y and 'z
if !hasmapto('<Plug>WrapperStart')
 nmap <unique> <SID>WS	<Plug>AlignMapsWrapperStart
endif
nmap <silent> <script> <Plug>AlignMapsWrapperStart	:set lz<CR>:call AlignWrapperStart()<CR>

" ---------------------------------------------------------------------
" AlignWrapperStart: {{{1
fun! AlignWrapperStart()
"  call Dfunc("AlignWrapperStart()")

  if line("'y") == 0 || line("'z") == 0 || !exists("s:alignmaps_wrapcnt") || s:alignmaps_wrapcnt <= 0
"   call Decho("wrapper initialization")
   let s:alignmaps_wrapcnt    = 1
   let s:alignmaps_keepgd     = &gdefault
   let s:alignmaps_keepsearch = @/
   let s:alignmaps_keepch     = &ch
   let s:alignmaps_keepmy     = SaveMark("'y")
   let s:alignmaps_keepmz     = SaveMark("'z")
   let s:alignmaps_posn       = SaveWinPosn(0)
   " set up fencepost blank lines
   put =''
   norm! mz'a
   put! =''
   ky
   let s:alignmaps_zline      = line("'z")
   exe "'y,'zs/@/\177/ge"
  else
"   call Decho("embedded wrapper")
   let s:alignmaps_wrapcnt    = s:alignmaps_wrapcnt + 1
   norm! 'yjma'zk
  endif

  " change some settings to align-standard values
  set nogd
  set ch=2
  AlignPush
  norm! 'zk
"  call Dret("AlignWrapperStart : alignmaps_wrapcnt=".s:alignmaps_wrapcnt." my=".line("'y")." mz=".line("'z"))
endfun

" ---------------------------------------------------------------------
" WE: wrapper end (internal)   {{{1
" Removes guard lines, restores marks y and z, and restores search pattern
if !hasmapto('<Plug>WrapperEnd')
 nmap <unique> <SID>WE	<Plug>AlignMapsWrapperEnd
endif
nmap <silent> <script> <Plug>AlignMapsWrapperEnd	:call AlignWrapperEnd()<CR>:set nolz<CR>

" ---------------------------------------------------------------------
" AlignWrapperEnd:	{{{1
fun! AlignWrapperEnd()
"  call Dfunc("AlignWrapperEnd() alignmaps_wrapcnt=".s:alignmaps_wrapcnt." my=".line("'y")." mz=".line("'z"))

  " remove trailing white space introduced by whatever in the modification zone
  'y,'zs/ \+$//e

  " restore AlignCtrl settings
  AlignPop

  let s:alignmaps_wrapcnt= s:alignmaps_wrapcnt - 1
  if s:alignmaps_wrapcnt <= 0
   " initial wrapper ending
   exe "'y,'zs/\177/@/ge"

   " if the 'z line hasn't moved, then go ahead and restore window position
   let zstationary= s:alignmaps_zline == line("'z")

   " remove fencepost blank lines.
   " restore 'a
   norm! 'yjmakdd'zdd

   " restore original 'y, 'z, and window positioning
   call RestoreMark(s:alignmaps_keepmy)
   call RestoreMark(s:alignmaps_keepmz)
   if zstationary > 0
    call RestoreWinPosn(s:alignmaps_posn)
"    call Decho("restored window positioning")
   endif

   " restoration of options
   let &gd= s:alignmaps_keepgd
   let &ch= s:alignmaps_keepch
   let @/ = s:alignmaps_keepsearch

   " remove script variables
   unlet s:alignmaps_keepch
   unlet s:alignmaps_keepsearch
   unlet s:alignmaps_keepmy
   unlet s:alignmaps_keepmz
   unlet s:alignmaps_keepgd
   unlet s:alignmaps_posn
  endif

"  call Dret("AlignWrapperEnd : alignmaps_wrapcnt=".s:alignmaps_wrapcnt." my=".line("'y")." mz=".line("'z"))
endfun

" ---------------------------------------------------------------------
if exists("g:alignmaps_usanumber")
	" map <silent> <Leader>anum  <SID>WS
	"	\:'a,'zs/\([-+]\)\=\(\d\+\%([eE][-+]\=\d\+\)\=\)\ze\%($\|[^@]\)/@\1@\2@@#/ge<CR>
	"	\:'a,'zs/\([-+]\)\=\(\d*\)\(\.\)\(\d*\([eE][-+]\=\d\+\)\=\)/@\1@\2@\3@\4#/ge<CR>
	"    \:AlignCtrl mp0P0r<CR>
	"    \:'a,'zAlign [@#]<CR>
	"    \:'a,'zs/@//ge<CR>
	"    \:'a,'zs/#/ /ge<CR>
	"    \<SID>WE
	map <silent> <Leader>anum  <SID>WS:'a,'zs/\([0-9.]\)\s\+\zs\([-+]\=\d\)/@\1/ge<CR>
				\:'a,'zs/\.@/\.0@/ge<CR>
				\:AlignCtrl mp0P0r<CR>
				\:'a,'zAlign [.@]<CR>
				\:'a,'zs/@/ /ge<CR>
				\:'a,'zs/\(\.\)\(\s\+\)\([0-9.,eE+]\+\)/\1\3\2/ge<CR>
				\:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR>
				\<SID>WE
elseif exists("g:alignmaps_euronumber")
	map <silent> <Leader>anum  <SID>WS:'a,'zs/\([0-9.]\)\s\+\([-+]\=\d\)/\1@\2/ge<CR>:'a,'zs/\.@/\.0@/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [,@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(,\)\(\s\+\)\([-0-9.,eE+]\+\)/\1\3\2/ge<CR>:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR><SID>WE
else
	map <silent> <Leader>anum  <SID>WS:'a,'zs/\([0-9.]\)\s\+\([-+]\=[.,]\=\d\)/\1@\2/ge<CR>:'a,'zs/\.@/\.0@/ge<CR>:AlignCtrl mp0P0<CR>:'a,'zAlign [.,@]<CR>:'a,'zs/\([-0-9.,]*\)\(\s*\)\([.,]\)/\2\1\3/g<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR><SID>WE
endif
map <silent> <Leader>aunum  <SID>WS:'a,'zs/\([0-9.]\)\s\+\([-+]\=\d\)/\1@\2/ge<CR>:'a,'zs/\.@/\.0@/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [.@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(\.\)\(\s\+\)\([-0-9.,eE+]\+\)/\1\3\2/ge<CR>:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR><SID>WE
map <silent> <Leader>aenum  <SID>WS:'a,'zs/\([0-9.]\)\s\+\([-+]\=\d\)/\1@\2/ge<CR>:'a,'zs/\.@/\.0@/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [,@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(,\)\(\s\+\)\([-0-9.,eE+]\+\)/\1\3\2/ge<CR>:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR><SID>WE

" ---------------------------------------------------------------------
" html table alignment	{{{1
" map <silent> <Leader>Htd <SID>WS:'y,'zs%<[tT][rR]><[tT][dD][^>]\{-}>\<Bar></[tT][dD]><[tT][dD][^>]\{-}>\<Bar></[tT][dD]></[tT][rR]>%@&@%g<CR>'yjma'zk:AlignCtrl m=Ilp1P0 @<CR>:'a,.Align<CR>:'y,'zs/ @/@/<CR>:'y,'zs/@ <[tT][rR]>/<[tT][rR]>/ge<CR>:'y,'zs/@//ge<CR><SID>WE

" ---------------------------------------------------------------------
" character-based left-justified alignment maps {{{1
" ---------------------------------------------------------------------
" plain Align maps; these two are used in <Leader>acom..\afnc	{{{1

" ---------------------------------------------------------------------
" Joiner : maps used above	{{{1

" ---------------------------------------------------------------------
" Menu Support: {{{1
"   ma ..move.. use menu
"   v V or ctrl-v ..move.. use menu
if has("menu") && has("gui_running") && &go =~ 'm' && !exists("s:firstmenu")
	let s:firstmenu= 1
	if !exists("g:DrChipTopLvlMenu")
		let g:DrChipTopLvlMenu= "DrChip."
	endif
	if g:DrChipTopLvlMenu != ""
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.<<\ and\ >>	<Leader>a<'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Assignment\ =	<Leader>t='
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Assignment\ :=	<Leader>a='
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Backslashes	<Leader>tml'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Breakup\ Comma\ Declarations	<Leader>a,'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.C\ Comment\ Box	<Leader>abox'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Commas	<Leader>t,'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Commas	<Leader>ts,'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Commas\ With\ Strings	<Leader>tsq'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Comments	<Leader>acom'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Comments\ Only	<Leader>aocom'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Declaration\ Comments	<Leader>adcom'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Declarations	<Leader>adec'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Definitions	<Leader>adef'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Function\ Header	<Leader>afnc'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Html\ Tables	<Leader>Htd'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.(\.\.\.)?\.\.\.\ :\ \.\.\.	<Leader>a?'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Numbers	<Leader>anum'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Numbers\ (American-Style)	<Leader>aunum	<Leader>aunum'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Numbers\ (Euro-Style)	<Leader>aenum'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Spaces\ (Left\ Justified)	<Leader>tsp'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Spaces\ (Right\ Justified)	<Leader>Tsp'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Statements\ With\ Percent\ Style\ Comments	<Leader>m='
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ <	<Leader>t<'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ \|	<Leader>t|'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ @	<Leader>t@'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ #	<Leader>t#'
		exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Tabs	<Leader>tab'
	endif
endif

" ---------------------------------------------------------------------
" CharJoiner: joins lines which end in the given character (spaces {{{1
"             at end are ignored)
fun! <SID>CharJoiner(chr)
	"  call Dfunc("CharJoiner(chr=".a:chr.")")
	let aline = line("'a")
	let rep   = line(".") - aline
	while rep > 0
		norm! 'a
		while match(getline(aline),a:chr . "\s*$") != -1 && rep >= 0
			" while = at end-of-line, delete it and join with next
			norm! 'a$
			j!
			let rep = rep - 1
		endwhile
		" update rep(eat) count
		let rep = rep - 1
		if rep <= 0
			" terminate loop if at end-of-block
			break
		endif
		" prepare for next line
		norm! jma
		let aline = line("'a")
	endwhile
	"  call Dret("CharJoiner")
endfun

" ---------------------------------------------------------------------
" s:Equals: {{{2
fun! s:Equals()
	"  call Dfunc("s:Equals()")
	'a,'zs/\s\+\([*/+\-%|&\~^]\==\)/ \1/e
	'a,'zs@ \+\([*/+\-%|&\~^]\)=@\1=@ge
	'a,'zs/==/\="\<Char-0xff>\<Char-0xff>"/ge
	'a,'zs/!=/\="!\<Char-0xff>"/ge
	norm g'zk
	AlignCtrl mIp1P1=l =
	AlignCtrl g =
	'a,'z-1Align
	'a,'z-1s@\([*/+\-%|&\~^!=]\)\( \+\)=@\2\1=@ge
	'a,'z-1s/\( \+\);/;\1/ge
	if &ft == "c" || &ft == "cpp"
		'a,'z-1v/^\s*\/[*/]/s/\/[*/]/@&@/e
		'a,'z-1v/^\s*\/[*/]/s/\*\//@&/e
		exe norm "'zk<Leader>t@"
		'y,'zs/^\(\s*\) @/\1/e
	endif
	'a,'z-1s/<Char-0xff>/=/ge
	'y,'zs/ @//eg
	"  call Dret("s:Equals")
endfun

" ---------------------------------------------------------------------
" Afnc: useful for splitting one-line function beginnings {{{1
"            into one line per argument format
fun! s:Afnc()
	"  call Dfunc("Afnc()")

	" keep display quiet
	let chkeep = &ch
	let gdkeep = &gd
	let vekeep = &ve
	set ch=2 nogd ve=

	" will use marks y,z ; save current values
	let mykeep = SaveMark("'y")
	let mzkeep = SaveMark("'z")

	" Find beginning of function -- be careful to skip over comments
	let cmmntid  = synIDtrans(hlID("Comment"))
	let stringid = synIDtrans(hlID("String"))
	exe "norm! ]]"
	while search(")","bW") != 0
		"   call Decho("line=".line(".")." col=".col("."))
		let parenid= synIDtrans(synID(line("."),col("."),1))
		if parenid != cmmntid && parenid != stringid
			break
		endif
	endwhile
	norm! %my
	s/(\s*\(\S\)/(\r  \1/e
	exe "norm! `y%"
	s/)\s*\(\/[*/]\)/)\r\1/e
	exe "norm! `y%mz"
	'y,'zs/\s\+$//e
	'y,'zs/^\s\+//e
	'y+1,'zs/^/  /

	" insert newline after every comma only one parenthesis deep
	sil! exe "norm! `y\<right>h"
	let parens   = 1
	let cmmnt    = 0
	let cmmntline= -1
	while parens >= 1
		"   call Decho("parens=".parens." @a=".@a)
		exe 'norm! ma "ay`a '
		if @a == "("
			let parens= parens + 1
		elseif @a == ")"
			let parens= parens - 1

			" comment bypass:  /* ... */  or //...
		elseif cmmnt == 0 && @a == '/'
			let cmmnt= 1
		elseif cmmnt == 1
			if @a == '/'
				let cmmnt    = 2   " //...
				let cmmntline= line(".")
			elseif @a == '*'
				let cmmnt= 3   " /*...
			else
				let cmmnt= 0
			endif
		elseif cmmnt == 2 && line(".") != cmmntline
			let cmmnt    = 0
			let cmmntline= -1
		elseif cmmnt == 3 && @a == '*'
			let cmmnt= 4
		elseif cmmnt == 4
			if @a == '/'
				let cmmnt= 0   " ...*/
			elseif @a != '*'
				let cmmnt= 3
			endif

		elseif @a == "," && parens == 1 && cmmnt == 0
			exe "norm! i\<CR>\<Esc>"
		endif
	endwhile
	norm! `y%mz%
	sil! 'y,'zg/^\s*$/d

	" perform substitutes to mark fields for Align
	sil! 'y+1,'zv/^\//s/^\s\+\(\S\)/  \1/e
	sil! 'y+1,'zv/^\//s/\(\S\)\s\+/\1 /eg
	sil! 'y+1,'zv/^\//s/\* \+/*/ge
	"                                                 func
	"                    ws  <- declaration   ->    <-ptr  ->   <-var->    <-[array][]    ->   <-glop->      <-end->
	sil! 'y+1,'zv/^\//s/^\s*\(\(\K\k*\s*\)\+\)\s\+\([(*]*\)\s*\(\K\k*\)\s*\(\(\[.\{-}]\)*\)\s*\(.\{-}\)\=\s*\([,)]\)\s*$/  \1@#\3@\4\5@\7\8/e
	sil! 'y+1,'z+1g/^\s*\/[*/]/norm! kJ
	sil! 'y+1,'z+1s%/[*/]%@&@%ge
	sil! 'y+1,'z+1s%*/%@&%ge
	AlignCtrl mIp0P0=l @
	sil! 'y+1,'zAlign
	sil! 'y,'zs%@\(/[*/]\)@%\t\1 %e
	sil! 'y,'zs%@\*/% */%e
	sil! 'y,'zs/@\([,)]\)/\1/
	sil! 'y,'zs/@/ /
	AlignCtrl mIlrp0P0= # @
	sil! 'y+1,'zAlign
	sil! 'y+1,'zs/#/ /
	sil! 'y+1,'zs/@//
	sil! 'y+1,'zs/\(\s\+\)\([,)]\)/\2\1/e

	" Restore
	call RestoreMark(mykeep)
	call RestoreMark(mzkeep)
	let &ch= chkeep
	let &gd= gdkeep
	let &ve= vekeep

	"  call Dret("Afnc")
endfun

" ---------------------------------------------------------------------
"  FixMultiDec: converts a   type arg,arg,arg;   line to multiple lines {{{1
fun! s:FixMultiDec()
	"  call Dfunc("FixMultiDec()")

	" save register x
	let xkeep   = @x
	let curline = getline(".")
	"  call Decho("curline<".curline.">")

	" Get the type.  I'm assuming one type per line (ie.  int x; double y;   on one line will not be handled properly)
	let @x=substitute(curline,'^\(\s*[a-zA-Z_ \t][a-zA-Z0-9_ \t]*\)\s\+[(*]*\h.*$','\1','')
	"  call Decho("@x<".@x.">")

	" transform line
	exe 's/,/;\r'.@x.' /ge'

	"restore register x
	let @x= xkeep

	"  call Dret("FixMultiDec : my=".line("'y")." mz=".line("'z"))
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" ------------------------------------------------------------------------------
" vim: ts=4 nowrap fdm=marker
