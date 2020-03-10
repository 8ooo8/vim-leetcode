"" API {{{1
"" @param   a:1 Question ID or Name
""          a:2 Optional code filename
fu! leetcode#doQ#doQ(...) 
  try
    if a:0 > 2
      throw ':LdoQ [Question ID or Name] [Code Filename]'
    endif
    if !leetcode#lang#utils#langIsSupported(g:leetcode_lang)
      throw 'The language specified by "g:leetcode_lang" is not supported.'
    endif

    if a:0 == 0
      cal s:loadLastDownQ() 
      retu 1
    endif

    "" Initialize the names & paths of the question and code files.
    "" At the same time, download questions and code template if requested.
    "" Afterwards, based on the names and paths find the requested files and open them.
    let root_path = leetcode#utils#path#getRootDir()
    try
      let Q_fullname = s:getDidQFullname(a:1)
    cat /.*/
      try | let Q_fullname = s:getQFullNameFromLeetcodeServer(a:1) | endt
    endt
    if a:0 == 1 && leetcode#utils#accessFiles#lastDidCodeFileStorageExists(Q_fullname)
      let [destination_dir_path, Q_filepath, code_filename, code_filepath] = 
            \leetcode#utils#accessFiles#readLastDidCodeFileInfo(Q_fullname)
      let need_to_down = 0
      if !filereadable(code_filepath)
        throw 'The last did code file for this question cannot be found.'
      endif
    endif
    if !exists('destination_dir_path') && !exists('Q_filepath') && !exists('code_filename') && !exists('code_filepath')
      let destination_dir_path = root_path .g:leetcode_path_delimit .Q_fullname
      let Q_filename = 'Q.txt'
      let Q_filepath = destination_dir_path .g:leetcode_path_delimit .Q_filename
      "" Download the question and the code template if needed
      let existing_code_filenames = leetcode#utils#accessFiles#allCodeFiles(Q_fullname)
      if a:0 == 2
        if a:2 =~ '\.' .leetcode#lang#utils#getExt() .'$'
          let code_filename = a:2
        el
          let code_filename = a:2 .'.' .leetcode#lang#utils#getExt()
        en
      endif
      let need_to_down = (a:0 == 2 && index(existing_code_filenames, code_filename) < 0) || len(existing_code_filenames) == 0
      if need_to_down
        let down_result = s:downQ(destination_dir_path, Q_fullname, a:1, Q_filename, (exists('code_filename') ? code_filename : ''))
        echom '[' .g:leetcode_name .'] Question and code file downloaded.'
      en
      "" Determine code_filename if it is not yet determined
      if !exists('code_filename')
        let code_filename = leetcode#utils#accessFiles#allCodeFiles(Q_fullname)[0]
      en
      let code_filepath = destination_dir_path .g:leetcode_path_delimit .code_filename

      if need_to_down
        cal leetcode#utils#accessFiles#writeLastDownQInfo(Q_fullname, destination_dir_path, Q_filepath, code_filename, code_filepath)
      en
    en
    
    let viewResult = s:viewQandCodeFiles(need_to_down, destination_dir_path, Q_filepath, code_filename, code_filepath)
    cal leetcode#utils#accessFiles#writeLastDidCodeFileInfo(Q_fullname, destination_dir_path, Q_filepath, code_filename, code_filepath)
    echom '[' .g:leetcode_name .'] "' .Q_fullname . g:leetcode_path_delimit .code_filename .'" loaded.'
    retu 1
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu

fu! leetcode#doQ#completeCmdArgs(arg_lead, cmd_line, cursor_pos)
  "" try
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
  "" cat /.*/ | endt
endfu

"" Local Var & Functions {{{1
fu! s:downQ(destination_dir_path, Q_fullname, Q_ID_or_name, Q_filename, code_filename)
  try
    let code_filenames = leetcode#utils#accessFiles#allCodeFiles(a:Q_fullname)
  
    cal system('mkdir -p "' .a:destination_dir_path .'"')
    if a:Q_ID_or_name =~? '\[\d\+\]\([ a-zA-Z0-9]\)\+'
      let Q_ID_or_name = matchstr(a:Q_ID_or_name, '\[\zs\d\+\ze\]')
    el
      let Q_ID_or_name = a:Q_ID_or_name
    en
    let Q_filepath = a:destination_dir_path . g:leetcode_path_delimit .a:Q_filename
    cal system('leetcode show -g -l ' .g:leetcode_lang .' -o "' .a:destination_dir_path .'" "'
          \.Q_ID_or_name .'"'.(filereadable(resolve(Q_filepath)) ? '' : ' > "' .Q_filepath .'"'))

    "" if the code filename is specified, change the name of the downloaded question
    "" accordingly
    if a:code_filename != ''
      "" get the name of the downloaded code template
      let new_code_filenames = leetcode#utils#accessFiles#allCodeFiles(a:Q_fullname)
      if len(code_filenames) == 0
        let down_code_filename = new_code_filenames[0]
      el
        for n in new_code_filenames
          for c in code_filenames
            if n != c | let down_code_filename = n | break | endif
          endfor
          if exists('down_code_filename') | break | endif
        endfor
      endif
      "" rename the downloaded code template
      cal system('mv "' .a:destination_dir_path .g:leetcode_path_delimit .down_code_filename .'" "'
          \.a:destination_dir_path .g:leetcode_path_delimit .a:code_filename .'"')
    en
  cat /.*/
    throw 'Error in creating the question and code file.'
  endt
endfu

fu! s:loadLastDownQ()
  try
    let last_down_Q_info = leetcode#utils#accessFiles#readLastDownQInfo()
    if !filereadable(last_down_Q_info[4])
      throw 'The last downloaded code file cannot be found.'
    endif
    let viewResult = s:viewQandCodeFiles(0, last_down_Q_info[1], last_down_Q_info[2], last_down_Q_info[3], last_down_Q_info[4])
    echom '[' .g:leetcode_name .'] "' .last_down_Q_info[0] . g:leetcode_path_delimit .last_down_Q_info[3] .'" loaded.'
    retu 1
  cat /.*/ | throw 'Error in loading the last downloaded question and code file.' | endt
endfu

fu! s:getDidQFullname(did_Q_ID_Name)
  "" a:did_Q_ID_Name is supposed to be in either one of the following 3 forms:
  "" (1) "[ID] Name". 
  "" (2) "ID". 
  "" (3) "Name".
  let root_path = leetcode#utils#path#getRootDir()
  let all_did_Q = leetcode#utils#accessFiles#allDidQ()
  if a:did_Q_ID_Name =~? '\[\d\+\]\([ a-zA-Z0-9]\)\+'
    "" when a:did_Q_ID_Name is in a form of "[ID] Name"
    cal map(all_did_Q, {key, val -> tolower(val)})
    let idx = index(all_did_Q, tolower(a:did_Q_ID_Name))
    if idx >= 0
      retu leetcode#utils#accessFiles#allDidQ()[idx]
    endif
  elseif a:did_Q_ID_Name =~ '^\s*\d\+\s*$' 
    "" when a:did_Q_ID_Name is in a form of "ID"
    cal map(all_did_Q, {key, val -> matchstr(val, '\[\zs\d\+\ze\]')})
    let idx = index(all_did_Q, matchstr(a:did_Q_ID_Name, '\s*\zs\d\+\ze\s*'))
    if idx >= 0
      retu leetcode#utils#accessFiles#allDidQ()[idx]
    endif
  el
    "" when a:did_Q_ID_Name is in a form of "Name"
    cal map(all_did_Q, {key, val -> tolower(matchstr(val, '\s*\[\d\+\]\s*\zs.*\ze$'))})
    let idx = index(all_did_Q, trim((a:did_Q_ID_Name)))
    if idx >= 0
      retu leetcode#utils#accessFiles#allDidQ()[idx]
    endif
  en
  throw 'No such did question.'
endfu

fu! s:viewQandCodeFiles(new_down, destination_dir_path, Q_filepath, code_filename, code_filepath)
    exe 'lcd ' .fnameescape(a:destination_dir_path)
    sil on!

    "" Load it using "edit" command when it is not the buffer in the current window to
    "" avoid an erase of the change(s) made to it
    let current_buffer_path = expand('%:p')
    if current_buffer_path == "" ? 1 : current_buffer_path != resolve(a:code_filepath)
      exe 'sil e! ' .fnameescape(a:code_filepath)
    endif

    if g:leetcode_view_Q
      try | exe 'sil bd!' .fnameescape(a:Q_filepath) 
      cat /.*/ | endt
      vs
      exe 'sil e! ' .fnameescape(a:Q_filepath)
      if a:new_down | cal s:RemoveHTMLTagsInCurrentQFile() | sil w | en
      exe 'lcd ' .fnameescape(a:destination_dir_path)
      wincmd p
    elseif !g:leetcode_view_Q && a:new_down
      exe 'sil e ' .a:Q_filepath
      cal s:RemoveHTMLTagsInCurrentQFile() | sil w
      b # | bd #
    en

    if a:new_down
      cal leetcode#lang#utils#addDependencies()
      sil w
    en
    cal leetcode#lang#utils#foldDependencies()

    try
      exe 'norm! `.' 
    cat /E20\|E19/ | cal leetcode#lang#utils#goToWhereCodeBegins()
    endt
    norm! zz

    if g:leetcode_auto_insert
      let current_col = col('.')
      norm! $
      let last_col = col('.')
      if current_col == last_col
        star! "" works like 'A' in normal mode
      el
        cal cursor(line('.'), current_col + 1)
        star ""works like 'i' in normal mode
      endif
    en

    retu 1
endf

fu! s:getQFullNameFromLeetcodeServer(Q_ID_or_name)
  "" Ensure it is under a valid directory so that
  "" the "leetcode-cli' commands may function properly
  try | sil pwd
  cat /E187/
    throw 'Present working directory is invalid. It is possibly deleted.'
  endtry
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
    throw 'Error in retriving the question. Please make sure the question ID or name is correct.'
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
  sil %sm@@@ge
  sil %sm@&#39;@'@ge
  sil %sm@&le;@<=@ge
  sil %sm@&ge;@>=@ge
  norm! gg
endf
