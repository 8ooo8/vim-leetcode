"" Version: 0.0.0
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
    echom '[leetcode plugin]: Please make sure your environment suuports the basic unix shell commands'
en
"if exists('g:loaded_leetcode') && g:loaded_leetcode | fini | en
"let g:loaded_leetcode = 1

"" Set Default Values {{{1
if !exists('g:leetcode_lang') | let g:leetcode_lang = 'cpp' | en
if !exists('g:leetcode_viewQ') | let g:leetcode_viewQ = 1 | en
if !exists('g:leetcode_autoinsert') | let g:leetcode_autoinsert = 1 | en
"" "g:leetcode_root_dir": if it does not exist, pwd will be used

"" Initialize {{{1
cal leetcode#utils#path#init()

"" API {{{1
" com! -nargs=* LdoQ cal leetcode#doQ#doQ(<f-args>)
com! -nargs=* -complete=customlist,leetcode#doQ#completeCmdArgs LdoQ cal leetcode#doQ#doQ(<f-args>)
com! -nargs=* Ltest cal leetcode#testCode#testCode(<q-args>)
com! -nargs=* Lsubmit cal leetcode#submitCode#submitCode(<f-args>)
"" TO-DO: DO LAST QUESTION IF Q ID OR NAME NOT GIVEN
"" TO-DO: LOCAL TEST
"" TO-DO: RENAME CODE FILE
"" TO-DO: DELETE QUESTION AND CORRESPONDING CODE FILES
"" TO-DO: SIGN IN
"" TO-DO: SIGN OUT
"" TO-DO: SHOW QUESTIONS
