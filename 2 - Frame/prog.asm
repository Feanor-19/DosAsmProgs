.model tiny
.code
.286
org 100h

Start:
            mov bx, 0b800h
            mov es, bx

            push 0C28h  ; row=12d, col=40d
            push 1300h  ; n=3; empty
            push 6400h+''  ; S1, 01100100
            push 6400h+''  ; S2, 01100100
            push 6400h+''  ; S3, 01100100

            call DrawLine

            mov ax, 4c13h
            int 21h

;-------------------------------------------
; Description:
;   Draws in videomem one line in
;   the following way:
;   S1 S2 ... (N times) ... S2 S3
;   where S1, S2 and S3 are two bytes:
;   symbol byte and attributes byte.
;
; Args (in stack from bottom to top):
;   - Row number of the S1 symbol
;   - Col number of the S1 symbol
;   - N (see above), must be > 0
;   - empty
;   - S1 (symbol byte)  ?????????????????????
;   - S1 (attribute byte)
;   - S2 (symbol byte)
;   - S2 (attribute byte)
;   - S3 (symbol byte)
;   - S3 (attribute byte)
;   - Ret code
; ATTENTION:
;   ES must be already set to 0b800h!
;   All args must have sensible values,
;   otherwise UB. Rows and Cols start with
;   zero.
; DESTROYS:
;   AX, BX, CX
;-------------------------------------------
DrawLine    proc

            ; counting in bx address of the S1
            xor bx, bx

            mov bp, sp

            ; trying to do row*80d in ax
            mov al, byte ptr [bp+11d] ; row num

            mov bl, 80d
            mul bl

            mov bx, ax

            ; we need col num as a word
            mov al, [bp+10d]
            cbw

            ; adding col num
            add bx, ax

            ; bx*=2, to get real address in videomem
            shl bx, 1

            ; S1
            mov ax, word ptr [bp+6d] ; ax = S1 (symbol+attrib)
            mov es:[bx], ax
            ; S1 END

            ; S2 (N times)
            mov ax, [bp+4d] ; ax = S2 (symbol+attrib)

            xor cl, cl
            mov cl, [bp+9d] ; cx = N
DrawLineL:  add bx, 2h
            mov es:[bx], ax
            loop DrawLineL
            ; S2 END

            ; S3
            add bx, 2h
            mov ax, word ptr [bp+2d] ; ax = S3 (symbol+attrib)
            mov es:[bx], ax
            ; S3 END

            ret
            endp
;-------------------------------------------
end         Start
