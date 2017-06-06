if exists('g:loaded_hugo') || &cp || v:version < 700
  finish
endif
let g:loaded_hugo = 1

command! -nargs=1 Tagged  cgetexpr system('bin/tag-files <args>') | cwindow
command! -nargs=1 TLagged lgetexpr system('bin/tag-files <args>') | cwindow

function! TaggedWord()
  setlocal iskeyword+=45
  execute 'Tagged ' . expand('<cword>')
  setlocal iskeyword-=45
endfunction
command! TaggedWord call TaggedWord()

function! TLaggedWord()
  setlocal iskeyword+=45
  execute 'TLagged ' . expand('<cword>')
  setlocal iskeyword-=45
endfunction
command! TLaggedWord call TLaggedWord()

command! Chrono cgetexpr system('bin/quick-chrono') | cwindow

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
   au BufReadPost quickfix setlocal nowrap

   au BufReadPost quickfix
     \ if w:quickfix_title =~ "^:cgetexpr system('bin/" |
       \ setl modifiable |
       \ silent exe ':%s/\v^([^|]+\|){2}\s*//g' |
       \ setl nomodifiable |
     \ endif
augroup END
