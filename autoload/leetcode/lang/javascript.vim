let s:lang = 'javascript'
let s:ext = 'js'
let s:code_begin_location = '?\s*\(var\|\const\)?+1'

fu! leetcode#lang#javascript#locateLeetcodeCliComment(topmost_line)
endfu

fu! leetcode#lang#javascript#getCustomDependencies()
endfu

fu! leetcode#lang#javascript#addDependencies()
endfu

fu! leetcode#lang#javascript#foldDependencies()
endfu

fu! leetcode#lang#javascript#goToWhereCodeBegins()
  keepj keepp sil /\m\%$/
  try 
    exe 'sil ' .s:code_begin_location
  cat /E486/
    throw 'Error in locating where to start code writing.'
  endt
endfu

fu! leetcode#lang#javascript#commentDependencies()
endfu

fu! leetcode#lang#javascript#uncommentDependencies()
endfu

fu! leetcode#lang#javascript#getExt()
  retu s:ext
endfu
