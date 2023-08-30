TITLE "Project 6: String Primitives and Macros"     (Proj6_stoudth.asm)

; Author: Hailey Stoudt
; Last Modified: 3/16/2023
; OSU email address: stoudth@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:   Project 6     Due Date: 3/19/2023
; Description: Requests 10 numbers from the user which the program collects as a string through a Macro and then
;			   converts the ASCII values in the string into an integer. This integer is stored in an array and added to
;			   a running total sum. Once 10 numbers are collected, the program then converts the integers back to ASCII
;			   values in a string which are displayed with another macro. The program also displays the total sum and the 
;			   average of the input. The numbers collected can be positive or negative and must fit inside a 32-bit register.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt and then stores user input details.
;
; Preconditions: Do not use EDX, ECX, or EAX as user input prompts. outputParamAddress_1 must be type BYTE for Readstring. 
;
; Receives:
;		 promptAddress			= address of prompt to be displayed
;		 outputParamAddress_1   = address of identifier where user input will be stored
;		 countValue				= value of num of bytes allowed
;		 outputParamAddress_2   = address where number of characters entered will be stored
;
; Returns: 
;		 outputParamAddress_1	= address storing user input
;		 outputParamAddress_2	= address containing number of characters stored
; ---------------------------------------------------------------------------------

mGetString MACRO promptAddress:REQ, outputParamAddress_1:REQ, countValue:REQ, outputParamAddress_2:REQ
	
	;save registers
	push	EAX
	push	EDX
	push	ECX

	;display prompt
	mov		EDX, promptAddress
	call	WriteString

	;get user num details
	mov		EDX, outputParamAddress_1
	mov		ECX, countValue
	call	ReadString
	mov		[outputParamAddress_2], EAX

	;restore registers
	pop		ECX
	pop		EDX
	pop		EAX
	
ENDM



; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays a string passed to MACRO
;
; Preconditions: Do not use EDX as argument. string stored at stringAddress must be type BYTE for WriteString. 
;
; Receives:
;		   stringAddress = memory address of string that is going to be displayed
;
; returns: None
; ---------------------------------------------------------------------------------

mDisplayString MACRO stringAddress:REQ

	; save registers
	push	EDX

	;write string
	mov		EDX, stringAddress
	call	WriteString

	;restore registers
	pop		EDX

ENDM


;Constants
ARRAYLENGTH	= 10


.data

projTitle		BYTE		"Project 6: String Primitives and Macros", 13, 10, 0
coderName		BYTE		"By Hailey Stoudt", 13, 10, 13, 10, 0
projDescPrompt	BYTE		"Please enter 10 signed integers. Make sure your integer is able to fit in a 32-bit register. I'll be checking! "
				BYTE		"At the end, I'll show you a list of your entered number, their sum, and their average.", 13, 10, 13, 10, 0
prompt			BYTE		"Please enter a signed integer: ", 0
userNumArray	SDWORD		ARRAYLENGTH DUP (?)								;to be filled with numbers entered by user
userNum			BYTE		12 DUP (?)								        ;to be entered by user		
userNumCount	SDWORD		?												;to be calculated by program
tempUserNum		SDWORD		?												;to be calculated by program		
userNumType		SDWORD		TYPE userNum
errorMessage	BYTE		"ERROR: You did not enter an signed number or your number was too big.", 13, 10, 0
totalSum		SDWORD		?												;to be calculated by program
totalAverage	SDWORD		?												;to be calculated by program
numDispMessage 	BYTE		"You entered the following numbers: ", 13, 10, 0
tempArray		BYTE		ARRAYLENGTH DUP (?)								;to be calculated by program
sumText			BYTE		"The sum of these numbers is: ", 0
avgText			BYTE		"The truncated average is: ", 0
goodbye			BYTE		"Thanks for playing. Goodbye!", 13, 10, 13, 10, 0
userNumSize		DWORD		12


.code
main PROC

; ---------------------------------------------------------------------------------------------------
; Display Introduction: 
;			Pushes argument to introduction procedure which will display intro for program. 
; ---------------------------------------------------------------------------------------------------


	;Steps to call introduction
	push	OFFSET projTitle
	push	OFFSET coderName
	push	OFFSET projDescPrompt
	call	introduction


; ---------------------------------------------------------------------------------------------------
; Get Values: 
;			Calls WriteVal Proc 10 times to receive 10 numbers from the user. WriteVal takes that 
;			input in the form of a string and converts it to a single number which is returned. This 
;			number is added to an array containing these numbers and added to the running total sum. 
; ---------------------------------------------------------------------------------------------------


	;initializes registers for loop
	mov		ECX, 10
	mov		EDI, OFFSET userNumArray

_Get10NumLoop:

	;pushes parameters on stack and calls procedure
    push	OFFSET prompt
	push	OFFSET userNum
	push	userNumSize
	push	OFFSET userNumCount
	push	OFFSET tempUserNum
	push	OFFSET errorMessage
	call	ReadVal

	;moves converted value into necessary identifiers/arrays 
	cld
	mov		EAX, totalsum
	add		EAX, tempUserNum
	mov		totalsum, EAX
	mov		EAX, tempUserNum
	stosd
	mov		tempUserNum, 0
	loop	_Get10NumLoop


; ---------------------------------------------------------------------------------------------------
; Write Array Values: 
;			Loops through the previously filled array of numbers and uses the ReadVal Proc to convert numbers
;			back to a string of ASCII values which it then reads with the mDisplayString macro. 
; ---------------------------------------------------------------------------------------------------


	;display message for num array
	call	crlf
	mov		EDX, OFFSET numDispMessage
	call	WriteString

	;initializes registers to write values from userNumArray
	mov		ESI, OFFSET userNumArray
	mov		ECX, ARRAYLENGTH

_WriteNumArray:

	;loops through userNumArray to write each value with WriteVal procedure
	lodsd
	push	userNumSize
	push	EAX
	push	OFFSET userNum
	call	WriteVal
	cmp		ECX, 1
	je		_ExitLoop
	mov		EAX, ","
	call	WriteChar
	mov		EAX, " "
	call	WriteChar
	loop	_WriteNumArray

_ExitLoop:


; ---------------------------------------------------------------------------------------------------
; Display Sum and Average: 
;			Displays text stating these are the total sum and average of the entered numbers. Displays
;			the sum and average using the WriteVal Proc. 
; ---------------------------------------------------------------------------------------------------


	;display sum text
	call	Crlf
	mov		EDX, OFFSET sumText
	call	WriteString

	;display sum number
	push	userNumSize
	push	totalSum
	push	OFFSET userNum
	call	WriteVal
	call	Crlf

	;display average text
	mov		EDX, OFFSET avgText
	call	WriteString

	;calculate average
	mov		EAX, totalSum
	mov		EBX, ARRAYLENGTH
	cdq
	idiv	EBX
	mov		totalAverage, EAX

	;display average
	push	userNumSize
	push	totalAverage
	push	OFFSET userNum
	call	WriteVal
	call	Crlf


; ---------------------------------------------------------------------------------------------------
; Display Goodbye message: 
;			Pushes argument to Goodbye message procedure which will display goodbye for program. 
; ---------------------------------------------------------------------------------------------------


	;set up call for goodbye message
	push	OFFSET goodbye
	call	goodbyeMessage


	Invoke ExitProcess,0	; exit to operating system
main ENDP



; ---------------------------------------------------------------------------------
; Name: introduction
; 
; Displays the program title and coder name along with the program description.
;
; Preconditions: Strings are passed via reference to introduction along stack for WriteString
;				 cal and must be type BYTE.
;
; Postconditions: None
;
; Receives: 
;			[EBP + 12]		= address of projDescPrompt which is a string with the project description
;			[EBP + 16]		= address of coderName which is a string with the coder name
;			[EBP + 20]		= address of projTitle which is a string with the project title
;
; Returns: None
;
; Registers changed: None
; ---------------------------------------------------------------------------------

introduction PROC USES EDX

	;Initializes base pointer for proc
	push	EBP
	mov		EBP, ESP

	;print project title and coder name
	mov		EDX, [EBP + 20]
	call	WriteString
	mov		EDX, [EBP + 16]
	call	WriteString

	;print project description
	mov		EDX, [EBP + 12]
	call	WriteString

	;restore and return
	pop		EBP
	ret		12

introduction ENDP



; ---------------------------------------------------------------------------------
; Name: ReadVal
; 
; Calls Macro mGetString to retrieve a user input integer which it stores as a string. The procedure
; then goes through every ASCII character of the string, converting each ASCII character to a digit 
; (or applicable sign symbol). If the procedure runs into an invalid character (an ASCII representing a 
; non-numeric or a sign out of place) it will display an error message and ask for a new entry. If the 
; converted integer is larger than 32 bits, it will display an error message and ask for a new entry. If 
; the user doesn't enter anything, it will display and error message and ask for a new entry. If the entry is
; valid it will store it in the output parameter and return. 
;
; Preconditions: Parameters must be passed on stack for procedure and Macro. Array for userinput must be TYPE BYTE.
;				 Variable to hold converted integer must be TYPE SDWORD. Variable that holds prompt and error message must be type BYTE.
;
; Postconditions: None
;
; Receives: 
;			[EBP + 52]	 =	memory address of identifier prompt - string array that contains the prompt for user entry - Macro takes this as a parameter
;			[EBP + 48]   =  memory address of indenifier userNum - Macro takes as parameter and then stores user entry at address
;			[EBP + 44]	 =	value of the allowed length for the entered user number - Macro uses this as a parameter
;			[EBP + 40]	 =  memory address of identifier userNumCount - Macro takes as parameter and then stores character count of user entry at address
;			[EBP + 36]	 =  memory address of identfier tempUserNum - procedure uses this to store the integer as it is converting it and pass this back from the procedure
;			[EBP + 32]	 =  memory address of error message string - uses this if an invalid entry is identified. 
;
; Returns: 
;			[EBP + 48] (OFFSET userNum)			= data at this address is changed to contain user entry
;			[EBP + 40] (OFFSET userNumCount)	= data at this address is changed to contain user entry character count
;			[EBP + 36] (OFFSET tempUserNum)		= data at this address is changed to contain converted integer from user input
;
; Registers Changed: None
; ---------------------------------------------------------------------------------

ReadVal	PROC USES EAX EBX ECX EDX ESI EDI

	;Initializes base pointer for proc
	push	EBP
	mov		EBP, ESP

_GetNumString:

	;Get user entry with MACRO
	mGetString	[EBP + 52], [EBP + 48], [EBP + 44], [EBP + 40]

	;initialize registers for loop
	mov		ECX, [EBP + 40]
	mov		EDI, [EBP + 36]
	mov		ESI, [EBP + 48]
	mov		EAX, 0
	mov		[EDI], EAX

_ConvertStringToInt:

	;pull out single character of entry
	cld
	mov		EAX, 0
	lodsb

	;check character is in num range and if num has been declared negative
	cmp		EAX, 48
	jl		_NonNumASCII
	cmp		EAX, 57
	jg		_NonNumASCII
	cmp		EBX, 45
	je		_NegValue
	
	;converts ASCII code to ints for positive input
	sub		EAX, 48
	push	EAX
	mov		EAX, 10
	imul	DWORD PTR [EDI]
	jo		_InvalidEntry
	pop		EDX
	add		EAX, EDX
	jo		_InvalidEntry
	mov		[EDI], EAX
	loop	_ConvertStringtoInt
	jmp		_Return
	
_NegValue:

	;converts ASCII code to ints for negative input
	sub		EAX, 48
	push	EAX
	mov		EAX, 10
	imul	DWORD PTR [EDI]
	jo		_InvalidEntry
	pop		EDX
	sub		EAX, EDX
	jo		_invalidEntry
	mov		[EDI], EAX
	loop	_ConvertStringtoInt
	jmp		_Return

_NonNumASCII:

	;validates if non-numeric ASCII char is + or -
	cmp		EAX, 43
	je		_Validsign
	cmp		EAX, 45
	je		_ValidSign
	jmp		_invalidEntry

	
_ValidSign:

	;makes sure sign is at beginning of number and initializes EBX if negative
	cmp		ECX, [EBP + 40]
	jne		_InvalidEntry
	mov		EBX, EAX
	loop	_convertStringToInt
	

_InvalidEntry:

	;displays error message and jumps to get new number
	mov		EDX, [EBP + 32]
	call	WriteString
	jmp		_GetNumString

_Return:

	;restores and returns
	;mov		[EDI], EAX
	pop		EBP
	ret		24


ReadVal	ENDP



; ---------------------------------------------------------------------------------
; Name: WriteVal
; 
; Takes a number based and converts it into ASCII values and then writes the number
; by calling a Marcro. The Marcro uses WriteString from the Irvine library to write the
; string of ASCII characters passed to it. 
;
; Preconditions: Parameters must be passed along the stack. The array to store the userNum
;				 must be type BYTE. The number to be converted must be a type SDWORD. The value of the allowed length must be 
;				 be type DWORD.
;
; Postconditions: None
;
; Receives: 
;			[EBP + 28] = memory address of the userNum variable. This is where the ASCII values will be stored. It will be passed
;						 to the Macro in order to write the values in the identifier. 
;			[EBP + 32] = value of the number that is being converted to ASCII values.
;			[EBP + 36] = value of the allowed length for the entered user number - used as a counter
;
; Returns: 
;			[EBP + 28] = the data at the memory address of userNum will be altered to contain ASCII values of the converted number.
;
; Registers Changed: None
; ---------------------------------------------------------------------------------

WriteVal PROC USES EAX EBX ECX EDX EDI

	;Initializes base pointer for proc
	push	EBP
	mov		EBP, ESP

	;initialize registers for clearUserNumLoop
	mov		ECX, [EBP + 36]
	mov		EDI, [EBP + 28]

_ClearUserNumLoop:

	;clears each BYTE of userNum so no writing errors occur
	cld
	mov		AL, 0
	stosb
	loop	_ClearUserNumLoop

	; initializes registers and checks for neg num
	mov		EDI, [EBP + 28]
	mov		EAX, [EBP + 32]
	mov		ECX, 1000000000
	mov		EBX, 0
	cmp		EAX, 0
	jl		_NegNum

	;checks if num is 0
	cmp		EAX, 0
	jne		_FindAsciiChar
	add		EAX, 48
	stosb
	jmp		_DisplayString

_FindAsciiChar:

	;decides branching necessary in conversion
	cmp		EBX, 1									
	je		_InnerLoop
	cmp		EAX, ECX
	jl		_TrySmallerVal
	mov		EBX, 1									;EBX set to 1 once conversion starts to trigger a jump so 0s aren't skipped

_InnerLoop:

	;converts digits back to ASCII and stores in userNum
	mov		EDX, 0
	div		ECX
	add		EAX, 48
	stosb
	mov		EAX, EDX
	cmp		ECX, 1
	je		_DisplayString

_TrySmallerVal:

	;Removes 0 from ECX for conversion in innerLoop
	push	EAX
	push	EDX
	mov		EDX, 0
	mov		EAX, ECX
	mov		ECX, 10
	div		ECX
	mov		ECX, EAX
	pop		EDX
	pop		EAX
	jmp		_FindAsciiChar

_NegNum:

	;Writes "-" to userNum and negates number
	neg		EAX
	push	EAX
	mov		EAX, 45
	stosb
	pop		EAX
	jmp		_FindAsciiChar

_DisplayString:	

	;Calls Macro to Write number stored in UserNum
	mDisplayString [EBP + 28]

	;restores and returns
	pop		EBP
	ret		12


WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: procedureName
; 
; Displays a goodbye message that is passed on the stack.
;
; Preconditions: goodbye message must be type BYTE.
;
; Postconditions: None
;
; Receives: 
;			[EBP + 12] = memory address of goodbye message string
;
; Returns: None
;
; Registers Changed: None
; ---------------------------------------------------------------------------------

goodbyeMessage PROC USES EDX


	;Initializes base pointer for proc
	push	EBP
	mov		EBP, ESP

	;write goodbye
	call	crlf
	mov		EDX, [EBP + 12]
	call	WriteString

	;restore and return
	pop		EBP
	ret		4


goodbyeMessage ENDP


END main
