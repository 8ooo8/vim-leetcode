let s:ans_pattern = '[✘✔]\s*answer\s*:\|[✘✔]\s*output\s*(\d\+\s*ms)\s*:'
let s:expected_ans_pattern = '[✘✔]\s*expected\s*answer\s*:'
let s:failed_testcase_pattern = '✘\s*\(testcase\|your\s*input\)\s*:'

"" API {{{1
fu! leetcode#utils#judgeCode#test(leetcode_cmd, Q_fullname)
  cal leetcode#utils#judgeCode#testOrSubmit(a:leetcode_cmd, a:Q_fullname)
endfu

fu! leetcode#utils#judgeCode#submit(leetcode_cmd, Q_fullname)
  cal leetcode#utils#judgeCode#testOrSubmit(a:leetcode_cmd, a:Q_fullname)
endfu

fu! leetcode#utils#judgeCode#testOrSubmit(leetcode_cmd, Q_fullname)
  sil w
  "" Commenting the dependencies to avoid a compilation error during a test or
  "" submission of the current code file
  let current_line = line('.')
  exe 'sil wundo! ' .fnameescape(g:leetcode_undo_history_path)
  cal leetcode#lang#utils#commentDependencies() | sil w!
  let commented = 1
  try 
    echoh None | ec '[' .g:leetcode_name .'] Loading ...'
    let raw_test_result = system(a:leetcode_cmd)
    let test_result = s:extractTestOrSumbitResult(raw_test_result)
    cal leetcode#utils#accessFiles#clearLastRunResultStorage()
    cal leetcode#utils#accessFiles#appendTextToLastRunResultStorage(join(test_result, "\n"))
    cal leetcode#lang#utils#uncommentDependencies() | sil w! | let commented = 0
    redraw | cal leetcode#utils#judgeCode#displayTestOrSubmitResult(test_result) 
    cal s:saveFailCase(a:Q_fullname, test_result)
  cat /.*/
    "" throw 'Error in code judgement.'
    echoe 'rethrow ' .v:exception
  finally
    if commented
      cal leetcode#lang#utils#uncommentDependencies() | sil w! | let commented = 0
    en
    try
      exe 'sil rundo ' .fnameescape(g:leetcode_undo_history_path)
    cat /E822/ ""when empty undo history
      let old_ul = &ul
      setl ul=-1
      exe "norm! a \<BS>\<Esc>"
      exe 'setl ul=' .old_ul
    endt 
    cal system('rm "' .g:leetcode_undo_history_path .'"')
    cal leetcode#lang#utils#foldDependencies()
    exe 'keepj norm! ' .current_line .'G'
  endt
endfu

fu! leetcode#utils#judgeCode#displayTestOrSubmitResult(test_result)
  "" Sample output 1 of the test command of 'leetcode-cli' in list form
  "" ['- Downloading valid-number', '- Sending code to judge', '- Waiting for judge result', 
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result',
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result', 
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result'
  "" , '- Waiting for judge result', '- Waiting for judge result',
  "" '  ✔ Finished', '  ✔ Your Input: "0"', '  ✔ Output (4 ms): true', 
  "" '  ✔ Expected Answer: true', '  ✔ Stdout: ']

  "" Sample output 2 of the test command of 'leetcode-cli' in list form
  "" ['- Downloading valid-number', '- Sending code to judge', '- Waiting for judge result', 
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result',
  "" '- Waiting for judge result', '  ✘ Compile Error',
  "" '  ✘ Error: Line 39: Char 5: error: ''asdasda'' was not declared in this scope',
  "" '  ✘ Error: solution.cpp: In member function i sNumber',
  "" 'Line 39: Char 5: error: ''asdasda'' was not declared in this scope',
  "" '     asdasda   return true;', '     ^~~~~~~', '  ✘ Your Input: "0"', 
  "" '  ✘ Expected Answer: ', ' ✘ Stdout: ']

  "" Sample output 1 of the submit command of 'leetcode-cli' in list form
  "" ['- Downloading valid-number', '- Sending code to judge', '- Waiting for judge result',
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result',
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result', 
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result'
  "" , '  ✘ Wrong Answer', '  ✘ 736/1481 cases passed (N/A)', '  ✘ Testcase: "0"',
  "" '  ✘ Answer: false', '  ✘ Expected Answer: true', '  ✘ Stdout: ']

  "" Sample output 2 of the submit command of 'leetcode-cli' in list form
  "" ['- Downloading valid-number', '- Sending code to judge', '- Waiting for judge result',
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result',
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result',
  "" '  ✘ Compile Error', '  ✘ 0/0 cases passed (N/A)', '  ✘ Error: Line 39: Char 8: error: '
  "" 'INTENTIONALLY'' was not declared in this scope', 
  "" '  ✘ Error: solution.cpp: In member function isNumber', 'Line 39: Char 8: error: ''INTENTIONALLY'
  "" ' was not declared in this scop
  "" e', '        INTENTIONALLY MAKE AN ERROR return false;', '        ^~~~~~~~~~~~~',
  "" '  ✘ Testcase: ', '  ✘ Answer: ', '  ✘ Expected Answer: ', '  ✘ Stdout: ']
 
  "" Sample output 3 of the submit command of 'leetcode-cli' in list form
  "" ['- Downloading valid-number', '- Sending code to judge', '- Waiting for judge result', 
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result',
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result', 
  "" '- Waiting for judge result', '- Waiting for judge result', '- Waiting for judge result'
  "" , '  ✔ Accepted', '  ✔ 1481/1481 cases passed (0 ms)', '  ✔ Your runtime beats 100 % of cpp submissions',
  "" '  ✔ Your memory usage beats 60 % of cpp submissions (8.2 MB)']


  "" Check if wrong answer
  let [ans, expected_ans] = s:getAnsAndExpectedAns(a:test_result)
  let wrong_ans = ans != expected_ans

  "" concatenating the stdout output, indent testcase(s) and stdoutput
  let stdout = ''
  let reading_stdout = 0
  let [stdout_start_line_idx, stdout_end_line_idx, stdout_start_posi] = [-1, -1, -1]
  for line_idx in range(len(a:test_result))
    let line = a:test_result[line_idx]
    if reading_stdout
      if (line =~ '^\s*✔' || line =~ '^\s*✘') && line =~ '\S\+\s*:'
        "" end reading stdout
        let reading_stdout = 0 
        let stdout_end_line_idx = line - 1
        break
      el
        "" concatenate the output; '\n' instead of "\n" is used to keep the string one line
        "" so that the linewise utility may still works great.
        let stdout .= line .'\n'
      endif
    elseif !reading_stdout && (line =~ '^\s*✔' || line =~ '^\s*✘') && line =~? 'stdout'
      "" start reading stdout
      let stdout_start_line_idx = line_idx
      let stdout_start_posi = matchend(line, ':\s*')
      "" retrieve the first part of the stdout output;
      "" '\n' instead of "\n" is used to keep the string one line.
      let stdout .= line[stdout_start_posi:] .'\n'
      let reading_stdout = 1
    endif
  endfor

  "" concatentate the stdout chops.
  "" to combine, firstly insert an appropriate quote in the beginning
  "" and append an appropriate quote in the end to keep the pattern that
  ""     \([''"]\)user-input\1\s*\(\\n\)\?\s*+\s*\(\\n\)\?\s*\([''"]\)user-input\2
  "" throughout the whole stdout output string.
  let concat_stdout = substitute(stdout,
        \ '^\zs\ze.\{-}\([''"]\)\s*\(\\n\)\?\s*+\s*\(\\n\)\?\s*\([''"]\).\{-}\4', '\1', '')
  "" reverse before substitute() to reduce the runtime and avoid exceeding the memory
  "" limit (maxmempattern)
  let concat_stdout = join(reverse(split(concat_stdout, '\zs')), '')
  let concat_stdout = substitute(concat_stdout,
        \ '^\zs\ze.\{-}\([''"]\)\s*\(n\\\)\?\s*+\s*\(n\\\)\?\s*\([''"]\).\{-}\4', '\1', '')
  let concat_stdout = join(reverse(split(concat_stdout, '\zs')), '')
  let added_extra_quotes = concat_stdout[0] != stdout[0]
  "" remove the unwanted plus signs and quotes, replace '\n' with "\n"
  let concat_stdout = substitute(concat_stdout,
        \ '\([''"]\).\{-}\1\zs\s*\(\\n\)\?\s*+\s*\(\\n\)\?\s*\ze\([''"]\).\{-}\4', '', 'g')
  let concat_stdout = substitute(concat_stdout, '[''"][''"]', '', 'g')
  let concat_stdout = substitute(concat_stdout, '\\n', "\n    ", 'g')
  if added_extra_quotes
    let concat_stdout = concat_stdout[1:len(concat_stdout) - 2] "" remove the 1st and last quotes
  endif
  let concat_stdout = "\n    " .concat_stdout

  "" replace the stdout part with the above concatenated stdout string
  if [stdout_start_line_idx, stdout_end_line_idx] != [-1, -1] "" when stdout exists in the test or submit result
    let a:test_result[stdout_start_line_idx] = a:test_result[stdout_start_line_idx][:stdout_start_posi - 1] .concat_stdout
    let stdout_end_line_idx = stdout_end_line_idx == -1 ? len(a:test_result) - 1 : stdout_end_line_idx
    if stdout_start_line_idx != stdout_end_line_idx
      cal remove(a:test_result, stdout_start_line_idx + 1, stdout_end_line_idx)
    endif
  endif

  "" indent the testcase(s)
  let reading_testcases = 0
  for line_idx in range(len(a:test_result))
    let line = a:test_result[line_idx]
    if reading_testcases
      if (line =~ '^\s*✔' || line =~ '^\s*✘') && line =~ '\S\+\s*:'
        "" end reading input
        break
      el
        let a:test_result[line_idx] = '    ' .a:test_result[line_idx]
      endif
    elseif !reading_testcases && (line =~ '^\s*✔' || line =~ '^\s*✘')
          \ && (line =~? 'input\%[s]' || line =~? 'test\%[ ]case\%[s]')
      "" start reading input
      let input_start_posi = matchend(line, ':\s*')
      let a:test_result[line_idx] = line[:input_start_posi - 1] ."\n    " .line[input_start_posi:]
      let reading_testcases = 1
    endif
  endfor

  "" Display the result
  ec "\n"
  for line in a:test_result
    echoh None
    let pos = 0
    let printing_key = 1
    let is_ans_or_expectedAns = line =~? s:ans_pattern || line =~? s:expected_ans_pattern
    let tick = 0
    let cross = 0
    while pos < len(line)
      let [chop, prevpos, pos] = matchstrpos(line, '(.*)\s*\|\d\+\%[\.]\d*\s*%\|\S*\s*', pos)
      if printing_key && chop =~ '✔' | echoh MoreMsg | let tick = 1 | echon chop
      elseif printing_key && chop =~ '✘' | echoh WarningMsg | let cross = 1 | echon  chop
      elseif printing_key && chop =~ ':' 
        echon  chop
        if is_ans_or_expectedAns && wrong_ans
          echoh ErrorMsg
        el
          echoh None
        endif
        let printing_key = 0
        let tick = 0
        let cross = 0
      elseif printing_key && chop =~ '(.*)\|%'
        echoh Title 
        echon chop
        if tick
          echoh MoreMsg
        elseif cross
          echoh WarningMsg
        el
          echoh None
         en
      el | echon chop
      en
    endwhile
    echoh None
    ec ''
  endfor
endfu

fu! s:extractTestOrSumbitResult(raw_result)
  let result_in_list_form = split(a:raw_result, '\n')
  let result_start_idx = 0
  let idx = 0
  for r in result_in_list_form
    if r =~? '\cWaiting for judge result'
      let result_start_idx = idx + 1
    endif
    let idx += 1
  endfor
  retu result_in_list_form[result_start_idx:]
endfu

fu! s:saveFailCase(Q_fullname, test_result)
  let has_failed_testcase = 0

  for line in a:test_result
    if has_failed_testcase
      if line =~ '^\s*✘'
        break
      el
        let failed_testcase .= '\\n' .substitute(line, '\m^\s*', '', '')
      endif
    endif

    if line =~? s:failed_testcase_pattern
      let has_failed_testcase = 1
      let failed_testcase = substitute(split(line,  nr2char(13) .'\|' .nr2char(10))[1], '^\s*', '', '') " for an unknow reason, split('\n') couldn't well split this line, which contains LF (value 10)
    endif
  endfor

  if has_failed_testcase
    cal leetcode#utils#accessFiles#saveLastFailCase(a:Q_fullname, failed_testcase)
  endif
endfu

fu! s:getAnsAndExpectedAns(test_result)
  let ans = v:null
  let expected_ans = v:null
  
  for line in a:test_result
    if line =~? s:ans_pattern
      let ans = substitute(line, '.*:\s*', '', '')
    elseif line =~? s:expected_ans_pattern
      let expected_ans = substitute(line, '.*:\s*', '', '')
    en
  endfor

  retu [ans, expected_ans]
endfu
