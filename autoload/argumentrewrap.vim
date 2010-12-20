function! RewrapFunctionCall()
    let s:splitExpression = '\v^(\s*)(.*)$'
    let s:indent = substitute( getline( "." ), s:splitExpression, '\1', '' )
    let s:input = substitute( getline( "." ), s:splitExpression, '\2', '' )
    let s:level = 0
    let s:start = 0
    
    for s:pos in range( 0, strlen( s:input ) )
        let s:char = strpart( s:input, s:pos, 1 )
        if s:char == "("
            if s:level == 0
                let s:start = s:pos + 1
                call setline( "." , s:indent . strpart( s:input, 0, s:pos + 1 ) )
            endif
            let s:level += 1
        elseif s:char == ")"
            let s:level -= 1
            if s:level > 0
                continue
            endif

            let s:argument = strpart( s:input, s:start, s:pos - s:start )
            let s:cleaned = substitute( s:argument, '\v^\s*(.\{-})\s*$', '\1', '' )
            let s:start = s:pos
            
            normal o
            call setline( ".", s:indent . s:cleaned )
            normal >>
        elseif s:char == ","
            if s:level != 1
                continue
            endif

            let s:argument = strpart( s:input, s:start, s:pos - s:start )
            let s:cleaned = substitute( s:argument, '\v^\s*(.\{-})\s*$', '\1', '' )
            let s:start = s:pos + 1
            
            normal o
            call setline( ".", s:indent . s:cleaned . "," )
            normal >>
        endif
    endfor

    normal o
    call setline( ".", s:indent . strpart( s:input, s:start ) )
endfun

nnoremap <silent> <leader>s :call RewrapFunctionCall()<CR>
