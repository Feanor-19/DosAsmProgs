.model tiny
.code
.286
org 100h
; ===========================================================
; RegFrm.asm
; Description:
;   Residential prog. Shows a frame with current register
;   values when F1 is pressed.
; ===========================================================
Start:
            mov si, offset OldHndlrOfs
            mov di, offset OldHndlrSeg
            mov dx, offset EventHndl

            call HookEvtHnl

            call ShowFrame
            call HideFrame

            call EndPreps

; ===========================================================
KeyToggle   equ 3Bh ; F1 pressed

ScreenW     equ 80d
ScreenH     equ 25d

FrmWidth    equ 20d
FrmHeight   equ 15d

TLCol       equ ( ScreenW - FrmWidth ) / 2  ; Col of Top Left char
TLRow       equ ( ScreenH - FrmHeight ) / 2 ; Row of Top Left char

            ; offset from 0B800h of the
            ; first byte of frame
FirstFrmByte equ (TLRow * ScreenW + TLCol)*2

; Offsets in videomem
BaseRegOfsH equ ((TLRow + 2) * ScreenW + (TLCol + 4) ) * 2
BaseRegOfsL equ BaseRegOfsH + 2

OfsAH       equ BaseRegOfsH + 0 * ScreenW*2
OfsAL       equ BaseRegOfsL + 0 * ScreenW*2

OfsBH       equ BaseRegOfsH + 1 * ScreenW*2
OfsBL       equ BaseRegOfsL + 1 * ScreenW*2

OfsCH       equ BaseRegOfsH + 2 * ScreenW*2
OfsCL       equ BaseRegOfsL + 2 * ScreenW*2

OfsDH       equ BaseRegOfsH + 3 * ScreenW*2
OfsDL       equ BaseRegOfsL + 3 * ScreenW*2

OfsSI_h     equ BaseRegOfsH + 4 * ScreenW*2
OfsSI_l     equ BaseRegOfsL + 4 * ScreenW*2

OfsDI_h     equ BaseRegOfsH + 5 * ScreenW*2
OfsDI_l     equ BaseRegOfsL + 5 * ScreenW*2

OfsBP_h     equ BaseRegOfsH + 6 * ScreenW*2
OfsBP_l     equ BaseRegOfsL + 6 * ScreenW*2

OfsSP_h     equ BaseRegOfsH + 7 * ScreenW*2
OfsSP_l     equ BaseRegOfsL + 7 * ScreenW*2

TEST_        db 8 DUP(0FFh)

Style       db  4Eh, '…Õª∫ ∫»Õº'
FrmText     db 'Register values:\n\nAX: '
            db 'HL\nBX: '
            db 'HL\nCX: '
            db 'HL\nDX: '
            db 'HL\nSI: '
            db 'HL\nDI: '
            db 'HL\nBP: '
            db 'HL\nSP: '
            db 'HL', 0FFh

; ===========================================================
; EventHndl - RESIDENTIAL FUNCTION
; Description:
;   Keyboard interruption handler. If pressed key is F1,
;   a frame with current register values is shown.
;
; ===========================================================
EventHndl   proc

            ; =============================
            ; chechking if it is needed key
            push ax
            in al, 60h
            cmp al, KeyToggle
            pop ax
            jne WrongKey

            ; ==============================
            ; Right key

            ; saving regs
            ;pusha ; - FALLS HERE
            ; ====== instead pusha =====
            push ax
            push bx
            push cx
            push dx
            push sp
            push bp
            push si
            push di
            ; ==========================
            push es
            push ds

            ; ============================
            ; ds = cs, because ds is wrong
            push cs
            pop ds

            ; ============================
            cmp [ISFRAMESHWN], 0h
            je JShowFrame

            ; =====================================
            ; disable frame
            mov [IsFrameShwn], 0

            call HideFrame

            jmp EvntHndlEnd
            ; =====================================
            ; show frame
JShowFrame: mov [IsFrameShwn], 1
            call ShowFrame
EvntHndlEnd:

            ; ====================================
            ; Confirm geting scan code on our own
            ; and ret to main prog

            ; Blinking for keyboard controller
            in al, 61h
            or al, 80h
            out 61h, al
            and al, not 80h
            out 61h, al

            ; send EOI to INT Cntrl
            mov al, 20h
            out 20h, al

            ; =====================================
            ; restoring regs
            pop ds
            pop es
            ;popa ; - FALLS HERE
            ; ======== instead popa ==============
            pop di
            pop si
            pop bp
            pop sp
            pop dx
            pop cx
            pop bx
            pop ax
            ; ====================================
            iret

            ; ====================================
WrongKey:   db 0EAh     ; jmp to old handler
OldHndlrOfs dw 0        ; offset
OldHndlrSeg dw 0        ; segment

            endp
; ===========================================================
IsFrameShwn db 0        ; 0 if frame isn't shown, 1 otherwise
; Buf for the old screen state.
ScreenBuf   db (FrmWidth*2)*(FrmHeight*2) DUP(?)
BufSize     equ $ - ScreenBuf
; ===========================================================
;
; ===========================================================

; ===========================================================
; ShowFrame
; Description:
;   Is called by EventHndl to show frame.
; DESTROYS:
;   AL, AH, SI, BX, CX, ES
; ===========================================================
ShowFrame   proc

            ; ===============================================
            ; SAVING PREV SCREEN STATE INTO BUF
            push ds ; saving

            ; adjusting to use movsw
            ; destination
            push ds
            pop es
            mov di, offset ScreenBuf

            ; source
            push 0B800h
            pop ds
            mov si, FirstFrmByte

            ; saving prev screen state into buf
            mov dl, 0h
            call MovBuf

            pop ds ; restoring ds

            ; =============================================
            ; drawing frame
            mov al, FrmWidth
            mov ah, FrmHeight
            mov si, offset Style
            mov bx, offset FrmText
            call DrawFrame

            ret
            endp
; ===========================================================
; HideFrame
; Description:
;   Is called by EventHndl to disable frame.
; DESTROYS:
;   AX, ES, DI, SI, CX
; ===========================================================
HideFrame   proc

            ; ===============================================
            ; moving bytes from screenbuf into videomem

            ; adjusting to use movsw
            ; destination
            mov ax, 0B800h
            mov es, ax
            mov di, offset FirstFrmByte

            ; source
            ; ds is ds
            mov si, offset ScreenBuf

            mov dl, 1h
            call MovBuf

            ret
            endp
; ===========================================================
; MovBuf
; Description:
;   A small helping function to mov prev part of the screen
;   into buf or the other way round. It moves only part of the
;   screen, hidden by the frame.
; Assumes:
;   - ES:[DI] first byte of destination
;   - DS:[SI] first byte of source
;   - If DL = 0, bytes from videomem move to buffer,
;   if DL = 1, bytes from buffer are moved to videomem.
; DESTROYS:
;   SI, DI, CX
; ===========================================================
MovBuf      proc

            mov cx, FrmHeight

ShFrmOutL:  push cx ; saving outter loop cnt
            ; inner loop
            mov cx, FrmWidth
            rep movsw

            cmp dl, 0h
            je VidToBuf
            ; BufToVid
            sub di, FrmWidth*2 ; ret back to line start
            add di, ScreenW*2  ; next line
            jmp CmnPath
VidToBuf:   sub si, FrmWidth*2 ; ret back to line start
            add si, ScreenW*2  ; next line

CmnPath:    pop cx ; restoring outter loop cnt
            loop ShFrmOutL

            ret
            endp
; ===========================================================
include DrFrm.asm
include PrnWord.asm
; ===========================================================
; Everything after this line won't be saved in the
; interruption mode!
EOP:

; ===========================================================
; HookEvtHnl
; Description:
;   A small helping function, which remembers old keyboard
;   INT Handler vector and enters own value instead.
; Args:
;   - DS:[SI] must be a word var to store offset of the old
;   handler
;   - DS:[DI] must be a word var to store segment of the old
;   handler
;   - DX must contain offset (from cs) of the new INT Handler
; DESTROYS:
;   AX, BX, ES
; ===========================================================
HookEvtHnl  proc

KeyboardHndl equ 09h

            mov ax, 3509h       ; getting old keyboard INT
            int 21h             ; handler vector

            ; storing into given vars
            mov ds:[si], bx
            mov bx, es
            mov ds:[di], bx

            ; Keyboard Handler vector
            push 0
            pop es
            mov bx, 4 * KeyboardHndl

            cli
            mov es:[bx], dx ; offset
            push cs
            pop es:[bx+2]   ; seg
            sti

            ret
            endp
; ===========================================================

; ===========================================================
; EndPreps
; Description:
;   A small helping function to end the preparation's part of
;   the program and tell DOS to leave loaded resident part of
;   the prog.
; ===========================================================
EndPreps    proc

            ; counting number of paragraphs from cs:00
            ; until label EOP
            mov dx, offset EOP
            shr dx, 4
            inc dx

            ; calling the func
            mov ax, 3100h
            int 21h

            ; well, ret is not quite needed...
            endp
; ===========================================================
end         Start
