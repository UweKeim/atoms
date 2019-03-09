 ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
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
 ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

  ; ÄÄ DATENSEGMENT: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   DATA SEGMENT                         ; Beginn des Datensegments.

        ASSUME ds:DATA                  ; DS zeigt auf das Datensegment.

        FALSE                EQU  0
        TRUE                 EQU  1

   ; ÄÄ Externe Variablen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        EXTRN VOCDriverPtr      : DWORD

        EXTRN HSC_Possible      : BYTE
        EXTRN VOC_Possible      : BYTE

   DATA ENDS

  ; ÄÄ CODESEGMENT: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   ; ÄÄ Externe Prozeduren/Funktionen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   CODE SEGMENT                         ; Das Programmsegment.

        P386N                           ; 386-Befehle.

        ASSUME cs:CODE                  ; CS zeigt auf das Codesegment.

   ; ÄÄ Prozeduren ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        CallVOCDriver PROC FAR
    ; ----------------------------------------------------------------
    ;  Aufgabe  : Ruft den VOC-Treiber auf.
    ;  Hinweise : Akzeptiert als Eingabe alle Register und gibt
    ;             als Rckgabe alle Register zurck.
    ; ----------------------------------------------------------------
        PUBLIC CallVOCDriver            ; ™ffentliche Prozedur.

        mov   ax, 0                     ; Default Exit-Wert.

        cmp   VOC_Possible, FALSE       ; Ist berhaupt m”glich ?
        je    VOCNotPossible            ; Nein, Ende.

        call  [DWORD PTR ds:VOCDRIVERPTR]; Rufe Treiber auf.

       VOCNotPossible:                  ; Nicht m”glich.
        retf                            ; Zurck zum Aufrufenden Programm.

        CallVOCDriver ENDP              ; Prozedurende.

   CODE ENDS                            ; Ende des Codesegments.
        END                             ; Ende des Programms.

 ; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ