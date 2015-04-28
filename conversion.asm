;-----------------------------------------------------------------------------
; Indica si el dato de Acc esta entre 0 y 9
; Acc:  Dato a comparar
; psw.5 = 0 dato entre 0 y 9
; psw.5 = 1 meror de 0 o mayor de 9 
;-----------------------------------------------------------------------------
C09_:	CLR PSW.5
	CJNE A,#30H,C09_1
C09_1:	JB PSW.7,C09_3		;Es menor de 30h ?
	CJNE A,#3AH,C09_2
C09_2:	JNB PSW.7,C09_3		;Es mayor de 3Ah ?
	SETB PSW.5
C09_3:	RET
;-----------------------------------------------------------------------------
; Convierte hexacecimal a BCD ASCII
; Acc:  Dato a convertir
; R7: centenas en ASCII
; R6: decenas en ASCII
; R5: unidades en ASCII
;-----------------------------------------------------------------------------
BINTOBCD12:	PUSH	B			; Save B
		PUSH	Acc  			; Save Acc
		MOV	B,#100			; Divide By 100
		DIV	AB			; Do Divide
                ORL A,#30H
		MOV	R7,A			; Store In DPH
;		POP	A  			; Recover Acc
		XCH 	A,B
		MOV	B,#10			; Divide By 10
		DIV	AB			; Do Divide
		;SWAP	A			; Move Result To High Of A
		;ORL	A,B			; OR In Remainder
                ORL A,#30H
		MOV	R6,A			; Move To DPL
                ORL B,#30H
		MOV R5,B			; Move To DPL
                POP 	Acc
		POP	B			; Recover B
		RET				; Return To Caller

;-----------------------------------------------------------------------------
; Convierte Hex a ASCII
; Acc:  Dato a convertir entre 00H y 0FH 
; Acc:  Dato convertido en ASCII
;-----------------------------------------------------------------------------
HEX_ASCII:      CLR C
                CJNE A,#10,$+3
                JC HEX_ASCII_menorDe10
                	CJNE A,#10,HEX_ASCII_B 
                		MOV A,#'A'
HEX_ASCII_B:       	CJNE A,#11,HEX_ASCII_C                
                		MOV A,#'B'
HEX_ASCII_C:       	CJNE A,#12,HEX_ASCII_D                
                		MOV A,#'C'
HEX_ASCII_D:       	CJNE A,#13,HEX_ASCII_E                
                		MOV A,#'D'
HEX_ASCII_E:       	CJNE A,#14,HEX_ASCII_F                
                		MOV A,#'E'
HEX_ASCII_F:       	CJNE A,#15,HEX_ASCII_Fin
                		MOV A,#'F'
                		SJMP HEX_ASCII_Fin
HEX_ASCII_menorDe10:        	
		ORL A,#00110000B
HEX_ASCII_Fin:  RET


;----------------------------------------------------------------------------
; Rutina para pasar de BCD a hexadecimal
;----------------------------------------------------------------------------
HexBCD:
        lcall BINTOBCD12
        mov a,r6
        anl a,#0Fh
        swap a
        mov r6,a
        mov a,r5
        anl a,#0fh
        orl a,r6
        ret

BCDHX_:	MOV A,R6
        LCALL C09_
        JNB PSW.5,BCDHX_ER      ;Comprobar decenas
        	ANL A,#0FH
	        MOV B,#0AH
        	MUL AB
	        MOV B,A
        MOV A,R5
        LCALL C09_
        JNB PSW.5,BCDHX_ER      ;Comprobar unidades
        	ANL A,#0FH
	        ADD A,B
                RET
BCDHX_ER:
        MOV A,#0
	RET

;----------------------------------------------------------------------------
; Rutina para pasar de BCD a hexadecimal
;----------------------------------------------------------------------------
BCD_HX:	mov r1,a
	ANL A,#0F0H
        SWAP A
	MOV B,#0AH
	MUL AB
	MOV B,A
	MOV A,R1
	ANL A,#0FH
	ADD A,B
	RET