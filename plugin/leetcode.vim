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
exe 'set rtp^=' .substitute(expand('%:p:h:h'), '\([ \[]\)', '\\\1', 'g')


"" Set Default Values {{{1
if !exists('g:leetcode_lang') | let g:leetcode_lang = 'cpp' | en
if !exists('g:leetcode_viewQ') | let g:leetcode_viewQ = 1 | en
if !exists('g:leetcode_autoinsert') | let g:leetcode_autoinsert = 1 | en
"" "g:leetcode_root_dir": if it does not exist, pwd will be used

"" Initialize {{{1
cal leetcode#utils#path#init()

"" API {{{1
"" TO-DO: ALLOW MULTIPLE SOLUTIONS TO A SINGLE QUESTION
com! -nargs=1 LdoQ cal leetcode#doQ(<f-args>)
"" TO-DO: LOCAL TEST
"" TO-DO: NICER VIEW OF TESTCODE AND SUBMITCODE
com! -nargs=? Ltest cal leetcode#testCode(<q-args>)
com! Lsubmit cal leetcode#submitCode()
"" TO-DO: SIGN IN
"" TO-DO: SHOW QUESTIONS
