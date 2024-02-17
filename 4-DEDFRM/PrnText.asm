; ===================================================
; PrintText
; Description:
;   Prints given string of text into the videomem
;   according to the following rules:
;   - '/n' is interpreted as a command to go onto a
;   new line. New line starts in the same column, as
;   the first symbol (see args), one row lower.
;   - '//' is printed as a single '/'.
;   - Single '/' followed by any symbol other than 'n'
;   is UB!
;   - The whole string must end with byte FFh.
;   - UB if length of one line exceeds screen width.
;   - Attribute bytes don't change.
; Args:
;   - DS:[SI] pointing at the beginning of the string.
;   - BL - Row number of the first symbol.
;   - BH - Col number of the first symbol.
; Assumes:
;   ES = 0b800h
; DESTROYS:
;   AX, CX, DI, BH, DX
; Attention:
;   All args must have sensible values, otherwise UB.
; ===================================================
PrintText       proc

PrnTextScreenW  equ 80d

ByteCtrl        equ '/'
ByteNewLine     equ 'n'
ByteStrEnd      equ 0FFh

                ; ===================================
                ; computing offset in the videomem
                ; of the first symbol into DI

                ; AX = row * 80d = BL * 80d
                xor ax, ax
                mov al, bl
                mov cx, 80d
                mul cx

                mov di, ax  ; DI = row*80

                xor ax, ax
                mov al, bh  ; AX = BH
                add di, ax  ; DI += col

                shl di, 1      ; di*=2

                ; remembering offset of the first
                ; symbol in the line
                mov dx, di

                ; ===================================
                ; printing the string

PrnStrLoop:     mov al, [si]    ; al = current symbol

                cmp al, BYTESTREND
                je PrnStrFinal

                cmp al, BYTECTRL
                jne PrnStrCommmon
                inc si
                mov ah, [si]
                cmp ah, BYTECTRL
                je PrnStrCommmon
                cmp ah, BYTENEWLINE
                jne PRNSTRFINAL

                inc si
                ; new line
                add dx, PrnTextScreenW * 2
                mov di, dx

                jmp PrnStrLoop

PrnStrCommmon:  stosb
                inc di  ; passing over attribute byte
                inc si
                jmp PrnStrLoop
PrnStrFinal:
                ret
                endp
; ===================================================
