.model tiny
.code
.286
org 100h

Start:

            mov al, 60d
            mov ah, 20d
            mov si, offset STYLE2
            mov bx, offset Text

            call DrawFrame

            ; ==============
            ; end
            mov ax, 4c13h
            int 21h

Style1 db 01001110b, '+-+| |+-+'
Style2 db 01001110b, 'ABCDEFGHI'
Style3 db 01001110b, '         '

Text   db 'Header: Hello!$'

include DrFrm.asm

end         Start

