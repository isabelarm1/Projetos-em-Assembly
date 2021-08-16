;------------------------------------------------------------------------------
;------------------ Dupla: Isabela Rocha e Andresa Fernandes ------------------
;------------------------- SIRENE DA POLICIA COM ISR --------------------------
;------------------------------------------------------------------------------
		
;------------------------------------------------------------------------------
;---------------------------- DEFINIÇÃO DAS PORTAS ----------------------------
;------------------------------------------------------------------------------
			SOM		equ	P1.6
			
;------------------------------------------------------------------------------
;------------------------- DECLARAÇÃO DAS VARÍAVEIS ---------------------------
;------------------------------------------------------------------------------
			dseg	at	8						;	Segmento de Dados
	

CONT:	ds		1

N:		ds	1
	
			bseg at 20h

FLAG:	dbit	1
	
			cseg	at	00h						;	Reset
				jmp		inicio				
			
			cseg	at	000bh					;	Timer 0
				jmp		timer0
			
;------------------------------------------------------------------------------
;------------------------------- INICIO ---------------------------------------
;------------------------------------------------------------------------------
inicio:
// --------- Inicializa a pilha
	mov		sp,#80h-1
	
// --------- Inicializa os timer's
	mov		TMOD,#02h							;	Timer 1: modo 0 / Timer 0: Modo 2
	mov		TH0,#(256-248)						;	Recarga timer 0 => N0_1 = 248 / f=600Hz
	mov		TH1,#(256-19)						;	Recarga timer 1 => N1 = 19 / f=250Hz
	setb	TR0
	setb	TR1
	mov		N,#248								;	N0_1= 248 / f=600Hz

// --------- Inicializa a interrupção
	mov		IE,#82h								;	1000 0000(2) = 80(16)
	
// --------- Zera o contador	
	mov		CONT,#0

;------------------------------------------------------------------------------
;------------------------------- VOLTA ----------------------------------------
;------------------------------------------------------------------------------

volta:
	jb		TF1,TF1_Sim							;	TF1=1?
	jmp		encontro1

// --------- Zera o contador
TF1_Sim:
	clr		TF1
	mov		TH1,#(256-19)						;	N1 = 19 / f=250Hz
	jb		FLAG,Flag_Sim						;	FLAG=1?
	DEC		N	
	mov		a,N
	cjne	a,#124,encontro1					;	N0_2<=124? N0_2=124 / f=1200Hz
	CPL		FLAG
	jmp		encontro1

Flag_Sim:
	inc		N
	mov		a,N
	cjne	a,#248,encontro1					;	N0_1<=248? N0_1=248 / f=600Hz
	cpl 	FLAG
	jmp		encontro1

encontro1:
	clr		c
	mov		a,#0h
	subb	a,N
	mov		TH0,a
	jmp		volta

;------------------------------------------------------------------------------
;------------------------------- Timer 0 --------------------------------------
;------------------------------------------------------------------------------

timer0:
	cpl		SOM
	RETI

end