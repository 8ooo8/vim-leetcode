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
  norm! gg   
  try | exe 'sil ' .s:depend_location
  cat /E486/ 
    echoe '[' .g:leetcode_name .'] ' .'Error in locating the position to add dependencies'
  endt
  cal append(line('.'), s:dependencies)
endfu

"" SUBJECT TO REVISE FOR A HIGHER SEARCH ACCURACY.
fu! leetcode#lang#cpp#foldDependencies()
  set foldmethod=manual
  try 
    norm! gg
    let first_fold_line = search(escape(s:dependencies[0], '/*[]'))
    if foldclosed(first_fold_line) == -1
      exe 'sil /\m\C\s*\/\{-,2}\s*' .s:dependencies[2] .'\s*$'
      let last_fold_line = searchpair('\C\s*#ifdef\>', '', '\C\s*endif\>', 'W')
      exe 'norm! ' .first_fold_line .'G' .(last_fold_line - first_fold_line + 1) .'zF'
    en
  cat /E486/
    echoe '[' .g:leetcode_name .']' .'Error in locating the dependencies to fold'
  endt
endfu

fu! leetcode#lang#cpp#goToWhereCodeBegins()
  sil /\m\%$/ | exe 'sil ' .s:code_begin_location
endfu
