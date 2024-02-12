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
;   5)  TL (L: attribute, H: symbol byte)
;   7)  HL (L: attribute, H: symbol byte)
;   10) TR (L: attribute, H: symbol byte)
;   12) VL (L: attribute, H: symbol byte)
;   14) IN (L: attribute, H: symbol byte)
;   15) BL (L: attribute, H: symbol byte)
;   17) BR (L: attribute, H: symbol byte)
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

DRFRM_ARG_ROW     equ     16h
DRFRM_ARG_COL     equ     14h
DRFRM_ARG_W       equ     12h
DRFRM_ARG_H       equ     10h
DRFRM_ARG_TL      equ     0Eh
DRFRM_ARG_HL      equ     0Ch
DRFRM_ARG_TR      equ     0Ah
DRFRM_ARG_VL      equ     8h
DRFRM_ARG_IN      equ     6h
DRFRM_ARG_BL      equ     4h
DRFRM_ARG_BR      equ     2h

DRHRL_ARGS_CNT equ 6d

            ; drawing top line
            ; TL HL ... HL TR
            mov bp, sp

            ; ================================
            ; Top line
            push [bp + DRFRM_ARG_ROW]     ; row
            push [bp + DRFRM_ARG_COL]     ; col
            push [bp + DRFRM_ARG_W]       ; N
            push [bp + DRFRM_ARG_TL]      ; S1
            push [bp + DRFRM_ARG_HL]      ; S2
            push [bp + DRFRM_ARG_TR]      ; S3

            mov dx, bp
            call DrawLine
            mov bp, dx

            ; ================================
            ; Middle lines

            add sp, 3d * 2d ; clearing symbols-args
            ; pushing new symbols as args
            push [bp + DRFRM_ARG_VL]      ; S1
            push [bp + DRFRM_ARG_IN]      ; S2
            push [bp + DRFRM_ARG_VL]      ; S3

            ; loop
            mov cx, [bp + DRFRM_ARG_H]
DRFRM_LOOP:
            inc byte ptr [bp + DRFRM_ARG_ROW]

            mov dx, bp
            call DrawLine
            mov bp, dx

            loop DRFRM_LOOP
            ; ================================
            ; Bottom line

            inc byte ptr [bp + DRFRM_ARG_ROW]

            add sp, 3d * 2d ; clearing symbols-args
            ; pushing new symbols as args
            push [bp + DRFRM_ARG_BL]      ; S1
            push [bp + DRFRM_ARG_HL]      ; S2
            push [bp + DRFRM_ARG_BR]      ; S3

            mov dx, bp
            call DrawLine
            mov bp, dx

            ; ================================
            ; end
            add sp, DRHRL_ARGS_CNT * 2d ; clearing stack
            ret
            endp
;-------------------------------------------
