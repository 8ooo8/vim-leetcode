"" API {{{1
fu! leetcode#testCode#testCode(...)
  if a:0 >= 2
    echoe '[' .g:leetcode_name .'] :Ltest [One Test Case]'
    retu -1
  endif

  if a:0 == 1
    cal leetcode#utils#judgeCode#test('leetcode test "' .expand('%:p') .'" -t "' .substitute(a:1, '"', '\\"', 'g') .'"')
  el
    cal leetcode#utils#judgeCode#test('leetcode test "' .expand('%:p') .'"')
  en
endfu
