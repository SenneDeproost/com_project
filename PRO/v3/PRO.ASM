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

; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +--------------------- COLLISION ---------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

; +++ GLOBAL COLLISION FUNCTION +++
PROC checkCollision
USES eax, ebx

	call checkCollisionLeftPaddle
	call checkCollisionRightPaddle
;	call checkCollisionLeftWall
;	call checkCollisionRightWall
 call checkCollisionTopWall
 call checkCollisionBottomWall
  ret

ENDP checkCollision

;+++ BOTTOM +++;
PROC checkCollisionBottomWall
  mov ax, 197 ; HEIGHT - 3
  cmp ax, [ball_y_pos]
  JLE @@less_or_equal1
@@greater1:
  JMP @@noCollision
@@less_or_equal1:
  JMP @@CollisionBottomWall

@@CollisionBottomWall:
  call mirrorBallAngle

@@noCollision:
ret

ENDP checkCollisionBottomWall

;+++ TOP +++;
PROC checkCollisionTopWall
  mov ax, 3
  cmp ax, [ball_y_pos]
  JgE @@less_or_equal1
@@lesser1:
  JMP @@noCollision
@@less_or_equal1:
  JMP @@CollisionTopWall

@@CollisionTopWall:
  call mirrorBallAngle

@@noCollision:
ret

ENDP checkCollisionTopWall


;+++ PADDLE 1 +++
PROC checkCollisionLeftPaddle
USES eax, ebx

mov ax, [paddle1_x_pos]
add ax, [paddle_width]
cmp ax, [ball_x_pos]
JGE @@greater_or_equal1
@@lesser1:
JMP @@noCollision
@@greater_or_equal1:
mov ax, [ball_y_pos]
mov bx, [paddle1_y_pos]
add bx, 3    ;ball_width
cmp ax, bx
JGE @@greater_or_equal2
@@lesser2:
JMP @@noCollision
@@greater_or_equal2:
mov bx, [paddle1_y_pos]
add bx, [paddle_heigth]
cmp ax, bx
JLE @@lesser_or_equal3
@@greater3:
JMP @@noCollision
@@lesser_or_equal3:
JMP @@CollisionLeftPaddle

@@CollisionLeftPaddle:
  call mirrorBallAngle
  call mirrorBallDirection

@@noCollision:
ret

ENDP checkCollisionLeftPaddle


;+++ PADDLE 2 +++
PROC checkCollisionRightPaddle
USES eax, ebx

  mov ax, [ball_x_pos]
  cmp ax, [paddle2_x_pos]
  jge @@CollisionRightPaddle
  jmp @@noCollision

@@CollisionRightPaddle:
  call mirrorBallAngle
  call mirrorBallDirection

@@noCollision:
ret

ENDP checkCollisionRightPaddle

;+++ ANGLE +++;
PROC mirrorBallAngle

  mov ax, [ball_angle]
  neg ax
  ;hier misschien nog een randomgetal aan toevoegen, om niet in een eindeloze loop te geraken met het spel
  mov [ball_angle], ax
  ret

ENDP mirrorBallAngle

;+++ DIRECTION +++;
PROC mirrorBallDirection

  mov ax, [ball_direction]
  neg ax
  mov [ball_direction], ax
  ret

ENDP mirrorBallDirection




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
  ARG @@x_pos:word, \
  @@y_pos:word
  LOCAL @@x_pos_2:word, \
  @@y_pos_2:word
  USES eax, ebx, ecx, edx, edi

; Specs van de ball
mov cx, [ball_x_pos] ; kolom
mov dx, [ball_y_pos] ; rij -> WORDT NIET GEMOVED NAAR DX REGISTER
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
	USES eax, edx

	mov ax, [ball_x_pos]
	add ax, [ball_direction]
	mov [ball_x_pos], ax

	mov ax, [ball_y_pos]
	add ax, [ball_angle]
	mov [ball_y_pos], ax

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


; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +------------------- SCORE BOARD -------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+

PROC drawScore
	ARG @@score_value:dword, @@x_pos:word, @@y_pos:dword
  USES eax, ebx, edx, ecx

mov eax, [@@score_value]

; Compare tests
cmp eax, 0
jz @@draw0
cmp eax, 1
jz @@draw1
cmp eax, 2
jz @@draw2
cmp eax, 3
jz @@draw3
cmp eax, 4
jz @@draw4
cmp eax, 5
jz @@draw5
cmp eax, 6
jz @@draw6
cmp eax, 7
jz @@draw7
cmp eax, 8
jz @@draw8
cmp eax, 9
jmp @@draw9

jmp @@end

; Calls to drawSprite
@@draw0:
push eax
lea eax, [number0]
jmp @@end
@@draw1:
push eax
lea eax, [number1]
jmp @@end
@@draw2:
push eax
lea eax, [number2]
jmp @@end
@@draw3:
push eax
lea eax, [number3]
jmp @@end
@@draw4:
push eax
lea eax, [number4]
jmp @@end
@@draw5:
push eax
lea eax, [number5]
jmp @@end
@@draw6:
push eax
lea eax, [number6]
jmp @@end
@@draw7:
push eax
lea eax, [number7]
jmp @@end
@@draw8:
push eax
lea eax, [number8]
jmp @@end
@@draw9:
push eax
lea eax, [number9]
jmp @@end

@@end:
call drawSprite, eax, [@@x_pos], [@@y_pos]
pop eax
ret

ENDP drawScore

PROC incScore
ARG @@player
USES eax

mov eax, [@@player]
cmp eax,  1
jz @@p1 ; Naar player 1
jmp @@p2 ; Anders player 2

@@p1:
mov eax, [score1]
inc eax
mov [score1], eax
jmp @@end

@@p2:
mov eax, [score2]
inc eax
mov [score2], eax
jmp @@end

@@end:
ret
ENDP incScore

; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+
; +---------------------- DRAW SPRITES -----------------------+
; +/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+/+


PROC drawSprite
ARG @@spritePtr :dword, \
@@x:dword, \
@@y:dword
;@@dstPtr :dword
LOCAL @@w:dword, @@h:dword

USES eax , ebx , ecx , edx , esi , edi

push eax
push ebx

lea eax, [@@spritePtr]
mov ebx, 0a0000h

mov esi , [@@spritePtr]
xor eax , eax
lodsw ; read width in AX
mov [@@w] , eax
lodsw ; read height in AX
mov [@@h] , eax
mov edi , 0a0000h
mov eax ,0 ;[@@y] ; strange (0 repareert bug voor scores)
mov ebx , [SCREENWIDTH]
mul ebx
add edi , eax
add edi , [@@x] ; EDI points to f i r s t pixe l
mov ecx , [@@h]
@@drawLine :
push ecx
mov ecx , [@@w] ; need to copy a l ine of the spr i t e
rep movsb ; copy from e s i to edi
add edi , [SCREENWIDTH]
sub edi , [@@w] ; edi now points to the next l ine in ds t
pop ecx
dec ecx
jnz @@drawLine

pop ebx
pop eax

ret
ENDP drawSprite



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
	USES eax, ebx
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
	call moveBall, 1, -10
	jmp @@no_key_pressed
@@n2:
	cmp ah, 75	; arrow left
	jne @@n3
	call incScore, 1
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

push ds 					             	; Put value of DS register on the stack
pop es 					            		; And write this value to ES

; VIDEO BUFFER

mov esi, offset offset_screenBuffer ; points to a "db 64000 dup" array
mov edi, 0a0000h ; the video memory
mov ecx, 64000 / 4 ; 320 * 200 , but copy groups four bytes
rep movsd ; moves a dword and updates ecx , e s i and edi



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

call checkCollision

call drawPaddle, 5, [paddle1_y_pos]
call drawPaddle, 310, [ball_y_pos]

;push eax
;mov eax, [number8]
;mov eax, [majesteit]
;pop eax
;--- Draw scores ---
;push eax
;lea eax,[majesteit]
;call drawSprite, eax, 170, 0
;pop eax
call drawScore, [score1], 145, 0
call drawScore, [score2], 170, 0

;;;mov esi, offset offset_screenBuffer ; points to a "db 64000 dup" array
;;;mov edi, 0a0000h ; the video memory
;;;mov ecx, 64000 / 4 ; 320 * 200 , but copy groups four bytes
;;;rep movsd ; moves a dword and updates ecx , e s i and edi


call moveBall, [ball_direction], [ball_angle]
call drawBall, [ball_x_pos], [ball_y_pos]

; --- GAME LOGIC ---


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
  offset_screenBuffer db 64000 dup(0) ; EEN ARRAY!


	; /+/+/+/+  DIMENSIONS +/+/+/+/

	; --- Paddle ---
	paddle_width dw 5
	paddle_heigth dw 25

	; --- Ball ---
	ball_width dw 3

  ; /+/+/+/+  GAME LOGIC +/+/+/+/

  ; --- Scores ---

  ;P1
  score1 dd 0
  ;score_digit1

  ;P2
  score2 dd 0
  ;score_digit2


	; /+/+/+/+ POSITIONS +/+/+/+/

	; --- Paddle ---

	; P1
  paddle1_x_pos dw 5
	paddle1_y_pos dw 100

	; P2
	paddle2_x_pos dw 310
	paddle2_y_pos dw 10

	; --- Ball ---
	ball_x_pos dw 200
	ball_y_pos dw 100

	; /+/+/+/+ SPEEDS +/+/+/+/
  paddle1_speed dw 3
  ball_speed dw 6

	; ++++++ TEMP (for testing purposes only) ++++++
	ball_angle dw -1
	ball_direction dw -1


majesteit dw 4, 8
db  0, 1, 1, 0
db  1, 0, 0, 1
db  1, 0, 0, 1
db  1, 0, 0, 1
db  1, 0, 0, 1
db  1, 0, 0, 1
db  1, 0, 0, 1
db  0, 1, 1, 0

  ; /+/+/+/+ SPRITES +/+/+/+/

  ball dw 4, 4
  db 1, 1, 1, 1
  db 1, 1, 1, 1
  db 1, 1, 1, 1
  db 1, 1, 1, 1

  number0 dw 4, 8
  db  0, 1, 1, 0
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0

  number1 dw 4, 8
  db  0, 0, 1, 0
  db  0, 1, 1, 0
  db  1, 0, 1, 0
  db  0, 0, 1, 0
  db  0, 0, 1, 0
  db  0, 0, 1, 0
  db  0, 0, 1, 0
  db  0, 1, 1, 1

  number2 dw 4, 8
  db  0, 1, 1, 0
  db  1, 0, 0, 1
  db  0, 0, 0, 1
  db  0, 0, 1, 0
  db  0, 1, 0, 0
  db  1, 0, 0, 0
  db  1, 0, 0, 0
  db  1, 1, 1, 1

  number3 dw 4, 8
  db  0, 1, 1, 0
  db  1, 0, 0, 1
  db  0, 0, 0, 1
  db  0, 1, 1, 0
  db  0, 0, 1, 1
  db  0, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0

  number4 dw 4, 8
  db  0, 0, 0, 1
  db  0, 0, 1, 1
  db  0, 1, 0, 1
  db  1, 0, 0, 1
  db  1, 1, 1, 1
  db  0, 0, 0, 1
  db  0, 0, 0, 1
  db  0, 0, 0, 1

  number5 dw 4, 8
  db  1, 1, 1, 1
  db  1, 0, 0, 0
  db  1, 0, 0, 0
  db  1, 1, 1, 0
  db  1, 0, 0, 1
  db  0, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0

  number6 dw 4, 8
  db  0, 0, 1, 1
  db  0, 1, 0, 0
  db  1, 0, 0, 0
  db  1, 0, 0, 0
  db  1, 1, 1, 0
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0

  number7 dw 4, 8
  db  1, 1, 1, 1
  db  1, 0, 0, 1
  db  0, 0, 1, 0
  db  0, 0, 1, 0
  db  0, 1, 0, 0
  db  0, 1, 0, 0
  db  1, 0, 0, 0
  db  1, 0, 0, 0

  number8 dw 4, 8
  db  0, 1, 1, 0
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0

  number9 dw 4, 8
  db  0, 1, 1, 0
  db  1, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 1
  db  0, 0, 0, 1
  db  0, 0, 0, 1
  db  1, 0, 0, 1
  db  0, 1, 1, 0

  crown1 dw 9, 9
  db  0, 1, 0, 1, 0, 1, 0, 1, 0
  db  1, 0, 1, 0, 1, 0, 1, 0, 1
  db  0, 1, 0, 1, 0, 1, 0, 1, 0
  db  1, 0, 1, 0, 1, 0, 1, 0, 1
  db  0, 0, 0, 0, 0, 0, 0, 0, 0
  db  1, 0, 0, 0, 1, 0, 0, 0, 1
  db  1, 1, 0, 1, 1, 1, 0, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1

  crown2 dw 9, 9
  db  1, 0, 1, 0, 1, 0, 1, 0, 1
  db  0, 1, 0, 1, 0, 1, 0, 1, 0
  db  1, 0, 1, 0, 1, 0, 1, 0, 1
  db  0, 1, 0, 1, 0, 1, 0, 1, 0
  db  0, 0, 0, 0, 0, 0, 0, 0, 0
  db  1, 0, 0, 0, 1, 0, 0, 0, 1
  db  1, 1, 0, 1, 1, 1, 0, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1

  skull dw 9, 9
  db  0, 1, 0, 0, 0, 0, 0, 1, 0
  db  1, 1, 0, 1, 1, 1, 0, 1, 1
  db  0, 0, 1, 0, 1, 0, 1, 0, 0
  db  0, 0, 1, 1, 1, 1, 1, 0, 0
  db  0, 0, 0, 1, 1, 1, 0, 0, 0
  db  0, 0, 0, 1, 1, 1, 0, 0, 0
  db  0, 0, 1, 0, 0, 0, 1, 0, 0
  db  1, 1, 0, 0, 0, 0, 0, 1, 1
  db  0, 1, 0, 0, 0, 0, 0, 1, 0



; # =============================================================================
; STACK
; # =============================================================================
STACK 1000h

END start
