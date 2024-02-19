.model tiny
.code
.286
org 100h

Start:
            mov ax, 3509h
            int 21h

            mov NxtHndlrOfs, bx
            mov bx, es
            mov NxtHndlrSeg, bx

            push 0
            pop es
            mov bx, 4 * 09h

            cli
            mov es:[bx], offset EventHndl
            push cs
            pop es:[bx+2]
            sti

            mov ax, 3100h
            mov dx, offset EOP
            shr dx, 4
            inc dx
            int 21h

EventHndl   proc

            push ax
            push bx
            push es

            push 0b800h
            pop es
            mov bx, (80*5 + 40)*2

            mov ah, 4eh
            in al, 60h
            mov es:[bx], ax

            pop es
            pop bx
            pop ax

            db 0EAh
NxtHndlrOfs dw 0
NxtHndlrSeg dw 0

            endp
EOP:
end         Start
