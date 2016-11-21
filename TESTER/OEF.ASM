IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

; # =============================================================================
; CODE
; # =============================================================================
CODESEG

; # =============================================================================
; Entry To ASM Code
; In:
;   CS - Code Selector    Base: 00000000h - Limit: 4G
;   DS - Data Selector    Base: 00000000h - Limit: 4G
;   ES - PSP Selector     Base: PSP Seg   - Limit: 100h
;   FS - ?
;   GS - ?
;   SS - Data Selector    Base: 00000000h - Limit: 4G
;   ESP -> STACK segment
;   Direction Flag - ?
;   Interrupt Flag - ?
;
;   All Other Registers Are Undefined!
; # =============================================================================
start:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 					             	; Put value of DS register on the stack
        pop es 					            		; And write this value to ES

        mov ah,00
        mov al,19
        int 10h	                      	;switch to 320x200 mode

        horiz:
          mov es, [startaddr]		;put segment address in es
          mov di, 32000		;row 101 (320 * 100)
          add di, 75			;column 76
          mov al, [colour]		;cannot do mem-mem copy so use reg
          mov cx, 160			;loop counter
         hplot:
           mov es:[di],al		;set pixel to colour
           inc di			;move to next pixel
         loop hplot



        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h

; # =============================================================================
; DATA
; # =============================================================================
DATASEG

startaddr	dw 0a000h	;start of video memory
colour db	3


; # =============================================================================
; STACK
; # =============================================================================
STACK 1000h

END start
