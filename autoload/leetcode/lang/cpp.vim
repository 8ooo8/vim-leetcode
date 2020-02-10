let s:lang = 'cpp'
let s:dependencies = [
      \'/*** [' .g:leetcode_name .'] For Local Syntax Checking ***/',
      \'#define DEPENDENCIES', '#ifdef DEPENDENCIES',
      \'#include <iostream>', '#include <iomanip>',
      \'#include <istream>', '#include <ostream>',  
      \'#include <sstream>',  '#include <stdio.h>',  
      \'#include <vector>',  '#include <stack>',
      \'#include <map>',  '#include <unordered_map>',  
      \'#include <set>',  '#include <unordered_set>',
      \'#include <list>',  '#include <forward_list>', 
      \'#include <array>', '#include <deque>',  
      \'#include <queue>',  '#include <bitset>', 
      \'#include <utility>',  '#include <algorithm>',  
      \'#include <string>', '#include <limits>',  
      \'using namespace std;', '#endif', ''] 
let s:depend_location = '/\mclass\s\+solution\c\s\+{/-' 
let s:code_begin_location = '?\m)\s*{?+'

fu! leetcode#lang#cpp#addDependencies()
  keepj norm! gg   
  try | exe 'keepp sil ' .s:depend_location
  cat /E486/ 
    echoe '[' .g:leetcode_name .'] Error in locating the position to add dependencies'
    retu -1
  endt
  "" Add dependencies and make it non-undoable
  let old_ul = &ul
  setlocal ul=-1
  keepj cal append(line('.'), s:dependencies)
  exe 'setlocal ul='.old_ul
  retu 0
endfu

fu! leetcode#lang#cpp#foldDependencies()
  set foldmethod=manual
  try 
    keepj norm! gg
    let first_fold_line = search(escape(s:dependencies[0], '/*[]'))
    if foldclosed(first_fold_line) == -1
      exe 'keepj keepp sil /\m\C\s*\/\{-,2}\s*' .s:dependencies[2] .'\s*$'
      let last_fold_line = searchpair('\C\s*#ifdef\>', '', '\C\s*endif\>', 'W')
      exe 'keepj norm! ' .first_fold_line .'G' .(last_fold_line - first_fold_line + 1) .'zF'
    en
  cat /E486/
    echoe '[' .g:leetcode_name .'] Error in locating the dependencies to fold'
  endt
endfu

fu! leetcode#lang#cpp#goToWhereCodeBegins()
  keepj keepp sil /\m\%$/
  exe 'sil ' .s:code_begin_location
endfu

fu! leetcode#lang#cpp#commentDependencies()
  exe 'keepj keepp sil %sm@\C^\(.*' .s:dependencies[1] .'.*\)$@//\1@'
endfu

fu! leetcode#lang#cpp#uncommentDependencies()
  exe 'keepj keepp sil %sm@\C\s*\zs/*\ze.*' .s:dependencies[1] .'.*$@@'
endfu
