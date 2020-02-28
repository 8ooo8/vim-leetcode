"" Version: 0.2.0
"" Usage:
"" This is tiny plugin which allows users quickly downloading and writing for 
"" leetcode questions. 
"" Requirements:
"" 1. Installed "leetcode-cli".
""    See "https://github.com/leetcode-tools/leetcode-cli".
"" 2. Supporting basic unix shell comaands.

let g:leetcode_name = 'vim-leetcode'

"" Check Compatiblity and Load Plugin {{{1
if v:version < 700
  echoe '[' .g:leetcode_name .']: Please update your vim to a verion 7 or higher.'
  fini
en
if has('win32unix') || has('win16') || has('win32') || has('win64')
    echom '[' .g:leetcode_name .']: Please make sure your environment suuports the basic unix shell commands'
en
if &cp | echoe '[' .g:leetcode_name .'] Not Vi-compatible. ":set nocp" to solve it.' | en
if exists('g:loaded_leetcode') && g:loaded_leetcode | fini | en
let g:loaded_leetcode = 1

"" Set Default Values {{{1
if !exists('g:leetcode_lang') | let g:leetcode_lang = 'cpp' | en
if !exists('g:leetcode_view_Q') | let g:leetcode_view_Q = 1 | en
if !exists('g:leetcode_auto_insert') | let g:leetcode_auto_insert = 1 | en
"" "g:leetcode_root_dir": if it does not exist, pwd will be used

"" Initialize {{{1
cal leetcode#utils#path#init()

"" API {{{1
com! -nargs=* -complete=customlist,leetcode#doQ#completeCmdArgs LdoQ cal leetcode#doQ#doQ(<f-args>)
com! -nargs=* LrenameCodeFile cal leetcode#renameCodeFile#renameCodeFile(<f-args>)
com! -nargs=* Ltest cal leetcode#testCode#testCode(<q-args>)
com! -nargs=* Lsubmit cal leetcode#submitCode#submitCode(<f-args>)
com! -nargs=* LprintLastRunResult cal leetcode#printLastRunResult#printLastRunResult(<f-args>)
