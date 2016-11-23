IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;*******************************************************************************
;*                  ++ PROGRAMMEERPROJECT COMPUTERSYSTEMEN ++                  *
;*                                    PONG                                     *
;*                     By Senne Deproost and Seppe Seghers                     *
;*******************************************************************************




; # =============================================================================
; CODE
; # =============================================================================
CODESEG


PROC updatePalette
  ARG @@Ncolours:word ; @@ is lokaal gedefinieerd
  LOCAL @@blabla:dword, @@babab:byte
  USES eax, ebx, ecx, edx, esi ; Welke registers worden in de functie gebruikt

  ; 1.Index eerste kleur naar poort 3C8h
  mov al, 00h       ; Plaats index in al
  mov dx, 03C8h    ; poortnummer (adres) in edx.
  out dx, al

  ; 2.Communiceer palet naar VGA-adapter (kaart)
  mov esi, offset palette ; adres van palet als bron

  mov ax, [@@Ncolours]
  mov ebx, 3
  ;xor ebx, edx
  mul ebx
  mov ecx, eax ; # te communicerende bytes -> ecx

  mov dx, 03C9h ; Poortnummer naar edx

  rep outsb

	ret
ENDP updatePalette



; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +----------------- USER INPUT ------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC keypress
	USES eax

	mov ah,00
	int 16h			;await keypress
	mov ah,00
	mov al,03
	int 10h

ENDP keypress



; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +--------------- INITIALIZATION ----------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC initGameState
	ret
ENDP initGameState

PROC setupVideo
	USES eax

	mov	ax, 13h
	int	10h

	ret
ENDP setupVideo


; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +------------------- TERMINATION----------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC unsetupVideo
	USES eax

	mov	ax, 03h
	int	10h

	ret
ENDP unsetupVideo

; Procedure to exit the program
PROC exit
	USES eax

	call unsetupVideo
	mov	eax, 4c00h
	int 21h
	ret
ENDP exit



; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +-------------------- BALL ---------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC drawBall
  ARG @@x_pos:word, @@y_pos:word
  LOCAL @@x_pos_2:word, @@y_pos_2:word
  USES eax, ebx, ecx, edx

; Specs van de ball
mov cx, [@@x_pos] ; kolom
mov dx, [@@y_pos] ; rij
mov al, 7 ; kleur (7 = white)
mov ah, 0ch


mov bx, cx
add bx, [b_width]
mov [@@x_pos_2], bx


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

ret

ENDP drawBall



; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +----------------- MIDDLE LINE -----------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC drawMidLine
  USES eax, ecx, edx

@@middle_line:
; Specs van de line
mov cx, 160 ; kolom
mov dx, 0 ; rij
mov al, 7 ; start kleur
mov ah, 0ch

@@draw_middle_line:
; Lijn is een rechthoek met breedte 1, vandaar minder code dan rechthoek
int 10h
inc dx      ; volgende rij
cmp dx, 200
JNE @@draw_middle_line

ret

ENDP drawMidLine


; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +------------------- PADDLE --------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC drawPaddle
	ARG @@x_pos:word, @@y_pos:word
	LOCAL @@x_pos_2:word, @@y_pos_2:word
  USES eax, ebx, ecx, edx

@@paddle:
;Zet info van de figuur in de registers.
mov cx, [@@x_pos] ; kolom
mov dx, [@@y_pos]  ; rij
mov al, 7 ; kleur
mov ah, 0ch ; EUREKA!!!!!

; Voeg breedte toe aan de x-waarde.
mov bx, cx
add bx, [paddle_width]
mov [@@x_pos_2], bx

; Voeg hoogte toe aan y-waarde.
mov bx, dx
add bx, [paddle_heigth]
mov [@@y_pos_2], bx

; Teken paddle
@@draw_paddle:
inc cx
int 10h
cmp cx, [@@x_pos_2] ; (314 - 310 = 4 breedte van paddle)
JNE @@draw_paddle

mov cx, [@@x_pos]  ; reset
inc dx      ; volgende rij
cmp dx, [@@y_pos_2]
JNE @@draw_paddle

ret

ENDP drawPaddle

PROC drawObjects

ret


;===============================================================================
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;===============================================================================

start:
call setupVideo

; +++ DRAW CALLS +++
call drawPaddle, [paddle1_x_pos], [paddle1_y_pos]
call drawPaddle, [paddle2_x_pos], [paddle2_y_pos]
call drawBall, [ball_x_pos], [ball_y_pos]
call drawMidLine

call initGameState
call keypress


end_prog:
mov ah,4ch
mov al,00			;terminate program
int 21h





; # =============================================================================
; DATA
; # =============================================================================
DATASEG

  SCREENWIDTH dd 320
  SCREENHEIGHT dd 200
  palette db 0, 0, 0, 63, 63, 63 ;Zwart en wit

  ; Counts the gameloops. Useful for timing and planning events.
	gameLoopCounter		dd 0

	; Debug messages
	moveMsg		db 'moveBlock$'
	rotateMsg	db 'rotateBlock$'
	pointMsg	db '.$'

	; THE NEXT BIG THING
	startaddr	dw	0a000h	;start of video memory
  colour	db	1

	; /+/+/+/+  DIMENSIONS +/+/+/+/

	; --- Paddle ---
	paddle_width dw 5
	paddle_heigth dw 25

	; --- Ball ---
	b_width dw 3

	; /+/+/+/+ POSITIONS +/+/+/+/

	; --- Paddle ---

	; P1
	paddle1_x_pos dw 5
	paddle1_y_pos dw 5

	; P2
	paddle2_x_pos dw 310
	paddle2_y_pos dw 5

	; --- Ball ---
	ball_x_pos dw 60
	ball_y_pos dw 60


; # =============================================================================
; STACK
; # =============================================================================
STACK 1000h

END start
