"" @return  [{Cmd}, [arg1 [,arg2 [,...]]]]
fu! leetcode#utils#cmd#getCmdAndArgList(CmdLine)
  let list = []
  let cmd_or_arg_start_idx = 0
  let is_in_between_args_or_cmd = 0
  let escape_next_char = 0
  let cursor = 1
  for c in split(a:CmdLine, '\zs')[cursor:] 
    if c == ' ' && !escape_next_char && !is_in_between_args_or_cmd
      cal add(list, strcharpart(a:CmdLine, cmd_or_arg_start_idx, cursor - cmd_or_arg_start_idx))
      let is_in_between_args_or_cmd = 1
    el
      if c != ' ' && is_in_between_args_or_cmd
        let is_in_between_args_or_cmd = 0
        let cmd_or_arg_start_idx = cursor
      en
      if c == '\' && !escape_next_char
        let escape_next_char = 1
      el
        let escape_next_char = 0
      en
    en
    let cursor += 1
  endfor
  if !is_in_between_args_or_cmd
    cal add(list, strcharpart(a:CmdLine, cmd_or_arg_start_idx, cursor - cmd_or_arg_start_idx))
  el
    cal add(list, '')
  en
  
  retu list
endfu
