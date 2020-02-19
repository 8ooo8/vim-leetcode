"" API {{{1
fu! leetcode#testCode#testCode(...)
  try
    if a:0 >= 2
      throw ':Ltest [One Test Case]'
    endif

    if a:0 == 1
      cal leetcode#utils#judgeCode#test('leetcode test "' .expand('%:p') .'" -t "' .substitute(a:1, '"', '\\"', 'g') .'"')
    el
      cal leetcode#utils#judgeCode#test('leetcode test "' .expand('%:p') .'"')
    en
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu
