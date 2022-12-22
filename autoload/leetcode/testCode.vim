"" API {{{1
fu! leetcode#testCode#testCode(...)
  try
    let test_cmd = 'leetcode test "' .expand('%:p') .'"'
    let Q_fullname = expand('%:p:h:t')
    if !a:1
      if len(a:2)
        let test_case = a:2 " for the case of `Ltest <test-case>`
      elseif len(a:2) == 0 && leetcode#utils#accessFiles#lastFailCaseExists(Q_fullname)
        let test_case = leetcode#utils#accessFiles#readLastFailCase(Q_fullname) " for the case of `Ltest!` that runs last fail case
      endif
      if exists('test_case')
        let test_cmd .= " -t '\"" .substitute(test_case, "'", "'\"'\"'", 'g') ."\"'"
      en
    en
    cal leetcode#utils#judgeCode#test(test_cmd, Q_fullname)
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu
