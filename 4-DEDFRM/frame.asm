.model tiny
.code
.286
org 100h

Start:
            COMMENT #
            mov al, 20d
            mov ah, 8d
            mov si, offset STYLE2
            mov bx, offset Text

            call DrawFrame
            #


            ; print str test
            mov ax, 0B800h
            mov es, ax
            mov si, offset TestText
            mov bl, 2d
            mov bh, 3d
            call PrintText



            ; ==============
            ; end
            mov ax, 4c13h
            int 21h

Style1 db 01001110b, 'ABCDEFGHI'
Style2 db 01001110b, '+-+| |+-+'
Style3 db 01001110b, '         '
Style4 db 01001110b, '…Õª∫ ∫»Õº'

Text   db 'Header: Hello!$'
TestText db 'First/nSeco//nd/n/nThird', 0FFh

include DrFrm.asm
include PrnText.asm

end         Start

