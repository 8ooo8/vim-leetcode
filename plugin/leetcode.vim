"" Version: 0.6.2
"" Description:
"" This is a leetcode question and code file manager. It allows a quick 
"" download, load, test and submission of leetcode questions. The file 
"" structure this plugin provides puts the leetcode files for each question 
"" in each corresponding directory with name in form of 
"" "[Question-ID] Question-Name". It also provides a necessary assistance to 
"" make syntax checking plugins, such as "syntastic", work; it keeps track of
"" the users' cursor position so that the users can immediately go back to 
"" where they left in the last loading of this question; ...
"" Requirements:
"" 1. Installed "leetcode-cli".
""    See "https://github.com/leetcode-tools/leetcode-cli".
"" 2. Supporting POSIX shell comands.
"" License: MIT

let g:leetcode_name = 'vim-leetcode'

"" Check Compatiblity and Load Plugin {{{1
if v:version < 800
  echoe '[' .g:leetcode_name .']: Please update your vim to a verion 8 or higher.'
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
if !exists('g:leetcode_table_of_finished_questions_sorted_by_acceptance_rate') | let g:leetcode_table_of_finished_questions_sorted_by_acceptance_rate = 0 | en
"" "g:leetcode_root_dir": if it does not exist, pwd will be used

"" Initialize {{{1
cal leetcode#utils#path#init()

"" API {{{1
com! -nargs=* -complete=customlist,leetcode#doQ#completeCmdArgs LdoQ cal leetcode#doQ#doQ(<f-args>)
com! -nargs=* LrenameCodeFile cal leetcode#renameCodeFile#renameCodeFile(<f-args>)
com! -nargs=* -bang Ltest cal leetcode#testCode#testCode(<bang>0, <q-args>)
com! -nargs=* Lsubmit cal leetcode#submitCode#submitCode(<f-args>)
com! -nargs=* LprintLastRunResult cal leetcode#printLastRunResult#printLastRunResult(<f-args>)
com! -nargs=* LupdateREADME cal leetcode#updateREADME#updateREADME(<f-args>)
