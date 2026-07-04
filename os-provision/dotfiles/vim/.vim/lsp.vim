set runtimepath+=$HOME/.vim/plugged/lsp
source $HOME/.vim/plugged/lsp/plugin/lsp.vim

let lspOpts = #{autoHighlightDiags: v:true}
call LspOptionsSet(lspOpts)

let lspServers = [
      \ #{
      \   name: 'pylsp',
      \   filetype: ['python'],
      \   path: 'pylsp',
      \   args: []
      \ }
      \ ]

call LspAddServer(lspServers)

nnoremap gd :LspGotoDefinition<CR>
nnoremap gr :LspShowReferences<CR>
nnoremap K  :LspHover<CR>
nnoremap gl :LspDiag current<CR>
nnoremap <leader>nd :LspDiag next \| LspDiag current<CR>
nnoremap <leader>pd :LspDiag prev \| LspDiag current<CR>
inoremap <silent> <C-Space> <C-x><C-o>

call LspOptionsSet(#{
    \   diagSignErrorText: '✘',
    \   diagSignWarningText: '▲',
    \   diagSignInfoText: '»',
    \   diagSignHintText: '⚑',
    \ })
