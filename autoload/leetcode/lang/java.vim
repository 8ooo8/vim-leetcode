let s:lang = 'java'
let s:ext = 'java'
let s:dependencies = [
      \'/*** [' .g:leetcode_name .'] For Local Syntax Checking ***/',
      \'import java.util.*;',
      \'import java.util.stream.*;',
      \'import javafx.util.*;',
      \'import java.util.Map.Entry;', '']
let s:depend_location = '/\mclass\s\+solution\c\s\+{/-' 
let s:code_begin_location = '?\m)\s*{?+'

"" TODO: refactor to reuse the duplicated logic

fu! leetcode#lang#java#locateLeetcodeCliComment(topmost_line)
  exe 'keepj norm! ' .(a:topmost_line - 1) .'G'
  let comment_first_line = search('\/\*')
  let comment_last_line = searchpair('\/\*', '', '\*\/', 'W')
  return [comment_first_line, comment_last_line]
endfu

fu! leetcode#lang#java#getCustomDependencies()
  keepj norm! gg
  let lc_code_start_line = search('@\s*lc\s*code\s*=\s*start')
  let [comment_first_line, comment_last_line] = leetcode#lang#java#locateLeetcodeCliComment(lc_code_start_line + 1)
  exe 'keepj norm! ' .comment_first_line .'G'
  let definition_comment_line = search('\cdefinition for')
  if definition_comment_line == 0
    retu []
  endif
  let custom_depend = []
  let custom_depend_line = definition_comment_line + 1
  while custom_depend_line < comment_last_line
    exe 'keepj norm! ' .custom_depend_line .'G'
    cal add(custom_depend, getline(custom_depend_line))
    let custom_depend_line += 1
  endwhile
  cal map(custom_depend, {key, val -> matchstr(val, '\s*\*\+\s*\zs.*')})
  retu custom_depend
endfu

fu! leetcode#lang#java#addDependencies()
  keepj norm! gg   
  try | exe 'keepp sil ' .s:depend_location
  cat /E486/ 
    throw 'Error in locating the position to add dependencies'
  endt
  "" Add dependencies and make it non-undoable
  let old_ul = &ul
  setl ul=-1
  keepj cal append(line('.'), s:dependencies)
  let custom_depend = leetcode#lang#java#getCustomDependencies()
  let custom_depend_begin_line = search(s:dependencies[len(s:dependencies) - 3])
  keepj cal append(custom_depend_begin_line, custom_depend)
  exe 'setlocal ul='.old_ul
  retu 1
endfu

fu! leetcode#lang#java#foldDependencies()
  setl foldmethod=manual
  try 
    keepj norm! gg
    let first_fold_line = search(escape(s:dependencies[0], '/*[]'))
    if foldclosed(first_fold_line) == -1
      exe 'keepj keepp sil /\m\C\s*\/\{-,2}\s*' .escape(s:dependencies[1], '.*') .'\s*$'
      let last_fold_line = search(escape(s:dependencies[-2], '.*'))
      exe 'keepj norm! ' .first_fold_line .'G' .(last_fold_line - first_fold_line + 1) .'zF'
    en
    retu 1
  cat /E486/
    throw 'Error in locating the dependencies to fold'
  endt
endfu

fu! leetcode#lang#java#goToWhereCodeBegins()
  keepj keepp sil /\m\%$/
  try 
    exe 'sil ' .s:code_begin_location
  cat /E486/
    throw 'Error in locating where to start code writing.'
  endt
endfu

fu! leetcode#lang#java#commentDependencies()
  exe 'keepj keepp sil %sm@\C^\(.*' .s:dependencies[1] .'.*\)$@//\1@'
endfu

fu! leetcode#lang#java#uncommentDependencies()
  exe 'keepj keepp sil %sm@\C\s*\zs/*\ze.*' .s:dependencies[1] .'.*$@@'
endfu

fu! leetcode#lang#java#getExt()
  retu s:ext
endfu
