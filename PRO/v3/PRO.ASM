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

; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +-------------------- UPDATE ---------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+


PROC updateGameState
	USES eax, edx

inc [gameLoopCounter]

;mov ah, 9

;int 21h
	ret

ENDP updateGameState



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
add bx, [ball_width]
mov [@@x_pos_2], bx


mov bx, dx
add bx, [ball_width]
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

PROC moveBall
	ARG @@ballSpeed:dword
	ARG @@ball_angle:dword
	ARG @@ball_direction:dword
	USES eax, edx

	mov ax, [ball_x_pos]
	add ax, 1
	mov [ball_x_pos], ax

	mov ax, [ball_y_pos]
	add ax, -2
	mov [ball_y_pos], ax

	call drawBall
	ret

ENDP moveBall



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

; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +---------------------- INPUT HANDLER ----------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

; Sync to 60 hz.
PROC waitVBlank
	USES eax, edx

	mov dx, 03dah
	@@waitVBlank_wait1:
	in al, dx
	and al, 8
	jnz @@waitVBlank_wait1
	@@waitVBlank_wait2:
	in al, dx
	and al, 8
	jz @@waitVBlank_wait2
	ret
ENDP waitVBlank

PROC movePaddleUp
	ARG @@speed:dword
	USES eax, edx

  ; Verander de positie van paddle1

  mov ax, [paddle1_y_pos]

  ; Test voor bovenste rand.
  cmp ax, 0
  jz @@last
  add ax, [speed]
  mov [paddle1_y_pos], ax

  @@last:
	ret

ENDP movePaddleUp

PROC movePaddleDown
	ARG @@speed:dword
	USES eax, edx

  ; Verander de positie van paddle1

  mov ax, [paddle1_y_pos]

  ; Test voor onderste rand.
  cmp ax, 176 ; Opletten of deze paddle wel op deze plek komen.
  jz @@last
  add ax, [speed]
  mov [paddle1_y_pos], ax

  @@last:
	ret

ENDP movePaddleDown


PROC rotateBlock
ARG speed:word
	USES eax, edx



	ret
ENDP rotateBlock

; Procedure to handle user input
PROC handleUserInput
	USES eax
	mov ah, 01h ; function 01h (test key pressed)
	int 16h		; call keyboard BIOS
	jz @@no_key_pressed
	mov ah, 00h
	int 16h
	cmp ah, 01	; scancode for ESCAPE key
	jne	@@n1
	call exit
	jmp @@no_key_pressed
@@n1:
	cmp ah, 77	; arrow right
	jne @@n2
	call movePaddleUp, 1
	jmp @@no_key_pressed
@@n2:
	cmp ah, 75	; arrow left
	jne @@n3
	call movePaddleDown, -1
	jmp @@no_key_pressed


@@n3:
	cmp ah, 80	; arrow down
	jne @@n4
	call movePaddleDown, 4
	jmp @@no_key_pressed
@@n4:
	cmp ah, 72	; arrow up
	jne @@n5
	call movePaddleUp, -4

	jmp @@no_key_pressed
@@n5:
@@no_key_pressed:
	ret
ENDP handleUserInput









; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +------------------- DRAW CALLS --------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC drawObjects



ret

ENDP drawObjects


; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +------------------- BACKGROUND --------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC fillBackground
  ARG @@Colour:word         ;fillBackground, @@Colour = Kleur van de achtergrond
  USES eax, ebx, ecx, edx, esi, edi

  mov edi, 00000000h
  ; 2.Adress van het scherm naar edi = destination index
  mov edi, 0a0000h ; Wijst naar destination

  ; 3.Aantal pixels in ecx
  mov eax, 320
  mov ebx, 200
  mul ebx
  mov ecx, eax

  ; 1.De kleur -> ax
  mov ax, [@@Colour] ; dicht bij stosb

  rep stosb

  ret
ENDP fillBackground






;===============================================================================
;+++++++++++++++++++++++++++++++++++++ START +++++++++++++++++++++++++++++++++++
;===============================================================================

start:


sti                             ; Set The Interrupt Flag
cld                             ; Clear The Direction Flag

; VIDEO BUFFER

mov esi, [offset_screenBuffer] ; points to a "db 64000 dup" array
mov edi, 0a0000h ; the video memory
mov ecx, 64000 / 4 ; 320 * 200 , but copy groups four bytes
rep movsd ; moves a dword and updates ecx , e s i and edi

push ds 					             	; Put value of DS register on the stack
pop es 					            		; And write this value to ES


call setupVideo


;call drawObjects
;call drawPaddle, [paddle1_x_pos], [paddle1_y_pos]
call drawPaddle, [paddle2_x_pos], [paddle2_y_pos]
;call drawBall, [ball_x_pos], [ball_y_pos]
call drawMidLine

call initGameState

;call keypress -> lelijk gedrogt!!


@@gameLoop:
call handleUserInput
call updateGameState
call fillBackground, 0
call drawMidLine
call updatePalette, 2


call drawPaddle, 5, [paddle1_y_pos]
call drawPaddle, 310, [paddle1_y_pos]

call waitVBlank

jmp @@gameLoop

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
  offset_screenBuffer dd 64000


	; /+/+/+/+  DIMENSIONS +/+/+/+/

	; --- Paddle ---
	paddle_width dw 5
	paddle_heigth dw 25

	; --- Ball ---
	ball_width dw 3


	; /+/+/+/+ POSITIONS +/+/+/+/

	; --- Paddle ---

	; P1
  paddle1_x_pos dw 100
	paddle1_y_pos dw 100

	; P2
	paddle2_x_pos dw 310
	paddle2_y_pos dw 0

	; --- Ball ---
	ball_x_pos dw 60
	ball_y_pos dw 60

	; /+/+/+/+ SPEEDS +/+/+/+/
  paddle1_speed dw 3
  ballSpeed dw 3

	; ++++++ TEMP (for testing purposes only) ++++++
	ball_angle dw 2
	ball_direction dw 1

; # =============================================================================
; STACK
; # =============================================================================
STACK 1000h

END start
