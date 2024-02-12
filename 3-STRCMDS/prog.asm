.model tiny
.code
.286
org 100h

Start:
            push ds
            pop es

            mov di, offset X
            ;call Strlen

            mov ax, 0B9A2h
            call PrnW

            mov ax, 4c13h
            int 21h

X db 'str$'

;-------------------------------------------
; Strlen
; Description:
;   Counts string's len.
; Result:
;   In AX.
; Assumes:
;   String's address is in ES:DI. Terminating
;   symbol is '$'.
; ATTENTION:
;   UB if string's len is more than a word's
;   max value.
; DESTROYS:
;   AX, CX
;-------------------------------------------
Strlen      proc

STRLEN_CX_DEF_VAL equ 0FFFFh

            mov al, '$'
            mov cx, STRLEN_CX_DEF_VAL
            repne scasb

            mov ax, STRLEN_CX_DEF_VAL
            sub ax, cx

            ret
            endp
;-------------------------------------------

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

end         Start
