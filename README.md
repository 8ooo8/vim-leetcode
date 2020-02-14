# Leetcode
Leetcode source code file structer in Vim.

## Requirement
* Basic Unix shell commands. Windows users may be interested in [cygwin][1].
* Unset Vi-compatible.
* Have [leetcode-cli][2] installed.

## Installation
### Without Plugin Manager
For your reference, in Unix-like system:
```
mkdir -p ~/.vim/plugged
cd ~/.vim/plugged
git clone https://gitlab.com/ben_coder/leetcode.git
```
In ~/.vimrc, add below statements.
```
source ~/.vim/plugged/leetcode/plugin/leetcode.vim
set runtimepath^=~/.vim/plugged/leetcode
```

## Quick Start
```
:LdoQ [Question ID or Name] [Code Filename]
```
* Load the specified question and the code file. Download the question and the code template when no code file or specified code file cannot be found.
* if `g:leetcode_viewQ` euqals 1, this command does not only load the code file for that question, but also the question file.
* When `[Question ID or Name]` and `[Code Filename]` both omitted, load the last downloaded code file.
* When `[Code Filename]` omitted, load one of the associated code files. Download the question and the code template if no existing code file.
* When none omitted, load the specified code file or download a code template if it does not exist.
* Press <Tab> to complete the `[Question ID or Name]` and `[Code Filename]` for existing questions and code files; <C-D> to list the available options.
* `[Question ID or Name]` in 3 forms: `"ID"`, `"Name"` and `"[ID] Name"`. For the frist 2 forms, complete match is required, i.e. `"5"` may not mean `"50"`; the last form primarily for loading existing questions and code files and it accepts a partial match.
```
:LrenameCodeFile {New Name}
```
* Rename the code file in the current window with `{New Name}`
```
:Lsubmit
```
* Sumbit the code file in the current window
```
:Ltest [One Test Case]
```
* Test the code file in the current window with the `[One Test Case]`; with default test case if `[One Test Case]` omitted.

## DETAILS TO BE ADDED LATER


[1]: https://www.cygwin.com/
[2]: https://github.com/leetcode-tools/leetcode-cli/
