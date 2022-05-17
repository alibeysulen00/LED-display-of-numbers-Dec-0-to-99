list		p=16f877A	
	#include	<p16f877A.inc>	
	
    __CONFIG H'3F31'
BIRLER EQU 0X21
ONLAR EQU 0X22
SAYACB EQU 0X23
SAYACO EQU 0X24
G1  EQU	0X25
G2  EQU	0X26
G3  EQU	0X27
w_temp		EQU	0x7D		
status_temp	EQU	0x7E		
pclath_temp	EQU	0x7F	
    ORG     0x000             	

    nop			  			  	; ICD ozelliginin aktif edilmesi icin gereken bekleme 
    goto    BASLA              	; baslama etiketine gir

	
;**********************************************************************************************
    ORG     0x004             	; kesme vektoru

    movwf   w_temp            	; W n?n yedegini al
    movf	STATUS,w          	; Status un yedegini almak icin onu once W ya al
    movwf	status_temp       	; Status u yedek register '?na al
    movf	PCLATH,w	  		; PCLATH '? yedeklemek icin onu once W 'ya al
    movwf	pclath_temp	  		; PCLATH '? yedek register a al

	; gerekli kodlar

    movf	pclath_temp,w	  	; Geri donmeden once tum yedekleri geri yukle
    movwf	PCLATH		  		
    movf    status_temp,w     	
    movwf	STATUS            	
    swapf   w_temp,f
    swapf   w_temp,w          	
	retfie            
	BASLA
BANKSEL ADCON1
    MOVLW 0X06
    MOVWF ADCON1

    CLRF TRISA
    CLRF TRISB

BANKSEL PORTA
    BSF PORTA,1
    CLRF PORTB

    MOVLW 0X00		;birler basama?? 
    MOVWF BIRLER

    MOVLW 0X05	;birler basama?? sayaç?
    MOVWF SAYACB	;her 9 oldu?unda 0 a dönmesi için 

    MOVLW 0X00		;onlar basama?? (soldaki 7segment)
    MOVWF ONLAR

    MOVLW 0X0A		;onlar basama?? sayac? 9 oldugunda 0 a dönsün
    MOVWF SAYACO

DONGU1
    BSF PORTA,0
    BCF PORTA,1	
    MOVF BIRLER,W	;birler basama??n?n anl?k de?eri workinge yüklenip
    CALL RAKAMLAR	;rakamlardan de?er al?nacakt?r
    MOVWF PORTB
    CALL GECIKME	;porta,1 clear seçme ucuna gelen ver?y? okuyacakt?r
    INCF BIRLER,F
    INCF BIRLER,F	;birler basama?? 1-1 artacakt?r
    

    BCF PORTA,0		;onlar basama?? için porta,0 seçim ucu kullan?lm??t?r
    BSF PORTA,1		;birler basama?? set edip kapand???nda onlar basama??na yaz?lacakt?r de?er
    MOVF ONLAR,W	;lookup table dan de?er al?nacakt?r
    CALL RAKAMLAR
    MOVWF PORTB
    CALL GECIKME
    DECFSZ SAYACB		;her dongude sayac birler 1-1 azalacakt?r
    CALL DONGU1

    MOVLW 0X00		;sayac birler s?f?r olunca birler basam??ndaki rakam 9 olmu? demekt?r
    MOVWF BIRLER		;tekrardan bu basama?? 0 yapaca??z 0-9 aras?nda sürekli sayd???m?z için

    MOVLW 0X05		;birler sayac? tekrardan 9 yap?l?yor
    MOVWF SAYACB

DONGU2			;birler basama?? 9 oldu?u zaman tekrar 0 lad?k
    BSF PORTA,1		;?imdi yapmam?z gereken soldaki rakam? yani onlar basama??n?
    BCF PORTA,0		;1 art?rmak bu sayede 9 dan sonra 10
    INCF ONLAR		; 19 dan sonra 20 .... 89 dan sonra 90 gelecektir
    MOVF ONLAR,W
    CALL RAKAMLAR
    MOVWF PORTB
    CALL GECIKME
    DECFSZ SAYACO		;sayac onlarda s?f?r olduysa demektirki 99 say?s?n? görüyoruz ?imdi bütün i?lemleri ba?a almam?z gerekiyor
    CALL DONGU1

    MOVLW 0X00		;99 olduysa bütün de?erleri ba?tan yükleyip ilk döngüye tekrar dallan?yoruz
    MOVWF BIRLER

    MOVLW 0X05
    MOVWF SAYACB

    MOVLW 0X00
    MOVWF ONLAR

    MOVLW 0X0A
    MOVWF SAYACO
    CALL DONGU1

GECIKME
    MOVLW	0XFF
    MOVWF	G1
    MOVLW	0XFF
    MOVWF	G2
    MOVLW	0X01
    MOVWF	G3
DONGU
    DECFSZ	G1,1
    GOTO	DONGU
    DECFSZ	G2,1
    GOTO	DONGU
    DECFSZ	G3,1
    GOTO	DONGU
    RETURN

RAKAMLAR
    ADDWF PCL,F
    RETLW h'3F'                              
    RETLW h'06'                             
    RETLW h'5B'                              
    RETLW h'4F'                             
    RETLW h'66'                             
    RETLW h'6D'                           
    RETLW h'7D'                             
    RETLW h'07'                             
    RETLW h'7F'
    RETLW h'6F'
    RETURN
				;~~ www.mikroislemcim.com ~~
END
						
