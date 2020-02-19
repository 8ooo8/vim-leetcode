"" API {{{1
fu! leetcode#utils#judgeCode#test(leetcode_cmd)
  cal leetcode#utils#judgeCode#testOrSubmit(a:leetcode_cmd)
endfu

fu! leetcode#utils#judgeCode#submit(leetcode_cmd)
  cal leetcode#utils#judgeCode#testOrSubmit(a:leetcode_cmd)
endfu

fu! leetcode#utils#judgeCode#testOrSubmit(leetcode_cmd)
  sil w
  "" Commenting the dependencies to avoid a compilation error during a test or
  "" submission of the current code file
  let current_line = line('.')
  exe 'sil wundo! ' .fnameescape(g:leetcode_undo_history_path)
  cal leetcode#lang#utils#commentDependencies()
  try 
    echoh None | ec '[' .g:leetcode_name .'] Loading ...'
    let test_result = system(a:leetcode_cmd)
    redraw | cal s:displayTestOrSubmitResult(test_result) 
  cat /.*/
    throw 'Error in code judgement.'
  finally
    cal leetcode#lang#utils#uncommentDependencies()
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


"" Local Var & Functions {{{1
fu! s:displayTestOrSubmitResult(result)
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

  let result_in_list_form = split(a:result, '\n')
  let result_start_idx = 0
  let idx = 0
  for r in result_in_list_form
    if r =~? '\cWaiting for judge result'
      let result_start_idx = idx + 1
    endif
    let idx += 1
  endfor

  "" Check if wrong answer
  let extracted_result = result_in_list_form[result_start_idx:]
  let ans_pattern = '[✘✔]\s*answer\s*:\|[✘✔]\s*output\s*(\d\+\s*ms)\s*:'
  let expected_ans_pattern = '[✘✔]\s*expected\s*answer\s*:'
  for line in extracted_result
    if line =~? ans_pattern
      let ans = substitute(line, '.*:\s*', '', '')
    elseif line =~? expected_ans_pattern
      let expected_ans = substitute(line, '.*:\s*', '', '')
    en
  endfor
  let wrong_ans = (exists('ans') && exists('expected_ans') && ans != expected_ans)

  "" Display the result
  ec "\n"
  for line in extracted_result
    echoh None
    let pos = 0
    let printing_key = 1
    let is_ans_or_expectedAns = line =~? ans_pattern || line =~? expected_ans_pattern
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
