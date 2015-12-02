set ignorecase
set smartcase
set hlsearch
set incsearch

nmap ,w :w<CR>
nmap ,/ /asdfio@#41248*afd<CR>

nmap <C-O> :vsc View.NavigateBackward<CR>
nmap <C-I> :vsc View.NavigateForward<CR>
vmap <C-O> :vsc View.NavigateBackward<CR>
vmap <C-I> :vsc View.NavigateForward<CR>

nmap 'vo :vsc VAssistX.VAOutline<CR>
nmap 'vr :vsc VAssistX.FindReferencesResults<CR>
nmap 'vp :vsc View.Output<CR>
nmap 'vs :vsc View.SolutionExplorer<CR>
nmap 'vb :vsc View.BookmarkWindow<CR>
vmap 'c :vsc VAssistX.SelectionToggleLineComment<CR>
vmap 'b :vsc VAssistX.SelectionToggleBlockComment<CR>
nmap ,j :vsc VAssistX.RefactorDocumentMethod<CR>
nmap ,i :vsc VAssistX.OpenCorrespondingFile<CR>
vmap ,( :vsc VAssistX.SurroundSelectionWithParentheses<CR>
vmap ,{ :vsc VAssistX.SurroundSelectionWithBraces<CR>
vmap ,# :vsc VAssistX.SurroundSelectionWithIfdefOrRegion<CR>
nmap ,f :vsc Edit.FormatDocumentAstyle<CR>
vmap ,f :vsc Edit.FormatSelectionAstyle<CR>

nmap 'rn :vsc VAssistX.RefactorRename<CR>
nmap 'rf :vsc VAssistX.RefactorRenameFiles<CR>

nmap 'ff :vsc VAssistX.OpenFileInSolutionDialog<CR>
nmap 'fr :vsc VAssistX.FindReferences<CR>
nmap 'fR :vsc VAssistX.FindReferencesinFile<CR>
nmap 'fs :vsc VAssistX.FindSymbolDialog<CR>
vmap 'fr :vsc VAssistX.FindSelected<CR>
nmap 'fn :vsc VAssistX.FindNextbyContext<CR>
nmap 'fp :vsc VAssistX.FindPreviousbyContext<CR>
vmap 'fn :vsc VAssistX.FindNextbyContext<CR>
vmap 'fp :vsc VAssistX.FindPreviousbyContext<CR>

nmap 'rn :vsc VAssistX.RefResultsNext<CR>
nmap 'rp :vsc VAssistX.RefResultsPrevious<CR>
vmap 'rn :vsc VAssistX.RefResultsNext<CR>
vmap 'rp :vsc VAssistX.RefResultsPrevious<CR>

nmap 'e1 :vsc 工具.外部命令1<CR>
nmap 'e2 :vsc 工具.外部命令2<CR>
nmap 'e3 :vsc 工具.外部命令3<CR>
nmap 'e4 :vsc 工具.外部命令4<CR>
nmap 'e5 :vsc 工具.外部命令5<CR>
nmap 'e6 :vsc 工具.外部命令6<CR>
nmap 'e7 :vsc 工具.外部命令7<CR>
nmap 'e8 :vsc 工具.外部命令8<CR>
nmap 'e9 :vsc 工具.外部命令9<CR>
