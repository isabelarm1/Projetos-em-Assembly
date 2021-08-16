; Programa Relogio Digital
; Dupla: Isabela Rocha e Andresa Fernandes
; Turma: 9841

/* ---------------------------------------------------------------------------------------------------------- */
/* ------------------------------------ Pinos: botões e displays -------------------------------------------- */
/* ------------- Obs.: Pino 4 é o primeiro, depois segue a ordem a partir do 0 (erro na VM) ----------------- */
/* ---------------------------------------------------------------------------------------------------------- */

Disp0			equ			P2.4
Disp1			equ			P2.0
Disp2 			equ			P2.1
Disp3			equ			P2.2
Disp4			equ			P2.3
Disp5			equ			P2.5
Disp6			equ			P2.6
Disp7			equ			P2.7
Bdata			equ			P3.0
Bsem			equ			P3.1
Bsegs			equ			P3.2
Bmin			equ			P3.3
Bhor			equ			P3.4
Bdia			equ			P3.5
Bmes			equ			P3.6
Bano			equ			P3.7
	
				dseg at 8   					; Memória de dados
		
/* ---------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------- Variáveis ------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

SEGS:			ds			1  				
MIN:			ds			1			
HORA:			ds			1				
DIA:			ds			1				
MES:			ds			1				
ANO:			ds			1				
DIASEMANA:		ds			1	
Cmes:			ds			1					; Chave referente ao mês
Cano:			ds			1					; Chave referente ao ano
COD0:     		ds      	1					; US     UA      
COD1:     		ds        	1   				; DS     DA  
COD2:     		ds        	1   				;       - 
COD3:     		ds        	1   				; UM     UM  
COD4:    		ds        	1   				; DM     SM  
COD5:     		ds        	1  					;       - 		3ª Letra do dia
COD6:     		ds        	1   				; UH     UD		2ª Letra do dia  
COD7:     		ds        	1   				; DH     DD 		1ª Letra do dia
CONTL:	  		ds			1					; Parte LOW do contador low(480) = 0E1h = 224
CONTH:    		ds			1					; Parte HIGH do contador high(480) = 01h = 1	

	
				cseg							;  Segmento de Programa

/* ---------------------------------------------------------------------------------------------------------- */
/* ------------------------------------------ Reseta valores ------------------------------------------------ */
/* ---------------------------------------------------------------------------------------------------------- */
inicio:	
				mov			SEGS,#0
				mov			MIN,#0
				mov			HORA,#12
				mov			DIA,#20
				mov			MES,#4
				mov			ANO,#21
		
			
/* ---------------------------------------------------------------------------------------------------------- */
/* -------------------------------------- Display: Varredura do Display ------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */
				
				; Inicializa o display: O Disp 0 é o primeiro a ser ligado
				clr     	Disp0				; Disp0 = 0             
				setb    	Disp1				; Disp1 = 1             
				setb    	Disp2   			; Disp2 = 1           
				setb      	Disp3   			; Disp3 = 1            
				setb	  	Disp4   			; Disp4 = 1             
				setb     	Disp5   			; Disp5 = 1             
				setb      	Disp6   			; Disp6 = 1          
				setb		Disp7  				; Disp7 = 1
				
varreduradisplay:
				jnb       	Disp0,rot1          ; Disp0 = 0?
				jnb       	Disp1,rot2			; Disp1 = 0?
				jnb       	Disp2,rot3			; Disp2 = 0?
				jnb       	Disp3,rot4			; Disp3 = 0?
				jnb      	Disp4,rot5			; Disp4 = 0?
				jnb       	Disp5,rot6			; Disp5 = 0?
				jnb       	Disp6,rot7			; Disp6 = 0?
				jnb       	Disp7,rot0			; Disp7 = 0?
          
rot1:     
				setb      	Disp0				; Disp0 = 1
				mov       	P0,COD1
				clr       	Disp1				; Disp1 = 0
				jmp       	encontro 

rot2:     
				setb      	Disp1				; Disp1 = 1
				mov       	P0,COD2
				clr       	Disp2				; Disp2 = 0	
				jmp       	encontro
          
rot3:    
				setb      	Disp2				; Disp2 = 1
				mov       	P0,COD3	
				clr       	Disp3				; Disp3 = 0
				jmp       	encontro
          
rot4:    
				setb      	Disp3				; Disp3 = 1
				mov       	P0,COD4
				clr       	Disp4				; Disp4 = 0
				jmp       	encontro
          
rot5:     
				setb      	Disp4				; Disp4 = 1
				mov       	P0,COD5
				clr       	Disp5				; Disp5 = 0
				jmp       	encontro
          
rot6:     
				setb      	Disp5				; Disp5 = 1
				mov       	P0,COD6
				clr       	Disp6				; Disp6 = 0
				jmp       	encontro
          
rot7:     
				setb     	Disp6				; Disp6 = 1
				mov       	P0,COD7
				clr       	Disp7				; Disp7 = 0
				jmp       	encontro
          
rot0:     
				setb      	Disp7				; Disp7 = 1
				mov       	P0,COD0
				clr   		Disp0				; Disp0 = 0
				jmp    		encontro 

/* ---------------------------------------------------------------------------------------------------------- */
/* -------------------------------- Timer 480 Hz - Para o display ------------------------------------------- */
/* ------ Frequência de Clock = 12MHz | Frequência deseja do timer: 480Hz | Timer Low 5 bits = 2^5 = 32 ----- */
/* ----------------------- N = 12MHz / (12x32x480Hz) = 65,1 ou aprox. 65  | N = 65 -------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */


encontro:  		mov	    TMOD,#00h           								; Modo Zero
				mov 	TH0,#(256-65) 										; Inicializa o N
				setb 	TR0 												; Liga timer
denovo: 		jnb 	TF0,$ 												; Aguarda o overflow
				clr 	TF0 												; Zera aviso de overflow 

				mov 	TH0,#(256-65) 										; FUNÇÃO recarga
/* ---------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------- Converte ano e mês ---------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

ConverteAno:	
				mov			a,ANO
				mov			b,#4
				div			ab					; Dois últimos algarismos do ano serão divididos por 4, quociente -> r0
				mov			r0,a
				mov			a,ANO
				mov			b,#7
				div			ab					; Dois últimos algarismos do ano serão divididos por 7, resto -> b
				mov			a,r0
				add			a,b					; Quociente + Resto
				mov			b,#7
				cjne		a,#7,dif7			; Soma != 7?
				mov			Cano,#6
				jmp			ConverteMes
			
dif7:		
				jc			SOMA_MENOR			; Soma < 7?
				div			ab					; Soma / 7
				mov			a,b					; Resto -> a
				subb		a,#1				; Resto - 1 -> a
				mov			Cano,a
				jmp			ConverteMes
			
SOMA_MENOR:	
				clr			c
				subb		a,#1				; Soma - 1 -> a
				mov			Cano,a
				jmp			ConverteMes
			
;	---	Conversão do Mês ---
ConverteMes:		
				mov			a,MES
				cjne		a,#1,difjaneiro		; mes != 1?
				mov			Cmes,#1
				jmp			CALCDIA
difjaneiro:		
				cjne		a,#2,diffevereiro	; mes != 2?
				mov			Cmes,#4
				jmp			CALCDIA
diffevereiro:	
				cjne		a,#3,difmarco		; mes != 3?
				mov			Cmes,#4
				jmp			CALCDIA
difmarco:		
				cjne		a,#4,difabril		; mes != 4?
				mov			Cmes,#0
				jmp			CALCDIA
difabril:		
				cjne		a,#5,difmaio		; mes != 5?
				mov			Cmes,#2
				jmp			CALCDIA
difmaio:		
				cjne		a,#6,difjunho		; mes != 6?
				mov			Cmes,#5
				jmp			CALCDIA
difjunho:		
				cjne		a,#7,difjulho		; mes != 7?
				mov			Cmes,#0
				jmp			CALCDIA
difjulho:		
				cjne		a,#8,difagosto		; mes != 8?
				mov			Cmes,#3
				jmp			CALCDIA
difagosto:		
				cjne		a,#9,difsetembro	; mes != 9?
				mov			Cmes,#6
				jmp			CALCDIA
difsetembro:	
				cjne		a,#10,difoutubro	; mes != 10?
				mov			Cmes,#1
				jmp			CALCDIA
difoutubro:		
				cjne		a,#11,difnovembro	; mes != 11?
				mov			Cmes,#4
				jmp			CALCDIA
difnovembro:	
				mov			Cmes,#6
				jmp			CALCDIA
						
/* ---------------------------------------------------------------------------------------------------------- */
/* ------------------------------ Cálculo do Dia: Algoritmo de Zeller --------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

CALCDIA:	
				mov			a,DIA
				mov			b,Cmes
				add			a,b	
				mov			b,Cano
				add			a,b
				mov			b,#7
				div			ab
				mov			a,b
				mov			DIASEMANA,b

/* ---------------------------------------------------------------------------------------------------------- */
/* --------------------------------- Display: Altera entre dia e data --------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */
			
SELDISPLAY1:
				jnb			Bsem,MOSTRADIA		; Bsem = 0?			
SELDISPLAY2:
				jnb			Bdata, MOSTRADATAx	; Bdata = 0?	
				jmp			MOSTRAHORA
			
MOSTRADATAx:	
				jmp			MOSTRADATA
MOSTRADIA:	
				mov			COD0,#0FFh
				mov			COD1,#0FFh
				mov			COD2,#0FFh
				mov			COD3,#0FFh
				mov			COD4,#0FFh
				mov			a,DIASEMANA
				cjne		a,#0,difsab			; DIASEMANA != 0?
				mov			COD7,#92h
				mov			COD6,#88h
				mov			COD5,#83h
				jmp			contador
difsab:	
				cjne		a,#1,difdom			; DIASEMANA != 1?
				mov			COD7,#0A1h
				mov			COD6,#0C0h
				mov			COD5,#0C8h
				jmp			contador
difdom:	
				cjne		a,#2,difseg			; DIASEMANA != 2?
				mov			COD7,#92h
				mov			COD6,#86h
				mov			COD5,#0C2h
				jmp			contador
difseg:	
				cjne		a,#3,difter			; DIASEMANA != 3?
				mov			COD7,#087h
				mov			COD6,#086h
				mov			COD5,#0CCh
				jmp			contador
difter:	
				cjne		a,#4,difqua			; DIASEMANA != 4?
				mov			COD7,#098h
				mov			COD6,#0C1h
				mov			COD5,#088h
				jmp			contador
difqua:	
				cjne		a,#5,difqui			; DIASEMANA != 5?
				mov			COD7,#098h
				mov			COD6,#0C1h
				mov			COD5,#0CFh
				jmp			contador
difqui:	
				mov			COD7,#092h
				mov			COD6,#086h
				mov			COD5,#089h
				jmp			contador
							
/* ---------------------------------------------------------------------------------------------------------- */
/* ------------------------------------- Display: Converte a hora ------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

MOSTRAHORA:	
				mov			a,SEGS
				mov			b,#10
				div			ab					; a quociente	= dezena do segundo
												; b resto		= unidade do segundo
				mov			dptr,#tabela		
	
				movc		a,@a+DPTR 			; Pegar o código
				mov			COD1,a    			; Dezena do display
				mov			a,b
				movc		a,@a+DPTR 			; Pegar o código
				mov			COD0,a    			; Unidade
	
	
				mov			a, MIN
				mov			b, #10
				div			ab					; a quociente	= dezena do minuto
												; b resto		= unidade do minuto
	
				movc		a,@a+dptr			; Busca a dezena do minuto na tabela
				mov			COD4,a				; Entrega a dezena do minuto ao COD4
				mov			a,b					; Move a unidade de minuto para o acumulador para habilitar a função de index
				movc		a,@a+dptr			; Busca a unidade de minuto na tabela
				mov			COD3,a				; Entrega a unidade de minuto ao COD3
	
	
				mov			a, HORA
				mov			b, #10
				div			ab					; a quociente	= dezena da hora
												; b resto		= unidade da hora
	
				movc		a,@a+dptr			; Busca a dezena da hora na tabela
				mov			COD7,a				; Entrega a dezena da hora ao COD7
				mov			a,b					; Move a unidade da hora para o acumulador para habilitar a função de index
				movc		a,@a+dptr			; Busca a unidade da hora na tabela
				mov			COD6,a				; Entrega a unidade da hora ao COD6
	
				mov		COD2,#0FFh
				mov		COD5,#0FFh

				jmp		contador

/* ---------------------------------------------------------------------------------------------------------- */
/* ------------------------------------- Display: Converte a data ------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */
	
MOSTRADATA:
				mov		a,ANO
				mov		b,#10
				div		ab						; a quociente	= dezena do ANO
												; b resto		= unidade do ANO
				mov		dptr,#tabela		
	
				movc	a,@a+DPTR 				; Pegar o código
				mov		COD1,a    				; Dezena do display
				mov		a,b
				movc	a,@a+DPTR 				; Pegar o código
				mov		COD0,a    				; Unidade
	
	
				mov		a, MES
				mov		b, #10
				div		ab						; a quociente	= dezena do MÊS
												; b resto		= unidade do MÊS
	
				movc	a,@a+dptr				; Busca a dezena do MÊS na tabela
				mov		COD4,a					; Entrega a dezena do MÊS ao COD4
				mov		a,b						; Move a unidade de MÊS para o acumulador para habilitar a função de index
				movc	a,@a+dptr				; Busca a unidade de MêS na tabela
				mov		COD3,a					; Entrega a unidade de MÊS ao COD3
	
	
				mov		a, DIA
				mov		b, #10
				div		ab						; a quociente	= dezena do dia
												; b resto		= unidade do dia
	
				movc	a,@a+dptr				; Busca a dezena do dia na tabela
				mov		COD7,a					; Entrega a dezena do dia ao COD7
				mov		a,b						; Move a unidade do dia para o acumulador para habilitar a função de index
				movc	a,@a+dptr				; Busca a unidade do dia na tabela
				mov		COD6,a					; Entrega a unidade do dia ao COD6
	
				mov		COD2,#0BFh
				mov		COD5,#0BFh
	
				jmp		contador


/* ---------------------------------------------------------------------------------------------------------- */
/* -------------------------------- Timer 1 Hz - Para o Relógio --------------------------------------------- */
/* ------ Frequência de Clock = 12MHz | Frequência deseja do timer: 1Hz | Timer Low 5 bits = 2^5 = 32 ------- */
/* ------------------ N * M = 12MHz / (12x32x1Hz) = 31250 (não é suportado, então, fatora) ------------------ */
/* ---------------------------------------- N = 250 e M = 125 ----------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

contador:		
				inc		CONTL					; CONTL = CONTL + 1
				mov 	a,CONTL
				jnz 	pular
				inc		CONTH
pular:			
				mov 	a,CONTH
				cjne 	a,#high(480),difw		; high de 480 = 1 CONTH != #high(480)?
				mov		a,CONTL
				cjne	a,#low(480),difw		; low de 480  = 224 ou 0e0h CONTH != #low(480)?
				jmp		zeracontador
difw:			jc	    varreduray
zeracontador:	
				mov		CONTL,#0
				mov		CONTH,#0
				jmp		volta
		
varreduray:	
				jmp		varreduradisplay

				
/* ---------------------------------------------------------------------------------------------------------- */
/* ------------------------------------------ Contagem do Relógio ------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

volta:	
				inc		SEGS					; SEGS = SEGS + 1
				mov		a,SEGS
				cjne	a,#60,dif				; A != 60?
				jmp		zeras      				; A =  60
dif:	
				jc		encontro1x  			; A < 60?
zeras:	
				mov		SEGS,#0

				inc		MIN						; MIN = MIN + 1
				mov		a,MIN
				cjne	a,#60,dif2				; A != 60?
				jmp		zeras2      			; A =  60
dif2:	
				jc		encontro1x  			; A < 60?
zeras2:	
				mov		MIN,#0

				inc		HORA	 				; HORA = HORA + 1
				mov		a,HORA
				cjne	a,#24,dif3				; A < 24?
				jmp		zeras3     				; A =  60
encontro1x:	
				jmp		encontro1	
dif3:	
				jc		encontro1x  			; A < 60?
zeras3:	
				mov		HORA,#0
				inc		DIA
				mov		a,MES
				cjne	a,#1,difjan				; a != 1?
				jmp		mes31
difjan:	
				cjne	a,#2,diffev				; a != 2?
				jmp		fev
diffev:	
				cjne	a,#3,difmar				; a != 3?
				jmp		mes31
difmar:	
				cjne	a,#4,difabr				; a != 4?
				jmp		mes30
difabr:	
				cjne	a,#5,difmai				; a != 5?
				jmp		mes31
difmai:	
				cjne	a,#6,difjun				; a != 6?
				jmp		mes30
difjun:	
				cjne	a,#7,difjul				; a != 7?
				jmp		mes31
difjul:	
				cjne	a,#8,difago				; a != 8?
				jmp		mes31
difago:	
				cjne	a,#9,difset				; a != 9?
				jmp		mes30
difset:	
				cjne	a,#10,difout			; a != 10?
				jmp		mes31
difout:	
				cjne	a,#11,difnov			; a != 11?
				jmp		mes30
difnov:	
				cjne	a,#12,encontro1			; a != 12?
		
				mov		a,DIA
				cjne	a,#31,dif31				; a != 13?
				jmp		encontro1
dif31:	
				jc		encontro1				; a < 13?
				mov		DIA,#1
				mov		MES,#1
				inc		ANO						; ano = ano + 1
				mov		a,ANO
				cjne	a,#99,dif99				; a != 99?
				jmp		encontro1
dif99:	
				jc		encontro1				; a < 99?
				mov		ANO,#0
				jmp		encontro1
	
mes30:		
				mov		a,DIA
				cjne	a,#30,dif30				; a != 30?
				jmp		encontro1
dif30:	
				jc		encontro1				; a < 30?
				mov		DIA,#1
				INC		MES						; mes = mes + 1
				jmp		encontro1	

mes31:
				mov		a,DIA
				cjne	a,#31,dif31x			; a != 31?
				jmp		encontro1
dif31x:	
				jc		encontro1				; a < 31?
				mov		DIA,#1
				INC		MES						; mes = mes + 1
				jmp		encontro1

fev:	
				mov		a,ANO
				mov		b,#4
				div		ab						; resto -> b
				mov		a,b
				jz		anobissexto 			; a = 0?
				mov		a,DIA
				cjne	a,#28,dif28				; a != 28?
				jmp		encontro1
dif28:	
				jc		encontro1
				mov		DIA,#1
				INC		MES						; mes = mes + 1
				jmp		encontro1
anobissexto:
				mov		a,DIA
				cjne	a,#29,dif29				; a != 29?
				jmp		encontro1
dif29:	
				jc		encontro1				; a < 29?
				mov		DIA,#1
				INC		MES						; mes = mes + 1
				jmp		encontro1

encontro1:
				jmp		ajuste

/* ---------------------------------------------------------------------------------------------------------- */
/* ---------------------------------- Display: Botões de Ajuste ------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */

ajuste:
				jnb		Bsegs,ajusteseg
continua1:
				jnb		Bmin,ajustemin
continua2:
				jnb		Bhor,ajustehora
continua3:
				jnb		Bdia,ajustedia
continua4:
				jnb		Bmes,ajustemes
continua5:
				jnb		Bano,ajusteano
				jmp 	varredurax
				
ajusteseg:
				mov		SEGS,#0
				jmp		continua1;
				
ajustemin:
				inc		MIN		 				; MIN = MIN + 1
				mov		a,MIN
				cjne	a,#60,continua2
				mov		MIN,#0
				jmp		continua2
				
ajustehora:		
				inc		HORA					 ; HORA = HORA + 1
				mov		a,HORA
				cjne	a,#24,continua3
				mov		HORA,#0
				jmp		continua3
				
ajustedia:		
				inc		DIA						 ; DIA = DIA + 1
				mov		a,DIA
				cjne	a,#32,continua4
				mov		DIA,#1
				jmp		continua4

ajustemes:		
				inc		MES	 					; MÊS = MÊS + 1
				mov		a,MES
				cjne	a,#13,continua5
				mov		MES,#1
				jmp		continua5

ajusteano:		
				inc		ANO	 					; MIN = MIN + 1
				mov		a,ANO
				cjne	a,#99,varredurax
				mov		ANO,#0
				jmp		varredurax
			
/* ---------------------- Função que funciona para evitar erro: TARGET OUT OF RANGE -------------------------- */
varredurax:
				jmp varreduradisplay

/* ---------------------------------------------------------------------------------------------------------- */
/* ---------------------------------- Tabela com códigos Hexadecimais --------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------- */
			
tabela:	
				db	0c0h						; 0
				db	0F9h      					; 1 
				db	0A4h      					; 2 
				db	0B0h      					; 3 
				db	099h      					; 4 
				db	092h      					; 5 
				db	082h      					; 6 
				db	0F8h      					; 7 
				db	080h      					; 8 
				db	090h      					; 9 

end