IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;*******************************************************************************
;*                     PROGRAMMEERPROJECT COMPUTERSYSTEMEN                     *
;*                                    PONG                                     *
;*                      By Senne Deproost and Seppe Seghers                    *
;*******************************************************************************


; # =============================================================================
; CODE
; # =============================================================================
CODESEG

sti                             ; Set The Interrupt Flag
cld                             ; Clear The Direction Flag

push ds 					             	; Put value of DS register on the stack
pop es 					            		; And write this value to ES




PROC drawBall
  ;ARG @@x_pos:word, @@y_pos:word
  USES eax, ebx, ecx, edx

; Specs van de line
mov cx, [b_x_pos_1] ; kolom
mov dx, [b_y_pos_1] ; rij
mov al, 7 ; kleur

; Voeg breedte toe aan b_x_pos_2.
mov bx, cx
add bx, [b_width]
mov [b_x_pos_2], bx

; Voeg hoogte toe aan b_y_pos_2.
mov bx, dx
add bx, [b_width]
mov [b_y_pos_2], bx

@@draw_ball:
inc cx
int 10h
cmp cx, [b_x_pos_2]
JNE @@draw_ball

mov cx, [b_x_pos_1]  ; reset
inc dx      ; volgende rij
cmp dx, [b_y_pos_2]
JNE @@draw_ball

ENDP drawBall


jmp start


;==============================

start:
; Ga video modus in.

mov ah, 0   ; set display mode function.
mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
int 10h     ; set it!


paddle_1:
; Specs van de figuur.
mov cx, 6 ; kolom
mov dx, 5  ; rij
mov al, 7 ; kleur
mov ah, 0ch

; Teken paddle_1
draw_paddle_1:
inc cx
int 10h
cmp cx, 10 ; (10 - 6 = 4 breedte van paddle)
JNE draw_paddle_1

mov cx, 6  ; reset
inc dx      ; volgende rij
cmp dx, 30
JNE draw_paddle_1

paddle_2:
; Specs van de figuur.
mov cx, 310 ; kolom
mov dx, 5  ; rij
mov al, 7 ; kleur
mov ah, 0ch

; Teken paddle_2
draw_paddle_2:
inc cx
int 10h
cmp cx, 314 ; (314 - 310 = 4 breedte van paddle)
JNE draw_paddle_2

mov cx, 310  ; reset
inc dx      ; volgende rij
cmp dx, 30
JNE draw_paddle_2

middle_line:
; Specs van de line
mov cx, 160 ; kolom
mov dx, 0 ; rij
mov al, 7 ; start kleur

draw_middle_line:
; Lijn is een rechthoek met breedte 1, vandaar minder code dan rechthoek
int 10h
inc dx      ; volgende rij
cmp dx, 200
JNE draw_middle_line




call drawBall




;vierkant_2:
;inc cx
;int 10h
;cmp cx, 30
;JNE vierkant_2

;mov cx, 10  ; reset to start of col
;inc dx      ;next row
;cmp dx, 30
;JNE vierkant_2

keypress:
mov ah,00
int 16h			;await keypress
mov ah,00
mov al,03
int 10h
end_prog:
mov ah,4ch
mov al,00			;terminate program
int 21h


        ;mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        ;int 21h                         ; DOS INT 21h

; # =============================================================================
; DATA
; # =============================================================================
DATASEG

startaddr	dw	0a000h	;start of video memory
colour	db	1

; --- BALL ---
b_x_pos_1 dw 100
b_y_pos_1 dw 5
b_x_pos dw 103
b_x_pos_2 dw 106
b_y_pos_2 dw 8

b_width dw 3


ball_width dw 4

; # =============================================================================
; STACK
; # =============================================================================
STACK 1000h

END start
