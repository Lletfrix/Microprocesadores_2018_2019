;**************************************************************************
;   Autores:
;       Rafael Sanchez Sanchez - rafael.sanchezs@estudiante.uam.es
;       Alejandro Santorum Varela - alejandro.santorum@estudiante.uam.es
;   Pareja: 16
;   Practica 3 Sistemas Basados en Microprocesadores
;**************************************************************************
;**************************************************************************
PRAC3A SEGMENT BYTE PUBLIC 'CODE'
PUBLIC _computeControlDigit
PUBLIC _decodeBarCode
ASSUME CS: PRAC3A

ASCIIOFFSET EQU 30H
ASCII6X     EQU 6*ASCIIOFFSET
ASCII3X     EQU 3*ASCIIOFFSET
PAISLEN     EQU 3
EMPRLEN     EQU 4
PRODLEN     EQU 5
SHRMASK     EQU 00FFH

_computeControlDigit PROC FAR
    PUSH BP
    MOV BP, SP

	; PRESERVANDO VALORES DE LOS REGISTROS
    PUSH DS BX CX DX

    LDS BX, 6[BP]

	; SUMANDO LOS NUMEROS DE POSICIONES IMPARES
    MOV AX, 0
    ADD AL, [BX]
    ADD AL, 2[BX]
    ADD AL, 4[BX]
    ADD AL, 6[BX]
    ADD AL, 8[BX]
    ADD AL, 10[BX]
    SUB AX, ASCII6X

	; MULTIPLICANDO POR 3 LOS NUMEROS DE POSICIONES
	; PARES Y SUMANDOLOS A LO ANTERIOR
    ADD AL, 1[BX]
    ADD AL, 1[BX]
    ADD AL, 1[BX]
    SUB AX, ASCII3X

    ADD AL, 3[BX]
    ADD AL, 3[BX]
    ADD AL, 3[BX]
    SUB AX, ASCII3X

    ADD AL, 5[BX]
    ADD AL, 5[BX]
    ADD AL, 5[BX]
    SUB AX, ASCII3X

    ADD AL, 7[BX]
    ADD AL, 7[BX]
    ADD AL, 7[BX]
    SUB AX, ASCII3X

    ADD AL, 9[BX]
    ADD AL, 9[BX]
    ADD AL, 9[BX]
    SUB AX, ASCII3X

    ADD AL, 11[BX]
    ADD AL, 11[BX]
    ADD AL, 11[BX]
    SUB AX, ASCII3X

	; DIVIDIMOS AX POR 10
    MOV CX, 10
	DIV CX

    MOV AX, DX
	; SI AX ERA UN MULTIPLO DE 10, ENTONCES YA
	; TENEMOS UN 0 EN AX (EL DIGITO DE CONTROL)
	CMP AX, 0
	JE FIN
	; POR EL CONTRARIO, TENEMOS QUE CALCULAR
	; 10 - EL RESTO DE LA DIVISION Y GUARDARLO
	; EN AX
    SUB AX, 10
    NEG AX

	FIN	:
    POP DX CX BX DS
    POP BP
    RET
_computeControlDigit ENDP

_decodeBarCode PROC FAR
    PUSH BP
    MOV BP, SP

; PRESERVANDO VALORES DE LOS REGISTROS
    PUSH DS BX DI CX AX

    LDS BX, 6[BP] ; COLOCAMOS EL SEGEMENTO EN LA DIRECCION DEL BARCODE

    MOV CX, PAISLEN ; LONGITUD CODIGO PAIS
    CALL TONUM ; OBTENEMOS EL VALOR NUMERICO DEL CODIGO DE PAIS

    LDS BX, 10[BP]; MOVEMOS EL DIRECCIONAMIENTO DE DATOS A LA VARIABLE
    MOV [BX], AX ; GUARDAMOS LA VARIABLE EN MEMORIA

    LDS BX, 6[BP]
    ADD BX, PAISLEN ; SUMAR OFFSET DE TODO LO YA COPIADO
    MOV CX, EMPRLEN ; LONGITUD CODIGO DE EMPRESA
    CALL TONUM

    LDS BX, 14[BP]
    MOV [BX], AX

    LDS BX, 6[BP]
    ADD BX, PAISLEN+EMPRLEN ; SUMAR OFFSET DE LO YA COPIADO
    MOV CX, PRODLEN ; LONGITUD CODIGO PRODUCTO
    CALL TONUM

    LDS BX, 18[BP]
    MOV [BX], AX
    MOV 2[BX], DX

    LDS BX, 6[BP]
    ADD BX, PAISLEN+EMPRLEN+PRODLEN ; SUMAR OFFSET DE LO YA COPIADO

    MOV AL, [BX]
    SUB AL, ASCIIOFFSET

    LDS BX, 22[BP]
    MOV [BX], AL

    POP AX CX DI BX DS
    POP BP
    RET
_decodeBarCode ENDP

;_______________________________________________________________
; SUBRUTINA PARA TRANSFORMAR UN VALOR ASCII EN A NUMERICO
; ENTRADA = CX - LONGITUD DEL NUMERO EN CARACTERES
; SALIDA = DX:AX
;_______________________________________________________________
TONUM PROC FAR
    PUSH DI BX

    MOV AX, 0
    MOV DX, 0
    SIGUETONUM:
    MOV DI, 10
    MUL DI
    MOV DI, [BX]
    AND DI, SHRMASK
    ADD AX, DI
    JNC NOCARRY
    INC DX
    NOCARRY:
    SUB AX, ASCIIOFFSET
    INC BX
    DEC CX
    JNZ SIGUETONUM

    POP BX DI
    RET
TONUM ENDP

PRAC3A ENDS ; FIN DEL SEGMENTO DE CODIGO
END ; FIN DE pract3a.asm
