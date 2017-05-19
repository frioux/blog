if exists('g:loaded_hugo') || &cp || v:version < 700
  finish
endif
let g:loaded_hugo = 1

function! Tagged(tag)
  exe 'args `bin/tag-files ' . a:tag . '`'
endfunction
command! -nargs=1 Tagged call Tagged('<args>')

function! TLagged(tag)
  exe 'argl `bin/tag-files ' . a:tag . '`'
endfunction
command! -nargs=1 TLagged call TLagged('<args>')

function! TaggedWord()
  set iskeyword+=45
  let l:tmp = @m
  normal "myiw
  set iskeyword-=45
  call Tagged(@m)
  let @m = l:tmp
endfunction
command! TaggedWord call TaggedWord()

function! TLaggedWord()
  set iskeyword+=45
  let l:tmp = @m
  normal "myiw
  set iskeyword-=45
  call TLagged(@m)
  let @m = l:tmp
endfunction
command! TLaggedWord call TLaggedWord()

function! Chrono()
  let l:cmd = 'args `bin/q --sql SELECT\ filename\ FROM\ articles\ ORDER\ BY\ date\ desc`'
  exe l:cmd
endfunction
command! Chrono call Chrono()

function! CompleteTags(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\w\|-'
      let start -= 1
    endwhile
    return start
  else
    if match(getline('.'), "tags:") == -1
      return []
    endif

    return systemlist('bin/tags ' . a:base . '%')
  endif
endfun

augroup hugo
   autocmd!

   au FileType markdown execute 'setlocal omnifunc=CompleteTags'
augroup END
