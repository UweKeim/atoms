 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)
 (*  Programm : UWE FONT 0.1                                               *)
 (*             Routinen f걊 Zeichens꼝ze laden/in Sprites wandeln.        *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UWEFNT01.PAS                                               *)
 (*             Hauptunit.                                                 *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 21.04.1995 Uwe Keim - Anfang.                              *)
 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)

 UNIT UWEFNT01;

  (*컴 COMPILER-EINSTELLUNGEN: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*)

  {$A-,B-,E+,F+,G+,I-,N+,O-,P-,Q-,R-,S-,T-,V-,X+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE ONEFILE}                     (* Ob alles aus 1 gro�en Datei gelesen wird. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ELSE}
  {$D-,L-,Y-}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- 섺FENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   (* 컴 Verschiedene Erkl꼛ungen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* ----------------------------------------------------------- *)
   (* Aufbau einer Font-Datei '????????.FNT':                     *)
   (*                                                             *)
   (* 00..01  DB  'U', 'K'         =  Kennung                     *)
   (* 02..02  DB  1                =  Version                     *)
   (* 03..05  DB  'F', 'N', 'T'    =  FoNT-Datei                  *)
   (* 06..06  DB  ?                =  Zeichenbreite in Pixeln     *)
   (* 07..07  DB  ?                =  Zeichenhoehe in Pixeln      *)
   (* 08..08  DB  ?                =  Infos: Bit 0 = 0: MonoFont, *)
   (*                                        Bit 0 = 1: FarbFont, *)
   (*                                        Bit 8 = 1: Propor-   *)
   (*                                                   tional-   *)
   (*                                                   Font.     *)
   (* 09..29  DB  ?                =  Dummy, fuer spaetere        *)
   (*                                 Erweiterungen frei.         *)
   (*                                                             *)
   (* Falls KEINE PROPORTIONAL-Schrift:                           *)
   (* 30..EOF DB  <Daten>          =  Zeichenweise, darin Zeilen- *)
   (*                                 weise von oben nach unten,  *)
   (*                                 darin pixelweise von links  *)
   (*                                 nach rechts gespeichert.    *)
   (*                                                             *)
   (* Falls PROPORTIONAL-Schrift:                                 *)
   (* 30..285 DB  ?                =  Breite von jedem der 256    *)
   (*                                 ASCII-Zeichen.              *)
   (* 286.EOF DB  <Daten>          =  Zeichenweise, darin Zeilen- *)
   (*                                 weise von oben nach unten,  *)
   (*                                 darin pixelweise von links  *)
   (*                                 nach rechts gespeichert.    *)
   (*                                                             *)
   (* Hinweise: Es k봭nen auch weniger als 256 Zeichen (z.B. nur  *)
   (*           die Zeichen von #0 bis #127) gespeichert werden.  *)
   (*           in diesem Fall steht dann an diesen Stellen bei   *)
   (*           Proportional-Schrift eine 0 an den Bytes 30..285. *)
   (* ----------------------------------------------------------- *)

   (* 컴 Verschiedene Konstanten, Typen und Variablen: 컴컴컴컴컴컴컴컴� *)

   (* 컴 Prototypen der Prozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)

   FUNCTION ChgString(AS : String; ACnt : Integer) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Zieht von den ASCII-Werten aller Zeichen eines       *)
    (*             Strings einen Faktor ab bzw. addiert einen Faktor.   *)
    (*  Eingabe  : AS   = Zu formatierender String,                     *)
    (*             ACNT = Anzahl an ASCII-Positionen, um die verschoben *)
    (*                    werden soll.                                  *)
    (*  R갷kgabe : Ge꼗derter String.                                   *)
    (*  Beispiel : "ChgString(#48#49#50, -48)" liefert "#0#1#2" zur갷k. *)
    (*  Hinweis  : Ist gedacht f걊 erstellen von Sprites aus Fonts, die *)
    (*             aus Platzgr걆den nicht den ganzen ASCII-Satz         *)
    (*             gespeichert haben und somit trotzdem in Klartext     *)
    (*             erstellt werden k봭nen und dann formatiert werden.   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadFont(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : L꼋t einen Zeichensatz oder eine Zeichensatz-         *)
    (*            bibliothek.                                           *)
    (* Eingabe  : AFNAME = Dateiname.                                   *)
    (*            NR     = Ladenummer des 1. Zeichensatzes.             *)
    (* R갷kgabe : Anzahl der aus dem File gelesenen Zeichens꼝ze.       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MakeTextSprite(AText : String; APosChg : Integer;
                            C, ChrDist, AOrientation : Byte;
                            ASpriteLoadNr, AFontNr : Integer);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Wandelt einen Text in einen Sprite.                   *)
    (* Eingabe  : ATEXT         = Der zu wandelnde Text,                *)
    (*            APOSCHG       = Mit welchem Wert die Funktion         *)
    (*                            "ChgString()" aufgerufen wird (siehe  *)
    (*                            auch dort),                           *)
    (*            C             = Schriftfarbe, bei MONOCHROM-Fonts,    *)
    (*            CHRDIST       = Abstand zwischen 2 Buchstaben,        *)
    (*            AORIENTATION  = Textausrichtung,                      *)
    (*                            1 : Von links nach rechts,            *)
    (*                            2 : Von oben nach unten,              *)
    (*                            3 : Von rechts nach links,            *)
    (*                            4 : Von unten nach oben,              *)
    (*            ASPRITELOADNR = SpriteLADEnummer f걊 das zu           *)
    (*                            generierende Sprite,                  *)
    (*            AFONTNR       = Der zu verwendende Zeichensatz.       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FreeFontMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt den Speicher eines Zeichensatzes frei            *)
    (* Eingabe  : ANR = Nummer des freizugebenden Zeichensatzes.        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ReadString(Var AS : String; APosChg : Integer;
                        ALength, AColor, AAniVer, AX, AY : Word; AChars : Byte;
                        AFontNr : Integer; ACursorChar : Char;
                        Var AExitCode : Byte;
                        AUpCase : Boolean; Chr_Lo, Chr_Hi  : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest einen String ein.                               *)
    (* Eingabe  : AS          = Der einzulesende String,                *)
    (*            ALENGTH     = L꼗ge des Strings,                      *)
    (*            APOSCHG     = Mit welchem Wert die Funktion           *)
    (*                          "ChgString()" aufgerufen wird (siehe    *)
    (*                          auch dort),                             *)
    (*            ACOLOR      = Bei Mono-Fonts die Farbe der Schrift,   *)
    (*            AANIVER     = 0 : Verwende das normale 'ANIMATE',     *)
    (*                          1 : Verwende 'EASYANIMATE',             *)
    (*            AX|AY       = Position am Bildschirm,                 *)
    (*            ACHARS      = Art der Zeichen, die erlaubt sind,      *)
    (*                          dabei gilt 0 : Alle Zeichen,            *)
    (*                                     1 : Nur A..Z,                *)
    (*                                     2 : Nur 0..9,                *)
    (*            AFONTNR     = Nummer des verwendeten Zeichensatzes,   *)
    (*            ACURSORCHAR = Zeichen, das f걊 den Cursor verwendet   *)
    (*                          werden soll (die NORMALE ASCII-Nr).     *)
    (*            AEXITCODE   = Ausgangscode beim verlassen,            *)
    (*                          dabei gilt 0 : Mit ESC verlassen,       *)
    (*                                     1 : Mit RETURN verlassen,    *)
    (*            AUPCASE     = TRUE :  Alle Eingaben werden in Gro�-   *)
    (*                                  buchstaben gewandelt,           *)
    (*                          FALSE : Die Buchstaben werden nicht     *)
    (*                                  ge꼗dert.                       *)
    (*            CHR_HI,                                               *)
    (*            CHR_LO      = H봠hste bzw. niedrigste ASCII-Nummer,   *)
    (*                          die noch als Eingabe akzeptiert wird.   *)
    (* Hinweis  : Die Prozedur wandelt w꼑rend der Eingabe den          *)
    (*            aktuellen String mittels 'MakeTextSprite(..)' immer   *)
    (*            in einen Sprite um und bringt diesen dann mittels     *)
    (*            '(EASY)ANIMATE' auf den Bildschirm.                   *)
    (*            Es m걌sen vor dem Aufrufen der Prozedur alle nicht    *)
    (*            gew걆schten Sprites ausgeschalten werden.             *)
    (* ---------------------------------------------------------------- *)

   (* 같 SYSTEM-ROUTINEN: 같같같같같같같같같같같같같같같같같같같같같같� *)

   PROCEDURE FNTInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles N봳ige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FNTCloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgem꾞.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION FNTGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.  *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                            *)
    (*             AS        = Eventueller zus꼝zlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  R갷kgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   USES Crt, Dos,

        {$IFDEF ONEFILE}
        ONEFile1,
        {$ENDIF}

        UweERR01,
        UweUNI01,
        UweVGA01;

   (* 컴 Verschiedene Konstanten, Typen und Variablen: 컴컴컴컴컴컴컴컴� *)

         (* Eigene Fehlercodes: 0950-0999: *)
   CONST FNT_Error_NoFNTFile             = 0950;
         FNT_Error_No_Font_At_Array_Nr   = 0951;

         (* So wird ein Font auf DISK gespeichert: *)
   TYPE  TFNTHeader          = Record
                                Kennung : Array[1..2] Of Char;
                                Version : Byte;
                                Art     : Array[1..3] Of Char;
                                Breite  : Byte;
                                Hoehe   : Byte;
                                Tag     : Byte;
                                Dummy   : Array[1..20] Of Byte;
                               End;

   VAR   FNTHeader           : TFNTHeader;      (* Siehe TFNTHeader, oben. *)

         (* Zeichensatz-Konstanten: *)
   CONST FontMAX             = 001;     (* Maximale Anzahl verschiedener geladener Zeichens꼝ze. *)
         FontHeightMAX       = 016;
         FontWidthMAX        = 015;
         MonoFontTAG         = 000;
         ColorFontTAG        = 001;
         ProportionalTAG     = 128;

         (* Zeichensatz-Tafeln: *)
   VAR   FontPTR             : Array[0..FontMAX] Of Pointer;
                                        (* Liste mit Zeigern auf verschiedene *)
                                        (* Zeichens꼝ze.                      *)
         FontTYPE            : Array[0..FontMAX] Of Byte;
                                        (* Typ des geladenen Fonts. *)
         FontHEIGHT          : Array[0..FontMAX] Of Byte;
                                        (* Fonth봦e in Zeilen. *)
         FontWIDTH           : Array[0..FontMAX] Of Byte;
                                        (* Fontbreite in Pixeln. *)
         FontPROP            : Array[0..FontMAX] Of Byte;
                                        (* = TAGPROPORTIONAL falls Proportionalschrift. *)
         FontWidthTBL        : Array[0..FontMAX] Of Array[0..255] Of Byte;
                                        (* Fontbreite f걊 jeden einzelnen Buchstaben. *)

   (* 컴 Prototypen der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴 *)

   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)

   PROCEDURE XXxXXxx; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  :                                                      *)
    (*  Eingabe  :                                                      *)
    (*  R갷kgabe :                                                      *)
    (*  Hinweis  :                                                      *)
    (* ---------------------------------------------------------------- *)

   (* 같 SYSTEM-ROUTINEN: 같같같같같같같같같같같같같같같같같같같같같같� *)

   (* 컴 R걅pfe der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   PROCEDURE XXxXXxx;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 SYSTEM-ROUTINEN: 같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   (* 컴 Interface횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   FUNCTION ChgString(AS : String; ACnt : Integer) : String;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
        SH1 : String;
    Begin
     SH1 := '';                         (* Default Return-Wert. *)

     (* Wenn kein Leerstring, weitermachen: *)
     If AS <> '' Then
      For IH1 := 1 To Length(AS) Do SH1 := SH1 + Chr(Ord(AS[IH1])+ACnt);

     ChgString := SH1;                  (* R갷kgabe. *)
    End;

   FUNCTION LoadFont(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PH1       : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}

        PBH1      : ^Byte;
        PX1       : Pointer;
        IH1       : Integer;
        LIH1      : LongInt;
        FNTCount  : Integer;
        Size      : LongInt;            (* Gr붳e des anzufordernden Speichers. *)
        RealSize  : LongInt;            (* Wahre Gr붳e, falls gr붳er 65528 Bytes. *)
        FileS     : LongInt;

    Begin
     FNTCount := 0;

     (* Datei 셟fnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-L꼗ge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-L꼗ge : 1 Byte. *)
     {$ENDIF}


     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     {$I-}

     {$IFDEF ONEFILE}
     While Not _EOF(F) Do               (* Je 1 Font-Datei aus ggf Bibliothek lesen. *)
     {$ELSE}
     While Not EOF(F) Do                (* Je 1 Font-Datei aus ggf Bibliothek lesen. *)
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Lesen, Header: *)
       {$I-}

       {$IFDEF ONEFILE}
       PH1 := @FNTHeader;
       _BlockRead(F, PH1, SizeOf(FNTHeader));
       {$ELSE}
       BlockRead(F, FNTHeader, SizeOf(FNTHeader));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Header auswerten: *)
       If (FNTHeader.Kennung <> 'UK') Or (FNTHeader.Art <> 'FNT') Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := FNT_Error_NoFNTFile;
         CriticalError(AFName);
        End;

       (* Header eintragen: *)
       FontWIDTH[Nr]  := FNTHeader.Breite;
       FontHEIGHT[Nr] := FNTHeader.Hoehe;

       (* Wenn MONO-Font: *)
       If FNTHeader.Tag And 1 = 0 Then FontTYPE[Nr] := MonoFontTAG

       (* Wenn COLOR-Font: *)
       Else FontTYPE[Nr] := ColorFontTAG;

       (* WIRKLICHE Gr붳e der Datei ermitteln, da ja nicht *)
       (* alle Zeichen auch benutzt werden m걌sen:         *)

       {$I-}

       {$IFDEF ONEFILE}
       FileS := _FileSize(F);             (* Gr붳e der Datei in Bytes. *)
       {$ELSE}
       FileS := FileSize(F);              (* Gr붳e der Datei in Bytes. *)
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       FileS := FileS - SizeOf(FNTHeader);

       (* Wenn PROPORTIONAL-Font: *)
       If FNTHeader.Tag And 128 = 128 Then
        Begin
         FontPROP[Nr] := ProportionalTAG;

         (* Gr붳e der Daten noch weniger Prop-Tab : *)
         FileS := FileS - SizeOf(FontWidthTBL[NR]);

         (* Proportionalit꼝stafel einlesen: *)
         {$I-}

         {$IFDEF ONEFILE}
         PH1 := @FontWidthTBL[NR];
         _BlockRead(F, PH1, SizeOf(FontWidthTBL[NR]));
         {$ELSE}
         BlockRead(F, FontWidthTBL[NR], SizeOf(FontWidthTBL[NR]));
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         (* Speichergr붳e berechnen: *)
         Size := FileS;
        End

       Else                             (* Kein Prop-Font. *)
        Begin
         FontPROP[Nr] := 0;

         Size := FileS;                 (* Gr붳e 갶ernehmen. *)

         (* F걄le Prop-Tafel mit gleicher Breite, dabei aber nur dort, wo *)
         (* auch Zeichen vorhanden sind; der Rest mit "0":                *)
         FillChar(FontWidthTBL[NR], SizeOf(FontWidthTBL[NR]), 0);
         For IH1 := 0 To (Size Div (FontWIDTH[Nr] * FontHEIGHT[Nr]) - 1) Do
          FontWidthTBL[NR][IH1] := FontWIDTH[Nr];
        End;

       (* Falls GR쇹er als 65528 Bytes, nur 65528 Bytes einlesen: *)
       RealSize := Size;
       If Size > 65528 Then Size := 65528;

       (* Speicher anfordern: *)
       FreeFontMem(Nr);                 (* Ggf. alten Fontspeicher freigeben. *)
       _GetMem(FontPTR[Nr], Size);

       (* Einlesen: *)
       {$I-}

       {$IFDEF ONEFILE}
       _BlockRead(F, FontPTR[NR], Size);
       {$ELSE}
       BlockRead(F, FontPTR[NR]^, Size);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Die ggf. nicht eingelesenen Bytes 갶erspringen: *)
       {$I-}

       {$IFDEF ONEFILE}
       _Seek(F, _FilePos(F)+RealSize-Size);
       {$ELSE}
       Seek(F, FilePos(F)+RealSize-Size);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* N꼊hster Zeichensatz: *)
       Inc(Nr);
       Inc(FNTCount);
      End;                              (* Von "WHILE NOT EOF(F)". *)
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Datei schlie�en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* R갷kgabe: *)
     ERR_Error := ERR_Error_Ok;

     LoadFont := FNTCount;
    End;

   PROCEDURE MakeTextSprite(AText : String; APosChg : Integer;
                            C, ChrDist, AOrientation : Byte;
                            ASpriteLoadNr, AFontNr : Integer);
    (* ---------------------------------------------------------------- *)
    Var PH1, PH2, PH3  : Pointer;
        IH1, IH2, IH3  : Integer;
        PBH1, PBH2     : ^Byte;
        PBH3           : ^Byte;
        PlanePtr       : Array[0..3] Of ^Byte;
        MemSize        : Word;
        TextBreite     : Word;
        TempMemSize    : Word;
        NewTextBreite  : Word;
        NewTempMemSize : Word;
        SH1            : String;
    Begin
     (* Wandle ggf. ASCII + oder -: *)
     AText := ChgString(AText, APosChg);

     If FontPTR[AFontNR] = Nil Then
      Begin
       ERR_Error := FNT_Error_No_Font_At_Array_Nr;
       Str(AFontNR, SH1);
       CriticalError(SH1);
      End;

     (* Breite berechnen: *)
     TextBreite := 0;
     For IH1 := 1 To Length(AText) Do
      TextBreite := TextBreite + FontWidthTBL[AFontNr][Ord(AText[IH1])] + ChrDist;
     Dec(TextBreite, ChrDist);          (* Nach letztem Zeichen kein Freiraum. *)

     (* Schauen, ob Breite ein Vielfaches von 4; ggf. vergr붳ern: *)
     If (TextBreite Mod 4) <> 0 Then Inc(TextBreite, 4-(TextBreite Mod 4));

     (*- Header erstellen: -*)

     TempMemSize := TextBreite * FontHEIGHT[AFontNr];
                                        (* Gr붳e des Tempor꼛en Speichers. *)
     (* Schauen, ob rotieren: *)
     If AOrientation In [2, 4] Then
      Begin
       IH1 := FontHEIGHT[AFontNr] Mod 4;
       If IH1 <> 0 Then
        Begin
         NewTextBreite  := 4 - IH1;
         NewTempMemSize := NewTextBreite * TextBreite;
        End
       Else
        Begin
         NewTempMemSize := TempMemSize;
         NewTextBreite  := FontHEIGHT[AFontNr];
        End;

       (* Spritestruct mit neuen Abmessungen: *)
       SpriteStruct.BreiteInBytes := NewTextBreite Div 4;
       SpriteStruct.HoeheInZ := TextBreite;     (* Die jetzige H섽E. *)
      End

     Else                               (* NICHT rotieren. *)
      Begin
       SpriteStruct.BreiteInBytes := TextBreite Div 4;
       SpriteStruct.HoeheInZ := FontHEIGHT[AFontNr];
      End;

     (* Rest vom Header: *)
     SpriteStruct.Translate[1] := 1;
     SpriteStruct.Translate[2] := 2;
     SpriteStruct.Translate[3] := 4;
     SpriteStruct.Translate[4] := 8;
     SpriteStruct.PlaneDatPtr[0] := SizeOf(SpriteStruct);
     SpriteStruct.PlaneDatPtr[1] := SizeOf(SpriteStruct) +     ((TextBreite Div 4) * FontHEIGHT[AFontNr]);
     SpriteStruct.PlaneDatPtr[2] := SizeOf(SpriteStruct) + 2 * ((TextBreite Div 4) * FontHEIGHT[AFontNr]);
     SpriteStruct.PlaneDatPtr[3] := SizeOf(SpriteStruct) + 3 * ((TextBreite Div 4) * FontHEIGHT[AFontNr]);
     FillChar(SpriteStruct.Dummy, SizeOf(SpriteStruct.Dummy), 0);

     FreeSpriteMem(ASpriteLoadNr);      (* Eventuellen alten Speicher freigeben. *)

     (* Speicher anfordern und Header hineinkopieren: *)
     MemSize := SizeOf(TSpriteStruct) + TextBreite * FontHEIGHT[AFontNr] + 15;

     If (MemSize > MaxAvail) Or (MemSize > 65528) Then
      Begin
       ERR_Error := VGA_Error_NotEnoughMemory;
       Exit;
      End;

     _GetMem(PH1, MemSize);

     (* Tafeln bezeichnen: *)
     SpriteSIZE [ASpriteLoadNr] := MemSize;
     SpriteSIZEX[ASpriteLoadNr] := TextBreite;
     SpriteSIZEY[ASpriteLoadNr] := FontHEIGHT[AFontNr];
     SpritePTR  [ASpriteLoadNr] := PH1;

     (* SpriteNummer zuordnen: *)
     If (LongInt(PH1) mod 16) = 0 Then PH2 := PH1
      Else LongInt(PH2) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);

     (* Header auf Heap bringen: *)
     Move(SpriteStruct, PH2^, SizeOf(TSpriteStruct));
     LongInt(PH1) := LongInt(PH2) + SizeOf(TSpriteStruct);

     (*----- Ab hier: Sprite-Pixeldaten berechnen: -----*)

     (* Zuerst alle Pixel in Speicher zeichnen, *)
     (* mit Standartrichtung (ADirection = 1):  *)

     (* Gr붳e des Tempor꼛en Speichers berechnen und belegen: *)
     _GetMem(PH1, TempMemSize);          (* TempMemSize wurde oben berechnet. *)
     FillChar(PH1^, TempMemSize, 0);
     PBH1 := PH1;                       (* F걊 nachher speichern. *)

     (* MONOCHROM-Font: *)
     If FontTYPE[AFontNr] = MonoFontTAG Then
      For IH1 := 1 To Length(AText) Do
       Begin
        (* Zeichen "anfahren": *)
        PBH2 := FontPTR[AFontNr];
        For IH2 := 0 To Ord(AText[IH1])-1 Do
         Inc(PBH2, (FontWidthTBL[AFontNr][IH2]) * FontHEIGHT[AFontNr]);

        (* Zeichen in Speicher schreiben: *)
        For IH3 := 1 To FontHEIGHT[AFontNr] Do
         Begin
          (* Zeile in Speicher schreiben: *)
          For IH2 := 1 To FontWidthTBL[AFontNr][Ord(AText[IH1])] Do
           Begin
            If PBH2^ <> 0 Then PBH1^ := C;
            Inc(PBH1);                  (* N꼊hster Pixel im Spritefeld. *)
            Inc(PBH2);                  (* N꼊hster Pixel im Fontfeld. *)
           End;

          Inc(PBH1, TextBreite - FontWidthTBL[AFontNr][Ord(AText[IH1])]);

         End;

        (* Stelle nach diesem Zeichen anfahren: *)
        PBH1 := PH1;                    (* Wieder auf Speicheranfang. *)
        For IH2 := 1 To IH1 Do          (* Stelle nach aktuellem Zeichen. *)
         Inc(PBH1, FontWidthTBL[AFontNr][Ord(AText[IH2])] + ChrDist);
       End

     (* COLOR-Font: *)
     Else
      For IH1 := 1 To Length(AText) Do
       Begin
        (* Zeichen "anfahren": *)
        PBH2 := FontPTR[AFontNr];
        For IH2 := 0 To Ord(AText[IH1])-1 Do
         Inc(PBH2, (FontWidthTBL[AFontNr][IH2]) * FontHEIGHT[AFontNr]);

        (* Zeichen in Speicher schreiben: *)
        For IH3 := 1 To FontHEIGHT[AFontNr] Do
         Begin
          (* Zeile in Speicher schreiben: *)
          For IH2 := 1 To FontWidthTBL[AFontNr][Ord(AText[IH1])] Do
           Begin
            PBH1^ := PBH2^;
            Inc(PBH1);                  (* N꼊hster Pixel im Spritefeld. *)
            Inc(PBH2);                  (* N꼊hster Pixel im Fontfeld. *)
           End;

          Inc(PBH1, TextBreite - FontWidthTBL[AFontNr][Ord(AText[IH1])]);

         End;

        (* Stelle nach diesem Zeichen anfahren: *)
        PBH1 := PH1;                    (* Wieder auf Speicheranfang. *)
        For IH2 := 1 To IH1 Do          (* Stelle nach aktuellem Zeichen. *)
         Inc(PBH1, FontWidthTBL[AFontNr][Ord(AText[IH2])] + ChrDist);
       End;

     (* Jetzt ggf. noch rotieren o.�. :*)

     (* Richtungen: 1: 栢� 栢 , 2: 栢栢 , 3: 栢 � � , 4: �  � .
		       � � �	    � �       � 栢�	 栢栢
		       栢� �	   栢栢       � � �
		       � � 栢		     栢 栢�	 栢栢
				   栢栢 		 � �
				   �  � 		 栢栢	*)

     Case AOrientation Of
      2 : Begin
           _GetMem(PH3, NewTempMemSize);
           FillChar(PH3^, NewTempMemSize, 0);
           PBH3 := PH3;
           PBH1 := PH1;

           (* PH1 und PBH1 zeigt auf Text in Richtung 1, *)
           (* PH3 und PBH3 zeigt auf leeren Breich.      *)

           (* Jetzt Speicher f걄len: *)

           (* PBH3 auf 1. Ziel-Punkt: *)
           Inc(PBH3, FontHEIGHT[AFontNr]);

           (* Zeile f걊 Zeile in Quell-Mem, Spalte f걊 Spalte in Ziel-Mem: *)
           For IH2 := 1 To FontHEIGHT[AFontNr] Do
            Begin

             For IH1 := 1 To TextBreite Do
              Begin
               PBH3^ := PBH1^;          (* Kopieren: *)

               Inc(PBH1);               (* Quell-Zeiger +1. *)
               Inc(PBH3, NewTextBreite);
              End;

             PBH3 := PH3;
             Inc(PBH3, FontHEIGHT[AFontNr] - IH2);
            End;

           (* So umbiegen, das wieder das Richtige in TEMPMEMSIZE und *)
           (* PH1 steht, f걊 das Kopieren in den Sprite:              *)
           FreeMem(PH1, TempMemSize);
           TempMemSize := NewTempMemSize;
           PH1 := PH3;
          End;
      3 : Begin
           _GetMem(PH3, TempMemSize);
           PBH3 := PH3;
           PBH1 := PH1;

           (* PH1 und PBH1 zeigt auf Text in Richtung 1, *)
           (* PH3 und PBH3 zeigt auf leeren Breich.      *)

           (* Jetzt Speicher f걄len: *)

           (* PBH3 auf 1. Ziel-Punkt: *)
           Inc(PBH3, TempMemSize-1);

           (* Zeile f걊 Zeile in Quell-Mem, Spalte f걊 Spalte in Ziel-Mem: *)
           For IH2 := 1 To FontHEIGHT[AFontNr] Do
            Begin

             For IH1 := 1 To TextBreite Do
              Begin
               PBH3^ := PBH1^;          (* Kopieren: *)

               Inc(PBH1);               (* Quell-Zeiger +1. *)
               Dec(PBH3);
              End;

             PBH3 := PH3;
             Inc(PBH3, TempMemSize-1);
             Dec(PBH3, TextBreite * IH2);
            End;

           (* So umbiegen, das wieder das Richtige in TEMPMEMSIZE und *)
           (* PH1 steht, f걊 das Kopieren in den Sprite:              *)
           FreeMem(PH1, TempMemSize);
           PH1 := PH3;
          End;
      4 : Begin
           _GetMem(PH3, NewTempMemSize);
           FillChar(PH3^, NewTempMemSize, 0);
           PBH3 := PH3;
           PBH1 := PH1;

           (* PH1 und PBH1 zeigt auf Text in Richtung 1, *)
           (* PH3 und PBH3 zeigt auf leeren Breich.      *)

           (* Jetzt Speicher f걄len: *)

           (* PBH3 auf 1. Ziel-Punkt: *)
           Inc(PBH3, (TextBreite - 1) * NewTextBreite);

           (* Zeile f걊 Zeile in Quell-Mem, Spalte f걊 Spalte in Ziel-Mem: *)
           For IH2 := 1 To FontHEIGHT[AFontNr] Do
            Begin

             For IH1 := 1 To TextBreite Do
              Begin
               PBH3^ := PBH1^;          (* Kopieren: *)

               Inc(PBH1);               (* Quell-Zeiger +1. *)
               Dec(PBH3, NewTextBreite);(* Ziel -Zeiger 1 Zeile nach unten. *)
              End;

             PBH3 := PH3;
             Inc(PBH3, (TextBreite - 1) * NewTextBreite + IH2);
            End;

           (* So umbiegen, das wieder das Richtige in TEMPMEMSIZE und *)
           (* PH1 steht, f걊 das Kopieren in den Sprite:              *)
           FreeMem(PH1, TempMemSize);
           TempMemSize := NewTempMemSize;
           PH1 := PH3;
          End;
     End;

     (* Planezeiger als ABSOLUTE Zeiger: *)
     LongInt(PlanePtr[0]) := LongInt(PH2) + SizeOf(TSpriteStruct);
     LongInt(PlanePtr[1]) := LongInt(PH2) + SizeOf(TSpriteStruct) +     (TextBreite Div 4) * FontHEIGHT[AFontNr];
     LongInt(PlanePtr[2]) := LongInt(PH2) + SizeOf(TSpriteStruct) + 2 * (TextBreite Div 4) * FontHEIGHT[AFontNr];
     LongInt(PlanePtr[3]) := LongInt(PH2) + SizeOf(TSpriteStruct) + 3 * (TextBreite Div 4) * FontHEIGHT[AFontNr];

     (* In Sprite schreiben: *)
     PBH1 := PH1;                       (* Von vorher zur갷k. *)
     For IH1 := 0 To TempMemSize-1 Do
      Begin
       PlanePtr[IH1 Mod 4]^ := PBH1^;

       Inc(LongInt(PlanePtr[IH1 Mod 4]));
       Inc(LongInt(PBH1));
      End;

     SpriteAD[ASpriteLoadNr] := (LongInt(PH2) Shr 16) + (LongInt(PH2) And 65535) Shr 4;

     (* TempMem wieder freigeben: *)
     FreeMem(PH1, TempMemSize);

     (* R갷kgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE FreeFontMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    Var Size : Word;
        IH1  : Integer;
    Begin
     If (ANr < 1) Or (ANr > FontMAX) Then
      ERR_Error := VGA_Error_InvalidSpriteLoadNr        (* Falsches Argument. *)
     Else
      If FontPTR[ANr] <> Nil Then
       Begin
        (* Speichergr붳e berechnen: *)
        Size := 0;
        For IH1 := 0 To 255 Do
         Size := Size + FontWidthTBL[ANr][IH1] * FontHEIGHT[ANr];

        (* Alles freigeben: *)
        FreeMem(FontPTR[ANr], Size);
        FontPTR[ANr]    := Nil;
        FontTYPE[ANr]   := 0;
        FontHEIGHT[ANr] := 0;
        FontWIDTH[ANr]  := 0;
        FontPROP[ANr]   := 0;
        FillChar(FontWidthTBL[ANr], SizeOf(FontWidthTBL[ANr]), 0);
       End;
    End;

   PROCEDURE ReadString(Var AS : String; APosChg : Integer;
                        ALength, AColor, AAniVer, AX, AY : Word; AChars : Byte;
                        AFontNr : Integer; ACursorChar : Char;
                        Var AExitCode : Byte;
                        AUpCase : Boolean; Chr_Lo, Chr_Hi  : Byte);
    (* ---------------------------------------------------------------- *)
    Const Right  = #077;
          Left   = #075;
          Space  = #032;
          Return = #013;
          BkSp1  = #008;
          BkSp2  = #127;
          Esc    = #027;
          Pos1   = #071;
          PosEnd = #079;
          Entf   = #083;
    Var TextNNr,   TextLOADNr   : Integer;
        CursorNNr, CursorLOADNr : Integer;
        IH1                     : Integer;
        Rk                      : Char;
        Z1                      : Byte;
        OldX1, OldX2            : Integer;
        OldY1, OldY2            : Integer;
    Begin
     (* Cursor erstellen: *)
     CursorNNr := GetFreeNNr;
     CursorLOADNr := GetFreeLOADNr;
     OldX1 := SpriteX[CursorNNr];
     OldY1 := SpriteY[CursorNNr];
     MakeTextSprite(ACursorChar, APosChg, AColor, 1, 1, CursorLOADNr, AFontNr);
     SpriteN[CursorNNr] := CursorLOADNr;
     SpriteX[CursorNNr] := AX;
     SpriteY[CursorNNr] := AY + FontHEIGHT[AFontNr];    (* Cursor 1 darunter. *)

     (* String auf ALENGTH bringen: *)
     AS := '';
     While Length(AS) < ALength Do
      AS := AS + ' ';

     (* String in Sprite wandeln: *)
     TextNNr := GetFreeNNr;
     TextLOADNr := GetFreeLOADNr;
     OldX2 := SpriteX[TextNNr];
     OldY2 := SpriteY[TextNNr];
     MakeTextSprite(AS, APosChg, AColor, 1, 1, TextLOADNr, AFontNr);
     SpriteN[TextNNr] := TextLOADNr;
     SpriteX[TextNNr] := AX;
     SpriteY[TextNNr] := AY;

     (* String zeigen: *)
     Animate;

     (* Voreinstellungen: *)
     Z1 := 1;

     (* Einlese-Schleife: *)
     Repeat
      (* 1 Zeichen einlesen: *)
      Rk := ReadKey;
      If AUpCase Then Rk := UpCase(Rk);
       If Rk = #0 Then                  (* Extended. *)
        Begin
         Rk := ReadKey;
         Case Rk Of
          LEFT   : If Z1 > 1        Then Dec(Z1);
          RIGHT  : If Z1 <= ALength Then Inc(Z1);
          ENTF   : If Z1 > 1        Then AS[Z1] := ' ';
          POS1   : If Z1 > 1        Then Z1 := 1;
          POSEND : If Z1 < ALength  Then Z1 := Length(AS) + 1;
         End;
        End
       Else                             (* Nicht Extended. *)
        Begin
         If Z1 <= ALength Then
          (* Nur, wenn erlaubtes Zeichen: *)
          If (Ord(Rk) In [Chr_Lo .. Chr_Hi]) Then
           Case AChars Of
            0 : If Rk In [#32..#126, #128..#254] Then
                 Begin
                  AS[Z1] := Rk;
                  Inc(Z1);
                 End;
            1 : If Rk In ['A'..'Z', 'a'..'z'] Then
                 Begin
                  AS[Z1] := Rk;
                  Inc(Z1);
                 End;
            2 : If Rk In ['0'..'9'] Then
                 Begin
                  AS[Z1] := Rk;
                  Inc(Z1);
                 End;
          End;
         Case Rk Of
          ESC    : Begin
                    AExitCode := 0;
                    Break;
                   End;
          RETURN : Begin
                    AExitCode := 1;
                    Break;
                   End;
          BKSP1,
          BKSP2  : If Z1 > 1 Then
                    Begin
                     Delete(AS, Z1-1, 1);
                     Insert(' ', AS, Length(AS)+1);
                     Dec(Z1);
                    End;
         End;
        End;

      (* String neu Zeigen: *)
      SpriteX[CursorNNr] := AX;
      If Z1 > 1 Then
       For IH1 := 1 To Z1-1 Do
        SpriteX[CursorNNr] := SpriteX[CursorNNr] +
                              FontWidthTBL[AFontNr][Ord(AS[IH1])] + 1;

      MakeTextSprite(AS, APosChg, AColor, 1, 1, TextLOADNr, AFontNr);
      Animate;

     Until 1 = 2;

     (* Leerstellen am Schlu� l봲chen. *)
     While AS[Length(AS)] = ' ' Do
      Delete(AS, Length(AS), 1);

     (* Sprites freigeben: *)
     FreeSpriteMem(CursorLOADNr);
     FreeSpriteMem(TextLOADNr);

     SpriteN[CursorNNr] := 0;
     SpriteN[TextNNr]   := 0;

     (* Mit Alten Werten wieder besetzen: *)
     SpriteX[CursorNNr] := OldX1;
     SpriteY[CursorNNr] := OldY1;
     SpriteX[TextNNr]   := OldX2;
     SpriteY[TextNNr]   := OldY2;
    End;

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 SYSTEM-ROUTINEN: 같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   PROCEDURE FNTInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(FNTCloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(FNTGetErrorMessage);

     (* Variablen initialisieren: *)
     FillChar(FontPTR     , SizeOf(FontPTR)     , 0);
     FillChar(FontTYPE    , SizeOf(FontTYPE)    , 0);
     FillChar(FontHEIGHT  , SizeOf(FontHEIGHT)  , 0);
     FillChar(FontWIDTH   , SizeOf(FontWIDTH)   , 0);
     FillChar(FontPROP    , SizeOf(FontPROP)    , 0);
     FillChar(FontWidthTBL, SizeOf(FontWidthTBL), 0);
    End;

   PROCEDURE FNTCloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   FUNCTION FNTGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      FNT_Error_NoFNTFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das FNT-Format f걊 Zeichens꼝ze.';
      FNT_Error_No_Font_At_Array_Nr   : S := S + 'Nicht vorhandener Font '+ AS + C +'im FontPTR[]-Feld angesprochen.';

      Else                              S := '';
     End;

     FNTGetErrorMessage := S;
    End;

  (* 컴 INITIALISIERUNGS훂EIL: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   BEGIN
    FNTInitRoutines;
   END.

 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)