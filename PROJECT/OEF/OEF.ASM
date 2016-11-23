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
  ARG @@x_pos:word, @@y_pos:word
  LOCAL @@x_pos_2:word, @@y_pos_2:word
  USES eax, ebx, ecx, edx

  mov cx, [@@x_pos] ; kolom
  mov dx, [@@y_pos] ; rij
  mov al, 7 ; kleur (7 = white)
  mov ah, 0ch

  ; Voeg breedte toe aan b_x_pos_2.
  mov bx, cx
  add bx, [b_width]
  mov [@@x_pos_2], bx

  ; Voeg hoogte toe aan b_y_pos_2.
  mov bx, dx
  add bx, [b_width]
  mov [@@y_pos_2], bx

  @@draw_ball:
  inc cx
  int 10h
  cmp cx, [@@x_pos_2]
  JNE @@draw_ball

  mov cx, [@@x_pos]  ; reset
  inc dx      ; volgende rij
  cmp dx, [@@y_pos_2]
  JNE @@draw_ball

ENDP drawBalls

PROC drawBalls
  USES eax, ebx, ecx, edx


ENDP drawBalls


jmp start


;==============================

start:
; Ga video modus in.

mov ah, 0   ; set display mode function.
mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
int 10h     ; set it!

;call drawBall, 50, 50


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
