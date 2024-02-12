.model tiny
.code
.286
org 100h

Start:
            mov bx, 0b800h
            mov es, bx

            mov dx, sp  ; saving old sp

            push 7d     ; row
            push 19d    ; col
            push 38d    ; W
            push 6d     ; H

            push  6400h + 'o'  ; TL 01100100
            push  6400h + '='  ; HL 01100100
            push  6400h + 'o'  ; TR 01100100
            push  6400h + '|'  ; VL 01100100
            push 0F900h + 'A'  ; IN 11111001
            push  6400h + 'o'  ; BL 01100100
            push  6400h + 'o'  ; BR 01100100

            call DrawFrame

            mov sp, dx  ; resurrect sp

            ;push 12d        ; row
            ;push 20d        ; col
            ;push 3d         ; N
            ;push 6400h+''  ; S1, 01100100
            ;push 6400h+''  ; S2, 01100100
            ;push 6400h+''  ; S3, 01100100
            ;call DrawLine

            mov ax, 4c13h
            int 21h

include drhl.asm
include DrFrame.asm

end         Start
