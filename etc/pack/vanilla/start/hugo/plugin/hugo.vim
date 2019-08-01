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

function! Link(domain, copy)
  let path = substitute(@%,   '\v^content/', a:domain . '/', '')
  let path = substitute(path, '\v\.md$', '/', '')
  if a:copy
    let @+ = path
  endif
  echom path
endfunction
command! -bang Link      call Link('https://blog.afoolishmanifesto.com', <bang>0)
command! -bang LinkShort call Link('https://frew.co',                    <bang>0)
command! -bang LinkLocal call Link('http://127.0.0.1:1313',              <bang>0)
command! -bang LinkRel   call Link(''                     ,              <bang>0)

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

function! ExpandTemplate()
   %s/\~\~CURDATE\~\~/\=strftime("%FT%T")/ge
   %s/\~\~GUID\~\~/\=systemlist("uuidgen")[0]/ge
endfunction

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
   au User ProjectionistApplyTemplate call ExpandTemplate()
augroup END

nnoremap g<C-]> :TaggedWord<CR>
