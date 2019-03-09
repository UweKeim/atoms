 ;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ;
 ;   Programm : UWEVGA01                                                    ;
 ;              Animationspaket, in Unitform.                               ;
 ; ------------------------------------------------------------------------ ;
 ;      Datei : UWVGA01A.ASM                                                ;
 ;              EnthÑlt zeitkritische Routinen (ANIMATE).                   ;
 ; ------------------------------------------------------------------------ ;
 ;    Version : 0.1                                                         ;
 ;      Autor : Uwe Keim                                                    ;
 ;      Start : 10. April 1994                                              ;
 ; ------------------------------------------------------------------------ ;
 ;    Assemblieren   : MASM /MX UWVGA01A   oder                             ;
 ;                     TASM -MX UWVGA01A                                    ;
 ;                    ... mit dem Programm UWEVGA01.PAS linken.             ;
 ;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ;

  ; ƒƒ DATENSEGMENT: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

   DATA SEGMENT                         ; Beginn des Datensegments.

        ASSUME ds:DATA                  ; DS zeigt auf das Datensegment.

        ALIGN  4

   ; ƒƒ Verschiedene Konstanten: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

        ; Sprite-Konstanten:
        NMAX    = 050                   ; Maximale Anzahl Sprites gleichzeitig.

        ; Bildschirm-Konstanten:
        XMAX           = 319            ; Hardware-Auflîsung horizontal.
        YMAX           = 199            ; Hardware-Auflîsung vertikal.
        BackGroundPage = 3              ; Nummer (0..3) der Hintergrundsseite.
        LineSize       = (XMAX + 1) / 4 ; Grî·e einer Zeile = 80 Bytes.
        ScreenSize     = (YMAX + 1) * LineSize
                                        ; 200 Zeilen zu je 320/4 Bytes.
        ; Hintergrunds-Modi:
        Static    = 0
        Scrolling = 1

        ; Wichtige Offsetwerte innerhalb des Sprite-Headers:
        BreiteInB = 00                  ; WORD. Breite in Pixel Shr 2.
        HoeheInZ  = 02                  ; WORD. Hoehe in Pixeln.

        Translate = 04                  ; 4 * BYTE. "1,2,4,8": Die einzelnen Ebenen.
        Plane0    = 08                  ; WORD. Zeiger auf Daten fÅr Plane 0.
        Plane1    = 10                  ; WORD. Zeiger auf Daten fÅr Plane 1.
        Plane2    = 12                  ; WORD. Zeiger auf Daten fÅr Plane 2.
        Plane3    = 14                  ; WORD. Zeiger auf Daten fÅr Plane 3.

        ; TemporÑre Variablen im Spriteheader:
        P0PlanePtr    = 16              ; WORD. Kopie des Zeigers auf Daten dieser Ebene.
        P1PlanePtr    = 18              ; WORD. Kopie des Zeigers auf Daten dieser Ebene.
        P2PlanePtr    = 20              ; WORD. Kopie des Zeigers auf Daten dieser Ebene.
        P3PlanePtr    = 22              ; WORD. Kopie des Zeigers auf Daten dieser Ebene.

        P0StartOfsScr = 24              ; WORD. Ofs-Adr der akt. Zeile auf Schirm.
        P1StartOfsScr = 26              ; WORD. Ofs-Adr der akt. Zeile auf Schirm.
        P2StartOfsScr = 28              ; WORD. Ofs-Adr der akt. Zeile auf Schirm.
        P3StartOfsScr = 30              ; WORD. Ofs-Adr der akt. Zeile auf Schirm.

        P0AddOfsRAM   = 32              ; WORD. Anzahl Bytes, um die RAM Zeiger verschoben wird.
        P1AddOfsRAM   = 34              ; WORD. Anzahl Bytes, um die RAM Zeiger verschoben wird.
        P2AddOfsRAM   = 36              ; WORD. Anzahl Bytes, um die RAM Zeiger verschoben wird.
        P3AddOfsRAM   = 38              ; WORD. Anzahl Bytes, um die RAM Zeiger verschoben wird.

        P0Repeats     = 40              ; WORD. Bytes pro Zeile in dieser Ebene.
        P1Repeats     = 42              ; WORD. Bytes pro Zeile in dieser Ebene.
        P2Repeats     = 44              ; WORD. Bytes pro Zeile in dieser Ebene.
        P3Repeats     = 46              ; WORD. Bytes pro Zeile in dieser Ebene.

        P0StartPlane  = 48              ; BYTE. AnzuwÑhlende Ebene auf dem Schirm.
        P1StartPlane  = 49              ; BYTE. AnzuwÑhlende Ebene auf dem Schirm.
        P2StartPlane  = 50              ; BYTE. AnzuwÑhlende Ebene auf dem Schirm.
        P3StartPlane  = 51              ; BYTE. AnzuwÑhlende Ebene auf dem Schirm.

        ZeilenRepeats = 52              ; WORD. Anzahl sichtbarer Zeilen.

        WinXMIN_      = 54              ; WORD. Linke Begrenzung.
        WinXMAX_      = 56              ; WORD. Rechte Begrenzung.

   ; ƒƒ Externe Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

        ; Timer-Variablen:
        EXTRN IsAT              : BYTE
        EXTRN TimeFlag          : BYTE
        EXTRN CycleTime         : DWORD

        ; Sprite-Variablen:
        EXTRN SpriteN           : WORD
        EXTRN SpriteAD          : WORD
        EXTRN SpritePTR         : WORD
        EXTRN SpriteX           : WORD
        EXTRN SpriteY           : WORD
        EXTRN NextSprite        : WORD
        EXTRN SplitIndex        : WORD
        EXTRN SplitIndex_Mal2   : WORD
        EXTRN SpritesXMod4      : WORD

        ; Hintergrund:
        EXTRN BackGroundMode    : BYTE
        EXTRN BackGroundADR     : WORD
        EXTRN UseVRAMBackGround : BYTE
        EXTRN DrawOuterArea     : BYTE

        ; Zeichenseite:
        EXTRN _Page             : WORD
        EXTRN _PageMal2         : WORD
        EXTRN PageADR           : WORD
        EXTRN PageOFS           : WORD
        EXTRN POfs_Adr          : WORD
        EXTRN PSeg_Adr          : WORD
        EXTRN PageHelpTab       : WORD
        EXTRN PageHelpTabMal2   : WORD

        ; VGA-Register (Konstanten):
              CRTAddress        = 3D4h
              StatusReg         = 3DAh

        ; Fenster-Variablen:
        EXTRN StartVirtualX     : WORD
        EXTRN StartVirtualY     : WORD
        EXTRN WinXMIN           : WORD
        EXTRN WinYMIN           : WORD
        EXTRN WinXMAX           : WORD
        EXTRN WinYMAX           : WORD
        EXTRN WinWidth          : WORD
        EXTRN WinHeight         : WORD
        EXTRN WinOfsXMINYMIN    : WORD
        EXTRN WinWidthDiv4      : WORD

        ; Scrolling-Variablen:
        EXTRN UseVRAMScroll     : BYTE
        EXTRN ScrollPageAdr     : WORD
        EXTRN AktX              : WORD
        EXTRN AktY              : WORD
        EXTRN AktIndexMal2      : WORD
        EXTRN BackTile          : WORD
        EXTRN BackTileMal64     : WORD
        EXTRN BackTileMal64SEG  : WORD
        EXTRN BACKX1            : WORD
        EXTRN BACKY1            : WORD
        EXTRN BACKX2            : WORD
        EXTRN BACKY2            : WORD
        EXTRN XTILES            : WORD
        EXTRN YTILES            : WORD
        EXTRN LEFTCut           : WORD
        EXTRN RIGHTCut          : WORD
        EXTRN TOPCut            : WORD
        EXTRN BOTTOMCut         : WORD
        EXTRN InnerTilesX       : WORD
        EXTRN InnerTilesY       : WORD
        EXTRN TilesWegLEFT      : WORD
        EXTRN TilesWegRIGHT     : WORD
        EXTRN HelpTab           : BYTE
        EXTRN HelpTab2          : WORD

   DATA ENDS

  ; ƒƒ CODESEGMENT: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

   ; ƒƒ Externe Prozeduren/Funktionen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

         EXTRN CS_GAdr                  : NEAR
         EXTRN CS_POfs_Adr              : NEAR

   CODE SEGMENT                         ; Das Programmsegment.

        P386N                           ; 386-Befehle.

        ASSUME cs:CODE                  ; CS zeigt auf das Codesegment.

        ALIGN  4

   ; ƒƒ Prozeduren ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

        Animate PROC FAR
    ; ----------------------------------------------------------------
    ;  Aufgabe  : 1 Animationszyklus.
    ;  Hinweise : baut den Hintergrund und die Sprites auf der Seite
    ;             "_PAGE", die verdeckt ist auf und schaltet dann um.
    ;             Es wird umgeschaltet: 2 -> 1 -> 0 -> 2 -> ...
    ; ----------------------------------------------------------------
        PUBLIC Animate                  ; ôffentliche Prozedur.

        push   bp                       ; BP auf Stack.

        ; Zeitueberwachung fuer Zyklus starten:
        mov   al, IsAT                  ; Ist das ein AT/386? ($0/$80=Ja/Nein).
        or    al, al                    ; Zeitmechanismus geht nur auf AT/386  ;
        jne   @NoTimeCheck              ; anderenfalls keine ZeitÅberwachung !
        mov   TimeFlag, al              ; AL=0 zugleich als Init-Wert benutzen.
        mov   dx, WORD PTR CycleTime    ; Mindestzykluszeit (in Mikrosekunden).
        mov   cx, WORD PTR CycleTime+2  ; eintragen: CX=HIGH-Word, DX=LOW-Word.
        mov   bx, OFFSET ds:TimeFlag    ; ES:BX=Zeiger auf TimeFlag, Bit 7=0/1
        mov   ax, SEG DATA              ; fÅr: Zeit lÑuft noch/ist um.
        mov   es, ax
        mov   ax, 8300h                 ; ZeitÅberwachung starten.
        int   15h
       @NoTimeCheck:

        cld                             ; Lîsche Richtungs-Flag. FÅr String-Operationen.

        ; Ein fÅr allemal setzen: ES = PAGEADR, FS = SCROLLADR, GS = DATASEG:
        mov   es, PageAdr               ; Segmentadresse der akt. Zeichenseite.
        mov   fs, BackTileMal64SEG      ; Segmentadresse der Kacheln (im RAM).
        mov   ax, SEG DATA              ; Datensegment-Segmentadresse.
        mov   gs, ax                    ; GS zeigt immer auf Datensegment.

        ; ============================================================
        ;  HINTERGRUND ZEICHNEN:
        ; ============================================================

        ; JETZT STATISCHEN HINTERGRUND IN ANIMATE-WINDOW ZEICHNEN
        ; UND / ODER IN BEREICH UM ANIMATE-WINDOW:

        ; Testen, ob STATISCH oder SCROLLING:
        cmp   BYTE PTR BackGroundMode, SCROLLING
        jne   @StaticBackGround
        jmp   @ScrollingBackGround

        ; ------------------------------------------------------------
        ;  STATISCHEN HINTERGRUND:
        ; ------------------------------------------------------------
       @StaticBackGround:

        ; Testen, ob BACKGROUNDPAGE aus dem Video-RAM (VRAM)
        ; oder aus dem normalen RAM kommt:
        cmp   BYTE PTR UseVRAMBackground,0  ; Aus VRAM ?
        jne   @STATICBackGroundVRAM
        jmp   @STATICBackGround_RAM     ; NEIN, aus normalem RAM.

        ; ---- Aus VRAM: ----
       @STATICBackGroundVRAM:

        ; Testen, ob Ñu·erer Bereich zeichnen:
        cmp   BYTE PTR DrawOuterArea, 0 ; Au·en zeichnen ?
        jne   @VRAMWholeScreen          ; JA, also ALLES zeichnen.

        ; 4 FÑlle des Animate-Windows sind mîglich:
        ;
        ; 1. :  €€€€€€€€€€€€€€€€€€€  2. :  €€€€€€€€€€€€€€€€€€€
        ;       €                 €        €  ±±±±±±±±±±±±±  €
        ;       €±±±±±±±±±±±±±±±±±€        €  ±±±±±±±±±±±±±  €
        ;       €±±±±±±±±±±±±±±±±±€        €  ±±±±±±±±±±±±±  €
        ;       €±±±±±±±±±±±±±±±±±€        €  ±±±±±±±±±±±±±  €
        ;       €                 €        €  ±±±±±±±±±±±±±  €
        ;       €€€€€€€€€€€€€€€€€€€        €€€€€€€€€€€€€€€€€€€
        ;
        ; 3. :  €€€€€€€€€€€€€€€€€€€  4. :  €€€€€€€€€€€€€€€€€€€
        ;       €                 €        €±±±±±±±±±±±±±±±±±€
        ;       €  ±±±±±±±±±±±±±  €        €±±±±±±±±±±±±±±±±±€
        ;       €  ±±±±±±±±±±±±±  €        €±±±±±±±±±±±±±±±±±€
        ;       €  ±±±±±±±±±±±±±  €        €±±±±±±±±±±±±±±±±±€
        ;       €                 €        €±±±±±±±±±±±±±±±±±€
        ;       €€€€€€€€€€€€€€€€€€€        €€€€€€€€€€€€€€€€€€€
        ;
        ; Wobei Fall 2 zu berÅcksichtigen nichts bringt.

        ; Realisiere jetzt:      If WINWidth  = (XMAX+1) And
        ;                           WinHeight = (YMAX+1) Then
        ;                         "FALL 4"
        ;                   Else If WINWidth  = (XMAX+1) Then
        ;                         "FALL 1"
        ;                   Else  "FALL 3"  ;

        cmp   WORD PTR WinWidth, XMAX + 1   ; Ist ganze Schirmbreite ?
        je    @VRAMTstYMAX              ; JA, teste auch Schirmhîhe.
        jmp   @VRAMNoBorderSize         ; NEIN, zu "FALL 3" gehen.
       @VRAMTstYMAX:                    ; Teste Schirmhîhe.
        cmp   WORD PTR WinHeight, YMAX + 1  ; Ist ganze Schirmhîhe ?
        je    @VRAMWholeScreen          ; JA, GANZER Schirm kopieren("FALL 4").
        jmp   @VRAMXSIZEFitsScreen      ; NEIN, "FALL 1".

        ; "FALL 4": Von Seite 2 auf GESAMTEN Schirm kopieren:
       @VRAMWholeScreen:
        dec   BYTE PTR DrawOuterArea    ; Auf jeden Fall Au·en gezeichnet.
        xor   di, di                    ; ZIEL-OFS = 0.
        mov   ds, BackGroundAdr         ; QUELL-SEG auf Hintergrundseite.
        xor   si, si                    ; QUELL-OFS = 0.

        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        mov   ax, 4105h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 1 einschalten.
        out   dx, ax                    ; Register ansprechen.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   ax, 0FF02h                ; AL = $02: Index des MAP MASK REGISTERS,
                                        ; AH = $FF: Alle Ebenen zum Schreiben ein.
        out   dx, ax                    ; Register ansprechen.
        mov   cx, ScreenSize            ; Anzahl Bytes.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.

        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        mov   ax, 4005h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 0 einschalten.
        out   dx, ax                    ; Register ansprechen.

        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.
        jmp   @ZeichneSprites           ; Hintergrund fertig.

        ; "FALL 1": GANZE Breite, NICHT GANZE Hîhe:
       @VRAMXSIZEFitsScreen:
        mov   ax, WinHeight             ; Berechne Hîhe des Fensters (NUR AL, da max. 200).
        mov   cl, (XMAX + 1) / 4        ; Breite.
        mul   cl                        ; AX := "BREITE * HôHE".
        mov   cx, ax                    ; In CX merken.

        mov   di, WinOfsXMinYMin        ; Merke linke obere Ecke in DI.
        mov   si, di                    ; QUELL-OFS.

        mov   ds, BackGroundAdr         ; QUELL-SEG auf Hintergrundseite.

        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        mov   ax, 4105h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 1 einschalten.
        out   dx, ax                    ; Register ansprechen.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   ax, 0FF02h                ; AL = $02: Index des MAP MASK REGISTERS,
                                        ; AH = $FF: Alle Ebenen zum Schreiben ein.
        out   dx, ax                    ; Register ansprechen.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.

        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        mov   ax, 4005h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 0 einschalten.
        out   dx, ax                    ; Register ansprechen.

        mov  ax, SEG Data               ; Original Datensegment lesen.
        mov  ds, ax                     ; Original Datensegment setzen.
        jmp  @ZeichneSprites            ; Hintergrund fertig.

        ; "FALL 3": NICHT GANZE Breite, NICHT GANZE Hîhe:
       @VRAMNoBorderSize:
        mov   cx, WinHeight             ; Lese und merke Hîhe des Fensters.

        mov   di, WinOfsXMinYMin        ; Merke linke obere Ecke in DI.
        mov   si, di                    ; QUELL-OFS.
        mov   bp, di                    ; Merke linke obere Ecke in BP.

        mov   bx, WinWidthDiv4          ; Lade Breite in Bytes.
        mov   ds, BackGroundAdr         ; QUELL-SEG auf Hintergrundseite.

        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        mov   ax, 4105h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 1 einschalten.
        out   dx, ax                    ; Register ansprechen.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   ax, 0FF02h                ; AL = $02: Index des MAP MASK REGISTERS,
                                        ; AH = $FF: Alle Ebenen zum Schreiben ein.
        out   dx, ax                    ; Register ansprechen.

        mov   dx, cx                    ; Merke Anzahl der Zeilen.

       @VRAMCopyBkEineZeile:
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        dec   dx                        ; 1 Zeile Weniger.
        jnz   @VRAMCopyBkEineZeile      ; Wenn noch Zeilen da, weiter.

        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        mov   ax, 4005h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 0 einschalten.
        out   dx, ax                    ; Register ansprechen.

        mov  ax, SEG Data               ; Original Datensegment lesen.
        mov  ds, ax                     ; Original Datensegment setzen.
        jmp  @ZeichneSprites            ; Hintergrund fertig.

        ; ---- Aus normalem RAM: ----
        @STATICBackGround_RAM:

        ; Testen, ob Ñu·erer Bereich zeichnen:
        cmp   BYTE PTR DrawOuterArea, 0 ; Au·en zeichnen ?
        jne   @RAMWholeScreen           ; JA, also ALLES zeichnen.

        ; Die 4 mîglichen FÑlle des Animate-Windows testen (s. "VRAM"):
        cmp   WORD PTR WinWidth, XMAX + 1   ; Ist ganze Schirmbreite ?
        je    @RAMTstYMAX               ; JA, teste auch Schirmhîhe.
        jmp   @RAMNoBorderSize          ; NEIN, zu "FALL 3" gehen.
       @RAMTstYMAX:                     ; Teste Schirmhîhe.
        cmp   WORD PTR WinHeight, YMAX + 1  ; Ist ganze Schirmhîhe ?
        je    @RAMWholeScreen           ; JA, GANZER Schirm kopieren("FALL 4").
        jmp   @RAMXSIZEFitsScreen       ; NEIN, "FALL 1".

        ; "FALL 4": Von BackGround-Page auf GESAMTEN Schirm kopieren:
       @RAMWholeScreen:
        dec   BYTE PTR DrawOuterArea    ; Auf jeden Fall Au·en gezeichnet.
        mov   ds, BACKGROUNDADR         ; QUELL-SEG auf Hintergrundseite.
        xor   si, si                    ; QUELL-OFS = 0.
        mov   ax, 0102h                 ; AL = $02: Index des MAP MASK REGISTERS.
                                        ; AH = $01: Schreibebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   bx, ScreenSize / 4        ; Wiederholungen  ; 1/4 * Schirmgrî·e, da DWORD.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        xor   di, di                    ; ZIEL-OFS = 0.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        xor   di, di                    ; ZIEL-OFS auf 0.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        xor   di, di                    ; ZIEL-OFS auf 0.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        xor   di, di                    ; ZIEL-OFS auf 0.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.

        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.
        jmp   @ZeichneSprites           ; Hintergrund fertig.

        ; "FALL 1": GANZE Breite, NICHT GANZE Hîhe:
       @RAMXSIZEFitsScreen:
        mov   ax, WinHeight             ; Berechne Hîhe des Fensters (NUR AL, da max. 200).
        mov   cl, (XMAX + 1) / 4        ; Breite.
        mul   cl                        ; AX := "BREITE * HôHE".
        mov   bx, ax                    ; In BX merken.
        shr   bx, 2                     ; "BX := BX Div 4", da "MOVS_D_".

        mov   bp, WinOfsXMinYMin        ; Merke linke obere Ecke in BP.

        mov   ds, BACKGROUNDADR         ; QUELL-SEG auf Hintergrundseite.

        mov   ax, 0102h                 ; AL = $02: Index des MAP MASK REGISTERS.
                                        ; AH = $01: Schreibebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; Wiederholungen.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        mov   di, bp                    ; ZIEL-OFS.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        mov   di, bp                    ; ZIEL-OFS.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   cx, bx                    ; Wiederholungen.
        mov   di, bp                    ; ZIEL-OFS.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.

        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.
        jmp   @ZeichneSprites           ; Hintergrund fertig.

        ; "FALL 3": NICHT GANZE Breite, NICHT GANZE Hîhe:
       @RAMNoBorderSize:
        mov   cx, WinHeight             ; Lese und merke Hîhe des Fensters.
        mov   bp, WinOfsXMinYMin        ; Merke linke obere Ecke in BP.
        mov   bx, WinWidthDiv4          ; Lade Breite in Bytes.
        mov   ds, BACKGROUNDADR         ; QUELL-SEG auf Hintergrundseite.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 02h                   ; Index des MAP MASK REGISTERS.

        ; Teste, ob BYTES, WORDS oder DWORDS kopieren:
        mov   si, bx                    ; Lade Breite in Bytes.
        and   si, 3                     ; ein vielfaches von 4 ?
        jne   @NoRAM_DWORDS
        jmp   @RAM_DWORDS               ; JA, kopiere DWORDS.
       @NoRAM_DWORDS:
        mov   si, bx                    ; Lade Breite in Bytes.
        and   si, 1                     ; ein vielfaches von 2 ?
        je    @RAM_WORDS                ; JA, kopiere DWORD.

       @RAMCopyBkEineZeileBYTES:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; Kopiere CX Bytes von DS:SI nach ES:DI.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; Kopiere CX Bytes von DS:SI nach ES:DI.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; Kopiere CX Bytes von DS:SI nach ES:DI.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; Kopiere CX Bytes von DS:SI nach ES:DI.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @RAMCopyBkEineZeileBYTES  ; Wenn noch Zeilen da, weiter.
        jmp   @RAMCopyBkEineZeileEnde   ; Ende.

       @RAM_WORDS:
        shr   bx, 1                     ; BX := BX / 2 fÅr WORDS.

       @RAMCopyBkEineZeileWORDS:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsw                     ; Kopiere CX Words von DS:SI nach ES:DI.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsw                     ; Kopiere CX Words von DS:SI nach ES:DI.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsw                     ; Kopiere CX Words von DS:SI nach ES:DI.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsw                     ; Kopiere CX Words von DS:SI nach ES:DI.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @RAMCopyBkEineZeileWORDS  ; Wenn noch Zeilen da, weiter.
        jmp   @RAMCopyBkEineZeileEnde   ; Ende.

       @RAM_DWORDS:
        shr   bx, 2                     ; BX := BX / 4 fÅr DWORDS.

       @RAMCopyBkEineZeileDWORDS:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @RAMCopyBkEineZeileDWORDS ; Wenn noch Zeilen da, weiter.

       @RAMCopyBkEineZeileEnde:
        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.

        jmp   @ZeichneSprites           ; Hintergrund fertig.

        ; ------------------------------------------------------------
        ;  SCROLLENDER HINTERGRUND:
        ; ------------------------------------------------------------
       @ScrollingBackGround:

        ; Testen, ob Bereich um Scrollfenster zeichnen:
        cmp   BYTE PTR DrawOuterArea, 0 ; Zeichnen ?
        jne   @DrawOutside              ; JA, zeichnen.
        jmp   @DoNotDrawOutSide         ; NEIN, direkt innen weiter.

        ; ---------- éu·eren Bereich neu zeichnen: ----------
        @DrawOutside:

        ; ------------- Aus RAM:
        @RAMSCROLLDrawOutSide:

        ; 4 Bereiche des éu·eren Bereichs:
        ;
        ;       €€€€€€€€€€€€€€€€€€€
        ;       €11111111111111111€
        ;       €11111111111111111€
        ;       €2222±±±±±±±±±3333€
        ;       €2222±±±±±±±±±3333€
        ;       €44444444444444444€
        ;       €44444444444444444€
        ;       €€€€€€€€€€€€€€€€€€€

        dec   BYTE PTR DrawOuterArea    ; Lîschen.
        mov   ds, gs:BACKGROUNDADR      ; QUELL-SEG auf Hintergrundseite.

        ; ---- Bereich 1 Zeichnen:
        @DrawArea1:
        cmp   WORD PTR gs:WinYMIN, 0    ; Ist Bereich 1 öberhaupt vorhanden ?
        je    @RAMDrawArea2             ; NEIN, nÑchster Bereich.

        mov   cx, gs:WINYMIN            ; Lese und merke Hîhe des Fensters.
        xor   bp, bp                    ; Merke linke obere Ecke in BP.
        mov   bx, LineSize / 4          ; Lade Breite in Bytes.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 02h                   ; Index des MAP MASK REGISTERS.

       @1_SCROLLRAMCopyBk:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @1_SCROLLRAMCopyBk        ; Wenn noch Zeilen da, weiter.

        ; ---- Bereich 2 Zeichnen:
        @RAMDrawArea2:
        cmp   WORD PTR gs:WinXMIN, 0    ; Ist Bereich 2 öberhaupt vorhanden ?
        je    @RAMDrawArea3             ; NEIN, nÑchster Bereich.

        mov   cx, gs:WinYMAX            ; Lese und merke Hîhe des Fensters.
        sub   cx, gs:WinYMIN            ; Hîhe := WinYMAX - WinYMIN + 1.
        inc   cx                        ; Noch + 1 um Hîhe zu korrigieren.

        mov   di, gs:WinYMIN            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bp, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.

        mov   bx, gs:WinXMIN            ; Lade Breite in Bytes.
        shr   bx, 2                     ; Pixel -> DWORDS.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 02h                   ; Index des MAP MASK REGISTERS.

       @2_SCROLLRAMCopyBk:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @2_SCROLLRAMCopyBk        ; Wenn noch Zeilen da, weiter.

        ; ---- Bereich 3 Zeichnen:
        @RAMDrawArea3:
        cmp   WORD PTR gs:WinXMAX, XMAX ; Ist Bereich 3 öberhaupt vorhanden ?
        je    @RAMDrawArea4             ; NEIN, nÑchster Bereich.

        mov   cx, gs:WinYMAX            ; Lese und merke Hîhe des Fensters.
        sub   cx, gs:WinYMIN            ; Hîhe := WinYMAX - WinYMIN + 1.
        inc   cx                        ; Noch + 1 um Hîhe zu korrigieren.

        mov   di, gs:WinYMIN            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bp, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        mov   dx, gs:WinXMAX            ; Aktuelle X-Koordinate.
        mov   bx, dx                    ; Auch nach BX.
        inc   bx                        ; Noch + 1.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        add   bp, bx                    ; BP := Ofs(X|Y).

        mov   bx, XMAX                  ; Rechter Schirm-Rand.
        sub   bx, dx                    ; Minus rechter Fensterrand = Breite des Bereichs 3.
        shr   bx, 2                     ; Pixel -> DWORDS.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 02h                   ; Index des MAP MASK REGISTERS.

       @3_SCROLLRAMCopyBk:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsb                     ; "REP MOVSD", kopiere DWORDS.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @3_SCROLLRAMCopyBk        ; Wenn noch Zeilen da, weiter.

        ; ---- Bereich 4 Zeichnen:
        @RAMDrawArea4:
        cmp   WORD PTR gs:WinYMAX, YMAX ; Ist Bereich 4 öberhaupt vorhanden ?
        je    @RAMEnd                   ; NEIN, nÑchster Bereich.

        mov   di, gs:WinYMAX            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bp, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.

        mov   cx, YMAX                  ; Unterer Schirmrand.
        sub   cx, gs:WINYMAX            ; Minus unterer Fensterrand.
        inc   cx                        ; + 1 = Hîhe von Bereich 4
        mov   bx, LineSize / 4          ; Lade Breite in Bytes.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 02h                   ; Index des MAP MASK REGISTERS.

       @4_SCROLLRAMCopyBk:
        push  cx                        ; Merke Anzahl Zeilen.

        mov   ah, 01h                   ; AH = $01: Schreibebene 0.
        out   dx, ax                    ; Schreibplane 0 einschalten.
        mov   si, bp                    ; QUELL-OFS.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 2                     ; AH = $02: Schreibebene 1.
        out   dx, ax                    ; Schreibplane 1 einschalten.
        mov   si, 1 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 4                     ; AH = $04: Schreibebene 2.
        out   dx, ax                    ; Schreibplane 2 einschalten.
        mov   si, 2 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        mov   ah, 8                     ; AH = $08: Schreibebene 3.
        out   dx, ax                    ; Schreibplane 3 einschalten.
        mov   si, 3 * 16000             ; QUELL-Zeiger auf Anfang Plane 1-Daten.
        add   si, bp                    ; Und Startwert dazu.
        mov   di, bp                    ; ZIEL-OFS.
        mov   cx, bx                    ; ZÑhler: Bytes in 1 Zeile.
        rep   movsd                     ; "REP MOVSD", kopiere DWORDS.
        add   bp, LineSize              ; Offset um 1 Zeile nach unten.

        pop   cx                        ; ZurÅck: Anzahl Zeilen.
        loop  @4_SCROLLRAMCopyBk        ; Wenn noch Zeilen da, weiter.

        ; ---- Ende Outer RAM:
       @RAMEnd:
        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.

        jmp   @DoNotDrawOutSide         ; Weiter mit innerem Fenster.

        ; ---------- Inneren (Scroll-)Bereich zeichnen: ----------
       @DoNotDrawOutSide:

        ; -- Diverse Variablen errechnen:

        ; LEFTCUT:
        ; Realisiere: "LeftCut := (StartVirtualX-BackX1) And $F":
        mov   ax, StartVirtualX         ; Lese virtuellen X-Start.
        mov   si, ax                    ; Merken fÅr Nummer der li. ob. Kachel errechnen.
        mov   cx, ax                    ; Auch nach CX (fÅr TilesWegLeft).
        mov   bx, ax                    ; Auch nach BX (fÅr RightCut).
        mov   dx, BackX1                ; Lese linke Position des Scrollbildes.
        mov   di, dx                    ; Merken fÅr Nummer der li. ob. Kachel errechnen.
        sub   ax, dx                    ; Ziehe ab: linke Position des Scrollbildes.
        and   ax, 0Fh                   ; Nur wichtig, wieviel Pixel in 0..15.
        mov   LEFTCut, ax               ; Merke Wert.

        ; TILESWEGLEFT:
        ; Realisiere: "(StartVirtualX - BackX1) Shr 4":
        sub   cx, dx                    ; StartVirtualX - BackX1.
        shr   cx, 4                     ; Dies noch / 16.
        mov   TilesWegLEFT, cx          ; Merke Wert.

        ; AKTX
        ; Realisiere: "AktX := WinXMIN-LEFTCut":
        mov   dx, WinXMIN               ; Linken Fensterrand.
        sub   dx, ax                    ; Minus LEFTCut.
        mov   AktX, dx                  ; Merke Wert.

        ; RIGHTCUT:
        ; Realisiere: "RightCut := (-StartVirtualX+BackX2-WinWidth+1) And $F":
        neg   bx                        ; BX := -BX (<=> StartVirtualX).
        add   bx, BackX2                ; Addiere: rechte Position des Scrollbildes.
        mov   dx, WinWidth              ; Lese Fensterbreite.
        sub   bx, dx                    ; Minus Fensterbreite.
        inc   bx                        ; +1 um auszugleichen.
        and   bx, 0Fh                   ; Nur wichtig, wieviel Pixel in 0..15.
        mov   RIGHTCut, bx              ; Merke Wert.

        ; INNERTILESX:
        ; Realisiere: "InnerTilesX := (WinWidth-(-RightCut And $F)-(-LeftCut And $F)) Shr 4":
        neg   ax                        ; LeftCut := -LeftCut.
        and   ax, 0Fh                   ; Maskiere aus bis auf 0..15.
        neg   bx                        ; RightCut := -RightCut;
        and   bx, 0Fh                   ; Maskiere aus bis auf 0..15.
        sub   dx, bx                    ; WinWidth  - (-RightCut And $F).
        sub   dx, ax                    ; Dies noch - (-LeftCut  And $F).
        shr   dx, 4                     ; Dies noch / 16.
        mov   InnerTilesX, dx           ; Merke Wert.

        ; TILESWEGRIGHT:
        ; Realisiere: "TilesWegRight := XTiles-InnerTilesX-TilesWegLeft":
        mov   ax, XTiles                ; Lese Breite in Kacheln.
        sub   ax, dx                    ; Minus InnerTilesX.
        sub   ax, cx                    ; Minus TilesWegLEFT.
        mov   TilesWegRIGHT, ax         ; Merke Wert.

        ; TOPCUT:
        ; Realisiere: "TopCut := (StartVirtualY-BackY1) And $F;
        mov   ax, StartVirtualY         ; Lese virtuellen Y-Start.
        mov   bp, ax                    ; Merken fÅr Nummer der li. ob. Kachel errechnen.
        mov   bx, ax                    ; Auch nach BX.
        mov   dx, BackY1                ; Obere Position des Scrollbildes.
        sub   bp, dx                    ; Ziehe ab: obere Position des Scrollbildes.
        and   bp, 0Fh                   ; Nur wichtig, wieviel Pixel in 0..15.
        mov   TOPCut, bp                ; Merke Wert.

        ; AKTY:
        ; Realisiere: "AktY := WinYMIN - TOPCut":
        mov   cx, WinYMIN               ; Lese oberen Fensterrand.
        sub   cx, bp                    ; Minus TOPCut.
        mov   AktY, cx                  ; Merke Wert.

        ; BOTTOMCUT:
        ; Realisiere: "BottomCut := (-StartVirtualY+BackY2-WinHeight+1) And $F":
        neg   bx                        ; BX := -BX (<=> StartVirtualY).
        add   bx, BackY2                ; Addiere: untere Position des Scrollbildes.
        mov   cx, WinHeight             ; Lese Fensterhîhe.
        sub   bx, cx                    ; Minus Fensterhîhe.
        inc   bx                        ; +1 um auszugleichen.
        and   bx, 0Fh                   ; Nur wichtig, wieviel Pixel in 0..15.
        mov   BOTTOMCut, bx             ; Merke Wert.

        ; INNERTILESY:
        ; Realisiere: "InnerTilesY := (WinHeight-(-BottomCut And $F)-(-TopCut And $F)) Shr 4":
        neg   bp                        ; TopCut := -TopCut.
        and   bp, 0Fh                   ; Maskiere aus bis auf 0..15.
        neg   bx                        ; BottomCut := -BottomCut;
        and   bx, 0Fh                   ; Maskiere aus bis auf 0..15.
        sub   cx, bx                    ; WinHeight  - (-BottomCut And $F).
        sub   cx, bp                    ; Dies noch - (-TopCut  And $F).
        shr   cx, 4                     ; Dies noch / 16.
        mov   InnerTilesY, cx           ; Merke Wert.

        ; Ermittle Nummer der SICHTBAREN LINKEN OBEREN Kachel:
        ; Realisiere: "AktIndex := (((StartVirtualY-BackY1) And $FFF0) Shr 4) * XTiles +
        ;                           ((StartVirtualX-BackX1) And $FFF0) Shr 4":
        sub   si, di                    ; "STARTVIRTUALX - BACKX1".
        and   si, 0FFF0h                ; Maskiere aus bis auf 0..15.
        shr   si, 4                     ; / 4.
        sub   ax, dx                    ; "StartVirtualY - BACKY1".
        and   ax, 0FFF0h                ; Maskiere aus bis auf 0..15.
        shr   ax, 4                     ; / 4.
        mov   bx, XTiles                ; Lese Hoehe in Kacheln.
        mul   bl                        ; AX := AX * BL.
        add   ax, si                    ; Oben errechneten Wert dazu.
        shl   ax, 1                     ; AX mal 2.
        mov   AktIndexMal2, ax          ; Speichern.

        ; Testen, ob Tiles auf SCROLLPAGE im VRAM oder im RAM sind:
        cmp   UseVRAMScroll, 0          ; Im VRAM ? (<> 0 = TRUE).
        je    @ScrollAusRAM             ; NEIN, im RAM.
        jmp   @ScrollAusVRAM            ; JA, im VRAM.

        ; ===== Scroll im RAM: =====
       @ScrollAusRAM:

        ; Testen, ob StartVirtualX auf ein VIELFACHES VON 4 fÑllt, dann
        ; ist es mîglich, WRITEMODUS 1 zu verwenden (Speed ++>> !):
        mov   ax, StartVirtualX         ; Lese virtuellen X-Start.
        and   ax, 3                     ; Ist Vielfaches von 4 (MOD 4 = 0) ?
        jne   @@ScrollUseWriteMode0     ; NEIN, normalen Modus 0.
        jmp   @@ScrollUseWriteMode1     ; JA, Modus 1.

        ; ----- Schreibmodus 0: -----
       @@ScrollUseWriteMode0:           ; Normaler Schreibmodus 0.
        ; <.....>                       ; Tue Etwas !!
        jmp   @ZeichneSprites           ; Weiter bei Sprites-Zeichnen.

        ; ----- Schreibmodus 1: -----
       @@ScrollUseWriteMode1:           ; BenÅtzte Schreibmodus 1.

        ; Einmalig DS auf SCROLLPAGE setzen:
        mov   ds, ScrollPageAdr         ; Setze Datensegment auf Scroll-Page-Segmentadresse.

        ; ***********************************************
        ; **** OBEN *************************************
        ; ***********************************************
       @@ScrollMode1Top:
        cmp   WORD PTR gs:TopCut, 0     ; Oben öberhang vorhanden ?
        je    @@ScrollMode1Middle       ; NEIN, gehe zu MITTE.

        ; ========== LINKE OBERE KACHEL: ==========
       @@ScrollMode1Top_Left:
        cmp   WORD PTR gs:LeftCut, 0    ; Linker öberhang vorhanden ?
        je    @@ScrollMode1Top_Middle   ; NEIN, gehe zu OBEN_MITTE.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   bp, gs:LEFTCut            ; Linker öberhang.
        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   bp, 2                     ; Pixel -> Bytes.  BP = "AddOfsRAM".
        sub   bx, bp                    ; Linker öberhang. BX = Bytes pro Zeile.
        add   si, bp                    ; QUELL-Zeiger um öberhang links erhîhen.

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:TOPCut             ; Oberer öberhang.
        sub   dx, ax                    ; Minus oberer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        push  ax                        ; Merke öberhang OBEN.
        add   si, ax                    ; QUELL-Zeiger um öberhang oben erhîhen.

        ; Ausgeben:

        ; 1. Ebene:
        mov   di, gs:WinOfsXMinYMin     ; Offset der linken oberen Fensterecke.
        push  dx                        ; Anzahl Zeilen.
       @@M1T_LShowLoop1_P1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_LShowLoop1_P1       ; NÑchste Pixelzeile.

        ; 2. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + oberen öberhang.
        mov   di, gs:WinOfsXMinYMin     ; Offset der linken oberen Fensterecke.
        push  dx                        ; Anzahl Zeilen.
       @@M1T_LShowLoop1_P2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_LShowLoop1_P2       ; NÑchste Pixelzeile.

        ; 3. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + diesen öberhang.
        mov   di, gs:WinOfsXMinYMin     ; Offset der linken oberen Fensterecke.
        push  dx                        ; Anzahl Zeilen.
       @@M1T_LShowLoop1_P3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_LShowLoop1_P3       ; NÑchste Pixelzeile.

        ; 4. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   ax                        ; Lese öberhang oben in Bytes.
        add   si, ax                    ; QUELL-Zeiger + diesen öberhang.
        mov   di, gs:WinOfsXMinYMin     ; Offset der linken oberen Fensterecke.
       @@M1T_LShowLoop1_P4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_LShowLoop1_P4       ; NÑchste Pixelzeile.

        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        ; ========== OBERE KACHEL(N): ==========
       @@ScrollMode1Top_Middle:
        cmp   WORD PTR gs:InnerTilesX, 0; Sind innen GANZE Kacheln in X vorhanden ?
        je    @@ScrollMode1Top_Right    ; NEIN, gehe zu OBEN_RECHTS.

        mov   di, gs:WinYMIN            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   di, bx                    ; + X-Koordinate = ENDPOSITION !

        mov   cx, gs:InnerTilesX        ; Anzahl GANZER Kacheln in X.

        ; Gleich AktX neu setzen, auf "AktX := AktX + InnerTilesX * 16":
        mov   ax, gs:AktX               ; Lese aktuelle X-Koordinate.
        mov   bx, ax                    ; Auch nach BX.
        mov   bx, cx                    ; Lese InnerTiles.
        shl   bx, 4                     ; BX := BX * 16.
        add   ax, bx                    ; AktX + InnerTilesX * 16.
        mov   gs:AktX, ax               ; Neue Koordinate setzen.

        mov   bx, gs:TOPCut             ; Oberer öberhang.
        shl   bx, 2                     ; Zeilen -> Bytes.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.

       @@M1T_MLoop:
        push  cx                        ; Rette verbleibende Anzahl Kacheln in X.

        mov   si, fs:[bp]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.
        add   si, bx                    ; QUELL-Zeiger um öberhang oben erhîhen.

        mov   cx, gs:TOPCut             ; Minus oberer öberhang.
        neg   cx                        ; TopCut -> -TopCUT.
        add   cx, 16                    ; + Maximale Hîhe: "CX := 16 - TOPCUT".

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        ; 1. Ebene:
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1T_MShowLoop1_P1:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1T_MShowLoop1_P1       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        ; 2. Ebene:
        add   si, bx                    ; QUELL-Zeiger + oberen öberhang.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1T_MShowLoop1_P2:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1T_MShowLoop1_P2       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        ; 3. Ebene:
        add   si, bx                    ; QUELL-Zeiger + oberen öberhang.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1T_MShowLoop1_P3:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1T_MShowLoop1_P3       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        ; 4. Ebene:
        add   si, bx                    ; QUELL-Zeiger + oberen öberhang.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1T_MShowLoop1_P4:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1T_MShowLoop1_P4       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        add   bp, 2                     ; AktTile-Zeiger auf NéCHSTES Word-Element.
        add   di, 4                     ; Auf Tile rechts daneben.

        pop   cx                        ; Verbleibende Anzahl Kacheln in X lesen.
        loop  @@M1T_MLoop               ; Und weiter.
        mov   gs:AktIndexMal2, bp       ; neuer Kachelindex.

        ; ========== RECHTE OBERE KACHEL: ==========
       @@ScrollMode1Top_Right:
        cmp   WORD PTR gs:RightCut, 0   ; Rechter öberhang vorhanden ?
        je    @@ScrollMode1Top_End      ; NEIN, gehe zu ENDE OBEN.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   di, gs:WinYMIN            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   di, bx                    ; + X-Koordinate = ENDPOSITION !

        mov   bp, gs:RIGHTCut           ; Rechter öberhang.
        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   bp, 2                     ; Pixel -> Bytes.  BP = "AddOfsRAM".
        sub   bx, bp                    ; Linker öberhang. BX = Bytes pro Zeile.

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:TOPCut             ; Oberer öberhang.
        sub   dx, ax                    ; Minus oberer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        push  ax                        ; Merke öberhang OBEN.
        add   si, ax                    ; QUELL-Zeiger um öberhang oben erhîhen.

        ; 1. Ebene:
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1T_RShowLoop1_P1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_RShowLoop1_P1       ; NÑchste Pixelzeile.

        ; 2. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + oberen öberhang.
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1T_RShowLoop1_P2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_RShowLoop1_P2       ; NÑchste Pixelzeile.

        ; 3. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + diesen öberhang.
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1T_RShowLoop1_P3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_RShowLoop1_P3       ; NÑchste Pixelzeile.

        ; 4. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        add   si, ax                    ; QUELL-Zeiger + diesen öberhang.
       @@M1T_RShowLoop1_P4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1T_RShowLoop1_P4       ; NÑchste Pixelzeile.

       @@ScrollMode1Top_End:

        add   WORD PTR gs:AktY, 16      ; Aktuelle Y-Koordinate + 1 Tile.
        mov   ax, gs:WinXMIN            ; Linker Fensterrand lesen.
        mov   bx, gs:LeftCut            ; Lese linken öberhang.
        sub   ax, bx                    ; Minus linker öberhang.
        mov   gs:AktX, ax               ; Neue X-Koordinate.

        mov   bl, gs:[bx + OFFSET HelpTab] ; BX := HelpTab[LEFTCUT].
        xor   bh, bh                    ; BH immer 0.
        mov   ax, gs:AktIndexMal2       ; Aktueller Kachelindex.
        shr   ax, 1                     ; Div 2 fÅr Index.
        add   ax, gs:TilesWegRight      ; Kacheln, die rechts echt weg sind.
        add   ax, gs:TilesWegLeft       ; Kacheln, die links echt weg sind.
        sub   ax, bx                    ; Minus HelpTab[LEFTCUT].
        shl   ax, 1                     ; Mal 2 fÅr Index.
        mov   gs:AktIndexMal2, ax       ; Aktueller Kachelindex.

        ; ***********************************************
        ; **** MITTE ************************************
        ; ***********************************************
       @@ScrollMode1Middle:
        cmp   WORD PTR gs:InnerTilesY, 0; Sind innen GANZE Kacheln in Y vorhanden ?
        je    @@ScrollMode1Bottom       ; NEIN, gehe zu OBEN_RECHTS.

        mov   cx, gs:InnerTilesY        ; Anzahl GANZER Kacheln in Y.
       @@M1M_Loop:
        push  cx                        ; Rette verbleibende Anzahl Kacheln in Y.

        ; ========== LINKE KACHEL: ==========
       @@ScrollMode1Middle_Left:
        cmp   WORD PTR gs:LeftCut, 0    ; Linker öberhang vorhanden ?
        je    @@ScrollMode1Middle_Middle; NEIN, gehe zu MITTE_MITTE.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr] ; Offset-Adresse der akt. Zeile.
        mov   bx, gs:WinXMIN            ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        add   di, bx                    ; + X-Koordinate.

        mov   bp, gs:LEFTCut            ; Linker öberhang.
        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   bp, 2                     ; Pixel -> Bytes.  BP = "AddOfsRAM".
        sub   bx, bp                    ; Linker öberhang. BX = Bytes pro Zeile.
        add   si, bp                    ; QUELL-Zeiger um öberhang links erhîhen.

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        ; 1. Ebene:
        mov   ax, di                    ; Speicher ZIEL-Ofs.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        ; 2. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; Speicher ZIEL-Ofs.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        ; 3. Ebene:
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; Speicher ZIEL-Ofs.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        ; 4. Ebene:
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.

        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        ; ========== INNERE KACHEL(N): ==========
       @@ScrollMode1Middle_Middle:
        cmp   WORD PTR gs:InnerTilesX, 0; Sind innen GANZE Kacheln in X vorhanden ?
        je    @@ScrollMode1Middle_Right ; NEIN, gehe zu MITTE_RECHTS.

        ; ZIEL-Ofs berechnen:
        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr] ; Offset-Adresse der akt. Zeile.
        mov   bx, gs:AktX               ; Lese aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        add   di, bx                    ; AX += X-Koordinate = ENDPOSITION !

        mov   cx, gs:InnerTilesX        ; Anzahl GANZER Kacheln in X.

        ; Gleich AktX neu setzen, auf "AktX := AktX + InnerTilesX * 16":
        mov   ax, gs:AktX               ; Lese aktuelle X-Koordinate.
        mov   bx, ax                    ; Auch nach BX.
        mov   bx, cx                    ; Lese InnerTiles.
        shl   bx, 4                     ; BX := BX * 16.
        add   ax, bx                    ; AktX + InnerTilesX * 16.
        mov   gs:AktX, ax               ; Neue Koordinate setzen.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.

        mov   al, 02h                   ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, al                    ; Register ansprechen.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER

       @@M1M_MLoop:
        mov   si, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; 1. Ebene:
        mov   al, 01h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; Rette ZIEL-Ofs.

        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        ; 2. Ebene:
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; Rette ZIEL-Ofs.

        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        ; 3. Ebene:
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; Rette ZIEL-Ofs.

        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        ; 4. Ebene:
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; Rette ZIEL-Ofs.

        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.

        mov   di, ax                    ; ZIEL-Ofs zurÅck.

        add   bp, 2                     ; AktTile-Zeiger auf NéCHSTES Word-Element.
        add   di, 4                     ; Auf Tile rechts daneben.

        dec   cx                        ; Anzahl - 1.
        jz    @@M1M_MLoopEnd            ; Bei 0, Fertig.
        jmp   @@M1M_MLoop               ; Sonst weiter.
       @@M1M_MLoopEnd:
        mov   gs:AktIndexMal2, bp       ; Setze neuen AktIndex.

        ; ========== RECHTE KACHEL: ==========
       @@ScrollMode1Middle_Right:
        cmp   WORD PTR gs:RightCut, 0   ; Rechter öberhang vorhanden ?
        je    @@ScrollMode1Middle_End   ; NEIN, gehe zu ENDE MITTE.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr] ; Offset-Adresse der akt. Zeile.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        add   di, bx                    ; + X-Koordinate = ENDPOSITION !

        mov   bp, gs:RIGHTCut           ; Rechter öberhang.
        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   bp, 2                     ; Pixel -> Bytes.  BP = "AddOfsRAM".
        sub   bx, bp                    ; Linker öberhang. BX = Bytes pro Zeile.

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        ; 1. Ebene:
        mov   ax, di                    ; ZIEL-Ofs.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.

        mov   di, ax                    ; ZIEL-Ofs.

        ; 2. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; ZIEL-Ofs.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.

        mov   di, ax                    ; ZIEL-Ofs.

        ; 3. Ebene:
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, di                    ; ZIEL-Ofs.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.

        mov   di, ax                    ; ZIEL-Ofs.

        ; 4. Ebene:
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.

        ; 1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 5:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 6:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 7:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 8:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 9:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 10:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 11:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 12:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 13:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 14:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 15:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.
        ; 16:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + rechter öberhang fÅr nÑchste Zeile.

       @@ScrollMode1Middle_End:
        add   WORD PTR gs:AktY, 16      ; Aktuelle Y-Koordinate + 1 Tile.
        mov   ax, gs:WinXMIN            ; Linker Fensterrand lesen.
        mov   bx, gs:LeftCut            ; Lese linken öberhang.
        sub   ax, bx                    ; Minus linker öberhang.
        mov   gs:AktX, ax               ; Neue X-Koordinate.

        mov   bl, gs:[bx + OFFSET HelpTab] ; BX := HelpTab[LEFTCUT].
        xor   bh, bh                    ; BH immer 0.
        mov   ax, gs:AktIndexMal2       ; Aktueller Kachelindex.
        shr   ax, 1                     ; In realen Wert.
        add   ax, gs:TilesWegRight      ; Kacheln, die rechts echt weg sind.
        add   ax, gs:TilesWegLeft       ; Kacheln, die links echt weg sind.
        sub   ax, bx                    ; Minus HelpTab[LEFTCUT].
        shl   ax, 1                     ; * 2 => In Wert zum direkten adressieren.
        mov   gs:AktIndexMal2, ax       ; Aktueller Kachelindex.

        pop   cx                        ; Verbleibende Anzahl Kacheln in Y lesen.
        dec   cx                        ; Anzahl Kacheln in Y -1.
        jz    @@ScrollMode1Bottom       ; Wenn =0, fertig.
        jmp   @@M1M_Loop                ; <>0, weiter.

        ; ***********************************************
        ; **** UNTEN ************************************
        ; ***********************************************
       @@ScrollMode1Bottom:
        cmp   WORD PTR gs:BottomCut, 0  ; Rechter öberhang vorhanden ?
        je    @@ScrollMode1End          ; NEIN, gehe zu ENDE.

        ; ========== LINKE UNTERE KACHEL: ==========
       @@ScrollMode1Bottom_Left:
        cmp   WORD PTR gs:LeftCut, 0    ; Linker öberhang vorhanden ?
        je    @@ScrollMode1Bottom_Middle; NEIN, gehe zu UNTEN_MITTE.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr] ; Offset-Adresse der akt. Zeile.
        mov   bx, gs:WinXMIN            ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        add   di, bx                    ; + X-Koordinate = ENDPOSITION !

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   bp, gs:LEFTCut            ; Linker öberhang.
        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   bp, 2                     ; Pixel -> Bytes.  BP = "AddOfsRAM".
        sub   bx, bp                    ; Linker öberhang. BX = Bytes pro Zeile.
        add   si, bp                    ; QUELL-Zeiger um öberhang links erhîhen.

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:BOTTOMCut          ; Oberer unten.
        sub   dx, ax                    ; Minus oberer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        push  ax                        ; Merke öberhang UNTEN.

        ; 1. Ebene:
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1B_LShowLoop1_P1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_LShowLoop1_P1       ; NÑchste Pixelzeile.

        ; 2. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + unteren öberhang.
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1B_LShowLoop1_P2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_LShowLoop1_P2       ; NÑchste Pixelzeile.

        ; 3. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + unteren öberhang.
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1B_LShowLoop1_P3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_LShowLoop1_P3       ; NÑchste Pixelzeile.

        ; 4. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        add   si, ax                    ; QUELL-Zeiger + unteren öberhang.
       @@M1B_LShowLoop1_P4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_LShowLoop1_P4       ; NÑchste Pixelzeile.

        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        ; ========== UNTERE KACHEL(N): ==========
       @@ScrollMode1Bottom_Middle:
        cmp   WORD PTR gs:InnerTilesX, 0; Sind innen GANZE Kacheln in X vorhanden ?
        je    @@ScrollMode1Bottom_Right ; NEIN, gehe zu UNTEN_RECHTS.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   di, bx                    ; + X-Koordinate = ENDPOSITION !

        mov   cx, gs:InnerTilesX        ; Anzahl GANZER Kacheln in X.

        ; Gleich AktX neu setzen, auf "AktX := AktX + InnerTilesX * 16":
        mov   ax, gs:AktX               ; Lese aktuelle X-Koordinate.
        mov   bx, ax                    ; Auch nach BX.
        mov   bx, cx                    ; Lese InnerTiles.
        shl   bx, 4                     ; BX := BX * 16.
        add   ax, bx                    ; AktX + InnerTilesX * 16.
        mov   gs:AktX, ax               ; Neue Koordinate setzen.

        mov   bx, gs:BOTTOMCut          ; Oberer öberhang.
        shl   bx, 2                     ; Zeilen -> Bytes.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.

       @@M1B_MLoop:
        push  cx                        ; Rette verbleibende Anzahl Kacheln in X.

        mov   si, fs:[bp]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   cx, gs:BOTTOMCut          ; Minus oberer öberhang.
        neg   cx                        ; TopCut -> -TopCUT.
        add   cx, 16                    ; + Maximale Hîhe: "CX := 16 - TOPCUT".

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        ; 1. Ebene:
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1B_MShowLoop1_P1:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1B_MShowLoop1_P1       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        ; 2. Ebene:
        add   si, bx                    ; QUELL-Zeiger + oberen öberhang.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1B_MShowLoop1_P2:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1B_MShowLoop1_P2       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        ; 3. Ebene:
        add   si, bx                    ; QUELL-Zeiger + oberen öberhang.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1B_MShowLoop1_P3:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1B_MShowLoop1_P3       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        ; 4. Ebene:
        add   si, bx                    ; QUELL-Zeiger + oberen öberhang.
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        mov   ax, cx                    ; Rette Anzahl Zeilen.
        mov   dx, di                    ; Rette ZIEL-Ofs.
       @@M1B_MShowLoop1_P4:
        movsd                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; + 1 Zeile - Bytes pro Zeile.
        loop  @@M1B_MShowLoop1_P4       ; NÑchste Pixelzeile.
        mov   di, dx                    ; ZIEL-Ofs zurÅck.
        mov   cx, ax                    ; Anzahl Zeilen zurÅck.

        add   bp, 2                     ; AktTile-Zeiger auf NéCHSTES Word-Element.
        add   di, 4                     ; Auf Tile rechts daneben.

        pop   cx                        ; Verbleibende Anzahl Kacheln in X lesen.
        loop  @@M1B_MLoop               ; Und weiter.
        mov   gs:AktIndexMal2, bp       ; neuer Kachelindex.

        ; ========== RECHTE UNTERE KACHEL: ==========
       @@ScrollMode1Bottom_Right:
        cmp   WORD PTR gs:RightCut, 0   ; Rechter öberhang vorhanden ?
        je    @@ScrollMode1Bottom_End   ; NEIN, gehe zu ENDE UNTEN.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; FS = Seg von BACKTILEMAL64: Lese Nummer dieser Kachel.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   di, bx                    ; + X-Koordinate = ENDPOSITION !

        mov   bp, gs:RIGHTCut           ; Rechter öberhang.
        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   bp, 2                     ; Pixel -> Bytes.  BP = "AddOfsRAM".
        sub   bx, bp                    ; Linker öberhang. BX = Bytes pro Zeile.

        mov   ax, 0102h                 ; Index des MAP MASK REGISTERS, Ebene 0.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER
        out   dx, ax                    ; Register ansprechen.

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:BOTTOMCut          ; Unterer öberhang.
        sub   dx, ax                    ; Minus unterer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        push  ax                        ; Merke öberhang UNTEN.

        ; 1. Ebene:
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1B_RShowLoop1_P1:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_RShowLoop1_P1       ; NÑchste Pixelzeile.

        ; 2. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 02h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + oberen öberhang.
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1B_RShowLoop1_P2:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_RShowLoop1_P2       ; NÑchste Pixelzeile.

        ; 3. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 04h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        push  ax                        ; Speichere öberhang oben.
        add   si, ax                    ; QUELL-Zeiger + diesen öberhang.
        push  di                        ; ZIEL-Ofs.
        push  dx                        ; Anzahl Zeilen.
       @@M1B_RShowLoop1_P3:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_RShowLoop1_P3       ; NÑchste Pixelzeile.

        ; 4. Ebene:
        mov   dx, 3C5h                  ; Index der SEQUENCER REGISTER
        mov   al, 08h                   ; Schreibebene.
        out   dx, al                    ; Ebene einschalten.
        pop   dx                        ; Anzahl Zeilen.
        pop   di                        ; ZIEL-Ofs.
        pop   ax                        ; Lese öberhang oben in Bytes.
        add   si, ax                    ; QUELL-Zeiger + diesen öberhang.
       @@M1B_RShowLoop1_P4:
        mov   cx, bx                    ; Wiederholungen pro Zeile
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize              ; + 1 Zeile.
        sub   di, bx                    ; - Bytes pro Zeile.
        add   si, bp                    ; + linker öberhang fÅr nÑchste Zeile.
        dec   dx                        ; Zeilenzahl - 1.
        jnz   @@M1B_RShowLoop1_P4       ; NÑchste Pixelzeile.

       @@ScrollMode1Bottom_End:

       @@ScrollMode1End:
        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.
        jmp   @ZeichneSprites           ; Ende kopieren aus RAM.

        ; ===== Scroll im VRAM: =====
       @ScrollAusVRAM:

        ; Testen, ob StartVirtualX auf ein VIELFACHES VON 4 fÑllt, dann
        ; ist es mîglich, WRITEMODUS 1 zu verwenden (Speed ++>> !):
        mov   ax, StartVirtualX         ; Lese virtuellen X-Start.
        and   ax, 3                     ; Ist Vielfaches von 4 (MOD 4 = 0) ?
        jne   @ScrollUseWriteMode0      ; NEIN, normalen Modus 0.
        jmp   @ScrollUseWriteMode1      ; JA, Modus 1.

        ; ----- Schreibmodus 0: -----
       @ScrollUseWriteMode0:            ; Normaler Schreibmodus 0.
        ; <......>                      ; Tu etwas !!!
        jmp   @ZeichneSprites           ; Weiter bei Sprites-Zeichnen.

        ; ----- Schreibmodus 1: -----
       @ScrollUseWriteMode1:            ; BenÅtzte Schreibmodus 1.

        ; Einmalig DS auf SCROLLPAGE setzen:
        mov   ds, ScrollPageAdr         ; Setze Datensegment auf Scroll-Page-Segmentadresse.

        ; Einmalig WriteMode 1 und Lesemode einstellen:
        mov   ax, 4105h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $41: Schreibmodus 1 einschalten.
        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        out   dx, ax                    ; Register ansprechen.
        mov   ax, 0F02h                 ; AL = $02: Index des MAP MASK REGISTERS.
                                        ; AH = $FF: Alle Ebenen zum Schreiben an.
        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        out   dx, ax                    ; Register ansprechen.

        ; ***********************************************
        ; **** OBEN *************************************
        ; ***********************************************
       @ScrollMode1Top:
        cmp   WORD PTR gs:TopCut, 0     ; Oben öberhang vorhanden ?
        je    @ScrollMode1Middle        ; NEIN, gehe zu MITTE.

        ; ========== LINKE OBERE KACHEL: ==========
       @ScrollMode1Top_Left:
        cmp   WORD PTR gs:LeftCut, 0    ; Linker öberhang vorhanden ?
        je    @ScrollMode1Top_Middle    ; NEIN, gehe zu OBEN_MITTE.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:TOPCut             ; Oberer öberhang.
        sub   dx, ax                    ; Minus oberer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        add   si, ax                    ; QUELL-Zeiger um öberhang oben erhîhen.

        mov   di, gs:WinOfsXMinYMin     ; Offset der linken oberen Fensterecke.
        mov   ax, gs:LEFTCut            ; Linker öberhang.
        mov   cx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   ax, 2                     ; Pixel -> Bytes.  AX = "AddOfsRAM".
        sub   cx, ax                    ; Linker öberhang. CX = Bytes pro Zeile.
        mov   bx, cx                    ; Merke Bytes pro Zeile.

       @M1T_LShowLoop1:
        mov   bp, si                    ; QUELL-Zeiger lesen.
        add   bp, ax                    ; + Linker öberhang.
        xchg  bp, si                    ; Tauschen.
        mov   cx, bx                    ; Bytes pro Zeile.
        push  di                        ; Rette DI.

        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.

        pop   di                        ; DI zurÅck.
        mov   si, bp                    ; Gemerktes zurÅck.
        add   si, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   di, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        dec   dx                        ; ZeilenzÑhler - 1.
        jnz   @M1T_LShowLoop1           ; NÑchste Pixelzeile.

        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        ; ========== OBERE KACHEL(N): ==========
       @ScrollMode1Top_Middle:
        mov   cx, gs:InnerTilesX        ; Anzahl GANZER Kacheln in X.
        or    cx, cx                    ; Sind innen GANZE Kacheln in X vorhanden ?
        je    @ScrollMode1Top_Right     ; NEIN, gehe zu OBEN_RECHTS.

        mov   di, gs:WinYMIN            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   dx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   dx, bx                    ; AX += X-Koordinate = ENDPOSITION !

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.

       @M1T_MLoop:
        push  cx                        ; Rette verbleibende Anzahl Kacheln in X.

        mov   si, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   cx, 16                    ; Maximale Hîhe.
        mov   ax, gs:TOPCut             ; Oberer öberhang.
        sub   cx, ax                    ; Minus oberer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        add   si, ax                    ; QUELL-Zeiger um öberhang oben erhîhen.
        mov   di, dx                    ; ZIEL-Zeiger lesen.

       @M1T_MShowLoop1:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.

        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        loop  @M1T_MShowLoop1           ; NÑchste Pixelzeile.

        add   bp, 2                     ; AktTile-Zeiger auf NéCHSTES Word-Element.
        add   dx, 4                     ; ZIEL-Zeiger auf Kachel rechts daneben.
        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        pop   cx                        ; Verbleibende Anzahl Kacheln in X lesen.
        loop  @M1T_MLoop                ; Und weiter.

        ; ========== RECHTE OBERE KACHEL: ==========
       @ScrollMode1Top_Right:
        cmp   WORD PTR gs:RightCut, 0   ; Rechter öberhang vorhanden ?
        je    @ScrollMode1Top_End       ; NEIN, gehe zu ENDE OBEN.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   bp, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:TOPCut             ; Oberer öberhang.
        sub   dx, ax                    ; Minus oberer öberhang.
        shl   ax, 2                     ; Zeilen -> Bytes.
        add   bp, ax                    ; QUELL-Zeiger um öberhang oben erhîhen.

        mov   di, gs:WinYMIN            ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   ax, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   ax, bx                    ; AX += X-Koordinate = ENDPOSITION !

        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        mov   si, gs:RightCut           ; Rechter öberhang in Pixeln.
        shr   si, 2                     ; Pixel -> Bytes.
        sub   bx, si                    ; "BX := 4 - RightCut Shr 2".

       @M1T_RShowLoop1:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.

        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.

        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        dec   dx                        ; ZeilenzÑhler - 1.
        jnz   @M1T_RShowLoop1           ; NÑchste Pixelzeile.

       @ScrollMode1Top_End:

        add   WORD PTR gs:AktY, 16      ; Aktuelle Y-Koordinate + 1 Tile.
        mov   ax, gs:WinXMIN            ; Linker Fensterrand lesen.
        mov   bx, gs:LeftCut            ; Lese linken öberhang.
        sub   ax, bx                    ; Minus linker öberhang.
        mov   gs:AktX, ax               ; Neue X-Koordinate.

        mov   bl, gs:[bx + OFFSET HelpTab] ; BX := HelpTab[LEFTCUT].
        xor   bh, bh                    ; BH immer 0.
        mov   ax, gs:AktIndexMal2       ; Aktueller Kachelindex.
        shr   ax, 1                     ; Div 2 fÅr Index.
        add   ax, gs:TilesWegRight      ; Kacheln, die rechts echt weg sind.
        add   ax, gs:TilesWegLeft       ; Kacheln, die links echt weg sind.
        sub   ax, bx                    ; Minus HelpTab[LEFTCUT].
        shl   ax, 1                     ; Mal 2 fÅr Index.
        mov   gs:AktIndexMal2, ax       ; Aktueller Kachelindex.

        ; ***********************************************
        ; **** MITTE ************************************
        ; ***********************************************
       @ScrollMode1Middle:
        mov   cx, gs:InnerTilesY        ; Anzahl GANZER Kacheln in Y.
        or    cx, cx                    ; Sind innen GANZE Kacheln in Y vorhanden ?
        je    @ScrollMode1Bottom        ; NEIN, gehe zu OBEN_RECHTS.

       @M1M_Loop:
        push  cx                        ; Rette verbleibende Anzahl Kacheln in Y.

        ; ========== LINKE KACHEL: ==========
       @ScrollMode1Middle_Left:
        cmp   WORD PTR gs:LeftCut, 0    ; Linker öberhang vorhanden ?
        je    @ScrollMode1Middle_Middle ; NEIN, gehe zu MITTE_MITTE.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   bp, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:WinXMIN            ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   dx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   dx, bx                    ; DX += X-Koordinate = ENDPOSITION !

        mov   ax, gs:LEFTCut            ; Linker öberhang.
        mov   cx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   ax, 2                     ; Pixel -> Bytes.  AX = "AddOfsRAM".
        sub   cx, ax                    ; Linker öberhang. CX = Bytes pro Zeile.
        mov   bx, cx                    ; Merke Bytes pro Zeile.

        ; 16 mal wiederholen, ist schneller als LOOP:
        ; 1:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 2:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 3:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 4:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 5:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 6:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 7:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 8:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 9:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 10:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 11:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 12:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 13:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 14:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 15:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 16:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        add   si, ax                    ; + Linker öberhang.
        mov   cx, bx                    ; Bytes pro Zeile.
        mov   di, dx                    ; ZIEL-Zeiger.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   dx, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        ; ========== INNERE KACHEL(N): ==========
       @ScrollMode1Middle_Middle:
        mov   cx, gs:InnerTilesX        ; Anzahl GANZER Kacheln in X.
        or    cx, cx                    ; Sind innen GANZE Kacheln in X vorhanden ?
        je    @ScrollMode1Middle_Right  ; NEIN, gehe zu MITTE_RECHTS.

        ; ZIEL-Ofs berechnen:
        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   dx, gs:AktX               ; Lese aktuelle X-Koordinate.
        mov   bx, dx                    ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   di, bx                    ; AX += X-Koordinate = ENDPOSITION !

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.

       @M1M_MLoop:
        mov   si, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        ; 16 mal wiederholen, ist schneller als LOOP:
        ; 1:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 2:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 3:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 4:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 5:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 6:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 7:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 8:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 9:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 10:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 11:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 12:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 13:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 14:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 15:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 16:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.

        add   dx, 16                    ; Aktuelle X-Koordinate + 1 Tile.

        sub   di, 15 * LineSize         ; ZIEL-Ofs auf Kachel rechts daneben.
        add   bp, 2                     ; AktTile-Zeiger auf NéCHSTES Word-Element.

        dec   cx                        ; Anzahl - 1.
        jz    @M1M_MLoopEnd             ; Bei 0, Fertig.
        jmp   @M1M_MLoop                ; Sonst weiter.
       @M1M_MLoopEnd:
        mov   gs:AktX, dx               ; Neue X-Koordinate setzen.
        mov   gs:AktIndexMal2, bp       ; Setze neuen AktIndex.

        ; ========== RECHTE KACHEL: ==========
       @ScrollMode1Middle_Right:
        cmp   WORD PTR gs:RightCut, 0   ; Rechter öberhang vorhanden ?
        je    @ScrollMode1Middle_End    ; NEIN, gehe zu ENDE MITTE.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   bp, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   ax, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   ax, bx                    ; AX += X-Koordinate = ENDPOSITION !

        mov   bx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        mov   si, gs:RightCut           ; Rechter öberhang in Pixeln.
        shr   si, 2                     ; Pixel -> Bytes.
        sub   bx, si                    ; "BX := 4 - RightCut Shr 2".

        ; 16 mal wiederholen, ist schneller als LOOP:
        ; 1:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 2:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 3:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 4:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 5:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 6:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 7:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 8:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 9:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 10:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 11:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 12:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 13:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 14:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 15:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        ; 16:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.
        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.
        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

       @ScrollMode1Middle_End:
        add   WORD PTR gs:AktY, 16      ; Aktuelle Y-Koordinate + 1 Tile.
        mov   ax, gs:WinXMIN            ; Linker Fensterrand lesen.
        mov   bx, gs:LeftCut            ; Lese linken öberhang.
        sub   ax, bx                    ; Minus linker öberhang.
        mov   gs:AktX, ax               ; Neue X-Koordinate.

        mov   bl, gs:[bx + OFFSET HelpTab] ; BX := HelpTab[LEFTCUT].
        xor   bh, bh                    ; BH immer 0.
        mov   ax, gs:AktIndexMal2       ; Aktueller Kachelindex.
        shr   ax, 1                     ; Zum berechnen DIV 2.
        add   ax, gs:TilesWegRight      ; Kacheln, die rechts echt weg sind.
        add   ax, gs:TilesWegLeft       ; Kacheln, die links echt weg sind.
        sub   ax, bx                    ; Minus HelpTab[LEFTCUT].
        shl   ax, 1                     ; Wieder mal 2 fÅr AktIndexMal2.
        mov   gs:AktIndexMal2, ax       ; Aktueller Kachelindex.

        pop   cx                        ; Verbleibende Anzahl Kacheln in Y lesen.
        dec   cx                        ; Anzahl Kacheln in Y -1.
        jz    @ScrollMode1Bottom        ; Wenn =0, fertig.
        jmp   @M1M_Loop                 ; <>0, weiter.

        ; ***********************************************
        ; **** UNTEN ************************************
        ; ***********************************************
       @ScrollMode1Bottom:
        cmp   WORD PTR gs:BottomCut, 0  ; Rechter öberhang vorhanden ?
        je    @ScrollMode1End           ; NEIN, gehe zu ENDE.

        ; ========== LINKE UNTERE KACHEL: ==========
       @ScrollMode1Bottom_Left:
        cmp   WORD PTR gs:LeftCut, 0    ; Linker öberhang vorhanden ?
        je    @ScrollMode1Bottom_Middle ; NEIN, gehe zu UNTEN_MITTE.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:BOTTOMCut          ; Unterer öberhang.
        sub   dx, ax                    ; Minus unterer öberhang.

        mov   ax, gs:LEFTCut            ; Linker öberhang.
        mov   cx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   ax, 2                     ; Pixel -> Bytes.  AX = "AddOfsRAM".
        sub   cx, ax                    ; Linker öberhang. CX = Bytes pro Zeile.
        mov   bx, cx                    ; Merke Bytes pro Zeile.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   cx, gs:WinXMIN            ; Aktuelle X-Koordinate.
        shr   cx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   di, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   di, cx                    ; AX += X-Koordinate = ENDPOSITION !

       @M1B_LShowLoop1:
        mov   bp, si                    ; QUELL-Zeiger lesen.
        add   bp, ax                    ; + Linker öberhang.
        xchg  bp, si                    ; Tauschen.
        mov   cx, bx                    ; Bytes pro Zeile.
        push  di                        ; Rette DI.

        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.

        pop   di                        ; DI zurÅck.
        mov   si, bp                    ; Gemerktes zurÅck.
        add   si, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   di, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        dec   dx                        ; ZeilenzÑhler - 1.
        jnz   @M1B_LShowLoop1           ; NÑchste Pixelzeile.

        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        ; ========== UNTERE KACHEL(N): ==========
       @ScrollMode1Bottom_Middle:
        mov   cx, gs:InnerTilesX        ; Anzahl GANZER Kacheln in X.
        or    cx, cx                    ; Sind innen GANZE Kacheln in X vorhanden ?
        je    @ScrollMode1Bottom_Right  ; NEIN, gehe zu UNTEN_RECHTS.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   bx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   dx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   dx, bx                    ; DX += X-Koordinate = ENDPOSITION !

       @M1B_MLoop:
        push  cx                        ; Rette verbleibende Anzahl Kacheln in X.

        mov   si, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   si, fs:[si]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   cx, 16                    ; Maximale Hîhe.
        sub   cx, gs:BOTTOMCut          ; Minus unterer öberhang.
        mov   di, dx                    ; ZIEL-Zeiger lesen.

       @M1B_MShowLoop1:
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.
        movsb                           ; Kopiere von DS:SI nach ES:DI.

        add   di, LineSize - 4          ; ZIEL auf nÑchste Pixelzeile darunter.

        loop  @M1B_MShowLoop1           ; NÑchste Pixelzeile.

        add   dx, 4                     ; ZIEL-Zeiger auf Kachel rechts daneben.
        add   WORD PTR gs:AktX, 16      ; Aktuelle X-Koordinate + 1 Tile.
        add   WORD PTR gs:AktIndexMal2,2; Kachelindex auf nÑchste Kachel.

        pop   cx                        ; Verbleibende Anzahl Kacheln in X lesen.
        loop  @M1B_MLoop                ; Und weiter.

        ; ========== RECHTE UNTERE KACHEL: ==========
       @ScrollMode1Bottom_Right:
        cmp   WORD PTR gs:RightCut, 0   ; Rechter öberhang vorhanden ?
        je    @ScrollMode1Bottom_End    ; NEIN, gehe zu ENDE UNTEN.

        mov   bp, gs:AktIndexMal2       ; Aktueller Kachelindex lesen.
        mov   bp, fs:[bp]               ; Lese Nummer dieser Kachel.

        ; --- Ausgeben:

        mov   dx, 16                    ; Maximale Hîhe.
        mov   ax, gs:BOTTOMCut          ; Unterer öberhang.
        sub   dx, ax                    ; Minus unterer öberhang.

        ; CX := 4 - (RightCut Shr 2) <=> (16 - RightCut) Shr 2:
        mov   ax, gs:RightCut           ; Linker öberhang.
        mov   cx, 4                     ; Maximale Anzahl Bytes pro Zeile.
        shr   ax, 2                     ; Pixel -> Bytes.  AX = "AddOfsRAM".
        sub   cx, ax                    ; Linker öberhang. CX = Bytes pro Zeile.
        mov   bx, cx                    ; Merke Bytes pro Zeile.

        mov   di, gs:AktY               ; Aktuelle Y-Koordinate.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   cx, gs:AktX               ; Aktuelle X-Koordinate.
        shr   cx, 2                     ; X-Koordinate: Pixel -> Bytes.
        mov   ax, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   ax, cx                    ; AX += X-Koordinate = ENDPOSITION !

       @M1B_RShowLoop1:
        mov   si, bp                    ; QUELL-Zeiger lesen.
        mov   di, ax                    ; ZIEL-Zeiger lesen.
        mov   cx, bx                    ; Bytes pro Zeile.

        rep   movsb                     ; Kopiere von DS:SI nach ES:DI.

        add   bp, 4                     ; QUELL-Zeiger auf nÑchste Zeile.
        add   ax, LineSize              ; ZIEL auf nÑchste Pixelzeile darunter.

        dec   dx                        ; ZeilenzÑhler - 1.
        jnz   @M1B_RShowLoop1           ; NÑchste Pixelzeile.

       @ScrollMode1Bottom_End:

       @ScrollMode1End:
        mov   ax, SEG Data              ; Original Datensegment lesen.
        mov   ds, ax                    ; Original Datensegment setzen.

        ; Am Ende wieder WriteMode 0 einstellen:
        mov   ax, 4005h                 ; AL = $05: Index des MODE REGISTERS,
                                        ; AH = $40: Schreibmodus 0 einschalten.
        mov   dx, 3CEh                  ; Index der GRAPHIC CONTROLLER REGISTER.
        out   dx, ax                    ; Register ansprechen.

        ; ============================================================
        ;  SPRITES ZEICHNEN:
        ; ============================================================
       @ZeichneSprites:

        ; Testen, ob Sprite-X-Koordinate ein vielfaches von 4 ist:
        cmp   BYTE PTR SpritesXMod4, 0  ; Ist es vielfaches von 4 ? (0 = NEIN)
        je    @ZeichneSpritesNormal     ; JA.
        jmp   @ZeichneSpritesMOD4       ; NEIN.

        ; ------------------------------------------------
        ; ==== Koordinate ist NICHT vielfaches von 4: ====
        ; ------------------------------------------------
       @ZeichneSpritesNormal:
        mov   si, NMAX * 2              ; SI auf HôCHSTE Nummer in SPRITEN[..].

       @Zeichne:                        ; Ein Sprite zeichenen.
        mov   bx, [si + OFFSET SpriteN] ; BX = SpriteN[..] = Spriteladenummer.
        shl   bx, 1                     ; BX = Spriteladenummer * 2.

        ; Jetzt: "SpriteN[..] := SpriteN[NextSprite[..]]" berechnen:
        mov   bx, [bx + OFFSET NextSprite]
                                        ; BX = NextSprite[SpriteN[?]].
        mov   [si + OFFSET SpriteN], bx ; als neue SpriteN[?] Åbernehmen.
        shl   bx, 1                     ; BX := BX * 2. FÅr ARRAY-Adressierung.

        jnz   @Aktiv                    ; Sprite vorhanden.
        jmp   @NoSprite                 ; Kein Sprite vorhanden.

       @Aktiv:                          ; Sprite vorhanden.

        cmp   si, SplitIndex_Mal2       ; Ist SplitPunkt.
        jae   @NoClipToWin              ; JA, nicht mehr auf WIN* clippen.
        jmp   @ClipToWin                ; NEIN, auf WIN* clippen.

        ; ----- NICHT auf auf WIN* clippen: -----
       @NoClipToWin:
        push  si                        ; Spritepositionsnummer * 2 retten.

        mov   dx, [si + OFFSET SpriteX] ; Aktuelle X-Koordinate lesen.
        sub   dx, StartVirtualX         ; Virtuelle -> Absolute Koordinaten.
        mov   di, [si + OFFSET SpriteY] ; Aktuelle Y-Koordinate lesen.
        sub   di, StartVirtualY         ; Virtuelle -> Absolute Koordinaten.

        mov   cx, XMAX                  ; Rechte Begrenzung.
        cmp   dx, cx                    ; RECHTS AU·ERHALB ?
        jg    @@ToSpriteFertig          ; JA, Ende.

        mov   bp, YMAX                  ; Untere Begrenzung.
        cmp   di, bp                    ; UNTEN AU·ERHALB ?
        jg    @@ToSpriteFertig          ; JA, Ende.

        xor   ax, ax                    ; Linke Begrenzung.
        xor   si, si                    ; Obere Begrenzung.

        ; ------ Ab hier: DS = ^SPRITEDATEN ! ------
        mov   ds, [bx + OFFSET SpriteAD]; DS zeigt auf Sprite-Daten.
                                        ; GS zeigt weiterhin auf DATENSEGMENT.

        ; Kopien der RAM-Plane-Zeiger anfertigen:
        mov   cx, ds:[Plane0]           ; Lese Zeiger auf RAM-Plane 0.
        mov   ds:[P0PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane1]           ; Lese Zeiger auf RAM-Plane 1.
        mov   ds:[P1PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane2]           ; Lese Zeiger auf RAM-Plane 2.
        mov   ds:[P2PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane3]           ; Lese Zeiger auf RAM-Plane 3.
        mov   ds:[P3PlanePtr], cx       ; Kopie erstellen.

        ; Ebenen errechnen:
        mov   bx, dx                    ; Lese aktuelle X-Koordinate.
        and   bx, 3                     ; Maskiere Bits 0 und 1 aus fÅr MAP MASK REGISTER.
        mov   cl, Translate[bx]         ; 0,1,2,3 -> 1,2,4,8 realisieren.
        mov   ch, cl                    ; Merke Ebene.
        shl   ch, 4                     ; Verschiebe in oberes Nibble.
        add   ch, cl                    ; Jetzt ist in CH an der akt. Ebene
                                        ; eine "1" und 4 Bits weiter links auch.
                                        ; Z.B. "00100010".
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P0StartPlane], cl     ; Speichere gewÑhlte Ebene.
        rol   ch, 1                     ; nÑchste Ebene.
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P1StartPlane], cl     ; Speichere gewÑhlte Ebene.
        rol   ch, 1                     ; nÑchste Ebene.
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P2StartPlane], cl     ; Speichere gewÑhlte Ebene.
        rol   ch, 1                     ; nÑchste Ebene.
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P3StartPlane], cl     ; Speichere gewÑhlte Ebene.

        jmp   @@OverToSpriteFertig      ; öberspringe Sprungleiste.
       @@ToSpriteFertig:                ; Sprungleiste zu SpriteFertig.
        jmp   @@SpriteFertig            ; Springe zu SpriteFertig.
       @@OverToSpriteFertig:

        ; Teste, ob LINKS AU·ERHALB:
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes.
        shl   bx, 2                     ; Bytes -> Pixel.
        add   bx, dx                    ; Akt. X-Koordinate + Breite.
        cmp   bx, ax                    ; Kleiner als [WINXMIN_] ?
        jl    @@ToSpriteFertig          ; JA, Ende.

        ; Teste, ob OBEN AU·ERHALB:
        mov   bx, ds:[HoeheInZ]         ; Spritehîhe in Zeilen lesen.
        mov   cx, bx                    ; Auch nach CX, fÅr ZÑhler der sichtbaren Zeilen.
        add   bx, di                    ; Akt. Y-Koordinate + Hîhe.
        cmp   bx, si                    ; Ist dies kleiner als [WINYMIN_] ?
        jle   @@ToSpriteFertig          ; JA, Ende.

        ; Teste, ob OBEN CLIPPEN:
        mov   ax, si                    ; [WINYMIN_] lesen.
        sub   ax, di                    ; Ziehe von [WINYMIN_] die akt Y-Koordinate ab.
        jle   @@NoTopCl                 ; Nichts clippen, weiter.
        sub   cx, ax                    ; ZÑhler der Zeilen - öberhang oben.
        mov   di, si                    ; [WINYMIN_] als neue Y-Koordinate.
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mul   bl                        ; AX := AX * BX <=> AX := öBERHANG_OBEN * BREITE_IN_BYTES.
        add   ds:[P0PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P1PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P2PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P3PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
       @@NoTopCl:                       ; Kein Clippen oben.

       ; Teste, ob UNTEN CLIPPEN:
        mov   ax, ds:[HoeheInZ]         ; Lese Spritehîhe in Zeilen.
        add   ax, di                    ; AX += aktuelle Y-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterhîhe auszugleichen.
        sub   ax, bp                    ; AX -= [WINYMAX_].
        jle   @@NoBottomCl              ; Wenn AX <= [WINYMAX_], kein Clippen.
        sub   cx, ax                    ; Verkleinere ZeilenzÑhler um öberhang unten.
       @@NoBottomCl:                    ; Kein Clippen unten.

        dec   cx                        ; Noch 1 weniger, um nacher Abfrageschleife schneller zu machen ("OR xx, xx").
        mov   ds:[ZeilenRepeats], cx    ; Fertigen ZeilenzÑhler speichern.

        ; Teste, ob RECHTS CLIPPEN:
        mov   ax, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mov   ds:[P0Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P1Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P2Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P3Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        shl   ax, 2                     ; Bytes -> Pixel.
        add   ax, dx                    ; AX += Aktuelle X-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterbreite auszugleichen.
        sub   ax, XMAX                  ; AX -= Rechte Begrenzung.
        jle   @@NoRightCl               ; <= 0, Weiter.
        mov   bp, ax                    ; Rechten öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        sub   ds:[P0Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P1Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P2Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P3Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        and   al, 3                     ; Restlicher rechter öberhang in Pixeln (<4).
        je    @@RightCl_0               ; Weniger, nichts mehr dazu addieren.
        cmp   al, 2                     ; Wieviel öberhang ?
        jl    @@RightCl_1               ; Noch 1 Pixel.
        je    @@RightCl_2               ; Noch 2 Pixel.
       @@RightCl_3:                     ; 3 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P1Repeats]   ; Plane-ZÑhler noch um 1 weniger.
       @@RightCl_2:                     ; 2 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P2Repeats]   ; Plane-ZÑhler noch um 1 weniger.
       @@RightCl_1:                     ; 1 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P3Repeats]   ; Plane-ZÑhler noch um 1 weniger.
       @@RightCl_0:                     ; Nichts mehr dazu addieren.
       @@NoRightCl:                     ; Kein Clippen rechts.

        ; Teste, ob LINKS CLIPPEN:
        xor   bp, bp                    ; öberhang in Bytes = 0.
        xor   ax, ax                    ; Restlicher linker öberhang in Pixeln (>4).
        xor   bx, bx                    ; Linker Rand lesen (XMIN).
        mov   cx, bx                    ; Linker Rand lesen.
        sub   bx, dx                    ; BX -= Aktuelle X-Koordinate.
        jle   @@NoLeftCl                ; JA, weiter.
        mov   bp, bx                    ; öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        mov   ax, bx                    ; öberhang lesen.
        and   ax, 3                     ; Restlicher linker öberhang in Pixeln (>4).
        mov   dx, cx                    ; X-Koordinate := WINXMIN_.
        sub   ds:[P0Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P1Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P2Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P3Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
       @@NoLeftCl:                      ; Kein Clippen links.
        mov   ds:[P0AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P1AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P2AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P3AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        or    al, al                    ; Noch Pixel öberhang ?
        je    @@LeftCl__                ; Weniger, nichts mehr dazu addieren.
        cmp   al, 2                     ; Wieviel öberhang ?
        jl    @@LeftCl_0                ; Noch 1 Pixel.
        je    @@LeftCl_1                ; Noch 2 Pixel.
       @@LeftCl_2:                      ; 3 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P2Repeats]   ; DafÅr auch ZÑhler 1 weniger pro Zeile.
        inc   WORD PTR ds:[P2AddOfsRAM] ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       @@LeftCl_1:                      ; 2 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P1Repeats]   ; DafÅr auch ZÑhler 1 weniger pro Zeile.
        inc   WORD PTR ds:[P1AddOfsRAM] ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       @@LeftCl_0:                      ; 1 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P0Repeats]   ; DafÅr auch ZÑhler 1 weniger pro Zeile.
        inc   WORD PTR ds:[P0AddOfsRAM] ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       @@LeftCl__:                      ; Nichts mehr dazu addieren.

        ; Start-Zeiger auf Schirm erechnen:
        shr   dx, 2                     ; X-Koordinate: Pixel -> Bytes.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   bx, dx                    ; BX += X-Koordinate = ENDPOSITION !
        mov   ds:[P0StartOfsScr], bx    ; Schirm-Offset der Ebene 0 setzen.
        mov   cx, bx                    ; Schirm-Offset der Ebene 1 merken.
        mov   dx, bx                    ; Schirm-Offset der Ebene 2 merken.
        mov   di, bx                    ; Schirm-Offset der Ebene 3 merken.

        ; Zeiger ggf. noch erhîhen:
        mov   ax, ds:[P0AddOfsRAM]      ; öberhang in Ebene 0.
        or    ax, ax                    ; Nur wenn NICHT Clippen.
        jne   @@NoRaise                 ; NEIN, nicht erhîhen.
        xor   bh, bh                    ; BH auf 0.
        mov   al, ds:[P0StartPlane]     ; Startebene der 1. Ebene (Plane0).
        mov   ah, al                    ; Auch nach AH.
        shl   al, 4                     ; Startebene der 1. Ebene um 4 nach links.
        add   ah, al                    ; jetzt in BEIDEN NIBBLES die Ebene.
        shl   ah, 1                     ; Letztes Bit in CARRY-FLAG.
        setb  bl                        ; BL=1, wenn CF=1 und umgekehrt.
        add   cx, bx                    ; Addiere ggf. 1.
        add   dx, bx                    ; Addiere ggf. 1.
        add   di, bx                    ; Addiere ggf. 1.
        shl   ah, 1                     ; Letztes Bit in CARRY-FLAG.
        setb  bl                        ; BL=1, wenn CF=1 und umgekehrt.
        add   dx, bx                    ; Addiere ggf. 1.
        add   di, bx                    ; Addiere ggf. 1.
        shl   ah, 1                     ; Letztes Bit in CARRY-FLAG.
        adc   di, 0                     ; Addiere ggf. 1.
       @@NoRaise:                       ; Zeiger nicht erhîhen.

        mov   ds:[P1StartOfsScr], cx    ; Schirm-Offset der Ebene 1 setzen.
        mov   ds:[P2StartOfsScr], dx    ; Schirm-Offset der Ebene 2 setzen.
        mov   ds:[P3StartOfsScr], di    ; Schirm-Offset der Ebene 3 setzen.

       ; ------ Jetzt nacheinander ausgeben: ------
       ; Immer EINE Ebene durch ALLE Zeilen durch.

       ; --- Plane0: ---
       @@Plane0:
        mov   di, ds:[P0Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @@Plane1                  ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P0StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P0StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P0PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @@P0EineZeile:                   ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P0AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @@P0Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @@P0Loop                  ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @@P0Loop:
        loop  @@P0Copy                  ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @@P0EineZeile             ; Solange Zeilen da, mache weiter.

       ; --- Plane1: ---
       @@Plane1:
        mov   di, ds:[P1Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @@Plane2                  ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P1StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P1StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P1PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @@P1EineZeile:                   ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P1AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @@P1Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @@P1Loop                  ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @@P1Loop:
        loop  @@P1Copy                  ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @@P1EineZeile             ; Solange Zeilen da, mache weiter.

       ; --- Plane2: ---
       @@Plane2:
        mov   di, ds:[P2Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @@Plane3                  ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P2StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P2StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P2PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @@P2EineZeile:                   ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P2AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @@P2Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @@P2Loop                  ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @@P2Loop:
        loop  @@P2Copy                  ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @@P2EineZeile              ; Solange Zeilen da, mache weiter.

       ; --- Plane3: ---
       @@Plane3:
        mov   di, ds:[P3Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @@SpriteFertig             ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P3StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P3StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P3PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @@P3EineZeile:                   ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P3AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @@P3Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @@P3Loop                  ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @@P3Loop:
        loop  @@P3Copy                  ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @@P3EineZeile             ; Solange Zeilen da, mache weiter.

       @@SpriteFertig:
        pop   si                        ; Gerette Position im SPRITEN[..]-Feld zurÅck.
        mov   ax, SEG Data              ; Lese normales Datensegment.
        mov   ds, ax                    ; Setze normales Datensegment als aktuelles.
        jmp   @NoSprite                 ; NÑchster Sprite.

        ; ----- Clippe auf WIN*: -----
       @ClipToWin:
        push  si                        ; Spritepositionsnummer * 2 retten.

        mov   dx, [si + OFFSET SpriteX] ; Aktuelle X-Koordinate lesen.
        sub   dx, StartVirtualX         ; Virtuelle -> Absolute Koordinaten.
        mov   di, [si + OFFSET SpriteY] ; Aktuelle Y-Koordinate lesen.
        sub   di, StartVirtualY         ; Virtuelle -> Absolute Koordinaten.

        mov   cx, WinXMAX               ; Rechte Begrenzung.
        cmp   dx, cx                    ; RECHTS AU·ERHALB ?
        jg    @ToSpriteFertig           ; JA, Ende.

        mov   bp, WinYMAX               ; Untere Begrenzung.
        cmp   di, bp                    ; UNTEN AU·ERHALB ?
        jg    @ToSpriteFertig           ; JA, Ende.

        mov   ax, WinXMIN               ; Linke Begrenzung.
        mov   si, WinYMIN               ; Obere Begrenzung.

        ; ------ Ab hier: DS = ^SPRITEDATEN ! ------
        mov   ds, [bx + OFFSET SpriteAD]; DS zeigt auf Sprite-Daten.
                                        ; GS zeigt weiterhin auf DATENSEGMENT.

        ; Kopien der RAM-Plane-Zeiger anfertigen:
        mov   cx, ds:[Plane0]           ; Lese Zeiger auf RAM-Plane 0.
        mov   ds:[P0PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane1]           ; Lese Zeiger auf RAM-Plane 1.
        mov   ds:[P1PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane2]           ; Lese Zeiger auf RAM-Plane 2.
        mov   ds:[P2PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane3]           ; Lese Zeiger auf RAM-Plane 3.
        mov   ds:[P3PlanePtr], cx       ; Kopie erstellen.

        ; Ebenen errechnen:
        mov   bx, dx                    ; Lese aktuelle X-Koordinate.
        and   bx, 3                     ; Maskiere Bits 0 und 1 aus fÅr MAP MASK REGISTER.
        mov   cl, Translate[bx]         ; 0,1,2,3 -> 1,2,4,8 realisieren.
        mov   ch, cl                    ; Merke Ebene.
        shl   ch, 4                     ; Verschiebe in oberes Nibble.
        add   ch, cl                    ; Jetzt ist in CH an der akt. Ebene
                                        ; eine "1" und 4 Bits weiter links auch.
                                        ; Z.B. "00100010".
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P0StartPlane], cl     ; Speichere gewÑhlte Ebene.
        rol   ch, 1                     ; nÑchste Ebene.
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P1StartPlane], cl     ; Speichere gewÑhlte Ebene.
        rol   ch, 1                     ; nÑchste Ebene.
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P2StartPlane], cl     ; Speichere gewÑhlte Ebene.
        rol   ch, 1                     ; nÑchste Ebene.
        mov   cl, ch                    ; Hole Ebene.
        and   cl, 0Fh                   ; Maskiere oberes Nibble wieder aus.
        mov   ds:[P3StartPlane], cl     ; Speichere gewÑhlte Ebene.

        jmp   @OverToSpriteFertig       ; öberspringe Sprungleiste.
       @ToSpriteFertig:                 ; Sprungleiste zu SpriteFertig.
        jmp   @SpriteFertig             ; Springe zu SpriteFertig.
       @OverToSpriteFertig:

        ; Teste, ob LINKS AU·ERHALB:
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes.
        shl   bx, 2                     ; Bytes -> Pixel.
        add   bx, dx                    ; Akt. X-Koordinate + Breite.
        cmp   bx, ax                    ; Kleiner als [WINXMIN_] ?
        jl    @ToSpriteFertig           ; JA, Ende.

        ; Teste, ob OBEN AU·ERHALB:
        mov   bx, ds:[HoeheInZ]         ; Spritehîhe in Zeilen lesen.
        mov   cx, bx                    ; Auch nach CX, fÅr ZÑhler der sichtbaren Zeilen.
        add   bx, di                    ; Akt. Y-Koordinate + Hîhe.
        cmp   bx, si                    ; Ist dies kleiner als [WINYMIN_] ?
        jle   @ToSpriteFertig           ; JA, Ende.

        ; Teste, ob OBEN CLIPPEN:
        mov   ax, si                    ; [WINYMIN_] lesen.
        sub   ax, di                    ; Ziehe von [WINYMIN_] die akt Y-Koordinate ab.
        jle   @NoTopCl                  ; Nichts clippen, weiter.
        sub   cx, ax                    ; ZÑhler der Zeilen - öberhang oben.
        mov   di, si                    ; [WINYMIN_] als neue Y-Koordinate.
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mul   bl                        ; AX := AX * BX <=> AX := öBERHANG_OBEN * BREITE_IN_BYTES.
        add   ds:[P0PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P1PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P2PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P3PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
       @NoTopCl:                        ; Kein Clippen oben.

       ; Teste, ob UNTEN CLIPPEN:
        mov   ax, ds:[HoeheInZ]         ; Lese Spritehîhe in Zeilen.
        add   ax, di                    ; AX += aktuelle Y-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterhîhe auszugleichen.
        sub   ax, bp                    ; AX -= [WINYMAX_].
        jle   @NoBottomCl               ; Wenn AX <= [WINYMAX_], kein Clippen.
        sub   cx, ax                    ; Verkleinere ZeilenzÑhler um öberhang unten.
       @NoBottomCl:                     ; Kein Clippen unten.

        dec   cx                        ; Noch 1 weniger, um nacher Abfrageschleife schneller zu machen ("OR xx, xx").
        mov   ds:[ZeilenRepeats], cx    ; Fertigen ZeilenzÑhler speichern.

        ; Teste, ob RECHTS CLIPPEN:
        mov   ax, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mov   ds:[P0Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P1Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P2Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P3Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        shl   ax, 2                     ; Bytes -> Pixel.
        add   ax, dx                    ; AX += Aktuelle X-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterbreite auszugleichen.
        sub   ax, gs:WinXMAX            ; AX -= Rechte Begrenzung.
        jle   @NoRightCl                ; <= 0, Weiter.
        mov   bp, ax                    ; Rechten öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        sub   ds:[P0Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P1Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P2Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P3Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        and   al, 3                     ; Restlicher rechter öberhang in Pixeln (<4).
        je    @RightCl_0                ; Weniger, nichts mehr dazu addieren.
        cmp   al, 2                     ; Wieviel öberhang ?
        jl    @RightCl_1                ; Noch 1 Pixel.
        je    @RightCl_2                ; Noch 2 Pixel.
       @RightCl_3:                      ; 3 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P1Repeats]   ; Plane-ZÑhler noch um 1 weniger.
       @RightCl_2:                      ; 2 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P2Repeats]   ; Plane-ZÑhler noch um 1 weniger.
       @RightCl_1:                      ; 1 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P3Repeats]   ; Plane-ZÑhler noch um 1 weniger.
       @RightCl_0:                      ; Nichts mehr dazu addieren.
       @NoRightCl:                      ; Kein Clippen rechts.

        ; Teste, ob LINKS CLIPPEN:
        xor   bp, bp                    ; öberhang in Bytes = 0.
        xor   ax, ax                    ; Restlicher linker öberhang in Pixeln (>4).
        mov   bx, gs:WinXMIN            ; Linker Rand lesen.
        mov   cx, bx                    ; Linker Rand lesen.
        sub   bx, dx                    ; BX -= Aktuelle X-Koordinate.
        jle   @NoLeftCl                 ; JA, weiter.
        mov   bp, bx                    ; öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        mov   ax, bx                    ; öberhang lesen.
        and   ax, 3                     ; Restlicher linker öberhang in Pixeln (>4).
        mov   dx, cx                    ; X-Koordinate := WINXMIN_.
        sub   ds:[P0Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P1Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P2Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P3Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
       @NoLeftCl:                       ; Kein Clippen links.
        mov   ds:[P0AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P1AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P2AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P3AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        or    al, al                    ; Noch Pixel öberhang ?
        je    @LeftCl__                 ; Weniger, nichts mehr dazu addieren.
        cmp   al, 2                     ; Wieviel öberhang ?
        jl    @LeftCl_0                 ; Noch 1 Pixel.
        je    @LeftCl_1                 ; Noch 2 Pixel.
       @LeftCl_2:                       ; 3 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P2Repeats]   ; DafÅr auch ZÑhler 1 weniger pro Zeile.
        inc   WORD PTR ds:[P2AddOfsRAM] ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       @LeftCl_1:                       ; 2 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P1Repeats]   ; DafÅr auch ZÑhler 1 weniger pro Zeile.
        inc   WORD PTR ds:[P1AddOfsRAM] ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       @LeftCl_0:                       ; 1 Pixel öberhang zusÑtzlich.
        dec   WORD PTR ds:[P0Repeats]   ; DafÅr auch ZÑhler 1 weniger pro Zeile.
        inc   WORD PTR ds:[P0AddOfsRAM] ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       @LeftCl__:                       ; Nichts mehr dazu addieren.

        ; Start-Zeiger auf Schirm erechnen:
        shr   dx, 2                     ; X-Koordinate: Pixel -> Bytes.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   bx, dx                    ; BX += X-Koordinate = ENDPOSITION !
        mov   ds:[P0StartOfsScr], bx    ; Schirm-Offset der Ebene 0 setzen.
        mov   cx, bx                    ; Schirm-Offset der Ebene 1 merken.
        mov   dx, bx                    ; Schirm-Offset der Ebene 2 merken.
        mov   di, bx                    ; Schirm-Offset der Ebene 3 merken.

        ; Zeiger ggf. noch erhîhen:
        mov   ax, ds:[P0AddOfsRAM]      ; öberhang in Ebene 0.
        or    ax, ax                    ; Nur wenn NICHT Clippen.
        jne   @NoRaise                  ; NEIN, nicht erhîhen.
        xor   bh, bh                    ; BH auf 0.
        mov   al, ds:[P0StartPlane]     ; Startebene der 1. Ebene (Plane0).
        mov   ah, al                    ; Auch nach AH.
        shl   al, 4                     ; Startebene der 1. Ebene um 4 nach links.
        add   ah, al                    ; jetzt in BEIDEN NIBBLES die Ebene.
        shl   ah, 1                     ; Letztes Bit in CARRY-FLAG.
        setb  bl                        ; BL=1, wenn CF=1 und umgekehrt.
        add   cx, bx                    ; Addiere ggf. 1.
        add   dx, bx                    ; Addiere ggf. 1.
        add   di, bx                    ; Addiere ggf. 1.
        shl   ah, 1                     ; Letztes Bit in CARRY-FLAG.
        setb  bl                        ; BL=1, wenn CF=1 und umgekehrt.
        add   dx, bx                    ; Addiere ggf. 1.
        add   di, bx                    ; Addiere ggf. 1.
        shl   ah, 1                     ; Letztes Bit in CARRY-FLAG.
        adc   di, 0                     ; Addiere ggf. 1.
       @NoRaise:                        ; Zeiger nicht erhîhen.

        mov   ds:[P1StartOfsScr], cx    ; Schirm-Offset der Ebene 1 setzen.
        mov   ds:[P2StartOfsScr], dx    ; Schirm-Offset der Ebene 2 setzen.
        mov   ds:[P3StartOfsScr], di    ; Schirm-Offset der Ebene 3 setzen.

       ; ------ Jetzt nacheinander ausgeben: ------
       ; Immer EINE Ebene durch ALLE Zeilen durch.

       ; --- Plane0: ---
       @Plane0:
        mov   di, ds:[P0Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @Plane1                   ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P0StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P0StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P0PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @P0EineZeile:                    ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P0AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @P0Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @P0Loop                   ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @P0Loop:
        loop  @P0Copy                   ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @P0EineZeile              ; Solange Zeilen da, mache weiter.

       ; --- Plane1: ---
       @Plane1:
        mov   di, ds:[P1Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @Plane2                   ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P1StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P1StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P1PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @P1EineZeile:                    ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P1AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @P1Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @P1Loop                   ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @P1Loop:
        loop  @P1Copy                   ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @P1EineZeile              ; Solange Zeilen da, mache weiter.

       ; --- Plane2: ---
       @Plane2:
        mov   di, ds:[P2Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @Plane3                   ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P2StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P2StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P2PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @P2EineZeile:                    ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P2AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @P2Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @P2Loop                   ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @P2Loop:
        loop  @P2Copy                   ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @P2EineZeile              ; Solange Zeilen da, mache weiter.

       ; --- Plane3: ---
       @Plane3:
        mov   di, ds:[P3Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    @SpriteFertig             ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, ds:[P3StartPlane]     ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P3StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P3PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       @P3EineZeile:                    ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P3AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       @P3Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    @P3Loop                   ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       @P3Loop:
        loop  @P3Copy                   ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   @P3EineZeile              ; Solange Zeilen da, mache weiter.

       @SpriteFertig:
        pop   si                        ; Gerette Position im SPRITEN[..]-Feld zurÅck.
        mov   ax, SEG Data              ; Lese normales Datensegment.
        mov   ds, ax                    ; Setze normales Datensegment als aktuelles.

       @NoSprite:
        sub   si, 2                     ; SI auf SpriteN[SI-1].
        js    @Fertig                   ; Wenn SI = 0, Ende.
        jmp   @Zeichne                  ; Sonst nÑchster Sprite.

       @Fertig:
        jmp   @ShowDrawnPage            ; Seite nun fertig, jetzt anzeigen.

        ; ------------------------------------------
        ; ==== Koordinate ist vielfaches von 4: ====
        ; ------------------------------------------
       @ZeichneSpritesMOD4:
        mov   si, NMAX * 2              ; SI auf HôCHSTE Nummer in SPRITEN[..].

       _@@Zeichne:                      ; Ein Sprite zeichenen.
        mov   bx, [si + OFFSET SpriteN] ; BX = SpriteN[..] = Spriteladenummer.
        shl   bx, 1                     ; BX = Spriteladenummer * 2.

        ; Jetzt: "SpriteN[..] := SpriteN[NextSprite[..]]" berechnen:
        mov   bx, [bx + OFFSET NextSprite]
                                        ; BX = NextSprite[SpriteN[?]].
        mov   [si + OFFSET SpriteN], bx ; als neue SpriteN[?] Åbernehmen.
        shl   bx, 1                     ; BX := BX * 2. FÅr ARRAY-Adressierung.

        jnz   _@@Aktiv                  ; Sprite vorhanden.
        jmp   _@@NoSprite               ; Kein Sprite vorhanden.

       _@@Aktiv:                        ; Sprite vorhanden.

        cmp   si, SplitIndex_Mal2       ; Ist SplitPunkt.
        jae   _@@NoClipToWin            ; JA, nicht mehr auf WIN* clippen.
        jmp   _@@ClipToWin              ; NEIN, auf WIN* clippen.

        ; ----- NICHT auf auf WIN* clippen: -----
       _@@NoClipToWin:
        push  si                        ; Spritepositionsnummer * 2 retten.

        mov   dx, [si + OFFSET SpriteX] ; Aktuelle X-Koordinate lesen.
        sub   dx, StartVirtualX         ; Virtuelle -> Absolute Koordinaten.
        mov   di, [si + OFFSET SpriteY] ; Aktuelle Y-Koordinate lesen.
        sub   di, StartVirtualY         ; Virtuelle -> Absolute Koordinaten.

        mov   cx, XMAX                  ; Rechte Begrenzung.
        cmp   dx, cx                    ; RECHTS AU·ERHALB ?
        jg    _@@@@ToSpriteFertig        ; JA, Ende.

        mov   bp, YMAX                  ; Untere Begrenzung.
        cmp   di, bp                    ; UNTEN AU·ERHALB ?
        jg    _@@@@ToSpriteFertig       ; JA, Ende.

        xor   ax, ax                    ; Linke Begrenzung.
        xor   si, si                    ; Obere Begrenzung.

        ; ------ Ab hier: DS = ^SPRITEDATEN ! ------
        mov   ds, [bx + OFFSET SpriteAD]; DS zeigt auf Sprite-Daten.
                                        ; GS zeigt weiterhin auf DATENSEGMENT.

        ; Kopien der RAM-Plane-Zeiger anfertigen:
        mov   cx, ds:[Plane0]           ; Lese Zeiger auf RAM-Plane 0.
        mov   ds:[P0PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane1]           ; Lese Zeiger auf RAM-Plane 1.
        mov   ds:[P1PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane2]           ; Lese Zeiger auf RAM-Plane 2.
        mov   ds:[P2PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane3]           ; Lese Zeiger auf RAM-Plane 3.
        mov   ds:[P3PlanePtr], cx       ; Kopie erstellen.

        jmp   _@@@@OverToSpriteFertig   ; öberspringe Sprungleiste.
       _@@@@ToSpriteFertig:             ; Sprungleiste zu SpriteFertig.
        jmp   _@@@@SpriteFertig         ; Springe zu SpriteFertig.
       _@@@@OverToSpriteFertig:

        ; Teste, ob LINKS AU·ERHALB:
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes.
        shl   bx, 2                     ; Bytes -> Pixel.
        add   bx, dx                    ; Akt. X-Koordinate + Breite.
        cmp   bx, ax                    ; Kleiner als [WINXMIN_] ?
        jl    _@@@@ToSpriteFertig       ; JA, Ende.

        ; Teste, ob OBEN AU·ERHALB:
        mov   bx, ds:[HoeheInZ]         ; Spritehîhe in Zeilen lesen.
        mov   cx, bx                    ; Auch nach CX, fÅr ZÑhler der sichtbaren Zeilen.
        add   bx, di                    ; Akt. Y-Koordinate + Hîhe.
        cmp   bx, si                    ; Ist dies kleiner als [WINYMIN_] ?
        jle   _@@@@ToSpriteFertig       ; JA, Ende.

        ; Teste, ob OBEN CLIPPEN:
        mov   ax, si                    ; [WINYMIN_] lesen.
        sub   ax, di                    ; Ziehe von [WINYMIN_] die akt Y-Koordinate ab.
        jle   _@@@@NoTopCl              ; Nichts clippen, weiter.
        sub   cx, ax                    ; ZÑhler der Zeilen - öberhang oben.
        mov   di, si                    ; [WINYMIN_] als neue Y-Koordinate.
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mul   bl                        ; AX := AX * BX <=> AX := öBERHANG_OBEN * BREITE_IN_BYTES.
        add   ds:[P0PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P1PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P2PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P3PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
       _@@@@NoTopCl:                    ; Kein Clippen oben.

       ; Teste, ob UNTEN CLIPPEN:
        mov   ax, ds:[HoeheInZ]         ; Lese Spritehîhe in Zeilen.
        add   ax, di                    ; AX += aktuelle Y-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterhîhe auszugleichen.
        sub   ax, bp                    ; AX -= [WINYMAX_].
        jle   _@@@@NoBottomCl           ; Wenn AX <= [WINYMAX_], kein Clippen.
        sub   cx, ax                    ; Verkleinere ZeilenzÑhler um öberhang unten.
       _@@@@NoBottomCl:                 ; Kein Clippen unten.

        dec   cx                        ; Noch 1 weniger, um nacher Abfrageschleife schneller zu machen ("OR xx, xx").
        mov   ds:[ZeilenRepeats], cx    ; Fertigen ZeilenzÑhler speichern.

        ; Teste, ob RECHTS CLIPPEN:
        mov   ax, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mov   ds:[P0Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P1Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P2Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P3Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        shl   ax, 2                     ; Bytes -> Pixel.
        add   ax, dx                    ; AX += Aktuelle X-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterbreite auszugleichen.
        sub   ax, XMAX                  ; AX -= Rechte Begrenzung.
        jle   _@@@@NoRightCl            ; <= 0, Weiter.
        mov   bp, ax                    ; Rechten öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        sub   ds:[P0Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P1Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P2Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P3Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
       _@@@@NoRightCl:                  ; Kein Clippen rechts.

        ; Teste, ob LINKS CLIPPEN:
        xor   bp, bp                    ; öberhang in Bytes = 0.
        xor   bx, bx                    ; Linker Rand lesen (XMIN).
        mov   cx, bx                    ; Linker Rand lesen.
        sub   bx, dx                    ; BX -= Aktuelle X-Koordinate.
        jle   _@@@@NoLeftCl             ; JA, weiter.
        mov   bp, bx                    ; öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        mov   ax, bx                    ; öberhang lesen.
        and   ax, 3                     ; Restlicher linker öberhang in Pixeln (>4).
        mov   dx, cx                    ; X-Koordinate := WINXMIN_.
        sub   ds:[P0Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P1Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P2Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P3Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
       _@@@@NoLeftCl:                   ; Kein Clippen links.
        mov   ds:[P0AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P1AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P2AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P3AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.

        ; Start-Zeiger auf Schirm erechnen:
        shr   dx, 2                     ; X-Koordinate: Pixel -> Bytes.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   bx, dx                    ; BX += X-Koordinate = ENDPOSITION !
        mov   ds:[P0StartOfsScr], bx    ; Schirm-Offset der Ebene 0 setzen.
        mov   cx, bx                    ; Schirm-Offset der Ebene 1 merken.
        mov   dx, bx                    ; Schirm-Offset der Ebene 2 merken.
        mov   di, bx                    ; Schirm-Offset der Ebene 3 merken.

        mov   ds:[P1StartOfsScr], cx    ; Schirm-Offset der Ebene 1 setzen.
        mov   ds:[P2StartOfsScr], dx    ; Schirm-Offset der Ebene 2 setzen.
        mov   ds:[P3StartOfsScr], di    ; Schirm-Offset der Ebene 3 setzen.

       ; ------ Jetzt nacheinander ausgeben: ------
       ; Immer EINE Ebene durch ALLE Zeilen durch.

       ; --- Plane0: ---
       _@@@@Plane0:
        mov   di, ds:[P0Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@@@Plane1               ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 01h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P0StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P0PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@@@P0EineZeile:                ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P0AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@@@P0Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@@@P0Loop               ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@@@P0Loop:
        loop  _@@@@P0Copy               ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@@@P0EineZeile          ; Solange Zeilen da, mache weiter.

       ; --- Plane1: ---
       _@@@@Plane1:
        mov   di, ds:[P1Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@@@Plane2               ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 02h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P1StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P1PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@@@P1EineZeile:                ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P1AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@@@P1Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@@@P1Loop               ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@@@P1Loop:
        loop  _@@@@P1Copy               ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@@@P1EineZeile          ; Solange Zeilen da, mache weiter.

       ; --- Plane2: ---
       _@@@@Plane2:
        mov   di, ds:[P2Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@@@Plane3               ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 04h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P2StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P2PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@@@P2EineZeile:                ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P2AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@@@P2Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@@@P2Loop               ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@@@P2Loop:
        loop  _@@@@P2Copy               ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@@@P2EineZeile          ; Solange Zeilen da, mache weiter.

       ; --- Plane3: ---
       _@@@@Plane3:
        mov   di, ds:[P3Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@@@SpriteFertig         ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 08h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P3StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P3PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@@@P3EineZeile:                ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P3AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@@@P3Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@@@P3Loop               ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@@@P3Loop:
        loop  _@@@@P3Copy               ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@@@P3EineZeile          ; Solange Zeilen da, mache weiter.

       _@@@@SpriteFertig:
        pop   si                        ; Gerette Position im SPRITEN[..]-Feld zurÅck.
        mov   ax, SEG Data              ; Lese normales Datensegment.
        mov   ds, ax                    ; Setze normales Datensegment als aktuelles.
        jmp   _@@NoSprite               ; NÑchster Sprite.

        ; ----- Clippe auf WIN*: -----
       _@@ClipToWin:
        push  si                        ; Spritepositionsnummer * 2 retten.

        mov   dx, [si + OFFSET SpriteX] ; Aktuelle X-Koordinate lesen.
        sub   dx, StartVirtualX         ; Virtuelle -> Absolute Koordinaten.
        mov   di, [si + OFFSET SpriteY] ; Aktuelle Y-Koordinate lesen.
        sub   di, StartVirtualY         ; Virtuelle -> Absolute Koordinaten.

        mov   cx, WinXMAX               ; Rechte Begrenzung.
        cmp   dx, cx                    ; RECHTS AU·ERHALB ?
        jg    _@@ToSpriteFertig         ; JA, Ende.

        mov   bp, WinYMAX               ; Untere Begrenzung.
        cmp   di, bp                    ; UNTEN AU·ERHALB ?
        jg    _@@ToSpriteFertig         ; JA, Ende.

        mov   ax, WinXMIN               ; Linke Begrenzung.
        mov   si, WinYMIN               ; Obere Begrenzung.

        ; ------ Ab hier: DS = ^SPRITEDATEN ! ------
        mov   ds, [bx + OFFSET SpriteAD]; DS zeigt auf Sprite-Daten.
                                        ; GS zeigt weiterhin auf DATENSEGMENT.

        ; Kopien der RAM-Plane-Zeiger anfertigen:
        mov   cx, ds:[Plane0]           ; Lese Zeiger auf RAM-Plane 0.
        mov   ds:[P0PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane1]           ; Lese Zeiger auf RAM-Plane 1.
        mov   ds:[P1PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane2]           ; Lese Zeiger auf RAM-Plane 2.
        mov   ds:[P2PlanePtr], cx       ; Kopie erstellen.
        mov   cx, ds:[Plane3]           ; Lese Zeiger auf RAM-Plane 3.
        mov   ds:[P3PlanePtr], cx       ; Kopie erstellen.

        jmp   _@@OverToSpriteFertig     ; öberspringe Sprungleiste.
       _@@ToSpriteFertig:               ; Sprungleiste zu SpriteFertig.
        jmp   _@@SpriteFertig           ; Springe zu SpriteFertig.
       _@@OverToSpriteFertig:

        ; Teste, ob LINKS AU·ERHALB:
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes.
        shl   bx, 2                     ; Bytes -> Pixel.
        add   bx, dx                    ; Akt. X-Koordinate + Breite.
        cmp   bx, ax                    ; Kleiner als [WINXMIN_] ?
        jl    _@@ToSpriteFertig         ; JA, Ende.

        ; Teste, ob OBEN AU·ERHALB:
        mov   bx, ds:[HoeheInZ]         ; Spritehîhe in Zeilen lesen.
        mov   cx, bx                    ; Auch nach CX, fÅr ZÑhler der sichtbaren Zeilen.
        add   bx, di                    ; Akt. Y-Koordinate + Hîhe.
        cmp   bx, si                    ; Ist dies kleiner als [WINYMIN_] ?
        jle   _@@ToSpriteFertig         ; JA, Ende.

        ; Teste, ob OBEN CLIPPEN:
        mov   ax, si                    ; [WINYMIN_] lesen.
        sub   ax, di                    ; Ziehe von [WINYMIN_] die akt Y-Koordinate ab.
        jle   _@@NoTopCl                ; Nichts clippen, weiter.
        sub   cx, ax                    ; ZÑhler der Zeilen - öberhang oben.
        mov   di, si                    ; [WINYMIN_] als neue Y-Koordinate.
        mov   bx, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mul   bl                        ; AX := AX * BX <=> AX := öBERHANG_OBEN * BREITE_IN_BYTES.
        add   ds:[P0PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P1PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P2PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
        add   ds:[P3PlanePtr], ax       ; RAM-Plane-Zeiger um öberhang oben erhîhen.
       _@@NoTopCl:                      ; Kein Clippen oben.

       ; Teste, ob UNTEN CLIPPEN:
        mov   ax, ds:[HoeheInZ]         ; Lese Spritehîhe in Zeilen.
        add   ax, di                    ; AX += aktuelle Y-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterhîhe auszugleichen.
        sub   ax, bp                    ; AX -= [WINYMAX_].
        jle   _@@NoBottomCl             ; Wenn AX <= [WINYMAX_], kein Clippen.
        sub   cx, ax                    ; Verkleinere ZeilenzÑhler um öberhang unten.
       _@@NoBottomCl:                   ; Kein Clippen unten.

        dec   cx                        ; Noch 1 weniger, um nacher Abfrageschleife schneller zu machen ("OR xx, xx").
        mov   ds:[ZeilenRepeats], cx    ; Fertigen ZeilenzÑhler speichern.

        ; Teste, ob RECHTS CLIPPEN:
        mov   ax, ds:[BreiteInB]        ; Spritebreite in Bytes lesen.
        mov   ds:[P0Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P1Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P2Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        mov   ds:[P3Repeats], ax        ; Speichere fÅr SpaltenzÑhler der Ebene.
        shl   ax, 2                     ; Bytes -> Pixel.
        add   ax, dx                    ; AX += Aktuelle X-Koordinate.
        dec   ax                        ; AX -= 1 um Fensterbreite auszugleichen.
        sub   ax, gs:WinXMAX            ; AX -= Rechte Begrenzung.
        jle   _@@NoRightCl              ; <= 0, Weiter.
        mov   bp, ax                    ; Rechten öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        sub   ds:[P0Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P1Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P2Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
        sub   ds:[P3Repeats], bp        ; Ziehe vom Plane-ZÑhler öberhang ab.
       _@@NoRightCl:                    ; Kein Clippen rechts.

        ; Teste, ob LINKS CLIPPEN:
        xor   bp, bp                    ; öberhang in Bytes = 0.
        xor   ax, ax                    ; Restlicher linker öberhang in Pixeln (>4).
        mov   bx, gs:WinXMIN            ; Linker Rand lesen.
        mov   cx, bx                    ; Linker Rand lesen.
        sub   bx, dx                    ; BX -= Aktuelle X-Koordinate.
        jle   _@@NoLeftCl               ; JA, weiter.
        mov   bp, bx                    ; öberhang lesen.
        shr   bp, 2                     ; Pixel -> Bytes.
        mov   ax, bx                    ; öberhang lesen.
        and   ax, 3                     ; Restlicher linker öberhang in Pixeln (>4).
        mov   dx, cx                    ; X-Koordinate := WINXMIN_.
        sub   ds:[P0Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P1Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P2Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
        sub   ds:[P3Repeats], bp        ; Plane-ZÑhler noch um öberhang in Bytes weniger.
       _@@NoLeftCl:                     ; Kein Clippen links.
        mov   ds:[P0AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P1AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P2AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
        mov   ds:[P3AddOfsRAM], bp      ; Bytes, die RAM-Zeiger an jedem Zeilenanfang verschoben wird.
       _@@LeftCl__:                     ; Nichts mehr dazu addieren.

        ; Start-Zeiger auf Schirm erechnen:
        shr   dx, 2                     ; X-Koordinate: Pixel -> Bytes.
        shl   di, 1                     ; Y-Koordinate: *2 fÅr ARRAY-Adressierung.
        mov   bx, WORD PTR cs:[di + OFFSET CS_GAdr]
                                        ; Offset-Adresse der akt. Zeile.
        add   bx, dx                    ; BX += X-Koordinate = ENDPOSITION !
        mov   ds:[P0StartOfsScr], bx    ; Schirm-Offset der Ebene 0 setzen.
        mov   cx, bx                    ; Schirm-Offset der Ebene 1 merken.
        mov   dx, bx                    ; Schirm-Offset der Ebene 2 merken.
        mov   di, bx                    ; Schirm-Offset der Ebene 3 merken.

        mov   ds:[P1StartOfsScr], cx    ; Schirm-Offset der Ebene 1 setzen.
        mov   ds:[P2StartOfsScr], dx    ; Schirm-Offset der Ebene 2 setzen.
        mov   ds:[P3StartOfsScr], di    ; Schirm-Offset der Ebene 3 setzen.

       ; ------ Jetzt nacheinander ausgeben: ------
       ; Immer EINE Ebene durch ALLE Zeilen durch.

       ; --- Plane0: ---
       _@@Plane0:
        mov   di, ds:[P0Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@Plane1                 ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 01h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P0StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P0PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@P0EineZeile:                  ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P0AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@P0Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@P0Loop                 ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@P0Loop:
        loop  _@@P0Copy                 ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@P0EineZeile            ; Solange Zeilen da, mache weiter.

       ; --- Plane1: ---
       _@@Plane1:
        mov   di, ds:[P1Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@Plane2                 ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 02h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P1StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P1PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@P1EineZeile:                  ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P1AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@P1Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@P1Loop                 ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@P1Loop:
        loop  _@@P1Copy                 ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@P1EineZeile            ; Solange Zeilen da, mache weiter.

       ; --- Plane2: ---
       _@@Plane2:
        mov   di, ds:[P2Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@Plane3                 ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 04h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P2StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P2PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@P2EineZeile:                  ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P2AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@P2Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@P2Loop                 ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@P2Loop:
        loop  _@@P2Copy                 ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@P2EineZeile            ; Solange Zeilen da, mache weiter.

       ; --- Plane3: ---
       _@@Plane3:
        mov   di, ds:[P3Repeats]        ; Wiederholungen pro Zeile.
        or    di, di                    ; Ist es 0 ?
        je    _@@SpriteFertig           ; Ja, Skip this.

        mov   dx, 3C4h                  ; Index der SEQUENCER REGISTER.
        mov   al, 2                     ; Index MAP MASK REGISTER.
        mov   ah, 08h                   ; Bildschirmebene dieser Ebene.
        out   dx, ax                    ; Ebene wÑhlen.

        mov   bp, ds:[P3StartOfsScr]    ; Offset auf Schirm dieser Zeile.
        mov   ax, ds:[ZeilenRepeats]    ; Anzahl sichtbarer Zeilen als ZÑhler.
        mov   dx, ds:[P3PlanePtr]       ; RAM-Zeiger auf Sprite-Daten.

       _@@P3EineZeile:                  ; Eine Zeile in dieser Ebene ausgeben.
        mov   bx, bp                    ; Offset auf Schirm dieser Zeile.
        mov   si, dx                    ; RAM-Zeiger auf Sprite-Daten.
        add   si, ds:[P3AddOfsRAM]      ; Verschiebungen dazu.
        mov   cx, di                    ; Wiederholungen pro Zeile.

        push  ax                        ; Speichere ZeilenzÑhler.

        ; Hier: CX Bytes von DS:SI nach ES:BX Åbertragen.
        ;       Die richtige Ebene ist schon gesetzt.
        stc                             ; BX so verringern, da· es zusammen
        sbb   bx, si                    ; mit SI zugleich als Zielindex

       _@@P3Copy:
        lodsb                           ; 1 Byte holen.
        or    al, al                    ; Ist es = 0 ?
        je    _@@P3Loop                 ; Ja, nichts zu tun.
        mov   es:[bx + si], al          ; öbertragen.
       _@@P3Loop:
        loop  _@@P3Copy                 ; NÑchstes Byte.

        add   bp, LineSize              ; Schirm-Ofs-Zeiger auf nÑchste Zeile.
        add   dx, ds:[BreiteInB]        ; RAM-Zeiger um 1 Zeile erhîhen.

        pop   ax                        ; ZeilenzÑhler zurÅck.

        dec   ax                        ; ZeilenzÑhler - 1.
        jns   _@@P3EineZeile            ; Solange Zeilen da, mache weiter.

       _@@SpriteFertig:
        pop   si                        ; Gerette Position im SPRITEN[..]-Feld zurÅck.
        mov   ax, SEG Data              ; Lese normales Datensegment.
        mov   ds, ax                    ; Setze normales Datensegment als aktuelles.

       _@@NoSprite:
        sub   si, 2                     ; SI auf SpriteN[SI-1].
        js    _@@Fertig                 ; Wenn SI = 0, Ende.
        jmp   _@@Zeichne                ; Sonst nÑchster Sprite.

       _@@Fertig:

        ; Aktuelle Zeichenseite anzeigen:
       @ShowDrawnPage:
        mov   si, _Page                 ; Aktuelle Seite laden.
        mov   bx, si                    ; Speichere Page-Wert.
        shl   si, 1                     ; SI := SI * 2  ; fÅr ARRAY-Adressierung.
        mov   cx, [OFFSET POfs_Adr + si]; "CX := POfs_Adr[Page]".

        ; Fertiggestellte Grafikseite anzeigen:
        mov   dx, StatusReg             ; Index des INPUT STATUS #1 REGISTERS.

       @WaitNotHSyncLoop:               ; Warte, bis kein H-SYNC.
        in    al, dx                    ; Daten einlesen.
        and   al, 1                     ; Wenn Bit 1 = 0: HORIZ. Retrace aktiv.
        jz    @WaitNotHSyncLoop         ; Wiederhole, bis INaktiv.

       @WaitHSyncLoop:                  ; Warte bis H-SYNC beginnt.
        in    al, dx                    ; Daten einlesen.
        and   al, 1                     ; Wenn Bit 1 = 0: HORIZ. Retrace aktiv.
        jnz   @WaitHSyncLoop            ; Wiederhole, bis aktiv.

        cli                             ; Interrupts sperren.

        ; LOW-Byte der Startadresse setzen:
        mov   dx, CRTAddress            ; Index der CRT-CONTROLLER REGISTER.
        mov   al, 0Dh                   ; Index des START ADRESS LOW REGISTERS.
        mov   ah, cl                    ; LOW-Byte der Startadresse.
        out   dx, ax                    ; Register fÅr Daten aktivieren und senden.

        ; HIGH-Byte der Startadresse setzen:
        dec   al                        ; Index des START ADRESS HIGH REGISTERS.
        mov   ah, ch                    ; HIGH-Byte der Startadresse.
        out   dx, ax                    ; Register fÅr Daten aktivieren und senden.

        sti                             ; Interrupts erlauben.

        mov   dx, StatusReg             ; Statusregister-Adresse.

        ; Neuer Werte in PAGE, PAGEADR und PAGEOFS eintragen:
        or    bx, bx                    ; "CMP BX, 0".
        jne   @NoPg0
        mov   bx, 2                     ; JA: Von 2 wieder rÅckwÑrts.
        jmp   @OvPg0
       @NoPg0:
        dec   bx                        ; NEIN: "BX := BX - 1".
       @OvPg0:
        mov   _Page, bx                 ; Jetzt ist in Page: "PAGE := PAGE-1".
        shl   bx, 1                     ; "BX := BX * 2", fÅr ARRAY-Adressierung.
        mov   cx, [OFFSET PSeg_Adr + bx]; Segmentadresse laden.
        mov   PageAdr, cx               ; "PAGEADR := PSEG_ADR[PAGE]".
        mov   cx, [OFFSET POfs_Adr + bx]; Offsetadresse laden.
        mov   PageOfs, cx               ; "PAGEOFS := POFS_ADR[PAGE]".

        ; öberprÅfen, ob gesetzte Zyklus(mindest)zeit abgelaufen ist:
       @TimeNotOver:
        mov   al, TimeFlag              ; Bit 7 = 0/1 fÅr Zeit ist
        and   al, 80h                   ; abgelaufen/lÑuft noch.
        je    @TimeNotOver

        pop   bp                        ; BP vom Stack.

        retf                            ; ZurÅck zum Aufrufenden Programm.

        Animate ENDP                    ; Prozedurende.

   CODE ENDS                            ; Ende des Codesegments.
        END                             ; Ende des Programms.

 ; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ