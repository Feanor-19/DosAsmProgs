.model tiny
.code
.186
org 100h

Start:      mov ah, 02h
            mov dx, offset MeowStr
            int 21h

            mov ax, 4c13h
            int 21h

MeowStr     db 'MMEEOOWW', 0Dh, 0Ah, '19', 19h, '$'

end         Start
