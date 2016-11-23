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

;
; Procedure to wait for a v-blank event (synchronizes game loop to 60Hz in mode 13h)
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



; Procedure to initialize a new game
PROC initGameState
	ret
ENDP initGameState

PROC moveBlock ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	ARG amount:dword
	USES eax, edx
mov ah, 9     ; Print string on screen
mov edx, offset moveMsg
int 21h
	ret
ENDP moveBlock

PROC rotateBlock
	USES eax, edx
mov ah, 9     ; Print string on screen
mov edx, offset rotateMsg
int 21h
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
	call moveBlock, 1
	jmp @@no_key_pressed
@@n2:
	cmp ah, 75	; arrow left
	jne @@n3
	call moveBlock, -1
	jmp @@no_key_pressed
@@n3:
	cmp ah, 80	; arrow down
	jne @@n4
	call moveBlock, 10
	jmp @@no_key_pressed
@@n4:
	cmp ah, 72	; arrow up
	jne @@n5
	call rotateBlock
	;call draw_paddle_pla, 1 ;!!!!!!!!!!!!!!!!!!!!
	jmp @@no_key_pressed
@@n5:
@@no_key_pressed:
	ret
ENDP handleUserInput

; Procedure to update the game world status (like enemies, collisions, events, ...)
PROC updateGameState
	USES eax, edx
  inc [gameLoopCounter]
  mov ah, 9
  mov edx, offset pointMsg
  int 21h
	ret
ENDP updateGameState

PROC exit
mov ah,4ch
mov al,00			;terminate program
int 21h
ENDP exit


; Procedure to draw everything on screen
PROC drawAll
	call waitVBlank
	ret
ENDP drawAll

;+-+-+-+-+- ACHTERGROND -+-+-+-+-+

PROC fillBackground
  ARG @@Colour:word         ;fillBackground, @@Colour = Kleur van de achtergrond
  USES eax, ebx, ecx, edx, esi, edi



  ; 2.Adress van het scherm naar edi = destination index
  mov edi, 0A0000h ; Wijst naar destination

  ; 3.Aantal pixels in ecx
  mov eax, [SCREENWIDTH]
  mov ebx, [SCREENHEIGHT]
  mul ebx
  mov ecx, eax

  ; 1.De kleur -> ax
  mov ax, [@@Colour] ; dicht bij stosb



  rep stosb
  ret
ENDP fillBackground

;+-+-+-+-+-+- PALETTE -+-+-+-+-+-+

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
ENDP updatePalette                      ; DOS INT 21h

;+-+-+-+-+-+-+- LOOP -+-+-+-+-+-+-+



;+-+-+-+-+-+-+- PPLA -+-+-+-+-+-+-+

PROC draw_paddle_pla
	ARG @@y_pos:word
	USES eax, ebx, ecx, edx, esi, edi
; Paddle player

paddle_1:
; Specs van de figuur.
mov cx, 6 ; kolom
mov dx, [@@y_pos]  ; rij
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
cmp dx, 100
JNE draw_paddle_1

ENDP draw_paddle_pla

PROC setupVideo
	USES eax

	mov	ax, 13h
	int	10h

	ret
ENDP setupVideo

;+-+-+-+-+-+-+- PCOM -+-+-+-+-+-+-+

;Paddle computer

;+-+-+-+-+-+-+- MAIN -+-+-+-+-+-+-+ ; Nog van toepassing?

PROC main

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 					             	; Put value of DS register on the stack
        pop es 					            		; And write this value to ES






		    ; Schakel naar de grafische mode
      ;  mov ah, 000h                    ; Naar de grafische mode
      ;  mov al, 013h                    ; Video mode flag (AL is de parameter die gegeven wordt aan de grafische mode)
      ;  int 10h                         ; Schakel de grafische mode in (interrupt call)

        ; Updaten palette (aanspreken videokaart)
      ;  call updatePalette, 2           ; Argument zegt hoeveel kleuren wegschrijven

        ; Kleur de achtergrond
      ;  call fillBackground, 1          ; 2 is de code voor groen



; MAIN Start of program
start:
    sti                             ; Set The Interrupt Flag
    cld                             ; Clear The Direction Flag

    push ds 						; Put value of DS register on the stack
    pop es 							; And write this value to ES

	; Setup and initialization
	call setupVideo
;	call initGameState
  call updatePalette, 2
  call fillBackground, 3
	;call draw_paddle_pla, 1

	;Main game (endless) loop
	@@gameLoop:
;	call handleUserInput
;	call updateGameState
	;call fillBackground, 3

;	call drawAll

	jmp @@gameLoop


	;+-+-+-+-+-+-+- TESTZONE -+-+-+-+-+-+-+



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

; # =============================================================================
; STACK
; # =============================================================================
STACK 1000h

END start
