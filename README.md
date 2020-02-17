# Leetcode
A Leetcode question and code file manager in Vim.

## Requirement
* Basic Unix shell commands. Windows users may be interested in [cygwin][1].
* Unset Vi-compatible.
* Have [leetcode-cli][2] installed and sign in.
    * ["skygragon/leetcode-cli"][3] is no longer in maintenance. Please fetch ["leetcode-tools/leetcode-cli"][2].
    * If encountering a problem of "Invalid password", install and enable a cookie [plugin][4]. The plugin will make use of the cookie in your web browser to pass through the recaptcha checking.

## Installation
### Without Plugin Manager
For your reference, in Unix-like system:
```bash
mkdir -p ~/.vim/plugged
cd ~/.vim/plugged
git clone https://gitlab.com/ben_coder/leetcode.git
```
In ~/.vimrc, add below statement.
```vim
set runtimepath^=~/.vim/plugged/leetcode
```

## Quick Start
```
:LdoQ [Question ID or Name] [Code Filename]
```
* __Load the specified question and the (specified) code file__ inside the _"Root Directory"_. Download the question and the code template when no existing code file for the specified question or the specified code file cannot be found.
* _"Root Directory"_ is indicated by the value of `g:leetcode_root_dir`. If this variable does not exist, the present working directory of the current window in this Vim session will be used.
* Using this command to download a question file and its corresponding code template would create a directory with a name _"[Question_ID] Question_Name"_ under _"Root Directory"_, and have the downloaded leetcode files placed inside this directory.
* If `g:leetcode_viewQ` euqals 1, this command does not only load the code file for that question, but also the question file.
* When `[Question ID or Name]` and `[Code Filename]` both omitted, load the last downloaded code file.
* When `[Code Filename]` omitted, load one of the associated code files. Download the question and the code template if no existing code file.
* When none omitted, load the specified code file or download a code template if it does not exist.
* Press <Tab> to complete the `[Question ID or Name]` and `[Code Filename]` for existing questions and code files; <C-D> to list the available options.
* `[Question ID or Name]` in 3 forms: `ID`, `Name` and `[ID] Name`. For the frist 2 forms, complete match is required, i.e. `5` may not mean `50`; the last form primarily for loading existing questions and code files and it accepts a partial match.
```
:LrenameCodeFile {New Name}
```
* __Rename the code file in the current window__ with `{New Name}`
```
:Lsubmit
```
* __Sumbit the code file in the current window__
```
:Ltest [One Test Case]
```
* __Test the code file in the current window__ with the `[One Test Case]`; with default test case if `[One Test Case]` omitted.

## Options
```vim
let g:leetcode_root_dir = 'the_root_directory_of_leetcode_files'
```
* Set this to __determine where to store the leetcode question and code files, as well as where to search for the existing leetcode files__.
* If this variable does not exist, the present working directory of the current window in Vim will be used.
```vim
let g:leetcode_lang = 'cpp'
```
* Set this to __determine which language to be used in doing leetcode questions__.
* Default value: 'cpp'
* Currently supported language(s): 'cpp'
```vim
let g:leetcode_viewQ = 1
```
* Set __1 to open a vertical split window for the question file__ when `LdoQ` command is used to load a code file; 0 to turn this off.
* Default value: 1
```vim
let g:leetcode_autoinsert = 1
```
* Set __1 to automatically enter insert mode after loading a code file__, possilby and a question file, using command `LdoQ`; 0 to turn this off.
* Default value: 1


## DETAILS TO BE ADDED LATER


[1]: https://www.cygwin.com/
[2]: https://github.com/leetcode-tools/leetcode-cli/
[3]: https://github.com/skygragon/leetcode-cli
[4]: https://skygragon.github.io/leetcode-cli/commands#plugin
