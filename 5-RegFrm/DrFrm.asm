.DrFrmNewLine   macro
                nop
                add di, DRFRM_SCREEN_W * 2 ; next line:
                xor dx, dx               ; di = di + screen_w*2-w*2
                mov dl, al
                add dl, al
                sub di, dx
                nop
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
;               'header\n\ntext', with byte 0FFh in
;               the end. '\\' in header or in text
;               means single '\', '\n' in text means
;               new line.
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
;   CX, SI, DI, DX
; Changes:
;   ES = 0b800h
; ===================================================
DrawFrame       proc
DRFRM_SCREEN_W  equ 80d
DRFRM_SCREEN_H  equ 25d

                ; ====================================
                ; moving style bytes to DrFrmData

                mov di, offset DRFRMDATA
                mov dh, [si] ; dh = attribute byte
                inc si ; [si] -> byte_A

                mov cx, 9d
                ;xchg ax, dx
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
                sub cl, DRFRM_SCREEN_W
                neg cl
                shr cl, 1

                ; ch = row = (screen_h - h) / 2
                mov ch, ah
                sub ch, DRFRM_SCREEN_H
                neg ch
                shr ch, 1

                ; saving for printing header and text a lot later
                push cx

                ; di = (row*screen_w + col)*2 = (ch*screen_w+cl)*2
                ; ASSUMING DRFRM_SCREEN_W = 80
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
                ; print header and text

                mov si, bx
                pop bx  ; bx = row (bh) and col (bl) of
                        ; the first symbol in frame (A)

                add bl, 2d  ; one space between borders
                            ; and text

                call PrintText

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
;   - ES = 0B800h
;   - DI points at the place for the first symbol.
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
include PrnText.asm
