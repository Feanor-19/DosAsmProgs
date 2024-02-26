.model tiny
.code
.286
org 100h
; ===========================================================
.NewLine    macro

            mov dl, 0Ah
            mov ah, 02h
            int 21h      ; putc('\n')

            mov dl, 0Dh
            mov ah, 02h
            int 21h      ; putc('\n')

            endm
; ===========================================================
Start:
            ; ===============================================
            ; getting the password
            mov di, offset PswdBuf
            call GetPassword

            ; ===============================================
            ; checking the password
            mov cx, ChadPswdLen
            mov si, offset PswdBuf
            mov di, offset ChadPswd
            call CheckPswd

            cmp al, 1
            jne AccDenied
            call AccessAllowed
            jmp ProgEnd
AccDenied:  call AccessDenied

            ; ===============================================
            ; end
ProgEnd:
            mov ax, 4c13h
            int 21h


; ===========================================================
; ====================GLOBAL CONSTANTS=======================
ChadPswdLen equ 8
ChadPswd    db ChadPswdLen DUP('*') ; yes, the password is '*'s
MsgAskPswd  db 'Please, enter the password: ', '$'

; ===========================================================
; ====================GLOBAL VARIABLES=======================
PswdBuf     db 8 DUP(?)

; ===========================================================
; CheckPswd
; Description:
;   Checks if the password is right.
;   (Compares two blocks of bytes of size N).
; Args:
;   - N in CX
;   - First address in DS:[SI]
;   - Second address in DS:[DI]
; Result:
;   - AL is set to 1 if blocks are equal. (password is right)
;   - AL is 0, if blocks aren't equal. (password is wrong)
; DESTROYS:
;   SI, DI, CX
; ===========================================================
CheckPswd   proc

            push ds
            pop es

            repe cmpsb

            ; sete al is in the future :-(
            je CheckPswd1
            mov al, 0h
            jmp CheckPswdF
CheckPswd1: mov al, 1h
CheckPswdF:

            ret
            endp
; ===========================================================
; GetPassword
; Description:
;   Asks user to enter password and reads it into given buf.
;   Enter means end of input.
; Args:
;   - DS:[DI] - buffer to store entered password.
; Destroys:
;   DI
; ===========================================================
GetPassword proc

            mov ah, 09h
            mov dx, offset MsgAskPswd
            int 21h

            mov dl, '*' ; to print later

GetPswdL:   mov ah, 08h ; getc()
            int 21h

            cmp al, 13d ; if 'enter'
            je short GetPswdEnd

            mov [DI], al
            inc di

            mov ah, 02h
            int 21h      ; putc('*')

            jmp GetPswdL

GetPswdEnd:
            .NewLine

            ret
            endp
; ===========================================================
; AccessAllowed
; Description:
;   Access to very important data is allowed.
; DESTROYS:
;   AX, DX
; ===========================================================
MsgAccessAlwd   db 'Access is ALLOWED! Welcome!', '$'
AccessAllowed   proc

                mov ah, 09h
                mov dx, offset MsgAccessAlwd
                int 21h

                ret

                endp
; ===========================================================
; AccessDenied
; Description:
;   Access to very important data is allowed.
; DESTROYS:
;   AX, DX
; ===========================================================
MsgAccessDend   db 'Access is DENIED! NOT Welcome!', '$'
AccessDenied    proc

                mov ah, 09h
                mov dx, offset MsgAccessDend
                int 21h

                ret

                endp
; ===========================================================
include prnw.asm
end         Start
