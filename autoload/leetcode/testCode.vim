"" API {{{1
fu! leetcode#testCode#testCode(...)
  try
    let test_cmd = 'leetcode test "' .expand('%:p') .'"'
    let Q_fullname = expand('%:p:h:t')
    if !a:1 && len(a:2)
      let test_cmd .= ' -t "' .substitute(a:2, '"', '\\"', 'g') .'"'
    elseif !a:1 && len(a:2) == 0 && leetcode#utils#accessFiles#lastFailCaseExists(Q_fullname)
      let test_cmd .= ' -t "' .escape(leetcode#utils#accessFiles#readLastFailCase(Q_fullname), '"') .'"'
    en
    cal leetcode#utils#judgeCode#test(test_cmd, Q_fullname)
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu
