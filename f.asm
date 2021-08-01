IDEAL
MODEL small
STACK 256

BMP_WIDTH = 320
BMP_HEIGHT = 200

DUCKS_GAP = 26
DUCK_WIDTH = 29
DUCK_HEIGHT = 25

macro PUSH_ALL
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
endm 

macro POP_ALL
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
endm 


Macro absolute a
	local l1
	cmp a, 0
	jge l1
	neg a
l1:
Endm







;---------------------------------------------;
; case: DeltaY is bigger than DeltaX		  ;
; input: p1X p1Y,		            		  ;
; 		 p2X p2Y,		           		      ;
;		 Color                                ;
; output: line on the screen                  ;
;---------------------------------------------;
Macro DrawLine2DDY p1X, p1Y, p2X, p2Y
	local l1, lp, nxt
	mov dx, 1
	mov ax, [p1X]
	cmp ax, [p2X]
	jbe l1
	neg dx ; turn delta to -1
l1:
	mov ax, [p2Y]
	shr ax, 1 ; div by 2
	mov [TempW], ax
	mov ax, [p1X]
	mov [pointX], ax
	mov ax, [p1Y]
	mov [pointY], ax
	mov bx, [p2Y]
	sub bx, [p1Y]
	absolute bx
	mov cx, [p2X]
	sub cx, [p1X]
	absolute cx
	mov ax, [p2Y]
lp:
	
	call PIXEL
	
	inc [pointY]
	cmp [TempW], 0
	jge nxt
	add [TempW], bx ; bx = (p2Y - p1Y) = deltay
	add [pointX], dx ; dx = delta
nxt:
	sub [TempW], cx ; cx = abs(p2X - p1X) = daltax
	cmp [pointY], ax ; ax = p2Y
	jne lp
	call PIXEL
ENDM DrawLine2DDY




;---------------------------------------------;
; case: DeltaX is bigger than DeltaY		  ;
; input: p1X p1Y,		            		  ;
; 		 p2X p2Y,		           		      ;
;		 Color -> variable                    ;
; output: line on the screen                  ;
;---------------------------------------------;
Macro DrawLine2DDX p1X, p1Y, p2X, p2Y
	local l1, lp, nxt
	mov dx, 1
	mov ax, [p1Y]
	cmp ax, [p2Y]
	jbe l1
	neg dx ; turn delta to -1
l1:
	mov ax, [p2X]
	shr ax, 1 ; div by 2
	mov [TempW], ax
	mov ax, [p1X]
	mov [pointX], ax
	mov ax, [p1Y]
	mov [pointY], ax
	mov bx, [p2X]
	sub bx, [p1X]
	absolute bx
	mov cx, [p2Y]
	sub cx, [p1Y]
	absolute cx
	mov ax, [p2X]
lp:
	
	call PIXEL
	
	inc [pointX]
	cmp [TempW], 0
	jge nxt
	add [TempW], bx ; bx = abs(p2X - p1X) = deltax
	add [pointY], dx ; dx = delta
nxt:
	sub [TempW], cx ; cx = abs(p2Y - p1Y) = deltay
	cmp [pointX], ax ; ax = p2X
	jne lp
	call PIXEL
ENDM DrawLine2DDX


Macro NewLine
	PUSH_ALL
	MOV AH, 09
	mov dx, offset New_Line
	int 21h
	POP_ALL
ENDM NewLine





DATASEG
;Vars


; Messages and Scoreboard
WriteToFile db "   -          ", '$'
ScoreName db "            ",'$',0
New_Line db 0dh,0Ah, '$'
TopScore db "Top Score: ", '$'
YourScore db "Your Score: ", '$'

ReadArray db 20 dup (?), '$'
ScoreFileName db "Score.txt",0

FailMsg db "You Lost! Time's up!", '$'
VictoryMsg db "You Win!",0Dh,0Ah, '$'
VictoryMsgNotScoreboard db "Didn't pass any records though....",0Dh,0Ah, '$'
VictoryMsgScoreboard db "Please enter your name", 0dh, 0ah, "for the scoreboard:", 0dh, 0ah, '$'

WindMsg db "Wind: ", '$'

; Game Mechanics
Round db 1
GameOver db 0
Reason db 0

; Time
TimeHere dw 0
Timer dw 0

; Ducks' Direction (0- left, 1-right)
DuckOneDirection db 1
DuckTwoDirection db 1
DuckThreeDirection db 1
DuckFourDirection db 1
DuckFiveDirection db 1

;Ducks' Speed
DuckOneSpeed db 0
DuckTwoSpeed db 0
DuckThreeSpeed db 0
DuckFourSpeed db 0
DuckFiveSpeed db 0

;Ducks' X
DuckOneX dw 0 ;Defind by most left X
DuckTwoX dw 0
DuckThreeX dw 0
DuckFourX dw 0
DuckFiveX dw 0

;Ducks' Living Situation Boolean
DuckOneL db 1
DuckTwoL db 1
DuckThreeL db 1
DuckFourL db 1
DuckFiveL db 1

; Booleans
AsyncBoolean db 0

; Drawing Line - Yossi's
TempW dw ?
pointX dw ? 
pointY dw ?
point1X dw ? 
point1Y dw ?
point2X dw ? 
point2Y dw ?
Color db ?

; For the rnd - taking an number from cs
RndCurrentPos dw start

; For the async mouse proc - covering and drawing a line later (09 = blue)
LastPlaceColor db 09
LastPlaceColorP1 db 09
LastPlaceColorP320 db 09
LastPlaceColorP321 db 09
LastMousePlaceY dw 0
LastMousePlaceX dw 0

; For drawing the ducks
TopH dw 0
TopL dw 0

; Wind
WindDirection dw 0
Wind dw 0

; For the bmp file (image)
OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

FileHandle	dw ?

Front db 'First.bmp', 0
Back db 'Map.bmp', 0

Header 	    db 54 dup(0) ;Header size
Palette 	db 400h dup (0) ;Palette size

ErrorFile db 0


BmpLeft dw ?
BmpTop dw ?
BmpColSize dw ?
BmpRowSize dw ?

;0FBh = Yellow in mspaint palette, 09 = Blue.
; An actual duck - highlight the 0Fbh by double-click on the left button of the mouse to see it
DuckRight db 09,09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09,09,09,09 ;1

db 09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09,09 ;2

db 09,09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09 ;3

db 09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09 ;4

db 09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,000h,000h,000h,0Fbh,09,09,09,09,09 ;5

db 09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,000h,000h,000h,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;6

db 09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;7

db 09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09 ;8

db 09,09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09 ;9

db 09,0Fbh,09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09 ;10

db 0Fbh,0Fbh,09,09,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09,09 ;11

db 0Fbh,0Fbh,0Fbh,09,09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09,09 ;12

db 0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09 ;13

db 0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09 ;14

db 0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09 ;15

db 0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;16

db 0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;17

db 09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;18

db 09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;19

db 09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;20

db 09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;21

db 09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09 ;22

db 09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09 ;23

db 09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09 ;24

db 09,09,09,09,09,09,09,09,09,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,0Fbh,09,09,09,09,09 ;25

CODESEG

Start:     
	mov ax, @data
	mov ds ,ax
	
	call SetGraphic
	
	call Opening
	
	call WaitUntilPressed
	
	call GameOn
	
	call SetTimer
	
	call ChangeDuckSpeedRnd
	
	call SetWindRnd
	
	call GameLoop
	
	call SetText
Exit:
    mov ax, 4C00h
    int 21h
	



proc GameLoop

@@Loop:

	call GameBackground
	
	call DrawDucks
	
	call MoveDucks
	
	call ShowTimer
	
	dec [Timer]
	inc [TimeHere]
	
	call DisplayWind
	
	call LoopDelay
	call LoopDelay
	call LoopDelay
	call LoopDelay
	
	call CheckForOut
	cmp [GameOver], 0
	jne @@GameOver

	jmp @@Loop
	
@@GameOver:
	mov [AsyncBoolean], 0
	cmp [Reason], 1
	je @@Victory
@@Fail:
	call Fail
	jmp @@ret
	
@@Victory:
	call Victory
	jmp @@ret
	
@@ret:
	call WaitUntilPressed
	ret
endp GameLoop



proc Fail
	push es
	push 0A000h
	pop es
	mov di, 0
	mov ax, 0
	mov cx, 32000
	rep stosw
	pop es
	
	mov ah, 2
	mov bh, 0
	mov dx, 0
	int 10h
	mov dx, offset FailMsg
	mov ah, 9
	int 21h
	ret
endp Fail


;================================================
; Description - Clears the screen (color it black)
;				Moves the cursor to 0,0 (top left)
;				Calls for a further proc
; INPUT: None
; OUTPUT: Screen 
; Register Usage: di, ax, cx, bh, dx + es (seg, not a register)
;================================================
proc Victory
	push es
	push 0A000h
	pop es
	mov di, 0
	mov ax, 0
	mov cx, 32000
	rep stosw ; ax -> es:di 32,000 times
	pop es
	
	mov ah, 2
	mov bh, 0
	mov dx, 0
	int 10h
	
	call OpenReadTopScore
	ret
endp Victory




;================================================
; Description - Opens the file of the top score name 'Score.txt'
;				Reads the top score and displays it on the screen
;				Compare the player's score to the top and displays
;				he passed it or not.
;				If he does- writes to the file to update the top score.
; INPUT: var- TimeHere
; OUTPUT: Screen, File: 'Score.txt'
; Register Usage: ax, bx, cx, dx, si
;================================================
proc OpenReadTopScore
; Display victory message - "You won...."

	mov ah, 09h
	mov dx, offset VictoryMsg
	int 21h
	
	NewLine
	
;Displays the player's score in seconds with a message included
	mov dx, offset YourScore
	int 21h
	
	mov ax, [TimeHere]
	call ShowAxDecimal
	
;Opend the file 'Score.txt'
	mov ah, 3dh
	mov al, 0
	mov dx, offset ScoreFileName
	int 21h
	mov [FileHandle], ax
	
;Reads the content of the file
	mov ah, 3fh
	mov bx, [FileHandle]
	mov cx, 14
	mov dx, offset ReadArray
	int 21h
	
;Displys the top score in seconds
	NewLine
	mov ah, 9
	mov dx, offset TopScore
	int 21h
	mov dx, offset ReadArray
	int 21h






; Compares the two scores (player's and top) and determines whether or not
; the player's score is the new top score

	mov bx, offset ReadArray ;Location of the score to compare
	xor ax, ax ; For multiply later
	mov dx, 10 ; The multiplyer - because to compare, we need both scores 
	           ; on decimal base (cuz thats how it displays on the screen)
	mov si, 0  ; si is the number in the array to read
	mov cx, 3  ; 3 digits number
@@Loop:
	mul dx                  ; multiply by 10 for decimal base and to add another num
	mov dx, 10              ; dx = 0 after division
	sub [byte bx+si], '0'   ;Remove ASCII number value
	add al, [byte bx+si]    ; AX = top score rn
	inc si 					;Next digit to read
	loop @@Loop
	
	cmp ax, [TimeHere]      ;Comparison
	jnb @@ll                ; If ax (the top score unsigned) is equal or below (smaller) 
							; than the top score, jump to the part of writing to the file
							; otherwise, continue and than exit
	NewLine
	mov ah, 09h
	mov dx, offset VictoryMsgNotScoreboard
	int 21h
	jmp @@Pret              ; jump to a mid-way (Pret) area because a direct jump is too far
							; Pret - Previous to ret
	
@@ll:    					; From now on, the player has won and is the top score
	NewLine
	mov ah, 09h
	mov dx, offset VictoryMsgScoreboard
	int 21h
	
	
@@Write:

;Reads the player's name from the interface
	mov ah, 0Ah
	mov dx, offset ScoreName
	mov [ScoreName], 10
	int 21h
	
	
	
	
	
	
	
;Gets the score to write and put in the right array, later will be written to the score file
;The score that will be written will be decimal ofc

	mov ax, [TimeHere]		 ;Will be divided later on
	mov bl, 10				 ; Divisor

;1st digit
	cmp ax, 0  				 ; No div 0 or by 0 nononononono
	je @@n
	div bl					 ; Get the top right number by dividing, 
	; That is a byte size dividing, so bl is the divisor, al is divided and ah is the שארית
	
	add ah, '0'				 ; Add ASCII number value to be a nice char to read
	mov [WriteToFile+2], ah  ;Move to array the will be written to the file
	
;2nd digit
	XOR AH, AH				 ; Nice and xored for the next digit
	cmp al, 0  				 ; No div 0 or by 0 nononononono						
	je @@n
	div bl
	add ah, '0'
	mov [WriteToFile+1], ah
	
;3rd digit
	add al, '0'              ; no need to div, it's the last one (al<10)
	mov [WriteToFile+0], al
	
	
	
	
	
	
	
	
; Copies the name of the player to the array to write, if no letter is there, 
; put 20 (space)
@@n:
	mov cx, 10               ; Max letter for the name area
	mov si, 0                ; Number of letter to take from the array
@@Loop2:
	mov al, [ScoreName+2+si] ; Gets the number
	cmp al, 0				 ; if empty- put space
	je @@Its0
	mov [WriteToFile+4+si], al
	jmp @@Next
@@Its0:
	mov [WriteToFile+4+si], 20
@@Next:
	inc si
	loop @@Loop2
	jmp @@dss
	
	
	
	
	; MIDZONE for jump to the ret
	; Pret is for previous ret
@@Pret:
	jmp @@Ret
	
	
	
	
	
	
	
@@dss:
;Closes the file and re-opens it to write intead of read

	mov ah, 3Eh
	mov bx, [FileHandle]
	int 21h
	
	mov ah, 3dh
	mov al, 1
	mov dx, offset ScoreFileName
	int 21h
	mov [FileHandle], ax
	
	
	
	
	
	
	
;removes the 0Dh (CR), and makes it the end of the array to write

	mov si, 0 ; the pointer for which char in the array
@@Looper:
	inc si
	cmp [BYTE WriteToFile+4+si], 0Dh
	jne @@Looper
	mov [byte WriteToFile+4+si], 0 ; 0 = end of array
	
	
	
	
	
;Writes to the file

	mov ah, 40h
	mov bx, [FileHandle]
	mov cx, 14
	mov dx, offset WriteToFile
	int 21h

	
@@Ret:
	; Close and out
	
	mov ah, 3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp OpenReadTopScore



proc SetTimer
	mov [Timer], 90 ; 1 and a half minutes
	ret
endp SetTimer






;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there and show it. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
proc ShowAxDecimal
       PUSH_ALL
	   
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack


       add al,30h  ;'0'
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
   
	   POP_ALL
	   
	   ret
endp ShowAxDecimal






;================================================
; Description - Writes the timer in the down left 
; corner of the screen using ShowAxDecimal for the seconds
;
; INPUT: var- TimeHere
; OUTPUT: Screen 
; Register Usage: ax,bx,dx
;================================================
proc ShowTimer
	PUSH_ALL
	push dx
	; move the cursor to down-left corner
	mov bh, 0
	mov ah, 2
	mov dh, 24
	mov dl, 0
	int 10h
	pop dx
	
	
	; To make it look nicer, print a 0 before the minutes
	mov ah, 2
	mov dl, '0' ;add ASCII
	int 21h
	xor dx, dx
	mov ax, [Timer]
	mov bx, 60
	div bx    ;Get the minutes by diving by 60
	xchg ax, dx ;To print
	add dl, '0' ;add ASCII
	push ax
	push dx
	mov ah, 2 ;Print minutes and ':'
	int 21h
	mov dl, ':'
	int 21h
	pop dx
	pop ax
	
	;Displays the seconds
	call ShowAxDecimal
	
	; returns the cursor to 0,0
	mov bh, 0
	mov ah, 2
	mov dh, 0
	mov dl, 0
	int 10h
	POP_ALL
	ret
endp ShowTimer
	
	



;================================================
; Description - Returns everything to 0
; INPUT: None
; OUTPUT: All the vars (except one that keeps score along the game) = 0
; Register Usage: si = byte count, di = word count, cx = Loop
;================================================
proc Zero
	PUSH_ALL
	mov cx, 5
	mov si, 0
	mov di, 0
@@Loop:
	mov [DuckOneL+si], 1
	mov [DuckOneX+di], 0
	mov [DuckOneDirection+si], 1
	inc si
	inc di
	inc di
	loop @@Loop
	POP_ALL
	ret
endp Zero


;;;;;;;;;;;;;;PROCS
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

proc SetText
	mov ax, 2
	int 10h
	ret
endp SetText





;================================================
; Description - Displays the opening screen using OpenShowBmp
; INPUT: None
; OUTPUT: Screen 
; Register Usage: dx
;================================================
proc Opening

	mov dx, offset Front
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	
	
	mov dx, offset Front
	call OpenShowBmp
	
	
ret
endp Opening





;================================================
; Description - Wait until the keyboard sends anything
; INPUT: None
; OUTPUT: None
; Register Usage: AX  
;================================================
proc WaitUntilPressed

	push ax
	mov ah, 0
	int 16h
	pop ax
	ret
endp WaitUntilPressed







;================================================
; Description - Sets an Async procedure (MyMouseHandle)
; 				for the actions of pressing the left mouse
;				button or just movement
; INPUT: None
; OUTPUT: None
; Register Usage: ax, dx, cx
;================================================
proc setAsyncMouse 
	mov ax, 1
	int 33h
	mov ax, 2
	int 33h
	mov [AsyncBoolean], 1
	
	 mov ax, seg MyMouseHandle 
     mov es, ax
     mov dx, offset MyMouseHandle   ; ES:DX ->Far routine
     mov ax,0Ch             ; interrupt number
     mov cx,00000011b              ; 2 = Left down, 1 = Movement
     int 33h                
	
	 
	ret
endp setAsyncMouse




;This proc is Async proc - 
; It will be registered using int33h (0ch) 
; then, each time when Mouse event will occur it will be called by mouse program (and OS).
; Events : movement and left button pressed
PROC MyMouseHandle  far
stop:
	cmp [AsyncBoolean], 0  ;Check
	je c1
	jne @@Rest

c1:
	jmp ExitProc
	
	
	
@@Rest:

	shr cx, 1
	cmp ax,2         ; Second bit = left click, left click before movement (priority)
	je @@LeftClick
	cmp ax, 1        ; First bit = movement
	je @@JustMovementNicht	
	jmp ExitProc
	
	

	
@@LeftClick:
	call CheckIfHit   ; Other proc to check if the duck will live or not
	
; Draw a line between the mouse and the last row, at the middle
	mov [Color], 11
	mov [point1X], 160
	mov [point1Y], 199
	
	
; Move the 2nd X as the wind says
	cmp [WindDirection], 0 ;1-Left, 0-Right 
	je @@add
@@sub:
	sub cx, [Wind]
	mov [point2X], cx
	add cx, [Wind]
	jmp @@l
@@add:
	add cx, [Wind]
	mov [point2X], cx
	sub cx, [Wind]
@@l:
	mov [point2Y], dx
	call DrawLine2D           ;Draw
	call Shoot				  ;Music
	call ChangeDuckSpeedRnd   ;Continue the procedure
	call GameBackground		  ;Cover the tracks
	call DrawDucks
	call SetWindRnd
	
@@JustMovementNicht:
	push es
	push 0A000h
	pop es
	
	;Covering Last taking the last place colors and putting it where the mouse was
	push dx
	mov ax, [LastMousePlaceY]
	mov bx, 320
	mul bx
	add ax, [LastMousePlaceX]
	mov bx, ax
	mov al, [LastPlaceColor]
	mov [es:bx], al
	mov al, [LastPlaceColorP1]
	mov [es:bx+1], al
	mov al, [LastPlaceColorP320]
	mov [es:bx+320], al
	mov al, [LastPlaceColorP321]
	mov [es:bx+321], al
	
	;Putting a dot in space, saving what was there before
	pop dx
	mov [LastMousePlaceY], dx
	mov [LastMousePlaceX], cx
	mov ax, dx
	mov dx, 320
	mul dx
	add ax, cx
	mov bx, ax
	mov al, [es:bx]
	mov [LastPlaceColor], al
	mov al, [es:bx+1]
	mov [LastPlaceColorP1], al
	mov al, [es:bx+320]
	mov [LastPlaceColorP320], al
	mov al, [es:bx+321]
	mov [LastPlaceColorP321], al
	mov al, 04Fh      ;The color red
	mov [es:bx], al
	mov [es:bx+1], al
	mov [es:bx+320], al
	mov [es:bx+321], al
@@Holup:
	pop es
	
	jmp ExitProc
ExitProc:

	retf
ENDP MyMouseHandle 




;================================================
; Description - Check if the shot hit.
;				First - if it hit a yellow place or black (body and eye)
;				If it is, cmp to the Y, and remove the duck
;				Else, bye bye
; INPUT: var - LastPlaceColor
; OUTPUT: Screen 
; Register Usage: ax, bx, cx, dx
;================================================
proc CheckIfHit
	PUSH_ALL
	push es
	push 0A000h
	pop es
	
	push dx
@@CheckIfYellow:
	mov bx, 320
	mov ax, dx
	MUL BX
	
	;Moves the checking point cuz wind
	cmp [WindDirection], 0 ;1-Left, 0-Right 
	je @@add
@@sub:
	sub cx, [Wind]
	add ax, cx
	jmp @@l
@@add:
	add cx, [Wind]
	add ax, cx
@@l:
	
	
	
	
	mov bx, ax
	pop dx
	mov cx, dx
	mov al, [LastPlaceColor]
	cmp al, 0FBh   ;0FBh = yellow
	je @@Hit
	cmp al, 0      ;0 = black
	je @@Hit
	jmp @@ret

;Check which duck, by cmp the Y
@@Hit:
	cmp cx, 25
	jl @@DuckOne
	je @@ret
	
	cmp cx, 51
	jl @@DuckTwo
	je @@ret
	
	cmp cx, 77
	jl @@DuckThree
	je @@ret
	
	cmp cx, 103
	jl @@DuckFour
	je @@ret
	
	cmp cx, 129
	jl @@DuckFive
	jmp @@ret
	
;Kill the duck
@@DuckOne:
	mov [DuckOneL], 0
	jmp @@ret
@@DuckTwo:
	mov [DuckTwoL], 0
	jmp @@ret
@@DuckThree:
	mov [DuckThreeL], 0
	jmp @@ret
@@DuckFour:
	mov [DuckFourL], 0
	jmp @@ret
@@DuckFive:
	mov [DuckFiveL], 0
	jmp @@ret
	
@@ret:
	pop es
	POP_ALL
	ret
endp CheckIfHit




;================================================
; Description - Changes the wind, direction and speed by RandomByCsWord
; INPUT: None
; OUTPUT: var - WindDirection, Wind
; Register Usage: bx, dx
;================================================
proc SetWindRnd
mov bx, 2
mov dx, 10
call RandomByCsWord
mov [Wind], ax
mov bx, 0
mov dx, 1
call RandomByCsWord
mov [WindDirection], ax
	ret
endp SetWindRnd






;================================================
; Description - Checks for getting out of the game.
;				If time's up - lost.
;				If all duck are dead - next round, all vars to 0.
;				If round 4 ended - get out of the game (Victory).
; INPUT: None
; OUTPUT: Screen 
; Register Usage: ax, bx, cx  
;================================================
proc CheckForOut
	PUSH_ALL

@@CheckOnTimer:
	cmp [Timer], 0  ;If equal - lost
	je @@Fail
	
	
	
@@CheckOnLives:
	;Duck Lives - If ax (the sum of lives) is equal to 0- move to next round
	xor ax, ax
	xor bx, bx
	mov cx, 5
	
; take the amount of living ducks, if 0 - next round.
@@Loop:
	add al, [DuckOneL+bx]
	inc bx
	loop @@Loop
	
	cmp al, 0 ;If equal - round's over
	je @@NextRound
	jne @@Continue
	
	
@@NextRound:
	cmp [Round], 4
	je @@Victory
	call Zero ; Put all of the vars on initial value
	inc [Round]
	add [Timer], 20 ; add 20 seconds
	
	push cx ;save cx
	mov cx, 6 ;Delay between Rounds
@@InLoop:
	call LoopDelay
	loop @@InLoop
	pop cx
	jmp @@Continue
	
	
@@Victory:
	mov [GameOver], 1
	mov [Reason], 1
	jmp @@Continue
	
@@Fail:
	mov [GameOver], 1
	mov [Reason], 2
	jmp @@Continue
	

	
@@Continue:
	POP_ALL
	ret
endp CheckForOut





;================================================
; Description - Displays the screen in the middle-
;				downside of the screen.
;				Displays the number in decimal with
;				ShowAxDecimal.
; INPUT: None
; OUTPUT: Screen 
; Register Usage: ax, bx, dx
;================================================
proc DisplayWind
	PUSH_ALL
	
;Moves the cursor to top down left corner
	mov bh, 0
	mov ah, 2
	mov dh, 24
	mov dl, 30
	int 10h
	
;Writes "Wind:"
	mov dx, offset WindMsg
	mov ah, 9
	int 21h
	
;Checks if the wind is to the right/left, and puts +/-
	cmp [WindDirection], 0 ;1-Left, 0-Right 
	je @@Right
	
@@Left:
	mov dl, '-'
	mov ah, 2
	int 21h
	jmp @@rest
	
@@Right:
	mov dl, '+'
	mov ah, 2
	int 21h
	jmp @@rest
	
@@rest:
	mov ax, [Wind]
	call ShowAxDecimal
	
;Moves the cursor back to 0,0
	mov bh, 0
	mov ah, 2
	mov dh, 0
	mov dl, 0
	int 10h
	
	
	POP_ALL
	ret
endp DisplayWind


;================================================
; Description - Draw the background of the game,
;				and sets the Async mouse proc.
;				* Mainly a management proc *
; INPUT: None
; OUTPUT: Screen 
; Register Usage: None
;================================================
proc GameOn
	call GameBackground
	
	call setAsyncMouse
ret
endp GameOn




;================================================
; Description - Draws the game background using
;				OpenShowBmp
; INPUT: None
; OUTPUT: Screen 
; Register Usage: dx
;================================================
proc GameBackground ; Open Pics and displays on screen (320 * 200)
	mov dx, offset Back
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	call OpenShowBmp
	
	
	
ret
endp GameBackground




;================================================
; Description - Changes each and every duck's speed
;				with RandomByCsWord.
; INPUT: var - DuckLive
; OUTPUT: Vars [Duck__Speed] 1-5, later on the screen
; Register Usage: cx, si, dx
;================================================
proc ChangeDuckSpeedRnd
PUSH_ALL
mov cx, 5 ;5 Ducks
mov si, 0 ;Starts with 0, on to 4 (5 tot)

@@Loop:
cmp [DuckOneL+si], 0 ;If it isn't alive - it won't move
je @@EndOfLoop

mov bx, 5 ;Min for rnd
mov dx, 57 ;Max for rnd
call RandomByCsWord
mov [DuckOneSpeed+si], al ;Takes the random num and puts it in the speed var

@@EndOfLoop:
inc si ;Onto the next Duck
loop @@Loop
POP_ALL
ret
endp ChangeDuckSpeedRnd



;================================================
; Description - Moves the ducks' position on the 
;				actual screen (and in vars - Ducks' X)
; INPUT: Vars - DuckSpeed, DuckLive, DuckX, DuckDirection
; OUTPUT: Screen, and var - Ducks' X, DuckDirection
; Register Usage: ax, bx, cx, dx, si, di
;================================================
proc MoveDucks
PUSH_ALL
mov cx, 5 ;5 Ducks
mov di, 0 ;Byte counter (up by 1 each time)
mov si, 0 ;Word counter (up by 2 each time)
@@Loop:
cmp [DuckOneL+di], 0 ;Won't move if it is dead
je @@EndLoop

;Compares the duck's direction and moves the way it should move
mov al, [DuckOneSpeed+di] ;for later on
mov ah, [DuckOneDirection+di] ;1- right, 0-left
cmp ah, 0
je @@Left 

;Moves the duck to the right
@@Right:
mov bx, [DuckOneX+si]
add bx, DUCK_WIDTH ;The duck's X is to his most left pixel
mov ah, 0 ; To Make al word sized (al->ax), al was the speed
add bx, ax ;Ax was the speed, Bx was the X, now bx = speed+X = Current Pos
cmp bx, 320 ;If it's out of the screen, change side
jnb @@ChangeDirectionFromRight 
add [word DuckOneX+si], ax 
jmp @@EndLoop

;Moves the duck to the left - Same proc as the @@Right 
@@Left:
mov bx, [DuckOneX+si]
mov ah, 0  ; To Make it a word sized
sub bx, ax
cmp bx, -1
jng @@ChangeDirectionFromLeft
sub [word DuckOneX+si], ax
jmp @@EndLoop

@@ChangeDirectionFromRight:
mov [DuckOneDirection+di], 0 ;Change direction
sub bx, 320 ; if it's over 320, 320-bx should give the rest of the distance
mov dx, 320
sub dx, bx
sub dx, DUCK_WIDTH ;make the X most left pixel
mov [word DuckOneX+si], dx
jmp @@EndLoop

@@ChangeDirectionFromLeft:
mov [DuckOneDirection+di], 1
sub ax, [word DuckOneX+si] ; it's like: neg X - SPEED (math.abs(X-speed)). The rest of what left from the speed, is the new pos
add ax, DUCK_WIDTH ;return the X to it's right place
mov [word DuckOneX+si], ax
jmp @@EndLoop

@@EndLoop:
inc si
inc si
inc di
loop @@Loop

POP_ALL
ret
endp MoveDucks



;================================================
; Description - A management proc
; INPUT: dx - File's name, vars: BmpColSize,BmpLeft,BmpTop,BmpRowSize (obvious)
; OUTPUT: Screen 
; Register Usage: None
;================================================
proc OpenShowBmp
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
@@ShowBmp:
	call  ShowBmp
	
	

	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp






;================================================
; Description - Opens the wanted bmp file on
;				reading mode, if there's an error
;				jmp to Error
; INPUT: dx - pointer to array of file name
; OUTPUT: like int 21h - 3dh (ax = handle)
; Register Usage: ax
;================================================
proc OpenBmpFile						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile


;================================================
; Description - Reads the 54 first bytes in the bmp
;				file called "Header" and puts it
;				in a var named Header
; INPUT: var - FileHandle
; OUTPUT: array - Header
; Register Usage: ax, bx, cx, dx
;================================================
proc ReadBmpHeader				
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



;================================================
; Description - Reads the 400h (1024) first bytes,
;				starts at 54 (end of handle).
;				This is the bmp's palette, thus
;				will to the array - Palette.
;
;				Read BMP file color palette, 256 colors * 4 bytes (400h)
; 				4 bytes for each color BGR + null)
;
; INPUT: var - FileHandle
; OUTPUT: array - Palette
; Register Usage: ax, bx (from previous procs), cx, dx
;================================================
proc ReadBmpPalette near 		
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette





;================================================
; Description - Moves the bmp's palette to the
;				program's palette.
;				Moves the var Palette into the
;				port 3C9h (Screen's palette).
;				The default (black = 0) will go
;				to the default port, 3C8h.
;
; INPUT: array- Palette
; OUTPUT: File Palette, ports 3C8h and 3C9h
; Register Usage: ax, cx, dx, si
;================================================
; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h it uses dx to the out cmd cuz 3C8h < 255 (max for number)
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cuz max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
	; The last byte is for something that 8086 won't use (too advanced), so we skip it (+4 bytes to si).
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette









;================================================
; Description - Display the BMP file on the screen.
;				Reads always one row from the bmp file 
;				and displays it	in es.
; INPUT: bx - file handle
; OUTPUT: array - Screen
; Register Usage: ax, bx (previous procs), cx, dx, bp, si, di 
;================================================
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize] ;for later
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0 ; if dx = 0 no leftovers, else bp will be the leftovers for later
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx ;sub the שארית, so we know what should be in the leftovers

@@row_ok:	
	mov dx,[BmpLeft] ;Where to begin
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line to the begin with
	dec di
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4 (calculated before)
	mov dx,offset ScrLine ; <- save the bytes
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsw to move forward
	mov cx,[BmpColSize]
	shr cx, 1
	mov si,offset ScrLine
	rep movsw ; Copy line to the screen, ds:si to es:di, inc si,di, times the 
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 

	
	
;================================================
; Description - Closes the file (int 21h -3Eh)
;
; INPUT: var - FileHandle
; OUTPUT: None
; Register Usage: ax, bx
;================================================
proc CloseBmpFile
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile






;---------------------------------------------;
; input: point1X point1Y,         ;
; 		 point2X point2Y,         ;
;		 Color                                ;
; output: line on the screen                  ;
;---------------------------------------------;
PROC DrawLine2D
	mov cx, [point1X]
	sub cx, [point2X]
	absolute cx
	mov bx, [point1Y]
	sub bx, [point2Y]
	absolute bx
	cmp cx, bx
	jnae @@c1        ; deltaX <= deltaY
	jmp DrawLine2Dp1 ; deltaX > deltaY
@@c1:
	mov ax, [point1X]
	mov bx, [point2X]
	mov cx, [point1Y]
	mov dx, [point2Y]
	cmp cx, dx
	jbe DrawLine2DpNxt1 ; point1Y <= point2Y
	xchg ax, bx
	xchg cx, dx
DrawLine2DpNxt1:
	mov [point1X], ax
	mov [point2X], bx
	mov [point1Y], cx
	mov [point2Y], dx
	DrawLine2DDY point1X, point1Y, point2X, point2Y
	ret
DrawLine2Dp1:
	mov ax, [point1X]
	mov bx, [point2X]
	mov cx, [point1Y]
	mov dx, [point2Y]
	cmp ax, bx
	jbe DrawLine2DpNxt2 ; point1X <= point2X
	xchg ax, bx
	xchg cx, dx
DrawLine2DpNxt2:
	mov [point1X], ax
	mov [point2X], bx
	mov [point1Y], cx
	mov [point2Y], dx
	DrawLine2DDX point1X, point1Y, point2X, point2Y
	ret
ENDP DrawLine2D


;-----------------------------------------------;
; input: pointX pointY,      					;
;           Color								;
; output: point on the screen					;
;-----------------------------------------------;
PROC PIXEL
PUSH_ALL

	mov bh,0h
	mov cx,[pointX]
	mov dx,[pointY]
	mov al,[Color]
	mov ah,0Ch
	int 10h
	
POP_ALL
	ret
ENDP PIXEL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;												 ;
;												 ;
;												 ;
;                In-Game Procs					 ;
;												 ;
;												 ;
;												 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;================================================
; Description - Draw the ducks on the screen,
;				each one with a singular proc
;
; INPUT: vars- Ducks' X, Ducks' directions
; OUTPUT: Screen
; Register Usage: ax, bx, cx, si, di
;================================================
proc DrawDucks
mov [TopH], 0 ;initial Y
mov si, 0 ;Word counter (up by 2 each time)
mov di, 0 ;Byte counter (up by 1 each time)
mov cx,5 ;5 ducks
@@Loop:

cmp [DuckOneL+di], 0 ;No painting if it's dead
je @@EndOfLoop

mov ax, [DuckOneX+si]
mov [TopL], ax ;Get the duck's X to local var for further proc
cmp [DuckOneDirection+di], 0 ;Decides which side to draw (0-left, 1-right)
je @@Left

@@Right:

call DrawDuckRight

jmp @@EndOfLoop

@@Left:

call DrawDuckLeft

jmp @@EndOfLoop

@@EndOfLoop:
add [TopH], DUCKS_GAP ;add Y for next duck
inc si ; Inc for next duck
inc si
inc di
loop @@Loop


mov [TopH], 0 ;reset just in case
ret
endp DrawDucks



;================================================
; Description - Draw a duck facing to the right side.
;				Takes the values from the array called DuckRight
;				and moves them to es with a loop.
;				Kind of a movsb with an addition.
; INPUT: vars - TopH, TopL
; OUTPUT: Screem
; Register Usage: ax, bx, cx, dx, si, di
;================================================
proc DrawDuckRight
PUSH_ALL

;Gets the first (x,y) for the loop
push es
push 0A000h
pop es
mov ax, [TopH]
mov bx, 320
mul bx ;Got the Y
mov bx, ax ;got the X
mov si, 0
mov di, 0

add bx, [TopL] ; X,Y
mov cx, 29 ;29 Width
mov dx, 25 ;25 Length

;Loop start (two counter cuz di need to reset)
@@FirstLoop:
@@SecondLoop:
mov al, [byte DuckRight+si] ;Read from array
mov [byte es:bx+di], al ;Move to the screen
inc si
inc di
loop @@SecondLoop

mov di, 0 ;reset di
add bx, 320 ; down by one row
mov cx, 29 ; another col size loop
dec dx ;outer loop counter (row amount)
cmp dx, 0
jnz @@FirstLoop ;Next row
pop es

POP_ALL
ret
endp DrawDuckRight



;================================================
; Description - Draw a duck facing the left side.
;				reads from the end of the lind backwords
;				pastes normally, like the draw right proc.
;
; INPUT: var - FileHandle
; OUTPUT: array - Palette
; Register Usage: ax, bx (from previous procs), cx, dx
;================================================
proc DrawDuckLeft
PUSH_ALL
push bp
push es
push 0A000h
pop es
; Gets the X,Y, like above
mov ax, [TopH]
mov bx, 320
mul bx ; Got Y
mov bx, ax ; bx = Y
mov si, offset DuckRight
add si, 29 ;Start from the end
mov di, 0

add bx, [TopL] ; add the X for X,Y
mov cx, 29 ; 29 cols
mov dx, 25 ; 25 rows

@@FirstLoop:
@@SecondLoop:
mov al, [byte ds:si]
mov [byte es:bx+di], al
dec si
inc di
loop @@SecondLoop

add si, 29*2 ; the end of next line in the array
mov di, 0 ;reset
add bx, 320 ; Next row
mov cx, 29 ; 29 cols (inner loop)
dec dx
cmp dx, 0
jnz @@FirstLoop ; Next
pop es
pop bp

POP_ALL
ret
endp DrawDuckLeft



;Random to make it more comfortable.
;My desc:
;================================================
; Description - Makes a rnd number between bx and dx
;				The actual number will be from 0 to dx-bx
;				an bx will be added later.
;				Uses an opcode from CS and the time counter,
;				XORs them for max randomization and make
;				a mask to keep it in range.
;
; INPUT: bx(min), dx(max), var - RndCurrentPos
; OUTPUT: array - ax
; Register Usage: ax, bx si, di, dx
;================================================

;Yos' Desc:
; Description  : get RND between any bx and dx includs (max 0 - 65,535)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
;
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h ;es is now the clock segment
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta (הפרש) between bx and dx
			   ; Now dx holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (dx) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter (40:06ch)
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter for better randomization
	
	; Now inc di in order to get a different number next time (useful if called at the same second)
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2) ;make sure the di isnt out of the cs range
	jb @@Continue
	mov di, offset start ; reset di if it's out of range
@@Continue:
	mov [word RndCurrentPos], di ; inc it for other number next time
	
	and ax, si ; filter result between 0 and si (the mask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord





; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if dx 4 or 5 or 6 or 7 si will be 7 (0111b)
; 		   if dx 64 till 127 si will be 127
Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord






; Description: This proc will make audio sound of gun shoot.	
;Step 1.  Copy a certain number (182) to Timer 2 (port 43h) to initialize it.
;Step 2.  Copy a 16 bit number to Timer to establish the frequency 
;             of the tone to be generated (port 42h).
;Step 3.  Turn on the speaker to enable the frequency adjusted sound
;             to be heard. (port 61h with or 00000011)
;Read more: http://www.intel-assembler.it/portale/5/make-sound-from-the-speaker-in-assembly/8255-8255-8284-asm-program-example.asp#ixzz3UqesSmjq

;The frequency number at BX  can take values between 0 and 65,535 inclusive. 
;This means you can generate any frequency between 18.21 Hz (frequency number = 65,535) 
;and 1,193,180 Hz (frequency number = 1).
proc Shoot
	PUSH_ALL
again1:
	mov     dx, 01000h
	mov     bx,500h             ; frequency value.
	 
	mov     al, 10110110b    ; 10110110b the magic number (use this binary number only)
	out     43h, al          ; actiavted.
	 
next_frequency:               ; Dx times.
	 
	mov     ax, bx           
	 
	out     42h, al          ; lsb to port 42h. (al)
	mov     al, ah            
	out     42h, al          ; send msb to port 42h. (ah)
	 
	in      al, 61h          ; get the value of port 61h.
	or      al, 00000011b    ; or al to this value, forcing first two bits high.
	out     61h, al          ; to turn on the speaker.
	 
	mov     cx, 70           ; just delay
delay_loop1:        
	loop    delay_loop1       

	inc     bx               ; inc requency 
	dec     dx          
	cmp     dx, 0          
	jnz     next_frequency  
	 
	in      al,61h           
	and     al,11111100b       ; turn speaker off
	out     61h,al           
	
	POP_ALL
	ret
endp Shoot






;================================================
; Description - Creates a delay between each round
;				of the game loop
;
; INPUT: None
; OUTPUT: Delay
; Register Usage: cx
;================================================
proc LoopDelay
	push cx
	
	mov cx ,100;250
@@Self1:
	
	push cx
	mov cx,2225

@@Self2:	
	loop @@Self2
	
	pop cx
	loop @@Self1
	
	pop cx
	ret
	
endp LoopDelay


EndOfCsLbl:
END start