"" @return  a Vim list of all existing code filenames for the specified question
fu! leetcode#utils#accessFiles#allCodeFiles(Q_fullname)
  let root_path = leetcode#utils#path#getRootDir()
  let code_dir_path = root_path .g:leetcode_path_delimit .a:Q_fullname
  let all_code_filenames = split(globpath(fnameescape(code_dir_path), '*' .g:leetcode_lang), '\n')
  cal map(all_code_filenames, {key, val -> matchstr(val, g:leetcode_path_delimit .'\zs[^\' .g:leetcode_path_delimit .']*\ze$')})
  retu all_code_filenames
endfu

"" @return  a Vim list of all did questions
fu! leetcode#utils#accessFiles#allDidQ()
  let root_path = leetcode#utils#path#getRootDir()
  let all_did_Q = split(globpath(root_path, '*' .g:leetcode_path_delimit), '\n')
  cal map(all_did_Q, {key, val -> matchstr(val, g:leetcode_path_delimit
        \.'\zs[^\' .g:leetcode_path_delimit .']*\ze' .g:leetcode_path_delimit .'$')})
  retu all_did_Q
endfu

