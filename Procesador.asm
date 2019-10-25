;------------------------------------------------------------------------;
; Ignacio Alvarez Barrantes                  Arquitectura de Computadores;
; 2019039643                                            Esteban Arias    ;
; Sebastian Gamboa Bolaños                                               ;
; 2019044679                     Proyecto #1                             ;  
;                               Ensamblador                              ;  
;------------------------------------------------------------------------;

%include "io.mac"


len EQU			1024 	;Macro textual

.DATA
	inputMessage	db	"Digite el nombre del archivo que desea correr: ",0
	pcTitle		db	"PC: ",0
	irTitle		db	"IR: ",0
	error		db	"Error de syntax",0
	

	invalidMessage	db	"El archivo ingresado no es reconocido por el programa",0	


.UDATA
	file			resb	50
	content			resb	1024
	IR			resb	5
	PC			resb	1
	FA			resb	4
	FB			resb	4
	FC			resb	4
	FD			resb	4
	FE			resb	4
	ZF			resb	4
	OF			resb	4
	CF			resb	4

section .bss
	descriptor		resb	8
	buffer			resb	1024	

.CODE
	.STARTUP
	mov			EAX,0
	mov			[PC],EAX

	;Intro message	

	PutStr		inputMessage	;Imprime la solicitud del input
	GetStr		file		;Guarda el nombre del archivo
	nwln

	;Carga el programa al EAX	

	call		openFile

	;Identifica instruccion

ReadInstruction:
	mov		EDX,[PC]
	inc		EDX
	mov		[PC],EDX
	call		PrintPC
	cmp		byte[EAX],"&" ;El programa termino
	je		END	
	cmp		byte[EAX],"*" ;Determina si es instruccion
	je		InstructionSet
	inc		EAX
	jmp		ReadInstruction
	
	
END:

	mov			EAX,6			;Cierra el file
	mov			EBX,[descriptor]
	int			80h			;Cierra el file

	mov			EAX,1		;exits the system call
	mov			EBX,0
	int			80h

	nwln
	.EXIT

InstructionSet:
	inc	EAX
	mov	EBX,EAX

	;Compara con cam -> mov
	
	cmp	byte[EAX],"c"
	jne	InstructionSet2
	inc	EAX
	cmp	byte[EAX],"a"
	jne	InstructionSet2
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet2
	call	Cambiar
	jmp	ReadInstruction

InstructionSet2:
	mov	EAX,EBX
	
	;Compara con met -> push

	cmp	byte[EAX],"m"
	jne	InstructionSet3
	inc	EAX
	cmp	byte[EAX],"e"
	jne	InstructionSet3
	inc	EAX
	cmp	byte[EAX],"t"
	jne	InstructionSet3
	call	Meter	
	push	ECX
	add	EAX,3
	jmp	ReadInstruction

InstructionSet3:
	mov	EAX,EBX
	
	;Compara con sac -> pop

	cmp	byte[EAX],"s"
	jne	InstructionSet4
	inc	EAX
	cmp	byte[EAX],"a"
	jne	InstructionSet4
	inc	EAX
	cmp	byte[EAX],"c"
	jne	InstructionSet4
	pop	ECX
	call	Sacar
	jmp	ReadInstruction

InstructionSet4:
	mov	EAX,EBX

	;Compara con chk -> cmp
	
	cmp	byte[EAX],"c"
	jne	InstructionSet5
	inc	EAX
	cmp	byte[EAX],"h"
	jne	InstructionSet5
	inc	EAX
	cmp	byte[EAX],"k"
	jne	InstructionSet5
	call	Check
	jmp	ReadInstruction

InstructionSet5:
	mov	EAX,EBX
	
	;Compara con cod -> shr

	cmp	byte[EAX],"c"
	jne	InstructionSet6
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet6
	inc	EAX
	cmp	byte[EAX],"d"
	jne	InstructionSet6
	call	CorrerDerecha	
	jmp	ReadInstruction

InstructionSet6:
	mov	EAX,EBX
	
	;Compara con coi -> shl

	cmp	byte[EAX],"c"
	jne	InstructionSet7
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet7
	inc	EAX
	cmp	byte[EAX],"i"
	jne	InstructionSet7
	call	CorrerIzquierda
	jmp	ReadInstruction
	

InstructionSet7:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sum -> add

	cmp	byte[EAX],"s"
	jne	InstructionSet8
	inc	EAX
	cmp	byte[EAX],"u"
	jne	InstructionSet8 
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet8
	call	Sumar
	PutLInt	[FB]
	add	EAX,2
	jmp	ReadInstruction


InstructionSet8:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con res -> sub

	cmp	byte[EAX],"r"
	jne	InstructionSet9
	inc	EAX
	cmp	byte[EAX],"e"
	jne	InstructionSet9 
	inc	EAX
	cmp	byte[EAX],"s"
	jne	InstructionSet9
	call	Restar
	PutLInt	[FB]
	add	EAX,2
	jmp	ReadInstruction

InstructionSet9:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con slt -> jmp

	cmp	byte[EAX],"s"
	jne	InstructionSet10
	inc	EAX
	cmp	byte[EAX],"l"
	jne	InstructionSet10 
	inc	EAX
	cmp	byte[EAX],"t"
	jne	InstructionSet10
	add	EAX,2
	call	Saltar
	jmp	ReadInstruction

InstructionSet10:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con itr -> loop

	cmp	byte[EAX],"i"
	jne	InstructionSet11
	inc	EAX
	cmp	byte[EAX],"t"
	jne	InstructionSet11 
	inc	EAX
	cmp	byte[EAX],"r"
	jne	InstructionSet11
	call	Iterar
	jmp	ReadInstruction


InstructionSet11:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con rod -> ror

	cmp	byte[EAX],"r"
	jne	InstructionSet12
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet12
	inc	EAX
	cmp	byte[EAX],"d"
	jne	InstructionSet12
	call	rotarDerecha
	jmp	ReadInstruction


InstructionSet12:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con roi -> rol

	cmp	byte[EAX],"r"
	jne	InstructionSet13
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet13
	inc	EAX
	cmp	byte[EAX],"i"
	jne	InstructionSet3
	call	rotarIzquierda
	jmp	ReadInstruction



InstructionSet13:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con prb -> test

	cmp	byte[EAX],"p"
	jne	InstructionSet14
	inc	EAX
	cmp	byte[EAX],"r"
	jne	InstructionSet14 
	inc	EAX
	cmp	byte[EAX],"b"
	jne	InstructionSet14
	call	Probar
	jmp	ReadInstruction




InstructionSet14:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con gem -> and

	cmp	byte[EAX],"g"
	jne	InstructionSet15
	inc	EAX
	cmp	byte[EAX],"e"
	jne	InstructionSet15 
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet15
	call	Gemelitos
	jmp	ReadInstruction

InstructionSet15:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sgm -> je

	cmp	byte[EAX],"s"
	jne	InstructionSet16
	inc	EAX
	cmp	byte[EAX],"g"
	jne	InstructionSet16
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet16
	call	saltarGemelos
	jmp	ReadInstruction

InstructionSet16:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sng -> jne

	cmp	byte[EAX],"s"
	jne	InstructionSet17
	inc	EAX
	cmp	byte[EAX],"n"
	jne	InstructionSet17 
	inc	EAX
	cmp	byte[EAX],"g"
	jne	InstructionSet17
	call	saltarNoGemelos
	jmp	ReadInstruction


InstructionSet17:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sco -> jz

	cmp	byte[EAX],"s"
	jne	InstructionSet18
	inc	EAX
	cmp	byte[EAX],"c"
	jne	InstructionSet18
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet18
	call	Gemelitos
	jmp	ReadInstruction


InstructionSet18:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con snc -> jnz

	cmp	byte[EAX],"s"
	jne	InstructionSet19
	inc	EAX
	cmp	byte[EAX],"n"
	jne	InstructionSet19 
	inc	EAX
	cmp	byte[EAX],"c"
	jne	InstructionSet19
	call	saltarNoCero
	jmp	ReadInstruction

InstructionSet19:
	jmp	END
	
     
;------------------------------------------------------------------------------
; 							File Opener
;------------------------------------------------------------------------------
;E: 1 string
;S: Contenido de un archivo dado
;D: Abre un archivo y lo retorna en el registro EAX

openFile:
	mov			ECX,0			;Read Only
	mov			EBX,file		;Nombre del archivo por abrir
	mov			EAX,5			;Abre el archivo
	int			80h				;Realiza el system call de read only

	mov			[descriptor],EAX;Guarda el descriptor

	mov			EAX,3			;Que lea desde el archivo
	mov			EBX,[descriptor];El descriptor del archivo
	mov			ECX,buffer		;Leer al buffer
	mov			EDX,len			;Lee 1024 bytes
	int			80h				;lee 1024 bytes al buffer desde file

	mov			EAX,buffer	;Mueve el contenido al EAX
	ret


;------------------------------------------------------------------------------
; 				 Cambiar
;------------------------------------------------------------------------------
;E: 2 string
;S: Mueve los valores de una variables
;D: Mueve valores en memoria

Cambiar:
	add			EAX,2
	cmp			byte[EAX],"A"
	je			IsRegisterA
	cmp			byte[EAX],"B"
	je			IsRegisterB
	cmp			byte[EAX],"C"
	je			IsRegisterC
	cmp			byte[EAX],"D"
	je			IsRegisterD
	cmp			byte[EAX],"E"
	je			IsRegisterE
	jmp			ERROR			
	ret


IsRegisterA:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FA],CX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2		
	jmp			ReadInstruction

IsRegisterB:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FB],CX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction

IsRegisterC:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FC],CX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction

IsRegisterD:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FD],CX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction

IsRegisterE:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FE],CX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction






;------------------------------------------------------------------------------
; 				 GetNumber
;------------------------------------------------------------------------------
;E: 1 string
;S: 1 int
;D: Dado un numero de tipo String lo retorna de tipo int

GetNumber:
	cmp			byte[EAX],"A"
	je			ObtainA
	cmp			byte[EAX],"B"
	je			ObtainB
	cmp			byte[EAX],"C"
	je			ObtainC
	cmp			byte[EAX],"D"
	je			ObtainD
	cmp			byte[EAX],"E"
	je			ObtainE
	cmp			byte[EAX],";"
	je			DoneNumber
	add			CX,CX
	mov			BX,CX
	add			CX,CX
	add			CX,CX
	add			CX,BX
	mov			DL,byte[EAX]
	sub			DL,48
	add			CX,DX
	inc			EAX
	jmp			GetNumber

DoneNumber:
	ret

ObtainA:
	mov			ECX,[FA]
	inc			EAX
	jmp			GetNumber

ObtainB:
	mov			ECX,[FB]
	inc			EAX
	jmp			GetNumber

ObtainC:
	mov			ECX,[FC]
	inc			EAX
	jmp			GetNumber

ObtainD:
	mov			ECX,[FD]
	inc			EAX
	jmp			GetNumber

ObtainE:
	mov			ECX,[FE]
	inc			EAX
	jmp			GetNumber


ERROR:
	PutStr			error
	jmp			END

;------------------------------------------------------------------------------
; 				 Meter
;------------------------------------------------------------------------------
;E: un dato
;S: void
;D: inserta el valor en la pila

Meter:
	
	add	EAX,2
	cmp	byte[EAX],"A"
	je	meterA
	cmp	byte[EAX],"B"
	je	meterB
	cmp	byte[EAX],"C"
	je	meterC
	cmp	byte[EAX],"D"
	je	meterD
	cmp	byte[EAX],"E"
	je	meterE
	jmp	ERROR

meterA:
	mov	ECX,[FA]
	ret

meterB:
	mov	ECX,[FB]
	ret

meterC:
	mov	ECX,[FC]
	ret

meterD:
	mov	ECX,[FD]
	ret
	
meterE:
	mov	ECX,[FE]
	ret


;------------------------------------------------------------------------------
; 				 Sacar
;------------------------------------------------------------------------------
;E: void
;S: un dato
;D: inserta el valor en la pila

Sacar:
	
	add	EAX,2
	cmp	byte[EAX],"A"
	je	sacarA
	cmp	byte[EAX],"B"
	je	sacarB
	cmp	byte[EAX],"C"
	je	sacarC
	cmp	byte[EAX],"D"
	je	sacarD
	cmp	byte[EAX],"E"
	je	sacarE
	jmp	ERROR

sacarA:
	mov	EDX,[PC]
	mov	[FA],ECX
	mov	[PC],EDX
	ret

sacarB:
	mov	EDX,[PC]
	mov	[FB],ECX
	mov	[PC],EDX
	ret

sacarC:
	mov	EDX,[PC]
	mov	[FC],ECX
	mov	[PC],EDX
	ret

sacarD:
	mov	EDX,[PC]
	mov	[FD],ECX
	mov	[PC],EDX
	ret
	
sacarE:
	mov	EDX,[PC]
	mov	[FE],ECX
	mov	[PC],EDX
	ret



;------------------------------------------------------------------------------
; 				 Print PC
;------------------------------------------------------------------------------
;E: void
;S: void
;D: imprime el pc

PrintPC:
	PutStr			pcTitle
	PutLInt			[PC]
	nwln
	ret



;------------------------------------------------------------------------------
; 				 Check
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si dos valores son iguales
;D: revisa el contenido de dos valores, y enciende flags si son iguales


Check:

	add			EAX,2
	mov			EDX,0
	mov			DL,byte[EAX]
	inc 		EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	cmp 		DL,byte[EAX]
	je			changeFlag3	
	mov 		ZF,0	
	ret

changeFlag3:
	mov ZF,1
	ret

	
;------------------------------------------------------------------------------
; 				 Correr Derecha
;------------------------------------------------------------------------------
;E: 1 valor
;S: Realiza un shift right del valor
;D: Realiza un shift right, y enciende o no banderas


CorrerDerecha:

	cmp			byte[EAX],"A"
	je			IsA
	cmp			byte[EAX],"B"
	je			IsB
	cmp			byte[EAX],"C"
	je			IsC
	cmp			byte[EAX],"D"
	je			IsD
	cmp			byte[EAX],"E"
	je			IsE
	jmp			ERROR			
	ret


IsA:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FA],DX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2
	ret

IsB:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FB],DX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	ret

IsC:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FC],DX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	ret

IsD:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FD],DX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	ret

IsE:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FE],DX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	ret


;------------------------------------------------------------------------------
; 				 Correr Izquierda
;------------------------------------------------------------------------------
;E: 1 valor
;S: Realiza un shift left del valor
;D: Realiza un shift left, y enciende o no banderas


CorrerIzquierda:

	cmp			byte[EAX],"A"
	je			IsA2
	cmp			byte[EAX],"B"
	je			IsB2
	cmp			byte[EAX],"C"
	je			IsC2
	cmp			byte[EAX],"D"
	je			IsD2
	cmp			byte[EAX],"E"
	je			IsE2
	jmp			ERROR			
	ret


IsA2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FA],DX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2
	ret

IsB2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FB],DX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	ret

IsC2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FC],DX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	ret

IsD2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FD],DX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	ret

IsE2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FE],DX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	ret


;------------------------------------------------------------------------------
; 				 Sumar
;------------------------------------------------------------------------------
;E: 2 datos
;S: void
;D: suma 2 registros un valor a un registro

Sumar:

	add			EAX,2
	cmp			byte[EAX],"A"
	je			AddA
	cmp			byte[EAX],"B"
	je			AddB
	cmp			byte[EAX],"C"
	je			AddC
	cmp			byte[EAX],"D"
	je			AddD
	cmp			byte[EAX],"E"
	je			AddE
	PutStr			error
	jmp			END


AddA:
	mov			EBX,[FA]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberA

AddB:
	mov			EBX,[FB]
	push			EBX	
	
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE
	
	jmp			AddNumberB

AddC:
	mov			EBX,[FC]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberC

AddD:
	mov			EBX,[FD]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberD

AddE:
	mov			EBX,[FE]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberE

AddRA:
	add			EBX,[FA]
	mov			[FA],EBX
	jmp			SumaEnd

AddRB:
	add			EBX,[FB]
	mov			[FB],EBX
	jmp			SumaEnd

AddRC:
	add			EBX,[FC]
	mov			[FC],EBX
	jmp			SumaEnd


AddRD:
	add			EBX,[FD]
	mov			[FD],EBX
	jmp			SumaEnd


AddRE:
	add			EBX,[FE]
	mov			[FE],EBX
	jmp			SumaEnd

AddNumberA:
	mov			ECX,0
	call			GetNumber
	pop			EBX
	add			EBX,ECX
	mov			[FA],EBX
	jmp			SumaEnd

AddNumberB:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FB],EBX

	jmp			SumaEnd

AddNumberC:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FC],EBX
	jmp			SumaEnd

AddNumberD:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FD],EBX
	jmp			SumaEnd

AddNumberE:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FE],EBX
	jmp			SumaEnd

SumaEnd:
	ret



;------------------------------------------------------------------------------
; 				 Restar
;------------------------------------------------------------------------------
;E: 2 datos
;S: void
;D: suma 2 registros un valor a un registro

Restar:

	add			EAX,2
	cmp			byte[EAX],"A"
	je			RestarA
	cmp			byte[EAX],"B"
	je			RestarB
	cmp			byte[EAX],"C"
	je			RestarC
	cmp			byte[EAX],"D"
	je			RestarD
	cmp			byte[EAX],"E"
	je			RestarE
	PutStr			error
	jmp			END


RestarA:
	mov			EBX,[FA]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberA

RestarB:
	mov			EBX,[FB]
	push			EBX	
	
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE
	
	jmp			RestarNumberB

RestarC:
	mov			EBX,[FC]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberC

RestarD:
	mov			EBX,[FD]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberD

RestarE:
	mov			EBX,[FE]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberE

RestarRA:
	sub			EBX,[FA]
	mov			[FA],EBX
	jmp			RestaEnd

RestarRB:
	sub			EBX,[FB]
	mov			[FB],EBX
	jmp			RestaEnd

RestarRC:
	add			EBX,[FC]
	mov			[FC],EBX
	jmp			RestaEnd


RestarRD:
	add			EBX,[FD]
	mov			[FD],EBX
	jmp			RestaEnd


RestarRE:
	add			EBX,[FE]
	mov			[FE],EBX
	jmp			RestaEnd

RestarNumberA:
	mov			ECX,0
	call			GetNumber
	pop			EBX
	sub			EBX,ECX
	mov			[FA],EBX
	jmp			RestaEnd

RestarNumberB:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FB],EBX

	jmp			RestaEnd

RestarNumberC:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FC],EBX
	jmp			RestaEnd

RestarNumberD:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FD],EBX
	jmp			RestaEnd

RestarNumberE:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FE],EBX
	jmp			RestaEnd

RestaEnd:
	ret


;------------------------------------------------------------------------------
; 					Saltar
;------------------------------------------------------------------------------
;E: void
;S: void
;D: Salta a una etiqueta 

Saltar:
	mov		EDX,buffer    ;Coloca un puntero al inicio del programa
	

FindLabel:
	cmp		byte[EDX],"!"
	je		IsLabel
	inc		EDX
	jmp		FindLabel

IsLabel:
	inc		EDX
	mov		BL,byte[EAX]
	cmp		byte[EDX],BL
	je		Match
	jmp		FindLabel

Match:
	mov		EAX,EDX

NextInstruction:
	cmp		byte[EAX],"*"
	je		LabelFound
	inc		EAX
	jmp		NextInstruction

LabelFound:
	ret


;------------------------------------------------------------------------------
; 					loop
;------------------------------------------------------------------------------
;E: void
;S: void
;D: Salta a una etiqueta mientras ECX sea diferente a 0


Iterar:
	mov		ECX,[FC]
	cmp		ECX,0		;Verifica si debe seguir repitiendo
	je		LoopDone
	sub		ECX,1
	mov		[FC],ECX
	add		EAX,2
	call	Saltar
	ret

LoopDone:
	ret


	
;------------------------------------------------------------------------------
; 					Rotate right
;------------------------------------------------------------------------------
;E: 1 valor
;S: void
;D: Rota un numero a la derecha
	

rotarDerecha:

	cmp			byte[EAX],"A"
	je			IsA3
	cmp			byte[EAX],"B"
	je			IsB3
	cmp			byte[EAX],"C"
	je			IsC3
	cmp			byte[EAX],"D"
	je			IsD3
	cmp			byte[EAX],"E"
	je			IsE3
	jmp			ERROR			
	ret


IsA3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FA],DX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2
	ret

IsB3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FB],DX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	ret

IsC3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FC],DX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	ret

IsD3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FD],DX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	ret

IsE3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FE],DX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	ret



;------------------------------------------------------------------------------
; 					Rotate left
;------------------------------------------------------------------------------
;E: 1 valor
;S: void
;D: Rota un numero a la izquierda
	

rotarIzquierda:

	cmp			byte[EAX],"A"
	je			IsA4
	cmp			byte[EAX],"B"
	je			IsB4
	cmp			byte[EAX],"C"
	je			IsC4
	cmp			byte[EAX],"D"
	je			IsD4
	cmp			byte[EAX],"E"
	je			IsE4
	jmp			ERROR			
	ret


IsA4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FA],DX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2
	ret

IsB4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FB],DX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	ret

IsC4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FC],DX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	ret

IsD4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FD],DX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	ret

IsE4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FE],DX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	ret

			

;------------------------------------------------------------------------------
; 				 Test
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si ciertos bits son iguales
;D: revisa el contenido de dos valores, y enciende flags si son los bits iguales


Probar:

	add			EAX,2
	mov			EDX,0
	mov			DL,byte[EAX]
	inc 		EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	test 		DL,byte[EAX]
	je			changeFlag2	
	mov 		ZF,0	
	ret

changeFlag2:
	mov ZF,1
	ret




;------------------------------------------------------------------------------
; 				 And
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si dos valores son iguales
;D: revisa el contenido de dos valores, y enciende flags si son iguales


Gemelitos:

	add			EAX,2
	mov			EDX,0
	mov			DL,byte[EAX]
	inc 		EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	and 		DL,byte[EAX]
	je			changeFlag	
	mov 		ZF,0	
	ret

changeFlag:
	mov ZF,1
	ret





;------------------------------------------------------------------------------
; 				 Jump if Equal
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si son iguales


saltarGemelos:

	je		Saltar	
	ret



;------------------------------------------------------------------------------
; 				 Jump if not Equal
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si no son iguales


saltarNoGemelos:

	jne		Saltar	
	ret



;------------------------------------------------------------------------------
; 				 Jump if zero
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si son iguales


saltarCero:

	
	jz		Saltar	
	ret



;------------------------------------------------------------------------------
; 				 Jump if not zero
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si no son iguales


saltarNoCero:

	jnz		Saltar	
	ret
