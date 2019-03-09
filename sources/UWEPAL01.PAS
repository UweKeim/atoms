 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)
 (*  Programm : UWEPAL01                                                   *)
 (*             Routinen zum manipulieren von Paletten.                    *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UWEPAL01.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 31. August 1994                                            *)
 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)

 UNIT UWEPAL01;

  {$A-,B-,D-,E+,F+,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE ONEFILE}                     (* Ob alles aus 1 groáen Datei gelesen wird. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- ™FFENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   (* ÄÄ Verschiedene Erkl„rungen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ----------------------------------------------------------- *)
   (*  Erzeugung von BIBLIOTHEKEN:                                *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~~~~~                                *)
   (*                                                             *)
   (*  Bibliotheken werden erzeugt, indem man die einzelnen       *)
   (*  Dateien mittels des COPY-Befehls zusammenkopiert.          *)
   (*  Dabei ist GANZ WICHTIG (!), daá man VOR (!) der Liste der  *)
   (*  zu kopierenden Dateien die Option "/B" fr Bin„rdateien    *)
   (*  setzt, da sonst die L„nge nicht stimmt (der Inhalt         *)
   (*  natrlich auch nicht).                                     *)
   (*                                                             *)
   (*  Beispiel: "COPY /B <Datei1.xxx> + <Datei2.xxx> +           *)
   (*            <Datei3.xxx>   <BibliotheksDatei.xxx>".          *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (* Aufbau einer Paletten-Datei '????????.PAL':                 *)
   (*                                                             *)
   (* 00..01  DB  'U', 'K'         =  Kennung                     *)
   (* 02..02  DB  1                =  Version                     *)
   (* 03..05  DB  'P', 'A', 'L'    =  PALetten-Datei              *)
   (* 06..06  DW  ?                =  Anzahl an R,G,B-Eintr„gen   *)
   (*                                 0 = 1 Eintrag, 255 = Alle   *)
   (* 07..29  DB  ?                =  Dummy, fr sp„tere          *)
   (*                                 Erweiterungen frei          *)
   (* 30..EOF DB  <R, G, B>, ...   =  Farbdaten.                  *)
   (*                                                             *)
   (* Die Farbwerte k”nnen im Bereich zwischen 0 und 255 liegen,  *)
   (* MšSSEN also fr VGA noch umgerechnet werden durch "/ 4" !   *)
   (*                                                             *)
   (* Wenn die Datei dann im Speicher ist, mittels "LOADPAL(..)", *)
   (* sind die Werte bereits umgerechnet !!!                      *)
   (* ----------------------------------------------------------- *)

   (* ÄÄ Verschiedene Typen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   TYPE TPaletteEntry = Record
                         Red, Green, Blue : Byte;
                        End;

        TPalette      = Array[0..255] Of TPaletteEntry;

        TPALHeader    = Record          (* Header der Palettendatei. *)
                         Kennung : Array[1..2] Of Char;
                         Version : Byte;
                         Art     : Array[1..3] Of Char;
                         AnzRGB  : Byte;
                         Dummy   : Array[1..23] Of Byte;
                        End;

   (* ÄÄ Verschiedene Konstanten: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   CONST (* Eigene Fehlercodes: 0450-0499: *)
         PAL_Error_NoPALFile             = 0450;
         PAL_Error_InvalidArgumentValues = 0451;
         PAL_Error_PALFieldIsFull        = 0452;

         (* Paletten-Konstanten: *)
         DefaultColors : TPalette = ((Red : 00; Green : 00; Blue : 00), (Red : 00; Green : 00; Blue : 42),
                                     (Red : 00; Green : 42; Blue : 00), (Red : 00; Green : 42; Blue : 42),
                                     (Red : 42; Green : 00; Blue : 00), (Red : 42; Green : 00; Blue : 42),
                                     (Red : 42; Green : 21; Blue : 00), (Red : 42; Green : 42; Blue : 42),
                                     (Red : 21; Green : 21; Blue : 21), (Red : 21; Green : 21; Blue : 63),
                                     (Red : 21; Green : 63; Blue : 21), (Red : 21; Green : 63; Blue : 63),
                                     (Red : 63; Green : 21; Blue : 21), (Red : 63; Green : 21; Blue : 63),
                                     (Red : 63; Green : 63; Blue : 21), (Red : 63; Green : 63; Blue : 63),
                                     (Red : 00; Green : 00; Blue : 00), (Red : 05; Green : 05; Blue : 05),
                                     (Red : 08; Green : 08; Blue : 08), (Red : 11; Green : 11; Blue : 11),
                                     (Red : 14; Green : 14; Blue : 14), (Red : 17; Green : 17; Blue : 17),
                                     (Red : 20; Green : 20; Blue : 20), (Red : 24; Green : 24; Blue : 24),
                                     (Red : 28; Green : 28; Blue : 28), (Red : 32; Green : 32; Blue : 32),
                                     (Red : 36; Green : 36; Blue : 36), (Red : 40; Green : 40; Blue : 40),
                                     (Red : 45; Green : 45; Blue : 45), (Red : 50; Green : 50; Blue : 50),
                                     (Red : 56; Green : 56; Blue : 56), (Red : 63; Green : 63; Blue : 63),
                                     (Red : 00; Green : 00; Blue : 63), (Red : 16; Green : 00; Blue : 63),
                                     (Red : 31; Green : 00; Blue : 63), (Red : 47; Green : 00; Blue : 63),
                                     (Red : 63; Green : 00; Blue : 63), (Red : 63; Green : 00; Blue : 47),
                                     (Red : 63; Green : 00; Blue : 31), (Red : 63; Green : 00; Blue : 16),
                                     (Red : 63; Green : 00; Blue : 00), (Red : 63; Green : 16; Blue : 00),
                                     (Red : 63; Green : 31; Blue : 00), (Red : 63; Green : 47; Blue : 00),
                                     (Red : 63; Green : 63; Blue : 00), (Red : 47; Green : 63; Blue : 00),
                                     (Red : 31; Green : 63; Blue : 00), (Red : 16; Green : 63; Blue : 00),
                                     (Red : 00; Green : 63; Blue : 00), (Red : 00; Green : 63; Blue : 16),
                                     (Red : 00; Green : 63; Blue : 31), (Red : 00; Green : 63; Blue : 47),
                                     (Red : 00; Green : 63; Blue : 63), (Red : 00; Green : 47; Blue : 63),
                                     (Red : 00; Green : 31; Blue : 63), (Red : 00; Green : 16; Blue : 63),
                                     (Red : 31; Green : 31; Blue : 63), (Red : 39; Green : 31; Blue : 63),
                                     (Red : 47; Green : 31; Blue : 63), (Red : 55; Green : 31; Blue : 63),
                                     (Red : 63; Green : 31; Blue : 63), (Red : 63; Green : 31; Blue : 55),
                                     (Red : 63; Green : 31; Blue : 47), (Red : 63; Green : 31; Blue : 39),
                                     (Red : 63; Green : 31; Blue : 31), (Red : 63; Green : 39; Blue : 31),
                                     (Red : 63; Green : 47; Blue : 31), (Red : 63; Green : 55; Blue : 31),
                                     (Red : 63; Green : 63; Blue : 31), (Red : 55; Green : 63; Blue : 31),
                                     (Red : 47; Green : 63; Blue : 31), (Red : 39; Green : 63; Blue : 31),
                                     (Red : 31; Green : 63; Blue : 31), (Red : 31; Green : 63; Blue : 39),
                                     (Red : 31; Green : 63; Blue : 47), (Red : 31; Green : 63; Blue : 55),
                                     (Red : 31; Green : 63; Blue : 63), (Red : 31; Green : 55; Blue : 63),
                                     (Red : 31; Green : 47; Blue : 63), (Red : 31; Green : 39; Blue : 63),
                                     (Red : 45; Green : 45; Blue : 63), (Red : 49; Green : 45; Blue : 63),
                                     (Red : 54; Green : 45; Blue : 63), (Red : 58; Green : 45; Blue : 63),
                                     (Red : 63; Green : 45; Blue : 63), (Red : 63; Green : 45; Blue : 58),
                                     (Red : 63; Green : 45; Blue : 54), (Red : 63; Green : 45; Blue : 49),
                                     (Red : 63; Green : 45; Blue : 45), (Red : 63; Green : 49; Blue : 45),
                                     (Red : 63; Green : 54; Blue : 45), (Red : 63; Green : 58; Blue : 45),
                                     (Red : 63; Green : 63; Blue : 45), (Red : 58; Green : 63; Blue : 45),
                                     (Red : 54; Green : 63; Blue : 45), (Red : 49; Green : 63; Blue : 45),
                                     (Red : 45; Green : 63; Blue : 45), (Red : 45; Green : 63; Blue : 49),
                                     (Red : 45; Green : 63; Blue : 54), (Red : 45; Green : 63; Blue : 58),
                                     (Red : 45; Green : 63; Blue : 63), (Red : 45; Green : 58; Blue : 63),
                                     (Red : 45; Green : 54; Blue : 63), (Red : 45; Green : 49; Blue : 63),
                                     (Red : 00; Green : 00; Blue : 28), (Red : 07; Green : 00; Blue : 28),
                                     (Red : 14; Green : 00; Blue : 28), (Red : 21; Green : 00; Blue : 28),
                                     (Red : 28; Green : 00; Blue : 28), (Red : 28; Green : 00; Blue : 21),
                                     (Red : 28; Green : 00; Blue : 14), (Red : 28; Green : 00; Blue : 07),
                                     (Red : 28; Green : 00; Blue : 00), (Red : 28; Green : 07; Blue : 00),
                                     (Red : 28; Green : 14; Blue : 00), (Red : 28; Green : 21; Blue : 00),
                                     (Red : 28; Green : 28; Blue : 00), (Red : 21; Green : 28; Blue : 00),
                                     (Red : 14; Green : 28; Blue : 00), (Red : 07; Green : 28; Blue : 00),
                                     (Red : 00; Green : 28; Blue : 00), (Red : 00; Green : 28; Blue : 07),
                                     (Red : 00; Green : 28; Blue : 14), (Red : 00; Green : 28; Blue : 21),
                                     (Red : 00; Green : 28; Blue : 28), (Red : 00; Green : 21; Blue : 28),
                                     (Red : 00; Green : 14; Blue : 28), (Red : 00; Green : 07; Blue : 28),
                                     (Red : 14; Green : 14; Blue : 28), (Red : 17; Green : 14; Blue : 28),
                                     (Red : 21; Green : 14; Blue : 28), (Red : 24; Green : 14; Blue : 28),
                                     (Red : 28; Green : 14; Blue : 28), (Red : 28; Green : 14; Blue : 24),
                                     (Red : 28; Green : 14; Blue : 21), (Red : 28; Green : 14; Blue : 17),
                                     (Red : 28; Green : 14; Blue : 14), (Red : 28; Green : 17; Blue : 14),
                                     (Red : 28; Green : 21; Blue : 14), (Red : 28; Green : 24; Blue : 14),
                                     (Red : 28; Green : 28; Blue : 14), (Red : 24; Green : 28; Blue : 14),
                                     (Red : 21; Green : 28; Blue : 14), (Red : 17; Green : 28; Blue : 14),
                                     (Red : 14; Green : 28; Blue : 14), (Red : 14; Green : 28; Blue : 17),
                                     (Red : 14; Green : 28; Blue : 21), (Red : 14; Green : 28; Blue : 24),
                                     (Red : 14; Green : 28; Blue : 28), (Red : 14; Green : 24; Blue : 28),
                                     (Red : 14; Green : 21; Blue : 28), (Red : 14; Green : 17; Blue : 28),
                                     (Red : 20; Green : 20; Blue : 28), (Red : 22; Green : 20; Blue : 28),
                                     (Red : 24; Green : 20; Blue : 28), (Red : 26; Green : 20; Blue : 28),
                                     (Red : 28; Green : 20; Blue : 28), (Red : 28; Green : 20; Blue : 26),
                                     (Red : 28; Green : 20; Blue : 24), (Red : 28; Green : 20; Blue : 22),
                                     (Red : 28; Green : 20; Blue : 20), (Red : 28; Green : 22; Blue : 20),
                                     (Red : 28; Green : 24; Blue : 20), (Red : 28; Green : 26; Blue : 20),
                                     (Red : 28; Green : 28; Blue : 20), (Red : 26; Green : 28; Blue : 20),
                                     (Red : 24; Green : 28; Blue : 20), (Red : 22; Green : 28; Blue : 20),
                                     (Red : 20; Green : 28; Blue : 20), (Red : 20; Green : 28; Blue : 22),
                                     (Red : 20; Green : 28; Blue : 24), (Red : 20; Green : 28; Blue : 26),
                                     (Red : 20; Green : 28; Blue : 28), (Red : 20; Green : 26; Blue : 28),
                                     (Red : 20; Green : 24; Blue : 28), (Red : 20; Green : 22; Blue : 28),
                                     (Red : 00; Green : 00; Blue : 16), (Red : 04; Green : 00; Blue : 16),
                                     (Red : 08; Green : 00; Blue : 16), (Red : 12; Green : 00; Blue : 16),
                                     (Red : 16; Green : 00; Blue : 16), (Red : 16; Green : 00; Blue : 12),
                                     (Red : 16; Green : 00; Blue : 08), (Red : 16; Green : 00; Blue : 04),
                                     (Red : 16; Green : 00; Blue : 00), (Red : 16; Green : 04; Blue : 00),
                                     (Red : 16; Green : 08; Blue : 00), (Red : 16; Green : 12; Blue : 00),
                                     (Red : 16; Green : 16; Blue : 00), (Red : 12; Green : 16; Blue : 00),
                                     (Red : 08; Green : 16; Blue : 00), (Red : 04; Green : 16; Blue : 00),
                                     (Red : 00; Green : 16; Blue : 00), (Red : 00; Green : 16; Blue : 04),
                                     (Red : 00; Green : 16; Blue : 08), (Red : 00; Green : 16; Blue : 12),
                                     (Red : 00; Green : 16; Blue : 16), (Red : 00; Green : 12; Blue : 16),
                                     (Red : 00; Green : 08; Blue : 16), (Red : 00; Green : 04; Blue : 16),
                                     (Red : 08; Green : 08; Blue : 16), (Red : 10; Green : 08; Blue : 16),
                                     (Red : 12; Green : 08; Blue : 16), (Red : 14; Green : 08; Blue : 16),
                                     (Red : 16; Green : 08; Blue : 16), (Red : 16; Green : 08; Blue : 14),
                                     (Red : 16; Green : 08; Blue : 12), (Red : 16; Green : 08; Blue : 10),
                                     (Red : 16; Green : 08; Blue : 08), (Red : 16; Green : 10; Blue : 08),
                                     (Red : 16; Green : 12; Blue : 08), (Red : 16; Green : 14; Blue : 08),
                                     (Red : 16; Green : 16; Blue : 08), (Red : 14; Green : 16; Blue : 08),
                                     (Red : 12; Green : 16; Blue : 08), (Red : 10; Green : 16; Blue : 08),
                                     (Red : 08; Green : 16; Blue : 08), (Red : 08; Green : 16; Blue : 10),
                                     (Red : 08; Green : 16; Blue : 12), (Red : 08; Green : 16; Blue : 14),
                                     (Red : 08; Green : 16; Blue : 16), (Red : 08; Green : 14; Blue : 16),
                                     (Red : 08; Green : 12; Blue : 16), (Red : 08; Green : 10; Blue : 16),
                                     (Red : 11; Green : 11; Blue : 16), (Red : 12; Green : 11; Blue : 16),
                                     (Red : 13; Green : 11; Blue : 16), (Red : 15; Green : 11; Blue : 16),
                                     (Red : 16; Green : 11; Blue : 16), (Red : 16; Green : 11; Blue : 15),
                                     (Red : 16; Green : 11; Blue : 13), (Red : 16; Green : 11; Blue : 12),
                                     (Red : 16; Green : 11; Blue : 11), (Red : 16; Green : 12; Blue : 11),
                                     (Red : 16; Green : 13; Blue : 11), (Red : 16; Green : 15; Blue : 11),
                                     (Red : 16; Green : 16; Blue : 11), (Red : 15; Green : 16; Blue : 11),
                                     (Red : 13; Green : 16; Blue : 11), (Red : 12; Green : 16; Blue : 11),
                                     (Red : 11; Green : 16; Blue : 11), (Red : 11; Green : 16; Blue : 12),
                                     (Red : 11; Green : 16; Blue : 13), (Red : 11; Green : 16; Blue : 15),
                                     (Red : 11; Green : 16; Blue : 16), (Red : 11; Green : 15; Blue : 16),
                                     (Red : 11; Green : 13; Blue : 16), (Red : 11; Green : 12; Blue : 16),
                                     (Red : 00; Green : 00; Blue : 00), (Red : 00; Green : 00; Blue : 00),
                                     (Red : 00; Green : 00; Blue : 00), (Red : 00; Green : 00; Blue : 00),
                                     (Red : 00; Green : 00; Blue : 00), (Red : 00; Green : 00; Blue : 00),
                                     (Red : 00; Green : 00; Blue : 00), (Red : 00; Green : 00; Blue : 00));

         (* Palettenanzahl: *)
         PALMAX = 2;                    (* Anzahl gleichzeitig geladenen Paletten. *)

   (* ÄÄ Verschiedene Variablen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   VAR PALHeader    : TPALHeader;       (* Siehe TPALHeader, oben. *)

       ActualColors : TPalette;         (* Aktuelle Farbpalette. *)
       ZeroColors   : TPalette;         (* Alles SCHWARZ, wird in PALINITROUTINES aufgefllt. *)

       PALField     : Array[0..PALMAX] Of TPalette;

   (* ÄÄ Prototypen der Prozeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   PROCEDURE SavePalette(AFName : String; AFirst, ACount : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Speichert eine Palettendatei, oder eine Paletten-     *)
    (*            Bibliothek !                                          *)
    (* Eingabe  : AFNAME = Dateiname del .PAL - Datei,                  *)
    (*            AFIRST = 1. Feld in PALFIELD[.], in das geschrieben   *)
    (*                     wird,                                        *)
    (*            ACOUNT = Anzahl der Felder in PALFIELD[.], die        *)
    (*                     geschrieben werden.                          *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadPalette(AFName : String; AFirst : Word) : Byte;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : L„dt eine Palettendatei, oder eine Paletten-          *)
    (*            Bibliothek !                                          *)
    (* Eingabe  : AFNAME = Dateiname del .PAL - Datei,                  *)
    (*            AFIRST = 1.Feld in PALFIELD[.], in das gelesen wird.  *)
    (* Rckgabe : Anzahl der aus der Datei gelesenen Paletten.          *)
    (* Hinweis  : Die Palette(n) muá noch mit SETPALETTE() gesetzt      *)
    (*            werden.                                               *)
    (*            Die Paletten-DATEI(!)-Eintr„ge werden gleich mit      *)
    (*            "DIV 4" umgewandelt.                                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetPalette(Var APal : TPalette);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : ndert die physikalische Palette.                     *)
    (* Eingabe  : APAL = Die zu zeigende Palette.                       *)
    (* Rckgabe : ACTUALCOLORS wird mit APAL belegt.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GetPalette(Var APal : TPalette);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest die physikalische Palette.                      *)
    (* Eingabe  : APAL = Die Palette, in die gelesen wird,              *)
    (* Rckgabe : APAL.                                                 *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FadeToPalette(DestPal : TPalette; AnzSteps : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Blendet von ACTUALCOLOR ber.                         *)
    (* Eingabe  : DESTPAL  = Neu Palette.                               *)
    (*            ANZSTEPS = Verz”gerung beim Blenden.                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PALInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles N”tige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PALCloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgem„á.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION PALGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.  *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                            *)
    (*             AS        = Eventueller zus„tzlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  Rckgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   USES Crt,
        UweERR01,

        {$IFDEF ONEFILE}
        ONEFile1,
        {$ENDIF}

        UweUNI01;

   (* ÄÄ Verschiedene Konstanten: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ÄÄ Verschiedene Typen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ÄÄ Verschiedene Variablen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   VAR CRTAddress   : Word;             (* Port-Adresse des CRT-Chips, verschieden bei MONO- und COLOR-Vga. *)
       StatusReg    : Word;             (* Port-Adresse des Statusregisters, verschieden bei MONO- und COLOR-Vga. *)

   (* ÄÄ Prototypen der ImplementationsÄProzeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ÄÄ Rmpfe der ImplementationsÄProzeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ÄÄ InterfaceÄProzeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   PROCEDURE SavePalette(AFName : String; AFirst, ACount : Word);
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PH1       : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}

        HPal      : TPalette;           (* Hilfspalette. *)
        IH1, IH2  : Integer;
        PB1       : ^Byte;

    Begin
     If (AFirst < 0) Or (AFirst > PALMAX) Then
      Begin
       ERR_Error := PAL_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Datei ™ffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);
     {$ELSE}
     Rewrite(F, 1);                     (* BlockRead-L„nge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     For IH1 := 1 To ACount Do
      Begin
       (* Ggf. Ende: *)
       If AFirst > PALMAX Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := PAL_Error_PALFieldIsFull;
         CriticalError(AFName);
        End;

       (* Header erstellen: *)
       With PALHeader Do
        Begin
         Kennung := 'UK';
         Version := 1;
         Art     := 'PAL';
         AnzRGB  := 255;
         FillChar(Dummy, SizeOf(Dummy), 0);
        End;

       (* Header schreiben: *)
       {$I-}

       {$IFDEF ONEFILE}
       PH1 := @PALHeader;
       _BlockWrite(F, PH1, SizeOf(PALHeader));
       {$ELSE}
       BlockWrite(F, PALHeader, SizeOf(PALHeader));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Palette ermitteln: *)
       HPal := PALField[AFirst];

       (* Alle Werte auf PAL umrechnen (* 4): *)
       PB1 := @HPal;
       For IH2 := 1 To 256*3 Do
        Begin
         PB1^ := PB1^ * 4;
         Inc(PB1);
        End;

       {$I-}

       {$IFDEF ONEFILE}
       PH1 := @HPal;
       _BlockWrite(F, PH1, 256*3);
       {$ELSE}
       BlockWrite(F, HPal, 256*3);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       Inc(AFirst);                     (* N„chstes Feld. *)
      End;

     (* Datei schlieáen: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);
    End;

   FUNCTION LoadPalette(AFName : String; AFirst : Word) : Byte;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PH1       : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}

        HPal      : TPalette;           (* Hilfspalette. *)
        ReadCount : Integer;
        IH1       : Integer;
        PB1       : ^Byte;

    Begin
     If (AFirst < 0) Or (AFirst > PALMAX) Then
      Begin
       ERR_Error := PAL_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Datei ™ffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-L„nge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     ReadCount := 0;

     {$I-}

     {$IFDEF ONEFILE}
     While Not _EOF(F) Do               (* Je 1 Palettendatei aus ggf. Bibliothek lesen. *)
     {$ELSE}
     While Not EOF(F) Do                (* Je 1 Palettendatei aus ggf. Bibliothek lesen. *)
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       Inc(ReadCount);

       (* Ggf. Ende: *)
       If AFirst > PALMAX Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := PAL_Error_PALFieldIsFull;
         CriticalError(AFName);
        End;

       (* Lesen, Header: *)
       {$I-}

       {$IFDEF ONEFILE}
       PH1 := @PALHeader;
       _BlockRead(F, PH1, SizeOf(PALHeader));
       {$ELSE}
       PB1 := @PALHeader;
       BlockRead(F, PB1^, SizeOf(PALHeader));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Header auswerten: *)
       If (PALHeader.Kennung <> 'UK') Or (PALHeader.Art <> 'PAL') Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := PAL_Error_NoPALFile;
         CriticalError(AFName);
        End;

       {$I-}

       {$IFDEF ONEFILE}
       PH1 := @HPal;
       _BlockRead(F, PH1, 256*3);
       {$ELSE}
       PB1 := @HPal;
       BlockRead(F, PB1^, 256*3);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Alle Werte auf PAL umrechnen (/ 4): *)
       PB1 := @HPal;
       For IH1 := 1 To 256*3 Do
        Begin
         PB1^ := PB1^ Shr 2;
         Inc(PB1);
        End;

       (* Wert bergeben: *)
       PALField[AFirst] := HPal;

       Inc(AFirst);                     (* N„chstes Feld. *)
      End;                              (* Von "WHILE NOT EOF(F)". *)
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Datei schlieáen: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Rckgabe: *)
     LoadPalette := ReadCount;
    End;

   PROCEDURE SetPalette(Var APal : TPalette);
    (* ---------------------------------------------------------------- *)
    Begin
     If @APal <> @ActualColors Then ActualColors := APal;

     Asm
      cld
      mov   si, OFFSET ActualColors     (* DS:SI = ^ActualColors[]. *)

      cli

      mov   dx, StatusReg
     @WaitNotVSyncLoop:
      in    al, dx
      and   al, 8
      jnz   @WaitNotVSyncLoop
     @WaitVSyncLoop:
      in    al, dx
      and   al, 8
      jz    @WaitVSyncLoop

      mov   dx, 3C8h
      xor   al, al
      out   dx, al
      inc   dx

      mov   cx, 256 / 2

     @L1:
      lodsw
      out   dx, al
      mov   al, ah
      out   dx, al
      lodsw
      out   dx, al
      mov   al, ah
      out   dx, al
      lodsw
      out   dx, al
      mov   al, ah
      out   dx, al
      loop  @L1

      sti
     End;
    End;

   PROCEDURE GetPalette(Var APal : TPalette); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     cld
     cli

     xor   al, al
     mov   dx, 3C7h
     out   dx, al
     les   di, APal
     mov   cx, 768
     mov   dx, 3C9h

    @L1:
     in    al, dx
     stosb
     loop  @L1

     sti
    End;

   PROCEDURE FadeToPalette(DestPal : TPalette; AnzSteps : Word);
    (* ---------------------------------------------------------------- *)
    Var OldColors, Pal : TPalette;
        I, Steps       : Integer;
        S, D           : Pointer;
    Begin
     Dec(AnzSteps);
     If AnzSteps < 1 Then Steps := 1
     Else Steps := AnzSteps;            (* Steps ins selbe Segment wie Pal bringen. *)

     OldColors := ActualColors;
     Pal := Destpal;                    (* Pal und OldColors ins selbe Segment bringen. *)
     S := @Pal; D:= @ActualColors;

     For I := 0 To Steps-1 Do
      Begin
       Asm
        les   di, D                     (* ES:DI = Zeiger auf ActualColors-Tabelle. *)
        lds   si, S                     (* DS:SI = Zeiger auf Pal-Tabelle. *)
        mov   bx, OFFSET OldColors - OFFSET Pal - 1
                                        (* DS:SI+BX+1 = Zeiger auf OldColors. *)
        mov   cx, 256

       @DoColor:

        xor   ah, ah
        lodsb                           (* AX := Pal[C].Red. *)
        sub   al, [si+bx]
        sbb   ah, 0                     (* AX := Pal[C].Red - OldColors[C].Red = Delta. *)
        imul  I                         (* DX:AX := Delta * I. *)
        idiv  Steps                     (* AX := Delta * I/Steps. *)
        Add   al, [si+bx]               (* AX := Delta * I/Steps + OldColors[C].Red. *)
        stosb

        (* Dto. fr Grn: *)
        xor   ah, ah
        lodsb
        sub   al, [si+bx]
        sbb   ah, 0
        imul  I
        idiv  Steps
        Add   al, [si+bx]
        stosb

        (* Dto. fr Blau: *)
        xor   ah, ah
        lodsb
        sub   al, [si+bx]
        sbb   ah, 0
        imul  I
        idiv  Steps
        Add   al, [si+bx]
        stosb

        Loop @DoColor

        mov   ax, SEG @Data
        mov   ds, ax
       End;
       SetPalette(ActualColors);
      End;
     SetPalette(Pal);
    End;

   PROCEDURE PALInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(PALCloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(PALGetErrorMessage);

     (* Ermitteln, ob Farb- oder Monochromdarstellung: *)
     Asm
      mov   dx, 3CCh                    (* Output-Register befragen. *)
      in    al, dx
      test  al, 1                       (* Ist es ein Farbbildschirm ? *)
      mov   dx, 3D4h
      jnz   @L1                         (* Ja. *)
      mov   dx, 3B4h                    (* Nein. *)
     @L1:                               (* DX = 3B4h / 3D4h = CRTAddress-Register fr monochrom/Farbe. *)
      mov   CRTAddress, dx
      add   dx, 6                       (* DX = 3BAh / 3DAh = Status-Register fr monochrom/Farbe. *)
      mov   StatusReg, dx
     End;

     (* Paletten vorbelegen: *)
     ActualColors := DefaultColors;     (* Standartpalette setzen. *)
     SetPalette(ActualColors);

     FillChar(ZeroColors, SizeOf(ZeroColors), 0);
                                        (* Alles SCHWARZ. *)
     FillChar(PALField, SizeOf(PALField), 0);
    End;

   PROCEDURE PALCloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Videomodus 3 setzen: *)
     Asm
      mov   ax, 0003h
      int   10h
     End;

     (* Palette wiederherstellen: *)
     ActualColors := DefaultColors;
     SetPalette(ActualColors);
    End;

   FUNCTION PALGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      PAL_Error_NoPALFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das PAL-Format fr Paletten.';
      PAL_Error_InvalidArgumentValues : S := S + 'šbergebene Werte nicht zugelassen.';
      PAL_Error_PALFieldIsFull        : S := S + 'PAL-FIELD-Feld ist voll.';

      Else                              S := '';
     End;

     PALGetErrorMessage := S;
    End;

  (* ÄÄ INITIALISIERUNGSÄTEIL: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   BEGIN
    PALInitRoutines;
   END.

 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)