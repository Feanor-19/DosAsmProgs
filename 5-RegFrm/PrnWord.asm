;===================================================================
; PrnW
; Description:
;   'Prints' to the given place in memory AX
;   in hex
; Args:
;   - AX - with word to print.
;   - ES:[DI] - place in memory (see ***)
; ***:
;   There must be 8 bytes pointed by DS:[DI]. if AX = ABCDh,
;   the bytes will be filled in the following way:
;   A _ B _ C _ D _
;   where '_' means this byte won't be changed.
; DESTROYS:
;   CX, DX
;===================================================================
PrnW        proc

            ; loop start
            mov cx, 4h          ; rotating ax 4 times
PrnWL:      mov dl, ah
            shr dl, 4d
            cmp dl, 10d
            jge short PrnWLtr

            add dl, '0' ; '0' ... '9'
            jmp short PrnWFin

PrnWLtr:    add dl, 'A' ; 'A' ... 'F'
            sub dl, 0Ah

PrnWFin:    mov byte ptr es:[di], dl
            rol ax, 4
            add di, 2d
            loop PrnWL
            ; loop end

            ; restoring di value
            sub di, 8d

            ; end
            ret
            endp
;===========================================
