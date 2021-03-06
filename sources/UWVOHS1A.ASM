 ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 ;   Programm : UWVOHS1a                                                    ;
 ;              VOC-Routinen.                                               ;
 ; ------------------------------------------------------------------------ ;
 ;      Datei : UWVOHS1a.ASM                                                ;
 ;              Routinen, die sich nur in Assembler realisieren lassen.     ;
 ; ------------------------------------------------------------------------ ;
 ;    Version : 0.1                                                         ;
 ;      Autor : Uwe Keim                                                    ;
 ;      Start : 11. Februar 1995                                            ;
 ; ------------------------------------------------------------------------ ;
 ;    Assemblieren   : MASM /MX UWVOHS1a   oder                             ;
 ;                     TASM -MX UWVOHS1a                                    ;
 ;                    ... mit dem Programm UWEVOHS1.PAS linken.             ;
 ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;

  ; 컴 DATENSEGMENT: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

   DATA SEGMENT                         ; Beginn des Datensegments.

        ASSUME ds:DATA                  ; DS zeigt auf das Datensegment.

        FALSE                EQU  0
        TRUE                 EQU  1

   ; 컴 Externe Variablen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

        EXTRN VOCDriverPtr      : DWORD

        EXTRN HSC_Possible      : BYTE
        EXTRN VOC_Possible      : BYTE

   DATA ENDS

  ; 컴 CODESEGMENT: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

   ; 컴 Externe Prozeduren/Funktionen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

   CODE SEGMENT                         ; Das Programmsegment.

        P386N                           ; 386-Befehle.

        ASSUME cs:CODE                  ; CS zeigt auf das Codesegment.

   ; 컴 Prozeduren 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

        CallVOCDriver PROC FAR
    ; ----------------------------------------------------------------
    ;  Aufgabe  : Ruft den VOC-Treiber auf.
    ;  Hinweise : Akzeptiert als Eingabe alle Register und gibt
    ;             als R갷kgabe alle Register zur갷k.
    ; ----------------------------------------------------------------
        PUBLIC CallVOCDriver            ; 셟fentliche Prozedur.

        mov   ax, 0                     ; Default Exit-Wert.

        cmp   VOC_Possible, FALSE       ; Ist 갶erhaupt m봥lich ?
        je    VOCNotPossible            ; Nein, Ende.

        call  [DWORD PTR ds:VOCDRIVERPTR]; Rufe Treiber auf.

       VOCNotPossible:                  ; Nicht m봥lich.
        retf                            ; Zur갷k zum Aufrufenden Programm.

        CallVOCDriver ENDP              ; Prozedurende.

   CODE ENDS                            ; Ende des Codesegments.
        END                             ; Ende des Programms.

 ; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴