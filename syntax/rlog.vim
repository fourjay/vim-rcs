syntax case match
syntax match rcslogDelim  '^-\{4,}$'
syntax match rcslogDelim  '^=\{4,}+$'
syntax match rcslogValues '^revision [0-9.]\+$' contains=rcslogNumber
syntax match rcslogFile   '^\(RCS file\|Working file\): .\+' contains=rcslogString
syntax match rcslogValues '^\(head\|branch\|locks\|access list\|symbolic names\|keyword substitution\|total revisions\|description\|locked by\|date\):\( [^;]\+\)\=' contains=rcslogString
syntax match rcslogValues '\(author\|state\): [^;]\+;'me=e-1 contains=rcslogString
syntax match rcslogValues '\(lines\|selected revisions\): [ 0-9+-]\+$' contains=rcslogNumber
syntax match rcslogString ': [^;]\+'ms=s+2 contained contains=rcslogNumber
syntax match rcslogNumber '[+-]\=[0-9.]\+' contained
highlight default link rcslogKeys    Comment
highlight default link rcslogDelim   PreProc
highlight default link rcslogValues  Identifier
highlight default link rcslogFile    Type
highlight default link rcslogString  String
highlight default link rcslogNumber  Number
highlight default link rcslogCurrent NonText
