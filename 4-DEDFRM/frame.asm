.model tiny
.code
.286
org 100h
; ===========================================================
; Frame.asm
; Description:
;   Draws a frame with text on the screen according
;   to settings, specified in command line.
; Command line arguments:
;   - Frame width (decimal without dign, 3 <= w <= 78 )
;   - Frame height (decimal without dign, 3 <= h <= 24)
;   - Predefined style (0, 1, 2, 3) or custom (see ***)
;   - Frame attribute byte in binary (like '01001110'),
;   DONT FORGET LEADING ZEROES!
;   - Header and text, separated uding '\n\n' in the
;   following way:
;   'Header\n\ntext'
;   '\\' in header or text means a dingle '\',
;   '\n' in text means a new line.
; ***:
;   If you want to use a custom style, type '*' and
;   enter 9 symbols, which will define your custom style.
; Example:
;   frame.com 40 15 2 4e Header\n\nSome Text
; More complex example:
;   frame.com 40 15 *ABCDEFGHI 4e C:\\Header\n\nFirst\nSecond
; ATTENTION:
;   Unexpected command line arguments lead to UB!
; ===========================================================

Start:
                ; ==============================
                ; ==============================
                ; parsing cmd args

                mov di, 80h
                xor bx, bx
                mov bl, [di] ; bl = cmd line len

                ; ==============================
                ; putting end symbol for text
                mov byte ptr [81h+bx], 0FFh

                inc di
                call SkipSpaces

                xor ax, ax
                ; ==============================
                ; width
                mov al, byte ptr [di]    ; sure it is a digit
                sub al, '0'
                inc di
                cmp byte ptr [di], ' '
                je short OneDigitWidth
                ; so width is two-digit

                ; al*=10
                mov bh, al
                shl al, 3
                add al, bh
                add al, bh

                add al, byte ptr [di]
                sub al, '0'

OneDigitWidth:  inc di
                call SkipSpaces

                ; ==============================
                ; height
                mov ah, byte ptr [di]    ; sure it is a digit
                sub ah, '0'
                inc di
                cmp byte ptr [di], ' '
                je short OneDigitHeight
                ; so height is two-digit

                ; ah*=10
                mov bh, ah
                shl ah, 3
                add ah, bh
                add ah, bh

                add ah, byte ptr [di]
                sub ah, '0'
OneDigitHeight: inc di
                call SkipSpaces

                ; ==============================
                ; style
                xor bx, bx
                mov bl, [di]
                cmp bx, '*'
                je short CustomStyle
                ; so bl is '0', '1', '2' or '3'
                sub bx, '0'
                mov si, offset STYLE0
                mov bl, byte ptr StyleOffsets[bx]
                add si, bx
                jmp short StyleEnd

CustomStyle:    mov si, di
                add di, 10d

StyleEnd:       inc di
                call SkipSpaces

                ; ==============================
                ; attribute (color) byte
                ; assembling color byte in BL
                xor bl, bl

                mov cx, 8d
ColorLoop:      shl bl, 1
                mov dl, [di]
                sub dl, '0'
                add bl, dl
                inc di
                loop ColorLoop

                ; putting color byte into its
                ; place in the chosen style
                mov byte ptr [si], bl

                ; ==============================
                ; header and text

                ; end of text is already marked

                call SkipSpaces

                ; sure it is text
                mov bx, di

                ; ==============================
                ; ==============================
                call DrawFrame

                ; ==============================
                ; ==============================
                ; end
                mov ax, 4c13h
                int 21h

Style0 db 01001110b, 'ABCDEFGHI'
Style1 db 01001110b, '+-+| |+-+'
Style2 db 01001110b, '         '
Style3 db 01001110b, 'ÉÍ»º ºÈÍ¼'

StyleOffsets db 0d, 10d, 20d, 30d

Text   db 'Header\n\nHello!\nSeco\\nd\n\nThird', 0FFh
TestText db 'First\nSeco\\nd\n\nThird', 0FFh

; ===========================================================
; A small helping function, which increments DI while
; [DI] != ' '.
; ===========================================================
SkipSpaces      proc

                jmp short SkipSpacesCnd
SkipSpacesLoop: inc di
SkipSpacesCnd:  cmp byte ptr [di], ' '
                je SkipSpacesLoop

                ret
                endp
; ===========================================================

include DrFrm.asm
include PrnText.asm

end         Start

