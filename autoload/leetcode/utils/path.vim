fu! leetcode#utils#path#init()
  if has('win32unix') || has('win16') || has('win32') || has('win64')
    let g:leetcode_path_delimit = '\'
    let g:leetcode_valid_dir_path = 'c:'
  el
    let g:leetcode_path_delimit = '/'
    let g:leetcode_valid_dir_path = '/'
  en
endfu

fu! leetcode#utils#path#escape(path)
  return escape(a:path, ' [')
endfu

fu! leetcode#utils#path#getRootDir()
  if exists('g:leetcode_root_dir')
    retu g:leetcode_root_dir
  el
    "" have the preceding blank line removed before returning
    retu split(execute('pwd'), '\n')[0]
  endif
endfu
