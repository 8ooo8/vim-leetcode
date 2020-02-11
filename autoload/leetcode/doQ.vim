"" API {{{1
"" @param   a:1 Question ID or Name
""          a:2 Optional code filename
fu! leetcode#doQ#doQ(...) 
  if a:0 < 1 || a:0 > 2
    echoe '[' .g:leetcode_name .'] :LdoQ {Question ID or Name} [code filename]'
    retu -1
  endif
  if !leetcode#lang#utils#langIsSupported(g:leetcode_lang)
    echoe '[' .g:leetcode_name .'] The language specified by "g:leetcode_lang" is not supported.'
    retu -2
  endif

  "" Initialize the names & paths of the question and code files
  let root_path = leetcode#utils#path#getRootDir()
  let Q_fullname = s:getQFullName(a:1)
  if Q_fullname == -1
    echoe '[' .g:leetcode_name .'] Error in retriving the question. Please make sure the question ID or name is correct.'
    retu -3
  endif
  let destination_dir_path = root_path .g:leetcode_path_delimit .Q_fullname
  let did_this_Q = isdirectory(destination_dir_path)
  let Q_filename = 'Q.txt'
  let Q_filepath = destination_dir_path .g:leetcode_path_delimit .Q_filename
  if !did_this_Q && a:0 == 1
    try
      exe 'sil !mkdir -p "' .destination_dir_path .'"'
      exe 'lcd ' .destination_dir_path
      exe 'sil !leetcode show -g -l ' .g:leetcode_lang .' "' .a:1 .'" > ' .Q_filename
    cat /*/
      echoe '[' .g:leetcode_name .'] Error in creating the question and code file. '
      retu -4
    endt
  en
  let existing_code_filenames = split(globpath(leetcode#utils#path#escape(destination_dir_path), '*.' .g:leetcode_lang), '\n')
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
  
  let viewResult = s:viewQandCodeFiles(did_this_Q, destination_dir_path, Q_filepath, code_filename, code_filepath)
  if viewResult == -1
    echoe '[' .g:leetcode_name .'] More than one match of code file in the buffer list'
    retu -6
  el
    echom '[' .g:leetcode_name .'] "' .Q_fullname . g:leetcode_path_delimit .code_filename .'" loaded.'
    retu 0
  endif
endfu

"" Local Var & Functions {{{1
fu! s:viewQandCodeFiles(did_this_Q, destination_dir_path, Q_filepath, code_filename, code_filepath)
  exe 'lcd ' .leetcode#utils#path#escape(a:destination_dir_path)
  sil on!
  try
    "" Try :b before :e to avoid an erase of the changes made to the code
    "" file buffer, which occurs when it is the current buffer
    exe 'sil b! ' .leetcode#utils#path#escape(a:code_filename)
    set bl
  cat /E93/
    ""when more than one match in the buffer list
    retu -1
  cat /E94/
    ""when no matched buffer
    exe 'sil e! ' .leetcode#utils#path#escape(a:code_filepath) 
  endt

  if g:leetcode_viewQ
    vs
    exe 'sil e' .leetcode#utils#path#escape(a:Q_filepath)
    if !a:did_this_Q | cal s:RemoveHTMLTagsInCurrentQFile() | sil w | en
    exe 'lcd ' .leetcode#utils#path#escape(a:destination_dir_path)
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

fu! s:getQFullName(Q_ID_or_name)
  "" Ensure it is under a valid directory so that
  "" the "leetcode-cli' commands may function properly
  exe 'lcd ' .g:leetcode_valid_dir_path
  let Q = system('leetcode show "' .a:Q_ID_or_name .'"')
  let Q_in_list_form = split(Q, '\n')
  for q in Q_in_list_form
    if q =~ '^\s*\[\d\+\][- \tA-Za-z0-9\[\]()]\+$'
      let Q_fullname = q
      break
    endif
  endfor
  if exists('Q_fullname')
    retu substitute(Q_fullname, '^\s*\|[ \t\n\r]*$', '', 'g')
  el
    return -1
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
