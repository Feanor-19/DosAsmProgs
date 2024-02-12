.model tiny
.code
.286
org 100h

Start:
            mov bx, 0b800h
            mov es, bx

            ;call DrawFrame

            ;push 0C28h  ; row=12d, col=40d
            ;push 1300h  ; n=3; empty
            ;push 6400h+''  ; S1, 01100100
            ;push 6400h+''  ; S2, 01100100
            ;push 6400h+''  ; S3, 01100100

            push 12d        ; row
            push 20d        ; col
            push 3d         ; N
            push 6400h+''  ; S1, 01100100
            push 6400h+''  ; S2, 01100100
            push 6400h+''  ; S3, 01100100

            call DrawLine

            mov ax, 4c13h
            int 21h

include drhl.asm

;-------------------------------------------
; DrawFrame
; Description:
;   Draws a frame in the videomem. You can
;   specify its interiour width and height,
;   as well as which symbols will be used for
;   drawing. See the scheme below (each pair
;   of letters represents one symbol):
;
;   TL HL ... HL TR _
;   VL IN ... IN VL   ^
;   .. .. ... .. ..   | Height (H>0)
;   VL IN ... IN VL _ v
;   BL HL ... HL BR
;      |       |
;      <------->
;     Width (W>0)
; Args (in stack from bottom to top,
; EACH LINE MEANS A WORD - TWO BYTES):
;   1)  Row number of the TL symbol
;   2)  Col number of the TL symbol
;   3)  W
;   4)  H
;   5)  TL (symbol)
;   6)  TL (attribute)
;   7)  HL (symbol)
;   8)  HL (attribute)
;   10) TR (symbol)
;   11) TR (attribute)
;   12) VL (symbol)
;   13) VL (attribute)
;   14) IN (symbol)
;   15) IN (attribute)
;   15) BL (symbol)
;   16) BL (attribute)
;   17) BR (symbol)
;   18) BR (attribute)
;   19) Ret code
; ATTENTION:
;   ES must be already set to 0b800h!
;   All args must have sensible values,
;   otherwise UB. Rows and Cols start with
;   zero.
; DESTROYS:
;   AX, BX, CX, BP
;-------------------------------------------
DrawFrame   proc
            ; drawing top line
            ; TL HL ... HL TR
            mov bp, sp

            push [bp+19d]   ; row
            push [bp+18d]   ; col
            push [bp+17d]   ; N


            ret
            endp
;-------------------------------------------
end         Start
