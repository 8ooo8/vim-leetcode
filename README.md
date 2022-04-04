# vim-leetcode

A manager of your Leetcode question and solution files in Vim.

![Video demo][video-demo]

This plugin downloads, loads and manages your Leetcode question and solution files _(check [this example repository][vim-leetcode-example] to view the file structure of the leetcode files and the README.md generated by this plugin)_. To make the experience of doing Leetcode questions on vim tremendously smooth, this plugin also offers pretty much convenient features, e.g. display the question file in a vertical split window next to the solution file (configurable), automatically move your cursor to your last edit position when you re-open an old solution file, automatically add code to import common libraries so that syntax checking plugins such as [syntastic][syntastic-repo] may work, etc. What is more, it is made to not pollute your undo history, search history, change list and jump list. Therefore, you don't need to worry about the dysfunction of the built-in mappings such as `g;`, `<C-o>` and `u`.

## Requirement

- POSIX shell commands. Windows users may need to install tools such as [cygwin].
- Have [leetcode-cli][leetcode-cli-repo] installed and sign in.
    - ["skygragon/leetcode-cli"][leetcode-cli-obsolete-repo] is no longer in maintenance. Please fetch ["leetcode-tools/leetcode-cli"][leetcode-cli-repo].
    - If encountering problems in using it, check the status of its plugins. Please be reminded that cookie plugin is required for logging in a leetcode account.

        
## Installation

### Without plugin manager

For your reference, in an Unix-like system:

```bash
mkdir -p ~/.vim/plugged
cd ~/.vim/plugged
git clone https://github.com/8ooo8/leetcode.git
```

In ~/.vimrc, add below statement.

```vim
set runtimepath^=~/.vim/plugged/leetcode
```

### With plugin manager

For example, with manager "vim-plug":

```vim
Plug '8ooo8/leetcode'
```


## Commands

### The `LdoQ` command

```
:LdoQ [Question-ID-or-Name] [Code-Filename]
```

- **Load the specified leetcode question and solution files. Download them if they do not exist.**
- If the specified files do not exist, download the question file and solution template file using [leetcode-cli][leetcode-cli-repo].
- The programming language of the solution template file is determined by [`g:leetcode_lang`](#the-gleetcode_lang-option).
- The location where the files are stored is determined by [`g:leetcode_root_dir`](#the-gleetcode_root_dir-option).
- This command loads the specified solution file and possibly also the question file in a vertical split window, depending on the value of [`g:leetcode_view_Q`](#the-gleetcode_view_q-option).
- Usages:
  - (1) `LdoQ`
    - **Load the last downloaded solution file** and possibly also its corresponding question file in a split window.
  - (2) `LdoQ Question-ID-or-Name`
    - **Load the solution file lastly opened by the command `LdoQ` among those solution file(s) for the specified question** and possibly also its corresponding question file in a split window.
    - **If no such file, download the question file as well as the solution template file** and load. The name of the solution file is given by [leetcode-cli][leetcode-cli-repo].
  - (3) `LdoQ Question-ID-or-Name Code-Filename`
    - **Load the specified solution file** and possibly also its corresponding question file in a split window.
    - **If no such file, download the question file as well as the solution template file** and load. The solution file will be named as `Code-Filename`.
  - The parameter `Question-ID-or-Name` has to be in the forms of "ID", "Name" or "[Question-ID] Question-Name". Case-insensitive.
  - Press **`<Tab>` to auto complete the parameters with the existing question and solution files**; **`<C-d>` to list the available parameters**.
- Check [this example repostory][vim-leetcode-example] to view the file structure.
- This command adds code to the newly downloaded solution files to import the common libraries as well as the classes provided by the questions so that syntax checking apps, such as ["syntastic"][syntastic-repo], still work when the mentioned libraries and classes are used.
- This command closes all other windows in the current tab.
- This command changes the present working directory of the window(s) into the directory of the leetcode file(s).
- This command moves the cursor to the position of the last change made to the loaded solution file. If it is a newly downloaded solution file, move the cursor to where users' solution should start. Afterwards, depending on the value of [`g:leetcode_auto_insert`](#the-gleetcode_auto_insert-option), possibly also automatically enter Insert mode.
- This command does not pollute the change list, jump list, search history and undo history. Hence, built-in mappings such as `g;`, `<C-O>` and `u` are not affected.

### The `Lrename` command

```
:LrenameCodeFile {New-Name}
```

- **Rename the solution file in the current window** with `{New-Name}`.

### The `Ltest` command

```
:Ltest [Test-Case]
```

- **Test the solution file in the current window** with the `[Test-Case]`; with default test case if `[Test-Case]` omitted.
- Before submitting the solution to test, the code inserted for syntax check by [`LdoQ`](#the-ldoq-command) is commented to avoid an influence to the test. Upon the finish of the test, the code is uncommented and the solution file is saved. Change list, jump list, search history and undo history are unpolluted. Hence, built-in mappings such as `g;`, `<C-O>` and `u` are not affected.
- Use '\n' to separate the parameters, e.g. `:Ltest ParameterA\nParameterB`.

### The `Lsumbit` command

```
:Lsubmit
```

- **Sumbit the solution file in the current window**.
- Before submitting the code, the code inserted for syntax check by [`LdoQ`](#the-ldoq-command) is commented to avoid an influence to the submission. Upon the finish of the submission, the code is uncommented and the solution file is saved. Change list, jump list, search history and undo history are unpolluted. Hence, built-in mappings such as `g;`, `<C-O>` and `u` are not affected.

### The `LprintLastRunResult` command

```
:LprintLastRunResult
```
- **Show the last successful [`test`](#the-ltest-command) or successful [`submit`](#the-lsumbit-command) result**.

### The `LupdateREADME` command

```
:LupdateREADME
```

- **Update the table of content(see below) in README.md**; if no table found, append a table to README.md.
  ![Table of content in README.md][README-table-img]
- The entries in the "Question" column are linked to the Leetcode official web pages which show the same questions; and the entries in the "Solution" column are linked to the corresponding solution files.
- The content in the columns "Question", "Difficulty", "Acceptance" and "Solution" are automatically generated while the rest needs to be input manually.
- The tuples are sorted by their acceptance rates.
- Check this [example][vim-leetcode-example] for a clearer view of this command.

    
## Options

### The `g:leetcode_root_dir` option


```vim
let g:leetcode_root_dir = 'the_root_directory_of_leetcode_files'
```

- Set this to **determine where to store the leetcode question and solution files, as well as where to search for the existing leetcode files**.
- If this variable does not exist, the present working directory of the current window in Vim will be used.

### The `g:leetcode_lang` option

```vim
let g:leetcode_lang = 'cpp'
```

- Set this to **determine which programming language to be used to do the leetcode questions**.
- Default value: 'cpp'
- Currently supported language(s): 'cpp'

### The `g:leetcode_view_Q` option

```vim
let g:leetcode_view_Q = 1
```

- Set **1 to also load the question file in a vertical split window** when [`LdoQ`](#the-ldoq-command) command is used to load a solution file; 0 to turn this off.
- Default value: 1

### The `g:leetcode_auto_insert` option

```vim
let g:leetcode_auto_insert = 1
```

- Set **1 to automatically enter insert mode after loading a solution file** using command `LdoQ` (like auto pressing `a` to enter insert mode); 0 to turn this off.
- Default value: 1



## License
[MIT][MIT-license]

[MIT-license]: LICENSE
[README-table-img]: docs/screenshots/v0.4.0/README_table.png
[video-demo]: docs/screenshots/v0.1.0/demo.gif

[cygwin]: https://www.cygwin.com/
[leetcode-cli-obsolete-repo]: https://github.com/skygragon/leetcode-cli
[leetcode-cli-plugin-tutorial]: https://skygragon.github.io/leetcode-cli/commands#plugin
[leetcode-cli-repo]: https://github.com/leetcode-tools/leetcode-cli/
[syntastic-repo]: https://github.com/vim-syntastic/syntastic
[vim-leetcode-example]: https://github.com/8ooo8/algo-practices/tree/master/leetcode


