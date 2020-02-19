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
    "" Update the info about the last downloaded Q if needed
    let [LDQ_Q_fullname, LDQ_destination_dir_path, LDQ_Q_filepath, LDQ_code_filename, LDQ_code_filepath] = 
          \leetcode#utils#accessFiles#readLastDownQInfo()
    if resolve(LDQ_code_filepath) == old_code_filepath
      cal leetcode#utils#accessFiles#writeLastDownQInfo(LDQ_Q_fullname, LDQ_destination_dir_path, LDQ_Q_filepath, 
            \newname, new_code_filepath)
    en
    "" Update the info about the last did code file for this question if needed
    let Q_fullname = expand('%:p:h:t')
    let [LDC_destination_dir_path, LDC_Q_filepath, LDC_code_filename, LDC_code_filepath] =
          \leetcode#utils#accessFiles#readLastDidCodeFileInfo(Q_fullname)
    if resolve(LDC_code_filepath) == old_code_filepath
      cal leetcode#utils#accessFiles#writeLastDidCodeFileInfo(Q_fullname, LDC_destination_dir_path, LDC_Q_filepath,
            \newname, new_code_filepath)
    endif
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
