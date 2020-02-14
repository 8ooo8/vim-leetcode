"" API {{{1
fu! leetcode#renameCodeFile#renameCurrentCodeFile(newname)
  let code_filenames = leetcode#utils#accessFiles#allCodeFiles(expand('%:p:h:t'))
  for c in code_filenames
    if c == a:newname || c == a:newname .'.' .leetcode#lang#utils#getExt()
      echoe '[' .g:leetcode_name .'] There is a code file with the same name.'
      retu -1
    endif
  endfor
  let dir_path = expand('%:p:h')
  let old_code_filename = expand('%:t')
  let old_code_filepath = expand('%:p')
  let new_code_filepath = dir_path .g:leetcode_path_delimit .a:newname .'.' .leetcode#lang#utils#getExt() 
  "" :saveas saves the marks, etc, as well
  exe 'sil sav ' .fnameescape(new_code_filepath)
  sil bw! #
  exe 'sil !rm "' .old_code_filepath .'"'
  echo 'Renamed from "' .old_code_filename .'" to "' .a:newname .'.' .leetcode#lang#utils#getExt() .'".'
  retu 0
endfu

"" Reserve the possibility of allowing renaming a code file whose buffer is not being
"" viewed in the current window
fu! leetcode#renameCodeFile#renameCodeFile(...)
  if a:0 != 1
    echoe '[' .g:leetcode_name .'] LrenameCodeFile {newname}'
    retu -1
  el
    cal leetcode#renameCodeFile#renameCurrentCodeFile(a:1)
  endif
endfu
