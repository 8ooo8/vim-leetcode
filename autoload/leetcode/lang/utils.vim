let s:lang_dir_path = expand('<sfile>:p:h')
let s:this_script_name = substitute(expand('<sfile>:t'), '.vim$', '', '')
let s:langs = split(globpath(fnameescape(s:lang_dir), '*.vim'), '\n')
cal map(s:langs, {key, val -> substitute(val, '.*\' .g:leetcode_path_delimit .'\(.\{-}\)\.vim$', '\1', 'g')})
cal filter(s:langs, 'v:val != ''' .s:this_script_name .'''')

fu! leetcode#lang#utils#langIsSupported(lang)
  if index(s:langs, a:lang) >= 0
    retu 1
  el
    retu 0
  en
endfu

fu! leetcode#lang#utils#commentDependencies()
  exe 'cal leetcode#lang#' .g:leetcode_lang .'#commentDependencies()'
endfu

fu! leetcode#lang#utils#uncommentDependencies()
  exe 'cal leetcode#lang#' .g:leetcode_lang .'#uncommentDependencies()'
endfu

fu! leetcode#lang#utils#addDependencies()
  exe 'cal leetcode#lang#' .g:leetcode_lang .'#addDependencies()'
endfu

fu! leetcode#lang#utils#foldDependencies()
  exe 'cal leetcode#lang#' .g:leetcode_lang .'#foldDependencies()'
endfu

fu! leetcode#lang#utils#goToWhereCodeBegins()
  exe 'cal leetcode#lang#' .g:leetcode_lang .'#goToWhereCodeBegins()'
endfu
