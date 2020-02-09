"" API {{{1
fu! leetcode#submitCode#submitCode(...)
  if a:0 >= 1
    echoe '[' .g:leetcode_name .'] :Lsubmit'
    retu -1
  endif

  cal leetcode#utils#judgeCode#submit('leetcode submit "' .expand('%:p') .'"')
endfu
