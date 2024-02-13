.model tiny
.code
.286
org 100h

Start:
            push ds
            pop es

            mov di, offset X
            call Strlen

            call PrnW

            mov ax, 4c13h
            int 21h

X db 'test$'

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
            dec ax

            ret
            endp
;-------------------------------------------

include prnw.asm

end         Start
