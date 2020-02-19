"" API {{{1
fu! leetcode#renameCodeFile#renameCurrentCodeFile(newname)
  try
    let code_filenames = leetcode#utils#accessFiles#allCodeFiles(expand('%:p:h:t'))
    if a:newname =~ '\.' .leetcode#lang#utils#getExt() .'$'
      let newname = a:newname
    el
      let newname = a:newname .'.' .leetcode#lang#utils#getExt()
    endif
    if index(code_filenames, newname) >= 0
      throw 'There is a code file with the same name.'
    endif
    let dir_path = expand('%:p:h')
    let old_code_filename = expand('%:t')
    let old_code_filepath = expand('%:p')
    let new_code_filepath = dir_path .g:leetcode_path_delimit .newname
    "" :saveas saves the marks, etc, as well
    exe 'sil sav ' .fnameescape(new_code_filepath)
    sil bw! #
    cal system('rm "' .old_code_filepath .'"')
    echo '[' .g:leetcode_name .'] Renamed from "' .old_code_filename .'" to "' .newname .'".'
    retu 1
  cat /.*/ | throw v:exception | endt
endfu

"" Reserve the possibility of allowing renaming a code file whose buffer is not being
"" viewed in the current window
fu! leetcode#renameCodeFile#renameCodeFile(...)
  try
    if a:0 != 1
      throw '[' .g:leetcode_name .'] :LrenameCodeFile {New Name}'
    endif
    cal leetcode#renameCodeFile#renameCurrentCodeFile(a:1)
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu
