.DrFrmNewLine   macro
                add di, SCREEN_WIDTH * 2 ; next line:
                xor dx, dx               ; di = di + screen_w*2-w*2
                mov dl, al
                add dl, al
                sub di, dx
                endm

; ===================================================
; DrawFrame
; Description:
;   Draws a frame in videomem.
; Args:
;   - AL:       Width
;   - AH:       Height
;   - DS:[SI]:  Address of string, containing frame
;               symbols and attribute byte (see ***)
;   - DS:[BX]:  Address of string, containing
;               header and text as follows:
;               'header: text$'. '$' means end.
; ***:
;   Starts with the attribute byte, followed by 9
;   bytes with symbols, used for frame. Example:
;
;   Bytes:
;   41h 42h 43h 44h 45h 46h 47h 48h 49h
;   Corresponding symbols:
;   A   B   C   D   E   F   G   H   I
;
;   Frame will be drawn in the following way:
;
;   AB......BC
;   DE......EF
;   ..........
;   DE......EF
;   GH......HI
;
;   So, this string must contain 10 bytes.
; Attention:
;   All args must have sensible values, otherwise UB.
; DESTROYS:
;
; ===================================================
DrawFrame       proc
SCREEN_WIDTH    equ 80d
SCREEN_HEIGHT   equ 25d

BYTE_ATTR       equ 0d
BYTE_A          equ 1d
BYTE_B          equ 2d
BYTE_C          equ 3d
BYTE_D          equ 4d
BYTE_E          equ 5d
BYTE_F          equ 6d
BYTE_G          equ 7d
BYTE_H          equ 8d
BYTE_I          equ 9d

                ; ====================================
                ; moving style bytes to DrFrmData

                mov di, offset DRFRMDATA
                mov dh, [si] ; dh = attribute byte
                inc si ; [si] -> byte_A

                mov cx, 9d
DrFrmDatLoop:   mov dl, [si]
                mov [di], dl
                mov [di + 1], dh
                inc si
                add di, 2d
                loop DrFrmDatLoop

                mov si, offset DRFRMDATA

                ; ====================================
                ; computing into DI address of the A

                ; cl = col = (screen_w - w) / 2
                mov cl, al
                sub cl, SCREEN_WIDTH
                neg cl
                shr cl, 1

                ; ch = row = (screen_h - h) / 2
                mov ch, ah
                sub ch, SCREEN_HEIGHT
                neg ch
                shr ch, 1

                ; di = (row*screen_w + col)*2 = (ch*screen_w+cl)*2
                ; ASSUMING SCREEN_WIDTH = 80
                xor di, di
                push ax ; saving

                xor ax, ax
                mov al, ch
                mov dx, 80d
                mul dl

                add di, ax

                mov dl, cl
                add di, dx

                shl di, 1

                ; while ax is free...
                mov ax, 0B800h
                mov es, ax

                pop ax

                ; ====================================
                ; drawing top line

                call DrawHorLine

                ; ====================================
                ; drawing middle line(s)

                .DrFrmNewLine

                xor cx, cx ; cx = height - 2
                mov cl, ah
                sub cx, 2h
DrFrmMLOutLoop:
                push cx ; saving outter loop cnt

                call DrawHorLine

                .DrFrmNewLine

                sub si, 6d  ; returning back to D

                pop cx ; ressurecting outter loop cnt
                loop DrFrmMLOutLoop

                ; ====================================
                ; drawing bottom line

                add si, 6d  ; setting to G

                call DrawHorLine

                ; ====================================
                ; end
                ret

; is filled with all frame symbols
; and attribute bytes (#) to simplify some code
DrFrmData       db 18 DUP(?)
;                  A # B # ... I #

                endp
; ===================================================

; ===================================================
; DrawHorLine
; Description:
;   Helping function DrawFrame. Not for using on its
;   own.
; Assumes:
;   - SI points at A, D or G
;   - Width of the line in AL
; DESTROYS:
;   CX
; Outcome:
;   - SI points at the next left bound symbol
;   - DI points at the byte right after the last
;   byte of the drawn line.
;
; ===================================================
DrawHorLine     proc

                movsw   ; Left bound symb (A, D or G)

                ; Inner symb (B, E or H)
                xor cx, cx
                mov cl, al ; cx = w
                sub cx, 2h ; without boundary symbols
DrHorLineLoop:  movsw
                sub si, 2h
                loop DrHorLineLoop
                add si, 2h

                movsw   ; Right bound symb (C, F or I)

                ret
                endp
; ===================================================
