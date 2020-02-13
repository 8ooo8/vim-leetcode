"" API {{{1
"" @param   a:1 Question ID or Name
""          a:2 Optional code filename
fu! leetcode#doQ#doQ(...) 
  if a:0 > 2
    echoe '[' .g:leetcode_name .'] :LdoQ [Question ID or Name] [code filename]'
    retu -1
  endif
  if !leetcode#lang#utils#langIsSupported(g:leetcode_lang)
    echoe '[' .g:leetcode_name .'] The language specified by "g:leetcode_lang" is not supported.'
    retu -2
  endif

  if a:0 == 0
    if s:loadLastDownQ() == -1
      echoe '[' .g:leetcode_name .'] Error in loading the last downloaded question.'
      retu -7
    en
    retu 0
  endif

  "" Initialize the names & paths of the question and code files
  let root_path = leetcode#utils#path#getRootDir()
  let Q_fullname = s:getDidQFullname(a:1)
  if Q_fullname == 0
    "" when the specified question does not exist
    "" TO-DO: LOW PRIORITY. IN A NEW BRANCH,
    "" SAVE THE QUESTION AT THE SAME TIME SO THAT NO NEED TO REQUEST THE
    "" LEETCODE SERVER FOR THE QUESTION AGAIN
    let Q_fullname = s:getQFullNameFromLeetcodeServer(a:1)
    if Q_fullname == -1
      echoe '[' .g:leetcode_name .'] Error in retriving the question. Please make sure the question ID or name is correct.'
      retu -3
    endif
  en
  let destination_dir_path = root_path .g:leetcode_path_delimit .Q_fullname
  let did_this_Q = isdirectory(destination_dir_path)
  let Q_filename = 'Q.txt'
  let Q_filepath = destination_dir_path .g:leetcode_path_delimit .Q_filename
  if !did_this_Q && a:0 == 1
    try
      exe 'sil !mkdir -p "' .destination_dir_path .'"'
      exe 'lcd ' .destination_dir_path
      if a:1 =~? '\[\d\+\]\([ a-zA-Z0-9]\)\+'
        exe 'sil !leetcode show -g -l ' .g:leetcode_lang .' "' .matchstr(a:1, '\[\zs\d\+\ze\]') .'" > ' .Q_filename
      el
        exe 'sil !leetcode show -g -l ' .g:leetcode_lang .' "' .a:1 .'" > ' .Q_filename
      en
    cat /*/
      echoe '[' .g:leetcode_name .'] Error in creating the question and code file. '
      retu -4
    endt
  en
  let existing_code_filenames = split(globpath(fnameescape(destination_dir_path), '*.' .g:leetcode_lang), '\n')
  cal map(existing_code_filenames, {key, val -> substitute(val, '.*\' .g:leetcode_path_delimit, '', '')})
  if a:0 == 1 ""when users do not specify the code filename
    let code_filename = existing_code_filenames[0]
  el
    for ecf in existing_code_filenames
      if ecf =~? a:2 | let code_filename = ecf | break | en
    endfor
      if !exists('code_filename')
        echoe '[' .g:leetcode_name .'] The specified code file cannot be found.'
        retu -5
      endif
  en
  let code_filepath = destination_dir_path .g:leetcode_path_delimit .code_filename
  if !did_this_Q
    cal leetcode#utils#accessFiles#writeLastDownQInfo(Q_fullname, destination_dir_path, Q_filepath, code_filename, code_filepath)
  en
  
  let viewResult = s:viewQandCodeFiles(did_this_Q, destination_dir_path, Q_filepath, code_filename, code_filepath)
  if viewResult == -1
    echoe '[' .g:leetcode_name .'] More than one match of code file in the buffer list.'
    retu -6
  el
    echom '[' .g:leetcode_name .'] "' .Q_fullname . g:leetcode_path_delimit .code_filename .'" loaded.'
    retu 0
  endif
endfu

fu! leetcode#doQ#completeCmdArgs(arg_lead, cmd_line, cursor_pos)
  let cmd_and_arg_list = leetcode#utils#cmd#getCmdAndArgList(a:cmd_line)
  if len(cmd_and_arg_list) == 2
    ""complete by "the did questions"
    let did_Q = leetcode#utils#accessFiles#allDidQ()
    cal map(did_Q, {key, val -> escape(val, ' ')})
    cal filter(did_Q, {key, val -> val =~? escape(a:arg_lead, '\[]')})
    retu did_Q
  elseif len(cmd_and_arg_list) == 3
    ""complete by "the code files"
    let code_filenames = leetcode#utils#accessFiles#allCodeFiles(s:getDidQFullname(substitute(cmd_and_arg_list[1], '\\', '', 'g')))
    cal map(code_filenames, {key, val -> escape(val, ' ')})
    cal filter(code_filenames, {key, val -> val =~? escape(a:arg_lead, '\[]')})
    retu code_filenames
  endif
endfu

"" Local Var & Functions {{{1
fu! s:loadLastDownQ()
  if a:0 == 0
    let last_down_Q_info = leetcode#utils#accessFiles#readLastDownQInfo()
    try
      let viewResult = s:viewQandCodeFiles(1, last_down_Q_info[1], last_down_Q_info[2], last_down_Q_info[3], last_down_Q_info[4])
      if viewResult == -1
        echoe '[' .g:leetcode_name .'] More than one match of code file in the buffer list.'
        retu -6
      el
        echom '[' .g:leetcode_name .'] "' .last_down_Q_info[0] . g:leetcode_path_delimit .last_down_Q_info[3] .'" loaded.'
        retu 0
      endif
    cat /.*/ |  retu -1 | endt
  endif
endfu

fu! s:getDidQFullname(did_Q_partialname)
  "" a:did_Q_partialname is supposed to be in either one of the following 3 forms:
  "" (1) "[ID] Name". Partial match.
  "" (2) "ID". Complete match to avoid the ambiguity problem.
  "" (3) "Name". Complete match to avoid the ambiguity problem.
  let root_path = leetcode#utils#path#getRootDir()
  let all_did_Q = leetcode#utils#accessFiles#allDidQ()
  if a:did_Q_partialname =~? '\[\d\+\]\([ a-zA-Z0-9]\)\+'
    "" when a:did_Q_partialname is in a form of "[ID] Name"
    let escaped_Q_partialname = escape(a:did_Q_partialname, '[]')
    for did_Q in all_did_Q
      if did_Q =~? escaped_Q_partialname
        retu did_Q
      endif
    endfor
  elseif a:did_Q_partialname =~ '\s*\d\+\s*' 
    "" when a:did_Q_partialname is in a form of "ID"
    cal map(all_did_Q, {key, val -> matchstr(val, '\[\zs\d\+\ze\]')})
    let idx = index(all_did_Q, matchstr(a:did_Q_partialname, '\s*\zs\d\+\ze\s*'))
    if idx >= 0
      retu leetcode#utils#accessFiles#allDidQ()[idx]
    endif
  el
    "" when a:did_Q_partialname is in a form of "Name"
    cal map(all_did_Q, {key, val -> matchstr(val, '\s*\[\d\+\]\s*\zs.*\ze$')})
    let idx = index(all_did_Q, trim(a:did_Q_partialname))
    if idx >= 0
      retu leetcode#utils#accessFiles#allDidQ()[idx]
    endif
  en
  retu 0
endfu

fu! s:viewQandCodeFiles(did_this_Q, destination_dir_path, Q_filepath, code_filename, code_filepath)
  exe 'lcd ' .fnameescape(a:destination_dir_path)
  sil on!
  try
    "" Try :b before :e to avoid an erase of the changes made to the code
    "" file buffer, which occurs when it is the current buffer
    exe 'sil b! ' .fnameescape(a:code_filename)
    set bl
  cat /E93/
    ""when more than one match in the buffer list
    retu -1
  cat /E94/
    ""when no matched buffer
    exe 'sil e! ' .fnameescape(a:code_filepath) 
  endt

  if g:leetcode_viewQ
    vs
    exe 'sil e' .fnameescape(a:Q_filepath)
    if !a:did_this_Q | cal s:RemoveHTMLTagsInCurrentQFile() | sil w | en
    exe 'lcd ' .fnameescape(a:destination_dir_path)
    1wincmd w
  elseif !g:leetcode_viewQ && !a:did_this_Q
    exe 'sil e ' .a:Q_filepath
    cal s:RemoveHTMLTagsInCurrentQFile() | sil w
    b # | bd #
  en

  if !a:did_this_Q
    cal leetcode#lang#utils#addDependencies()
    sil w
  en
  cal leetcode#lang#utils#foldDependencies()

  if a:did_this_Q
    try
      exe 'norm! `.' 
      "" when it is an unchanged file, e.g. a copy of the old code file
    cat /E20\|E19/ | cal leetcode#lang#utils#goToWhereCodeBegins()
    endt
  el
    cal leetcode#lang#utils#goToWhereCodeBegins()
  en
  if g:leetcode_autoinsert
    star
  en

  retu 0
endf

fu! s:getQFullNameFromLeetcodeServer(Q_ID_or_name)
  "" Ensure it is under a valid directory so that
  "" the "leetcode-cli' commands may function properly
  exe 'lcd ' .g:leetcode_valid_dir_path
  "" When a:Q_ID_or_name is in a form of "[ID] Name", fetch the question by the ID.
  "" Afterwards, check if a:Q_ID_or_name matches with the fetched question
  if a:Q_ID_or_name =~ '\[\d\+\]\([ a-zA-Z0-9]\)\+'
    let Q_ID_or_name = matchstr(a:Q_ID_or_name, '\[\zs\d\+\ze\]')
  el
    let Q_ID_or_name = a:Q_ID_or_name
  endif
  let Q = system('leetcode show "' .Q_ID_or_name .'"')
  let Q_in_list_form = split(Q, '\n')
  for line in Q_in_list_form
    if line =~ '^\s*\[\d\+\][- \tA-Za-z0-9\[\]()]\+$'
      let Q_fullname = trim(line)
      break
    endif
  endfor
  if exists('Q_fullname') && (a:Q_ID_or_name !~ '\[\d\+\]\([ a-zA-Z0-9]\)\+' ||
        \Q_fullname =~? escape(a:Q_ID_or_name, '[]'))
    retu Q_fullname
  el
    return -1
  en
endfu

fu! s:from_QFullName_to_codeTemplateName(Q_fullname)
  let id_transformed = substitute(a:Q_fullname, '^\s*\[\s*\(\d\+\)\s*\]\s*', '\1.', '')
  let head_tail_spaces_removed = substitute(id_transformed, '^\s*\|\s*$', '', 'g')
  let parentheses_removed = substitute(head_tail_spaces_removed , '[()]', '', 'g')
  return tolower(substitute(parentheses_removed, '\S\zs\(\s\+\)\ze\S', '-', 'g'))
endf

fu! s:RemoveHTMLTagsInCurrentQFile()
  sil %sm@<.\{-}>\|</.\{-}>@@ge
  sil %sm@&quot;@"@ge
  sil %sm@&nbsp;@ @ge
  sil %sm@&gt;@>@ge
  sil %sm@&lt;@<@ge
  norm! gg
endf
