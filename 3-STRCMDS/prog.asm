.model tiny
.code
.286
org 100h

Start:
            push ds
            pop es

            ; ==============
            ; strlen test
            ;mov di, offset X
            ;call Strlen
            ;call PrnW

            ; ==============
            ; memchr test
            mov di, offset X
            mov cx, 2d
            mov al, 's'
            call MemChr

            ; print found or not
            ; and which letter is pointed by DI
            mov al, es:[di]
            call PrnW

            ; ==============
            ; end
            mov ax, 4c13h
            int 21h

X db 'test$'

include prnw.asm

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

;-------------------------------------------
; MemChr
; Description:
;   Looks through N bytes of memory, searching
;   for byte with specified value.
; Args:
;   - N in CX.
;   - First byte of memory to look through is
;   ES:[DI]
;   - Value to search is in AL.
; Returns:
;   If found, AH is set to 1, ES:[DI] points
;   to the found byte. If not found, AH is set
;   zero.
;-------------------------------------------
MemChr      proc

            repne scasb         ; it stops one byte after
            dec di              ; returning to needed byte
            cmp es:[di], al
            je short MEMCHRFND
            mov ah, 0h
            jmp short MemChrFin
MemChrFnd:  mov ah, 1h
MemChrFin:  ret
            endp
;-------------------------------------------

end         Start
