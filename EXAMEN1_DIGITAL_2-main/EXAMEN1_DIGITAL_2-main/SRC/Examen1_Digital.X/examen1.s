;*************************************************************************************************
;      ___           ___           ___           ___           ___           ___                 ;
;     /  /\         /__/|         /  /\         /__/\         /  /\         /__/\                ;
;    /  /:/_       |  |:|        /  /::\       |  |::\       /  /:/_        \  \:\               ;
;   /  /:/ /\      |  |:|       /  /:/\:\      |  |:|:\     /  /:/ /\        \  \:\              ;
;  /  /:/ /:/_   __|__|:|      /  /:/~/::\   __|__|:|\:\   /  /:/ /:/_   _____\__\:\             ;
; /__/:/ /:/ /\ /__/::::\____ /__/:/ /:/\:\ /__/::::| \:\ /__/:/ /:/ /\ /__/::::::::\            ;
; \  \:\/:/ /:/    ~\~~\::::/ \  \:\/:/__\/ \  \:\~~\__\/ \  \:\/:/ /:/ \  \:\~~\~~\/            ;
;  \  \::/ /:/      |~~|:|~~   \  \::/       \  \:\        \  \::/ /:/   \  \:\  ~~~             ;
;   \  \:\/:/       |  |:|      \  \:\        \  \:\        \  \:\/:/     \  \:\                 ;
;    \  \::/        |  |:|       \  \:\        \  \:\        \  \::/       \  \:\                ;
;     \__\/         |__|/         \__\/         \__\/         \__\/         \__\/                ;
;                                                                                                ;
;     _____                      ___                                   ___                       ;
;    /  /::\       ___          /  /\        ___           ___        /  /\			 ;
;   /  /:/\:\     /  /\        /  /:/_      /  /\         /  /\      /  /::\			 ;
;  /  /:/  \:\   /  /:/       /  /:/ /\    /  /:/        /  /:/     /  /:/\:\    ___     ___	 ;
; /__/:/ \__\:| /__/::\      /  /:/_/::\  /__/::\       /  /:/     /  /:/~/::\  /__/\   /  /\	 ;
; \  \:\ /  /:/ \__\/\:\__  /__/:/__\/\:\ \__\/\:\__   /  /::\    /__/:/ /:/\:\ \  \:\ /  /:/	 ;
;  \  \:\  /:/     \  \:\/\ \  \:\ /~~/:/    \  \:\/\ /__/:/\:\   \  \:\/:/__\/  \  \:\  /:/	 ;
;   \  \:\/:/       \__\::/  \  \:\  /:/      \__\::/ \__\/  \:\   \  \::/        \  \:\/:/	 ;
;    \  \::/        /__/:/    \  \:\/:/       /__/:/       \  \:\   \  \:\         \  \::/	 ;
;     \__\/         \__\/      \  \::/        \__\/         \__\/    \  \:\         \__\/	 ;
;                               \__\/                                 \__\/			 ;
;************************************************************************************************;
;			    ANDRES JUAN DURAN VALENCIA 2420191020				 ;
;			JUAN SEBASTIAN MOSQUERA CIFUENTES 2420191031				 ;
;			    EXAMEN1 ELECTRONICA DIGITAL 2					 ;
;				    25 - MARZO - 2021						 ;
;												 ;
PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet

CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS
    
#define nivel PORTD,0	;sensor de nivel
#define temp PORTD,1	;sensor de temperatura
#define oxi1 PORTD,2	;oxi1 es el bit mas significativo de mi sensor de oxigeno
#define oxi2 PORTD,3	;oxi2 es el bit menos significativo de mi sensor de oxigeno
#define bomba PORTC,0	;bomba = led amarillo
#define resist PORTC,1	;resistencia electrica de calefaccion = led rojo
#define aire PORTC,2	;bomba de aire = led verde
    
PSECT code

INISYS: 
    ;Cambio a Banco N1
    BCF STATUS, 6
    BSF STATUS, 5 ; Banco1
    ;Modificar TRIS
    BSF	TRISD,0	;nivel=PORTD0->ENTRADA SENSOR DE NIVEL
    BSF	TRISD,1	;temp=PORTD1->ENTRADA SENSOR DE TEMPERATURA
    BSF TRISD,2	;oxi1=PORTD2->ENTRADA BIT MAS SIGNIFICATIVO SENSOR DE OXIGENO
    BSF TRISD,3	;oxi2=PORTD3->ENTRADA BIT MENOS SIGNIFICATIVO SENSOR DE OXIGENO
    BCF	TRISC,0	;bomba=PORTC0->SALIDA BOMBA DE AGUA
    BCF	TRISC,1 ;resist=PORTC1->SALIDA RESISTENCIA DE CALEFACCION
    BCF TRISC,2	;aire=PORTC2->SALIDA BOMBA DE AIRE
    ; Regresar a banco 0

    BCF STATUS, 5 ; Banco0

MAIN:
    
    PUNTO1:
    BTFSC   nivel
    GOTO    OFFBOMBA	;SI D0=1
    GOTO    ONBOMBA	;SI D0=0
    ONBOMBA:
    BSF bomba		;ENCIENDE LA BOMBA DE AGUA (LED AMARILLO)
    GOTO PUNTO2		
    OFFBOMBA:
    BCF bomba		;APAGA LA BOMBA DE AGUA (LED AMARILLO)
    GOTO PUNTO2
    

    PUNTO2:
    BTFSC   temp
    GOTO    OFFRESIST	;SI D1=1
    GOTO    ONRESIST	;SI D1=0
    ONRESIST:
    BSF	resist		;ENCIENDE LA RESISTENCIA (LED ROJO)
    GOTO PUNTO3 
    OFFRESIST:
    BCF resist		;APAGA LA RESISTENCIA (LED ROJO)
    GOTO PUNTO3
    
    PUNTO3:
    BTFSC   oxi1	;SOLO PREGUNTO POR EL BIT MAS SIGNIFICATIVO PORQUE SI ESTA EN CERO QUIERE DECIR QUE LE FALTA OXIGENO
    GOTO    OFFAIRE	;SI D2=1
    GOTO    ONAIRE	;SI D2=0
    ONAIRE:
    BSF	aire		;ENCIENDE LA BOMBA DE AIRE (LED VERDE)
    GOTO MAIN
    OFFAIRE:
    BCF aire		;APAGA LA BOMBA DE AIRE (LED VERDE)
    GOTO MAIN
    
 END resetVec