;-------------------------------------------
; DrawLine
; Description:
;   Draws in videomem one line in
;   the following way:
;   S1 S2 ... (N times) ... S2 S3
;   where S1, S2 and S3 are two bytes:
;   symbol byte and attributes byte.
;
; Args (in stack from bottom to top,
; EACH LINE MEANS A WORD - TWO BYTES):
;   1) Row number of the S1 symbol
;   2) Col number of the S1 symbol
;   3) N (see above), must be > 0
;   4) S1 (attribute byte, symbol byte)
;   5) S2 (attribute byte, symbol byte)
;   6) S3 (attribute byte, symbol byte)
;   7) Ret code
; ATTENTION:
;   ES must be already set to 0b800h!
;   All args must have sensible values,
;   otherwise UB. Rows and Cols start with
;   zero.
; DESTROYS:
;   AX, BX, CX, BP
;-------------------------------------------
DrawLine    proc

ARG_ROW     equ     0Ch
ARG_COL     equ     0Ah
ARG_N       equ     8h
ARG_S1      equ     6h
ARG_S2      equ     4h
ARG_S3      equ     2h

            mov bp, sp

            ; ================================
            ; counting in bx address of the S1

            xor bx, bx

            ; trying to do row*80d in ax
            mov ax, [bp + ARG_ROW]
            mov bl, 80d
            mul bl

            mov bx, ax

            ; adding col num
            mov ax, [bp + ARG_COL]
            add bx, ax

            ; bx*=2, to get real address in videomem
            shl bx, 1

            ; ================================
            ; S1
            mov ax, word ptr [bp + ARG_S1] ; ax = S1 (symbol+attrib)
            mov es:[bx], ax

            ; ================================
            ; S2 (N times)
            mov ax, [bp + ARG_S2] ; ax = S2 (symbol+attrib)

            xor cx, cx
            mov cx, [bp + ARG_N] ; cx = N
DrawLineL:  add bx, 2h
            mov es:[bx], ax
            loop DrawLineL

            ; ================================
            ; S3
            add bx, 2h
            mov ax, word ptr [bp + ARG_S3] ; ax = S3 (symbol+attrib)
            mov es:[bx], ax

            ; ================================
            ; end
            ret
            endp
;-------------------------------------------
