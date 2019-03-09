 ;*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*;
 ;*  Programm : UWEMAUS1A                                                  *;
 ;*             Der Assembler-Maus-Interrupt-Handler.                      *;
 ;* ---------------------------------------------------------------------- *;
 ;*     Datei : UWEMAU1A.ASM                                               *;
 ;*             Die externe Funktion.                                      *;
 ;* ---------------------------------------------------------------------- *;
 ;*   Version : 0.1                                                        *;
 ;*     Autor : Uwe Keim                                                   *;
 ;*     Start : 30. August 1994                                            *;
 ;* ---------------------------------------------------------------------- *;
 ;*   Assemblieren   : MASM /MX MOUSEPA;   oder                            *;
 ;*                    TASM -MX MOUSEPA;                                   *;
 ;*                   ... mit dem Programm UWEMAUS1.PAS linken.            *;
 ;*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*;

  ;* -- Datensegment: --------------------------------------------------- *;

   DATA segment word public
   DATA ends                            ; Keine Variablen in diesem Programm.

  ;* -- Programm: ------------------------------------------------------- *;

   CODE   segment byte public           ; Das Programmsegment.

          assume CS:CODE                ; CS zeigt auf das Codesegment, der In-
                                        ; halt von DS, SS und ES ist unbekannt.

   Public MAUSAssHandler                ; Gibt dem TP-Programm die M봥lichkeit,
                                        ; die Adresse des Assembler-Handlers
                                        ; zu ermitteln.

   Extrn  MAUSInterruptHandler : FAR    ; Der auzurufende TP-Event-Handler.
                                        ; MUSS (!!!) FAR sein, weil in Unit
                                        ; aufgerufen !

   Aktiv  db  0                         ; Zeigt an, ob gerade ein Aufruf aus-
                                        ; gef갿rt wird.

   ;* 컴 Prozedur: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *;

   MAUSAssHandler proc far
    ;* ---------------------------------------------------------------- *;
    ;*  Aufgabe  : Der Event-Handler, der zun꼊hst vom Maustreiber      *;
    ;*             aufgerufen wird, um seinerseits dann die             *;
    ;*             TP-Prozedur MAUSInterruptHandler aufzurufen.         *;
    ;*  Hinweis :  Aufruf von TP: nicht erlaubt!                        *;
    ;* ---------------------------------------------------------------- *;

    ;* Zun꼊hst alle Prozessorregister auf dem Stack sichern: *;

    cmp  Aktiv, 0                       ; Aufruf noch nicht beendet ?
    jne  ende                           ; Nein --> Aufruf nicht zulassen.

    mov  aktiv, 1                       ; Keine Aufrufe mehr zulassen.

    push  ax
    push  bx
    push  cx
    push  dx
    push  di
    push  si
    push  bp
    push  es
    push  ds

    ;* Die Argumente f걊 den Aufruf der TP-Funktion auf den Stack bringen: *;
    ;* Aufruf: "MAUSInterruptHandler(AFlags, AButtons, X, Y : Integer);".  *;

    push  ax                            ; Event-Flags auf den Stack bringen.
    push  bx                            ; Status der Mauskn봯fe auf den Stack.
    push  cx                            ; X-Koordinate auf Stack.
    push  dx                            ; Y-Koordinate auf Stack.

;   mov  di, cx                         ; Horizontale Ordinate in DI merken.
;   mov  cl, 3                          ; Schiebez꼑ler f. Koordinatenumrechnung.

;   shr  di, cl                         ; DI (horizontale Ord.) durch 8 teilen
;   push di                             ; und auf den Stack bringen.

;   shr  dx, cl                         ; DX (vertikale Ord.) durch 8 teilen
;   push dx                             ; und auf den Stack bringen.

    mov  ax, DATA                       ; Segmentadresse des Datensegments in AX
    mov  ds, ax                         ; und von dort in das DS-Register.

    call  MAUSInterruptHandler ;Aufruf der TP-Prozedur

    ;* Die gesicherten Register wieder vom Stack holen: *;

    pop  ds
    pop  es
    pop  bp
    pop  si
    pop  di
    pop  dx
    pop  cx
    pop  bx
    pop  ax

    mov  aktiv, 0                       ; Aufruf ist wieder erlaubt.

    ende:
    ret                                 ; Zur갷k zum Maustreiber.

   MAUSAssHandler  endp
    ;* ---------------------------------------------------------------- *;

   CODE ends                            ; Ende des Codesegments.
        End                             ; Ende des Programms.

 ;*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*;