syntax  match  TodoDate        '\d\{2,4\}-\d\{2\}-\d\{2\}'       contains=VimwikiTodo
syntax  match  TodoDueDate 'due:\d\{2,4\}-\d\{2\}-\d\{2\}'   contains=VimwikiTodo
syntax  match  TodoProject    '\(^\|\W\)+[^[:blank:]]\+'        contains=VimwikiTodo
syntax  match  TodoContext    '\(^\|\W\)@[^[:blank:]]\+'        contains=VimwikiTodo

hi def link TodoDate           PreProc
hi def link TodoDueDate    VimWikiBold
hi def link TodoProject       Constant
hi def link TodoContext      Statement
