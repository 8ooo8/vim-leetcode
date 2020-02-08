let s:lang_dir = expand('<sfile>:p:h')
let s:this_script_name = expand('<sfile>:t')
let s:langs = split(globpath(s:lang_dir, '*.vim'), '\n')
cal filter(s:langs, 'v:val !~ "\' .g:leetcode_path_delimit .s:this_script_name .'"')
cal map(s:langs, {key, val -> substitute(val, '.*\' .g:leetcode_path_delimit .'\(.\{-}\)\.vim$', '\1', 'g')})

fu! leetcode#lang#utils#langIsSupported(lang)
  if index(s:langs, a:lang) >= 0
    retu 1
  el
    retu 0
  en
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
