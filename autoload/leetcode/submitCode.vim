"" API {{{1
fu! leetcode#submitCode#submitCode(...)
  try
    if a:0 >= 1
      throw ':Lsubmit'
    endif

    cal leetcode#utils#judgeCode#submit('leetcode submit "' .expand('%:p') .'"', expand('%:p:h:t'))
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu
