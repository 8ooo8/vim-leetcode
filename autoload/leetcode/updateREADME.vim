"" API {{{1
fu! leetcode#updateREADME#updateREADME(...)
  try
    if a:0 >= 1
      throw ':LupdateREADME'
    endif
    
    "" Initialize the content of table to be put in README.md
    let content_of_table = []
    cal add(content_of_table, {'c1': 'Question', 'c2':'Difficulty', 'c3':'Acceptance', 'c4': 'Solution', 'c5': 'Time', 'c6': 'Space', 'c7': 'Note'})
    cal add(content_of_table, {'c1': '-', 'c2':'-', 'c3':'-', 'c4': '-', 'c5': '-', 'c6': '-', 'c7': '-'})
    let did_Q = leetcode#utils#accessFiles#allDidQ()
    for q in did_Q
      let url = s:getURL(substitute(q, '^\[\d\+\] ', '', ''))
      let code_files = leetcode#utils#accessFiles#allCodeFiles(q)
      let code_filepaths = []
      for c in code_files
        cal add(code_filepaths, q .g:leetcode_path_delimit .c)
        let Q_file_content = system('cat "' .g:leetcode_root_dir .g:leetcode_path_delimit . q .'/Q.txt"')
        let difficulty = matchstr(Q_file_content, '\c\* *\zs\(hard\|medium\|easy\)')
        let acceptance = printf('%.1f', str2float(matchstr(Q_file_content, '\c\* *\(hard\|medium\|easy\) *(\zs[0-9\.]\+\ze%)'))) .'%'
        cal add(content_of_table, {'c1': s:bindLinktoText(q, url), 'c2': difficulty, 'c3': acceptance, 'c4': s:bindLinktoText(c, q .g:leetcode_path_delimit .c), 'c5': '', 'c6': '', 'c7': ''})
      endfor
    endfor

    "" Read in the exisiting content in README.md and
    "" combine it with the content retrieved above.
    "" Then, overwrite the README.md with the combined content
    let readme_path = g:leetcode_root_dir .g:leetcode_path_delimit .'README.md'
    let readme_content = split(system('cat "' .readme_path .'"'), '\n')
    let table_top_line_content = '|'
    for i in range(len(content_of_table[0]) + 1)[1:]
      let table_top_line_content .= content_of_table[0]['c' .i] .'|'
    endfor
    let table_top_line_num = match(readme_content, table_top_line_content)
    if table_top_line_num == -1
      let old_table_exists = 0
      let table_top_line_num = len(readme_content)
    el
      let old_table_exists = 1
      let first_tuple_line_num = table_top_line_num + 2
      let last_tuple_line_num = match(readme_content, '^[^|]\|^$', first_tuple_line_num) - 1
      let last_tuple_line_num = last_tuple_line_num == -2 ? len(readme_content) - 1: last_tuple_line_num
    endif

    "" Read in the existing content in README.md to combine with the retrieved content
    if old_table_exists
      for old_content in readme_content[first_tuple_line_num:last_tuple_line_num]
        let old_content_in_list = split(old_content, '|', 1)
        let old_content_in_list = old_content_in_list[1:len(old_content_in_list) - 2]
        for new_content_idx in range(len(content_of_table))[2:]
          if old_content_in_list[3] == content_of_table[new_content_idx]['c4']
            let new_content_c_num = 5
            for old_content_chop in old_content_in_list[4:]
              let content_of_table[new_content_idx]['c' .new_content_c_num] .= old_content_chop
              if empty(old_content_chop) ||  old_content_chop[len(old_content_chop) - 1] != '\'
                let new_content_c_num += 1
              elseif old_content_chop[len(old_content_chop) - 1] == '\'
                let content_of_table[new_content_idx]['c' .new_content_c_num] .= '|'
              endif
            endfor
          endif
        endfor
      endfor
    endif

    "" Overwrite the content of table
    ""check if correct first last tuple
    if old_table_exists
      cal remove(readme_content, table_top_line_num, last_tuple_line_num)
    endif
    let prev_Q = ''
    let tuples_of_table = content_of_table[2:]
    cal sort(tuples_of_table, {i1, i2 -> 
          \float2nr(ceil(str2float(i1['c3'][:len(i1['c3']-2)]) - str2float(i2['c3'][:len(i2['c3']-2)])))}) "" sort by acceptance rates
    cal remove(content_of_table, 2, len(content_of_table) - 1)
    cal extend(content_of_table, tuples_of_table)
    for row_idx in range(len(content_of_table))
      let row = content_of_table[row_idx]
      if prev_Q == row['c1']
        for i in range(4)[1:]
          let row['c' .i] = ''
        endfor
        cal insert(readme_content, s:formattedRow(row), table_top_line_num + row_idx)
      el
        cal insert(readme_content, s:formattedRow(row), table_top_line_num + row_idx)
        let prev_Q = row['c1']
      endif
    endfor
    cal map(readme_content, {key, val -> escape(val, '"')})
    cal system('echo "' .s:list2Str(readme_content) .'" > "' .readme_path .'"')
  cat /.*/ | echoe '[' .g:leetcode_name .'] ' .v:exception | endt
endfu


"" Local Var & Functions {{{1
fu! s:getURL(Q_name)
  return 'https://leetcode.com/problems/' .tolower(substitute(substitute(a:Q_name, '[ -]\+', '-', 'g'), '[^a-zA-Z1-9\-]', '', 'g'))
endfu

fu! s:bindLinktoText(text, link)
  retu '[' .escape(a:text, '[]') .'](<' .a:link .'>)'
endfu

fu! s:formattedRow(raw_row)
  let formattedRow = '|'
  for i in range(len(a:raw_row) + 1)[1:]
    let formattedRow .= a:raw_row['c' .i] .'|'
  endfor
  retu formattedRow
endfu

fu! s:list2Str(list)
  let str = ''
  for l in a:list[0 : len(a:list) - 2]
    let str .= l . "\n"
  endfor
  retu str .a:list[len(a:list) - 1]
endfu
