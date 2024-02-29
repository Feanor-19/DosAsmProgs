;-------------------------------------------
; PrnW
; Description:
;   Prints to standart output AX
;   in hex (using int 21h (02h))
; DESTROYS:
;   CX, DX
;-------------------------------------------
PrnW        proc

            mov si, 3h          ; starting from smallest bytes,
                                ; which are in the rightmost character

            ; loop start
            mov cx, 4h          ; rotating ax 4 times
PrnWL:      mov dl, al
            and dl, 00001111b
            cmp dl, 10d
            jge PrnWLtr

            add dl, '0' ; '0' ... '9'
            jmp short PrnWFin

PrnWLtr:    add dl, 'A' ; 'A' ... 'F'
            sub dl, 0Ah

PrnWFin:    mov byte ptr [PrnWData + si], dl
            ror ax, 4
            dec si
            loop PrnWL
            ; loop end

            ; printing
            push ax                 ; saving ax
            mov dx, offset PRNWDATA
            mov ah, 09h
            int 21h
            pop ax                  ; ressurecting ax

            ; end
            ret
            endp

PrnWData    db ?, ?, ?, ?, '$'
;-------------------------------------------
