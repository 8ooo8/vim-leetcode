"" API {{{1
fu! leetcode#printLastRunResult#printLastRunResult(...)
  try
    if a:0 >= 1
      throw ':LprintLastRunResult'
    endif

    let result = leetcode#utils#accessFiles#readLastRunResult()
    cal leetcode#utils#judgeCode#displayTestOrSubmitResult(split(result, "\n"))
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu
