" Vim plug-in
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: June 13, 2010
" URL: http://peterodding.com/code/vim/easytags
" Requires: Exuberant Ctags (http://ctags.sf.net)
" License: MIT
" Version: 1.9

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3114 1 :AutoInstall: easytags.zip

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('g:loaded_easytags')
  finish
endif

" Configuration defaults. {{{1

if !exists('g:easytags_file')
  if has('win32') || has('win64')
    let g:easytags_file = '~\_vimtags'
  else
    let g:easytags_file = '~/.vimtags'
  endif
endif

if !exists('g:easytags_resolve_links')
  let g:easytags_resolve_links = 0
endif

if !exists('g:easytags_always_enabled')
  let g:easytags_always_enabled = 0
endif

if !exists('g:easytags_on_cursorhold')
  let g:easytags_on_cursorhold = 1
endif

if !exists('g:easytags_ignored_filetypes')
  let g:easytags_ignored_filetypes = '^tex$'
endif

" Before sourcing the rest of the plug-in first check that the location of the
" "Exuberant Ctags" program has been configured or that the program exists in
" one of its default locations.

if exists('g:easytags_cmd') && executable(g:easytags_cmd)
  let s:ctags_installed = 1
else
  " On Ubuntu Linux, Exuberant Ctags is installed as `ctags'. On Debian Linux,
  " Exuberant Ctags is installed as `exuberant-ctags'. On Free-BSD, Exuberant
  " Ctags is installed as `exctags'. Finally there is `ctags.exe' on Windows.
  for s:command in ['ctags', 'exuberant-ctags', 'esctags', 'ctags.exe']
    if executable(s:command)
      let g:easytags_cmd = s:command
      let s:ctags_installed = 1
      break
    endif
  endfor
  unlet s:command
endif

if !exists('s:ctags_installed')
  echomsg "easytags.vim: Exuberant Ctags unavailable! Plug-in not loaded."
  if executable('apt-get')
    echomsg "On Ubuntu & Debian Linux, you can install Exuberant Ctags"
    echomsg "by installing the package named `exuberant-ctags':"
    echomsg "  sudo apt-get install exuberant-ctags"
  else
    echomsg "Please download & install Exuberant Ctags from http://ctags.sf.net"
  endif
  finish
endif
unlet s:ctags_installed

" Let Vim know about the global tags file created by this plug-in.

" Parse the &tags option and get a list of all configured tags files including
" non-existing files (this is why we can't just call the tagfiles() function).
let s:tagfiles = xolox#option#split_tags(&tags)
let s:expanded = map(copy(s:tagfiles), 'expand(v:val)')

" Add the tags file to the &tags option when the user hasn't done so already.
if index(s:expanded, expand(g:easytags_file)) == -1
  let s:entry = g:easytags_file
  if (has('win32') || has('win64')) && s:entry =~ '^\~[\\/]'
    " On UNIX you can use ~/ in &tags but on Windows that doesn't work.
    let s:entry = expand(s:entry)
  endif
  let &tags = xolox#option#join_tags(insert(s:tagfiles, s:entry, 0))
endif

unlet! s:tagfiles s:expanded s:entry

" The :UpdateTags and :HighlightTags commands. {{{1

command! -bar -bang UpdateTags call easytags#update_cmd(<q-bang> == '!')
command! -bar HighlightTags call easytags#highlight_cmd()

" Automatic commands. {{{1

augroup PluginEasyTags
  autocmd!
  if g:easytags_always_enabled
    autocmd BufReadPost,BufWritePost * call easytags#autoload()
  endif
  if g:easytags_on_cursorhold
    autocmd CursorHold,CursorHoldI * call easytags#autoload()
  endif
  autocmd User PublishPre HighlightTags
augroup END

" }}}1

" Make sure the plug-in is only loaded once.
let g:loaded_easytags = 1

" vim: ts=2 sw=2 et
