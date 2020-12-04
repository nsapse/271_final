TITLE Project 6     (Proj6_SAPSEN.asm)

; Author: Noah Sapse
; Last Modified: 11/26/20
; OSU email address:sapsen@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/6/20
; Description:		Project 6 is the final project for CS271 it involves doing the following:
;					1. Implements macros that get and display a string to the user.
;					2. Uses those to get ten digits from the user
;					4. Stores the numeric values in an array
;					5. Implements procedures which convert strings of ascii digits to numeric representations and
;					then converts it back into ascii digits for display.
;					6. Displays the integers, their sum, and their average.

INCLUDE Irvine32.inc

MAX_LEN	= 11				; The max length of the string the user can input. A 32 bit register can hold a value of up
							; to 2,147,483,647 which is ten digits long. An additional byte is being allowed for a sign 
							; digit (i.e. + or -)


; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Ask the user to enter a number then saves it into a predetermined memory
; location as an ASCII value. It is assumed this ASCII string will later be converted
; into a decimal.
;
; Preconditions: None
;
; Receives:
;			promptString	-		The string for prompting the user
;			saveLocation	-		The Address of the array where it will be storing the value entered
;			maxLength		-		The Max Length of Acceptable Input
;			blank_error		-		An error message for when the user doesn't enter anything
;			input_len		-		A memory location to store the length of the input entered by the user
;			
; returns:	None (not allowed ... murmurs to self)
; ---------------------------------------------------------------------------------
mGetString	MACRO promptString, saveLocation, maxLength, blank_error, input_len
	push	EDX
	push	ECX
	push	EAX
	push	ESI
	push	EDI

	; ---------------------------------------------------------------------------------
	;	Get input from the User - First Display A Prompt then Read Input
	; ---------------------------------------------------------------------------------
	_prompt_user:
		mov		EDX, promptString
		call	WriteString
		mov		EDX, saveLocation
		mov		ECX, maxLength
		call	ReadString
	

	; Determine if the User Entered a Blank String and Re-Prompt if Necessary
	_check_for_input:
		cmp		EAX, 1
		JB		_display_error
		push	EDI
		mov		EDI, input_len
		mov		[EDI], EAX
		pop		EDI
		;call	WriteInt
	
	; ---------------------------------------------------------------------------------
	;	Move User's Input to saveLocation. Uses addresses returned by ReadString to 
	;	initiate move using string primitives.
	; ---------------------------------------------------------------------------------
	
	mov		ECX, EAX			; Set counter to number of characters entered
	mov		ESI, EDX			; The source is EDX where ReadString wrote to
	mov		EDI, saveLocation	; The Destination is our input array
	
	CLD
	rep		MOVSB
	
	jmp		_restore_registers

	; _display an error if the number entered was too low (blank)
	_display_error:
		mov		EDX, blank_error
		call	writeString
		jmp		_prompt_user

	; Restore Registers
	_restore_registers:
		pop		EDI
		pop		ESI
		POP		EAX
		pop		ECX
		pop		EDX
	
ENDM

;	WriteString ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays a string to the screen.
;
; Preconditions: An array of ASCII data exists to display
;
; Receives:
;			arrayAdr = The Address of the Array of ASCII data.
;
; returns:  None
; ---------------------------------------------------------------------------------

mDisplayString	MACRO arrayADR
	mov		EDX, arrayADR
	call	writeString
ENDM

mIncrementBuffer MACRO bufferADR
	push	ebx
	push	EDI
	mov		EDI, [bufferADR]
	mov		ebx, 1
	add		[EDI], ebx
	pop		EDI
	pop		ebx
ENDM
; (insert constant definitions here)

.data

; ---------------------------------------------------------------------------------
;	Messages and Strings
; ---------------------------------------------------------------------------------

; The introductory strings
introString			BYTE	"Assignment Six - To Hell and Back",0
authorString		BYTE	"Written by: Noah Sapse",0

; Strings with instructions for the user on how to use the program
instructionString	BYTE	"Please provide 10 signed decimal numbers", 0
registerString		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0
resultString		BYTE	"Afterwords a list of the integers, their sum, and their average will be displayed.",0
requestString		BYTE	"Please enter a signed number: ",0
enteredString		BYTE	"You Entered: ",0

; Error Messages
errorString			BYTE	"Your number was either unsigned, too large, or not a number. Try again", 0
emptyErrorMessage	BYTE	"You did not enter anything. ", 0

; Memory to Save Digits as ASCII String/Convert ASCII to Digits
stringBuffer		BYTE	MAX_LEN DUP(?)	
stringBufferSize	DWORD	SIZEOF stringBuffer
numBuffer			SDWORD	0
inputLen			DWORD	1 DUP(0)
numLen				DWORD	0
signIndicator		DWORD	1 DUP(0)
allInputArray		DWORD	10 DUP(0)
arraySumBuffer		SDWORD	0

; Memory for Converting the Decimal Data to ASCII
outputBuffer		BYTE	MAX_LEN DUP(?)	
outputString		BYTE	MAX_LEN DUP(?)	
reversalBuffer		BYTE	MAX_LEN DUP(?)	

.code

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Prints a nice little introduction for our user explaining the name of the 
; program and how to use it.
;
; Preconditions:		Strings have been pushed to the stack
;
; Postconditions:		Strings are displayed on screen.
;
; Receives:			
;				[ebp + 8]	-	The Title/Introductory String
;				[ebp + 12]	-	The Author String
;				[ebp + 16]	-	Instruction String Part 1
;				[ebp + 20]	-	Instruction String Part 2
;				[ebp + 24]	-	Instruction String Part 3
;
; Returns:		None 
; ---------------------------------------------------------------------------------

introduction PROC
	; setting up the base pointer
	push	EBP
	mov		EBP, ESP

	; Saving Registers
	push	EDX

	; Prints the Title String
	mDisplayString [EBP + 8]
	call	Crlf

	; Prints the Author String
	;mov		EDX, [EBP + 12]
	mDisplayString [EBP + 12]
	call	Crlf

	; Print a nice little buffer before the instructions
	call	Crlf
	call	Crlf

	; Prints the Instruction Strings
	;mov		EDX, [EBP + 16]
	mDisplayString	[EBP+ 16]
	;mov		EDX, [EBP + 20]
	mDisplayString	[EBP + 20]
	;mov		EDX, [EBP + 24]
	mDisplayString	[EBP + 24]


	; Print a nice little buffer before the next block of text 

	call	Crlf
	call	Crlf

	pop		EDX
	pop		EBP
	ret		24	
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Ask the user to enter a number then reads it in an ASCII value 
; 
;
; Preconditions: None
;
; Postconditions: Input will be read in from the user and validated 
;
; Receives: 
;		[ebp + 8]	-	The offset of the message prompting the user to enter a number
;		[ebp + 12]	-	The offset of the memory location where the input will be stored.
;		[ebp + 16]	-	The lenght of the buffer where the ascii representation of input will be stored.
;		[ebp + 20]	-	The offset of the message informing the user that they entered a blank input
;		[ebp + 24]	-	The offset of the address where numeric total will be kept once tallied
;		[ebp + 28]	-	The offset of a variable tracking the length of the user input 
;		[ebp + 32]	-	The offset of an error message telling the user that they entered an unnaceptable number.
;		[ebp + 36]	-	The offset of the byte indicating whether a number is negative or positive
;		
;	
;
; Returns:  None
; ---------------------------------------------------------------------------------

ReadVal		PROC
	push	EBP
	mov		EBP, ESP

	push	EDX	
	push	EAX
	push	EBX
	push	ECX
	push	EDI

	_get_value:	
		mGetString		[EBP + 8], [EBP + 12], [EBP + 16], [EBP + 20], [EBP + 28]

	; ---------------------------------------------------------------------------------
	;	Take the string which is currently stored as ascii values and convert it to 
	;	a decimal value.
	; ---------------------------------------------------------------------------------

	; clear the sign indicator - shouldn't be necessary, but is cheap insurance
	push	ebx
	mov		ebx, 0
	mov		[ebp + 36], ebx
	pop		ebx

	_numeric_conversion_loop:
		CLD
		mov		ESI, [EBP + 12]		; Source is array of bytes we read in
		mov		EDI, [EBP + 24]		; Destination is accumulator variable we initiated	
		mov		ECX, [EBP + 28]
		push	[ECX]
		pop		ECX					; Get the number to the counter loop

		_full_conversion_loop:
				
			; ---------------------------------------------------------------------------------
			;	Checks that AL is within the ASCII range for 0-9. If not, jump to the error block
			; ---------------------------------------------------------------------------------
				xor		EAX, EAX
				LODSB

			_check_for_sign:
				cmp		AL, 43				
				JE		_positive_block
				cmp		AL, 45
				JE		_negative_block

			_check_validity:
				CMP		AL, 48			; If it is less than 48 it's not a number
				JL		_improper_input
				CMP		AL, 57
				JG		_improper_input	; If it is greater than 57 it's not a number

			; ---------------------------------------------------------------------------------
			;	Checks if a digit is a plus or minus sign. If we're on the first iteration it
			;	sets the sign byte and loops back. Otherwise it jumps to the error block.
			; ---------------------------------------------------------------------------------


			_convert_to_int:
				; Subtract 48 to get the current digit then save value on the stack
				sub		AL, 48
				push	EAX
			
				; Multiply the current buffer by ten
				mov		EAX, [edi]
				mov		EBX, 10	
				mul		EBX
			
				; Add the current digit to the multiplied buffer
				pop		EDX
				add		EAX, EDX
				mov		[EDI], EAX

		;loop back until you reach the end of the input string
			loop	_full_conversion_loop
			
		; If the sign bit is set negate the decimal
		mov		EAX, [ebp + 36]
		mov		EBX, 1
		cmp		EAX, EBX
		JNE		_end								; If the number is positive just skip the rest of this block
		mov		EDI, [ebp + 24]
		push	[EDI]
		pop		EAX	
		neg		EAX
		mov		[EDI], EAX


	; Restoring all used registers
	_end:
	pop		EDI
	pop		ECX
	pop		EBX
	pop		EAX	
	pop		EDX
	pop		EBP

	ret		32	


	; ---------------------------------------------------------------------------------
	;	If the user entered an improper input print a message and jump back to the prompt
	;-------------------------------------------------------------------------

	_improper_input:
	mov		EDX, [EBP + 32]
	call	writeString
	call	Crlf
	JMP		_get_value

	_positive_block:

	; Check if it is the first iteration of the loop (i.e. the sign is the first character)
	push	EAX
	push	[ebp + 28]
	pop		EAX
	cmp		ECX, [EAX]
	pop		EAX

	; If the symbol isn't the first character the input was improper, let the user know
	JNE		_improper_input

	; Jump back on to process the next character
	loop	_full_conversion_loop	

	_negative_block:

	; Check if it is the first iteration of the loop (i.e. the sign is the first character)
	push	EAX
	push	[ebp + 28]
	pop		EAX
	cmp		ECX, [EAX]
	pop		EAX

	; If the symbol isn't the first character the input was improper, let the user know
	JNE		_improper_input
	
	; Set the sign tracker to one for negative.
	push	ebx
	mov		ebx, 1
	mov		[ebp + 36], ebx
	pop		ebx



	; Jump back on to process the next character
	loop	_full_conversion_loop	

ReadVal		ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Takes numeric data and converts it to ascii data for display in the terminal.
;
; Preconditions:	The array passed to the procedure is populated with only
;					codes for valid integers.	
;
; Postconditions:	Displays the integers as an ascii string to the console
;
; Receives: 
;			[EBP + 8]	-	The address of the decimal value to convert to ASCII
;			[EBP + 12]	-	The address of an empty array being used to do the conversion
;			[EBP + 16]	-	The Address of the Sign Indicator;
;			[EBP + 20]	-	The Address of a Buffer to Keep Track of the Length For Reversals
;			[EBP + 24]	-	The Address of a Buffer to Use for Reversal
; Returns: None
; ---------------------------------------------------------------------------------
WriteVal PROC
	push	EBP
	mov		EBP, ESP
	
	; Preserve Registers
	push	EAX
	push	EDX
	push	EBX
	push	EDI
	push	ESI
	push	ECX
	
	; Load Data
	mov		ESI, [ebp + 8]			; Source register is the address of the Integer
	mov		EDI, [ebp + 12]			; Destination register is a blank array
	CLD							    	; Try going through the array in order.

	
	; Determine the sign of the number we're dealing with and store a record of it.
	mov		EAX, [ESI]
	mov		EBX, 0
	cmp		EAX, EBX
	push	EDI
	mov		EDI, [EBP + 16]		; Push EDI to the stack to save it and move the sign byte address to it.
	JL		_negative_block
	MOV		[EDI], EBX			; Set a positive sign byte to be referenced for later
	pop		EDI					; To restore EDI to the value before it was pointed to the sign byte
	jmp		_conversion_loop

	_negative_block:
		mov		EBX, 1
		mov		[EDI] , EBX		; Set a negative sign byte to be referenced later
		neg		EAX				; Make the actual number negative to be easier to deal with in division algorithm
		mov		[ESI], EAX
		pop		EDI				; To restore EDI to the value before it was pointed to the sign byte
		


	; Add the null terminator byte - do this before we start as we will be reversing the string
	_terminating_byte:
		mov		AL, 0						; Add the null bit to the string we're writing
		STOSB
		mIncrementBuffer [ebp + 20]			; The string is now one longer when we reverse it.
		
	; Get Dereferenced Data Into EAX for Division
	_conversion_loop:
		push	[ESI]
		pop		EAX						; Full digit now in Accumulator

		; Divide By Ten 
		mov		EBX, 10
		CDQ
		IDIV		EBX

		; Move the remainder to the destination and decrement
		push	EAX						; Save the quotient for the next iteration
		mov		EAX, EDX				; Move the remaider to the accumulator to be transferred to EDI.
		add		AL, 48					; Add 48 to convert to ASCII
		STOSB
		pop		[ESI]					; Replace the source with the current quotient

		; Increment the lenght tracker so we know how many iterations are necessary to reverse the string
		mIncrementBuffer [ebp + 20]

		;check if the quotient is now zero and we should break the loop or repeat
		push	EAX
		mov		EAX, 0	
		cmp		[ESI], EAX
		pop		EAX
		JNE 	_conversion_loop

	; Check the sign and make sure it is represented	
	mov     EBX, 0
	mov		EAX, [EBP + 16]
	push	[EAX]
	pop     EAX
	cmp		EAX, EBX			;Compare the current number to zero to see if it is negative.
	JNE		_add_negative
	mov		AL, 43
	STOSB
	mIncrementBuffer [ebp + 20]
	jmp _end
	_add_negative:
	mov		AL, 45
	STOSB

		
	; REVERSE THE STRING WE JUST MADE

	;Setup registers for string primitives
	mov		ECX, [EBP + 20]				; Move the string length we just tracked to the counter
	mov		EDI, [EBP + 24]
	mov		ESI, [EBP + 12]

	; get the length of the string and multiply it by four to account for DWORD values
	push	[ECX]
	pop		ECX
	mov		EAX, ECX
	
	; Add the offset so that we begin at the end of the string and can move in reverse
	ADD     ESI, ECX					

	_reversal_loop:
	STD
	LODSB
	CLD
	STOSB
	loop _reversal_loop

	xor	ECX, ECX			; Clear ECX for good measure before moving forward

	_end:	
	
	; print the string we constructed and reversed
	mDisplayString [EBP + 24]
	
	; Restore Registers
	pop		ECX
	pop		ESI
	pop		EDI
	pop		EBX
	pop		EDX
	pop		EAX
	pop		EBP

	ret		12
WriteVal		ENDP

; ---------------------------------------------------------------------------------
; Name: arraySum
;
; Returns the sum of 
;
; Preconditions:	The array passed to the procedure is populated with only
;					codes for valid integers.	
;
; Postconditions:	The sum is saved to [EBP + 16]
;
; Receives: 
;			[EBP + 8]	-	The address of the array of inputs
;			[EBP + 12]  -	The current length of the array. ie the number of loops to run
;			[EBP + 16]	-	The address of the buffer being used to store the sum
;
; Returns: None
; ---------------------------------------------------------------------------------
arraySum PROC
	push	ECX
	push	ESI
	push	EDI
	push	EAX

	; Move all relevant parameters to their homes
	mov		ECX, [EBP + 12]
	mov		ESI, [EBP + 8]
	mov		EDI, [EBP + 16]

	; Load a number into the accumulator
	STOSD
	ADD		EDI, EAX			; Add the acummulator to the tally

	pop		EAX
	pop		EDI
	pop		ESI
	pop		ECX
	ret 12
arraySum ENDP

; ---------------------------------------------------------------------------------
; Name: Main
;
;
; Preconditions:		
;
; Postconditions:	;
; Receives: 
;			
; Returns: None
; ---------------------------------------------------------------------------------

main PROC

; ---------------------------------------------------------------------------------
;	prints a nice little into for the user before we get started.
; ---------------------------------------------------------------------------------

push	offset	ResultString
push	offset	RegisterString
push	offset	instructionString
push	offset	authorString
push	offset	introString
call	introduction

; Set the array where values will be stored to EDI
mov		EDI, offset allInputArray	

_request_ten:

	; Call the input function

	push	offset signIndicator
	push	offset errorString
	push	offset inputLen
	push	offset numBuffer
	push	offset emptyErrorMessage	
	push	MAX_LEN
	push	offset stringBuffer
	push	offset requestString
	call	ReadVal


	; Load the last value found into the array of values.

	CLD
	mov		EAX, numbuffer
	STOSD
	
	
	; Print a message to the user prefacing what number they entered
	call	Crlf
	mDisplayString offset enteredString



	; Call the output function to print the number found
	push	offset	reversalBuffer
	push	offset	numLen					; Different than inputlen, used to reverse
	push	offset	signIndicator
	push	offset	outputBuffer
	push	offset	numBuffer
	call	WriteVal
	call	Crlf
	loop	_request_ten

	; Print all the inputs entered into the array for the user to see all at once
	
	COMMENT @
	; Call the summing function to print the current sum of the inputs
	push	offset arraySumBuffer
	mov		EAX, 10
	SUB		EAX, ECX				; Ten - the Current Counter = The Current Len of the Array
	push	EAX
	push	EDI
	call	arraySum
	@

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
