function! argumentrewrap#IsolateParenthesisToMatch( input )
    let l:pos = 0
    let l:firstLevelParenthesis = ""
    let l:count = { "(": 0, "{": 0, "[": 0 }
    let l:opening = '\((\|\[\|{\)'
    let l:closing = '\()\|\]\|}\)'

    
    for l:pos in range( 0, strlen( a:input ) )
        let l:char = strpart( a:input, l:pos, 1 )
        if l:char =~ l:opening
            let l:match = matchstr( l:char, l:opening )
            let l:count[l:match] += 1
            if argumentrewrap#ParenthesisLevel( l:count ) == 1
                let l:firstLevelParenthesis = l:match
            endif
        elseif l:char =~ l:closing
            let l:match = matchstr( l:char, l:closing )
            let l:count[argumentrewrap#MapClosingToOpeningParenthesis( l:match )] -= 1
        elseif l:char == "," && argumentrewrap#ParenthesisLevel( l:count ) == 1
            return { "open": l:firstLevelParenthesis, "close": argumentrewrap#MapOpeningToClosingParenthesis( l:firstLevelParenthesis ) }
        endif
    endfor
    
    return { "open": "", "close": "" }
endfunc

function! argumentrewrap#MapOpeningToClosingParenthesis( opening )
    let l:paranthesisMapping = { "(": ")", "[": "]", "{": "}" }
    return l:paranthesisMapping[a:opening]
endfunc

function! argumentrewrap#MapClosingToOpeningParenthesis( closing )
    let l:paranthesisMapping = { ")": "(", "]": "[", "}": "{" }
    return l:paranthesisMapping[a:closing]
endfunc

function! argumentrewrap#IsolateIndentation( input )
    return substitute( a:input, '\v^(\s*).*$', '\1', "" )
endfunc

function! argumentrewrap#ParenthesisLevel( count )
    return a:count["("] + a:count["["] + a:count["{"]
endfunc

function! argumentrewrap#TrimArgument( argument )
    return substitute( a:argument, '^\s*\(.\{-}\)\s*,\{0,1\}\s*$', '\1', '' )
endfunc

function! argumentrewrap#ExtractByDelimiter( input, start, delimiter )
    let l:pos = 0
    for l:pos in range( a:start, strlen( a:input ) )
        let l:char = strpart( a:input, l:pos, 1 )
        let l:search = ""
        for l:search in a:delimiter
            if l:char == l:search
                return { "pos": l:pos, "excerpt": strpart( a:input, a:start, l:pos - a:start + 1 ), "delimiter": l:char }
            endif
        endfor
    endfor
    return ""
endfunc

function! argumentrewrap#AppendIndentedLine( line )
    call append( ".", a:line )
    call cursor( line( "." ) + 1, 0 )
    normal >>
endfunc

function! argumentrewrap#RewrapArguments()
    let l:input = getline( "." )
    let l:parenthesis = argumentrewrap#IsolateParenthesisToMatch( l:input )
    if l:parenthesis.open == ""
        " There is no parenthesis with arguments. Therfore nothing to do.
        return
    endif
    
    " The indentation level is needed for further handling
    let l:indentation = argumentrewrap#IsolateIndentation( l:input )

    " Extract startline and set it
    let l:segment = argumentrewrap#ExtractByDelimiter( l:input, strlen( l:indentation ), [l:parenthesis.open] )
    call setline( ".", l:indentation . l:segment.excerpt )
    
    let l:search = ["(", "[", "{", ",", "}", "]", ")"]
    let l:count = { "(": 0, "[": 0, "{": 0 }
    let l:count[l:parenthesis.open] += 1
    let l:currentArgument = ""
    while l:count[l:parenthesis.open] > 0
        let l:segment = argumentrewrap#ExtractByDelimiter( l:input, l:segment.pos + 1, l:search )

        if l:segment.delimiter == "(" || l:segment.delimiter == "[" || l:segment.delimiter == "{"
            let l:count[l:segment.delimiter] += 1
            let l:currentArgument = l:currentArgument . l:segment.excerpt
        elseif l:segment.delimiter == ")" || l:segment.delimiter == "]" || l:segment.delimiter == "}"
            let l:openingParenthesis = argumentrewrap#MapClosingToOpeningParenthesis( l:segment.delimiter ) 
            let l:count[l:openingParenthesis] -= 1
            let l:currentArgument = l:currentArgument . l:segment.excerpt
        elseif l:segment.delimiter == ","
            if argumentrewrap#ParenthesisLevel( l:count ) == 1
                let l:cleaned = argumentrewrap#TrimArgument( l:currentArgument . l:segment.excerpt )
                let l:currentArgument = ""
                call argumentrewrap#AppendIndentedLine( l:indentation . l:cleaned . "," )
            else
                let l:currentArgument = l:currentArgument . l:segment.excerpt
            endif
        endif
    endwhile
     
    call argumentrewrap#AppendIndentedLine( l:indentation . argumentrewrap#TrimArgument( strpart( l:currentArgument, 0, strlen( l:currentArgument ) - 1 ) ) )
    call append( ".", l:indentation . l:parenthesis.close . strpart( l:input, l:segment.pos + 1 ) )
    call cursor( line( "." ) + 1, 0 )
endfunc
