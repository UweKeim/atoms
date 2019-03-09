 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)
 (*  Programm : UWEVGA01                                                   *)
 (*             Animationspaket, in Unitform.                              *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UWEVGA01.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 10. April 1994                                             *)
 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

 UNIT UWEVGA01;

  {$A+,B-,D+,L+,N-,E-,O-,R-,S-,V-,G+,F-,I-,X-}
  {$P-,Q-,T-}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE ONEFILE}                     (* Ob alles aus 1 gro·en Datei gelesen wird. *)
  {$UNDEF  BackGrPageInRAM}             (* Ob Hintergrundseite im RAM oder VRAM. *)
  {$UNDEF  UseScrolling}                (* Ob Gescrollt wird oder nicht. *)
  {$UNDEF  ScrollPageInRAM}             (* Ob ScrollPage im normalen RAM liegt oder nicht. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y-}                           (* Debug-Infos an. *)
  {$ELSE}
  {$D-,L-,Y-}                           (* Debug-Infos aus. *)
  {$ENDIF}

  (* -- ôFFENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   USES Crt, Dos,
        UweERR01,

        {$IFDEF ONEFILE}
        ONEFile1,                       (* Routinen zum lesen aus Datei-Lib. *)
        {$ENDIF}

        UwePAL01,                       (* Paletten-Routinen. *)
        UweUNI01;                       (* Allgemeine Routinen. *)

   (* ƒƒ Verschiedene ErklÑrungen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ----------------------------------------------------------- *)
   (*  Hinweise zum scrollenden Hintergrund:                      *)
   (*                                                             *)
   (*  Wenn das Animationsfenster GRô·ER ist als der scrollbare   *)
   (*  Breich, gibts zum Teil MöLL auf dem Schirm (am Ende        *)
   (*  werden schon die Kacheln der neuen Zeile gezeichnet).      *)
   (*  Dies habe ich aber (noch (?)) nicht abgefangen, da es      *)
   (*  sonst zu langsam wird und das in der Regel ja nicht vor-   *)
   (*  kommen sollte, da dann ja STATIC Background sinnvoller     *)
   (*  wÑre.                                           (31.10.94) *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (*  Erzeugung von SPRITE-BIBLIOTHEKEN:                         *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                         *)
   (*                                                             *)
   (*  Bibliotheken werden erzeugt, indem man die einzelnen       *)
   (*  Dateien mittels des COPY-Befehls zusammenkopiert.          *)
   (*  Dabei ist GANZ WICHTIG (!), da· man VOR (!) der Liste der  *)
   (*  zu kopierenden Dateien die Option "/B" fÅr BinÑrdateien    *)
   (*  setzt, da sonst die LÑnge nicht stimmt (der Inhalt         *)
   (*  natÅrlich auch nicht).                                     *)
   (*                                                             *)
   (*  Beispiel: "COPY /B <Datei1.xxx> + <Datei2.xxx> +           *)
   (*            <Datei3.xxx>   <BibliotheksDatei.xxx>".          *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (* Aufbau einer Sprite-Datei '????????.SPR':                   *)
   (*                                                             *)
   (* 00..01  DB  'U', 'K'         =  Kennung                     *)
   (* 02..02  DB  1                =  Version                     *)
   (* 03..05  DB  'S', 'P', 'R'    =  SPRite-Datei                *)
   (* 06..07  DW  ?                =  Breite in Feldern           *)
   (* 08..09  DW  ?                =  Hoehe in Feldern            *)
   (* 10..49  DB  ?                =  Dummy, fÅr spÑtere          *)
   (*                                 Erweiterungen frei          *)
   (* 50..EOF DB  <Daten, Ebene0>                                 *)
   (*             <Daten, Ebene1>                                 *)
   (*             <Daten, Ebene2>                                 *)
   (*             <Daten, Ebene3>  = Pixel-Daten des Sprites.     *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (* Aufbau einer Hintergrunds-Datei '????????.TIL':             *)
   (*                                                             *)
   (* 00..01  DB  'U', 'K'         =  Kennung                     *)
   (* 02..02  DB  1                =  Version                     *)
   (* 03..05  DB  'T', 'I', 'L'    =  TILe-Datei                  *)
   (* 06..07  DW  ?                =  Breite in Tiles             *)
   (* 08..09  DW  ?                =  Hoehe in Tiles              *)
   (* 10..49  DB  ?                =  Dummy, fÅr spÑtere          *)
   (*                                 Erweiterungen frei          *)
   (* 50..EOF DW  <Daten der Kachel-Nummern>                      *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (* Aufbau einer Image-Datei '????????.IMG':                    *)
   (*                                                             *)
   (* 00..01  DB  'U', 'K'         =  Kennung                     *)
   (* 02..02  DB  1                =  Version                     *)
   (* 03..05  DB  'I', 'M', 'G'    =  IMaGe-Datei                 *)
   (* 06..07  DW  ?                =  Breite in Pixeln            *)
   (* 08..09  DW  ?                =  Hoehe in Pixeln             *)
   (* 10..49  DB  ?                =  Dummy, fÅr spÑtere          *)
   (*                                 Erweiterungen frei          *)
   (* 50..EOF DB  <Daten, Ebene0>                                 *)
   (*             <Daten, Ebene1>                                 *)
   (*             <Daten, Ebene2>                                 *)
   (*             <Daten, Ebene3>  = Pixel-Daten des Bildes       *)
   (*                                                             *)
   (* AUFBAU GLEICH WIE SPRITE-DATEI !                            *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (*  Zur Hintergrundseite:                                      *)
   (*                                                             *)
   (*  Es ist mîglich, die STATISCHE Hintergrundseite entweder    *)
   (*  im Video-RAM (VRAM) zu speichern oder im normalen RAM      *)
   (*  (auf dem HEAP also).                                       *)
   (*  Dies kann entschieden werden mittels der Prozedur          *)
   (*  "SetStaticBackGroundMode(..)".                             *)
   (* ----------------------------------------------------------- *)

   (* ƒƒ Verschiedene Typen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

         (* So wird ein Sprite im SPEICHER gespeichert: *)
   TYPE  TSpriteStruct       = Record
                                BreiteInBytes : Word;
                                HoeheInZ      : Word;
                                Translate     : Array[01..04] Of Byte;
                                PlaneDatPtr   : Array[00..03] Of Word;
                                Dummy         : Array[01..43] Of Byte;
                                (* Ab Hier kommen dann die Spritedaten. *)
                               End;
   VAR   SpriteStruct        : TSpriteStruct;   (* Siehe TSpriteStruct, oben. *)
       
                (* So wird ein Sprite auf DISK gespeichert: *)
   TYPE  TSPRHeader          = Record
                                Kennung : Array[1..2] Of Char;
                                Version : Byte;
                                Art     : Array[1..3] Of Char;
                                Breite  : Word;
                                Hoehe   : Word;
                                Dummy   : Array[1..40] Of Byte;
                               End;

         (* So werden die Daten Åber einen scrollbaren Hintergrund  *)
         (* auf Disk gespeichert, dies sind NUR die Positionen der  *)
         (* Tiles, nicht aber die Grafikdaten (diese mÅssen mittels *)
         (* "LoadTile(..)" eingelesen werden:                       *)
         TTILHeader          = Record
                                Kennung   : Array[1..2] Of Char;
                                Version   : Byte;
                                Art       : Array[1..3] Of Char;
                                BreiteInT : Word;
                                HoeheInT  : Word;
                                Dummy     : Array[1..40] Of Byte;
                               End;

         (* So wird ein Image-Bild im SPEICHER gespeichert: *)
         (* (Auf DISK wird es wie "SPRHEADER" gespeichert). *)
         TIMGHeader          = TSpriteStruct;

         (* So wird ein PCX-Bild auf DISK gespeichert: *)
         TPCXHeader          = Record
                                Hersteller    : Byte;
                                Version       : Byte;
                                CodierArt     : Byte;
                                BitProPixel   : Byte;
                                Bildgroesse   : Array[1..4] Of Word;
                                HorizAufl     : Word;
                                VertiAufl     : Word;
                                Farbskala     : Array[1..48] Of Byte;
                                Reserviert    : Byte;
                                Farbebenen    : Byte;
                                BytesProZeile : Word;
                                FarbeOdGrau   : Word;
                                Fueller       : Array[1..58] Of Byte;
                               End;

         (* Mîglichkeiten, eine statische Hintergrundsseite zu verwalten: *)
         TStaticBkMode       = (RAM, VRAM);    (* Entweder Video- oder normales RAM. *)

   (* ƒƒ Verschiedene Konstanten: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST (* Eigene Fehlercodes: 1000-1999: *)
         VGA_Error_NoVGA                 = 1001;
         VGA_Error_NoPCXFile             = 1002;
         VGA_Error_NoPCX320_200Points    = 1003;
         VGA_Error_NoPCX256Color         = 1004;
         VGA_Error_InvalidSpriteLoadNr   = 1005;
         VGA_Error_NoSPRFile             = 1006;
         VGA_Error_NoIMGFile             = 1007;
         VGA_Error_InvalidArgumentValues = 1008;
         VGA_Error_SpriteNArrayIsFull    = 1009;
         VGA_Error_NotEnoughMemory       = 1010;
         VGA_Error_SpriteLOADArrayIsFull = 1011;
         VGA_Error_FileSizeTooBig        = 1012;
         VGA_Error_No386                 = 1013;
         VGA_Error_InvalidCoordinates    = 1014;
         VGA_Error_BackgroundToBig       = 1015;
         VGA_Error_InvalidMode           = 1016;
         VGA_Error_SPRNoTileSize         = 1017;
         VGA_Error_SPRTooManyDifTiles    = 1018;
         VGA_Error_TooManyTilesInTILFile = 1019;
         VGA_Error_NoColorDisplay        = 1020;

         (* Bildschirm-Konstanten: *)
         XMAX                = 319;     (* Hardware-Auflîsung horizontal. *)
         YMAX                = 199;     (* Hardware-Auflîsung vertikal. *)
         BackGroundPage      = 3;       (* Nummer (0..3) der Hintergrundsseite. *)
         ScrollPage          = 3;       (* Seite, auf die die Tiles geladen werden. *)
         CRTAddress          = $3D4;    (* Port-Adresse des CRT-Chips, verschieden bei MONO- und COLOR-Vga. *)
         StatusReg           = $3DA;    (* Port-Adresse des Statusregisters, verschieden bei MONO- und COLOR-Vga. *)

         (* Grafikkarten-Werte: *)
         POfs_Adr            : Array[0..3] Of Word = ($0000, $3E80, $7D00, $BB80);
                                        (* Tabelle der Grafikseiten-Startadr (Offset-Anteil). *)
         PSeg_Adr            : ARRAY[0..3] Of Word = ($A000, $A3E8, $A7D0, $ABB8);
                                        (* Tabelle der Grafikseiten-Startadr (Segment-Anteil). *)
         ScreenSeg           : Word = $A000;
                                        (* Segmentadresse des physik. Bildschirms. *)
         LineSize            = (XMAX + 1) Div 4;
                                        (* Grî·e einer Zeile = 80 Bytes. *)
         ScreenSize          = (YMAX + 1) * LineSize;
                                        (* 200 Zeilen zu je 320/4 Bytes. *)
         UseVRAMBackground   : Boolean = TRUE;
                                        (* TRUE  : BackGrPage im VIDEO-RAM. *)
                                        (* FALSE : BackGrPage im normalen RAM. *)
         SpritesXMod4        : Boolean = FALSE;
                                        (* TRUE  : X-Koordinate fÑllt auf Vielfaches von 4. *)

         (* Hintergrunds-Modi: *)
         Static              = 0;
         Scrolling           = 1;

         (* Kachel-Konstanten: *)
         MaxTiles            = 10000;   (* Maximale Anzahl an Hintergrund-Kacheln. *)
         MaxTileSets         = 5;       (* Maximale Anzahl von Tile-Sets. *)

   TYPE  TRAMBackGrPageBuf   = Array[0..4 * ScreenSize - 1 + 15] Of Byte;
                                        (* RAM-Puffer fÅr die BACKGROUND-Seite. *)
   VAR   RAMBackGrPageBuf    : ^TRAMBackGrPageBuf;
                                        (* Zeiger darauf. *)
   VAR   RAMScrollPageBuf    : ^TRAMBackGrPageBuf;
                                        (* Zeiger auf SCROLLPAGE im RAM. *)

   CONST (* Sprite-Konstanten: *)
         LoadMAX             = 320;     (* Maximale Anzahl verschiedener geladener Sprites. *)
         NMAX                = 050;     (* Maximale Anzahl Sprites gleichzeitig. *)
         (* IMMER AUCH IN "UWVGA01A.ASM éNDERN ! *)

         (* Fenster-Bereiche: *)
         WinXMIN             : Integer = 0;
         WinYMIN             : Integer = 0;
         WinXMAX             : Integer = XMAX;
         WinYMAX             : Integer = YMAX;
         WinWidth            : Integer = XMAX - 0 + 1;
         WinWidthDiv4        : Integer = (XMAX + 1) Div 4;
         WinHeight           : Integer = YMAX - 0 + 1;
         WinOfsXMinYMin      : Integer = 0; (* Ofs-Adr der linken oberen Ecke. *)

         DrawOuterArea       : Byte    = 0;
                                        (* Gibt an, ob Bereich au·erhalb *)
                                        (* des Animationsfensters mit    *)
                                        (* BACKGROUNDPAGE gefÅllt wird.  *)
                                        (* Wenn neu, mit "3" fÅllen !    *)

         StartVirtualX : Integer = 0;   (* Obere linke Bildschirmecke. *)
         StartVirtualY : Integer = 0;

         (* Suchrichtung: *)
         Up                  = 1;
         Down                = 2;
   VAR   SearchDirection     : Byte;

         (* Grafikkarten-Werte: *)
   CONST TranslateTab        : Array[0..3] Of Byte = (1, 2, 4, 8);
                                        (* Fuer Maskenadressierung, die einzelnen Ebenen. *)

   (* ƒƒ Verschiedene Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   VAR   _Page               : Word;    (* Aktuell sichtbare Seite. *)
         _PageMal2           : Word;    (* Dto. nur schon mal 2. *)
         BackGroundAdr       : Word;    (* Segmentadresse der Hintergrundseite. *)
         ScrollPageADR       : Word;    (* Segmentadresse der Scrollseite. *)

         (* FÅr Scrolling: *)
         LEFTCut             : Word;    (* Linker öberhang in Pixeln. *)
         RIGHTCut            : Word;    (* Dto. rechts. *)
         TOPCut              : Word;    (* Dto. oben. *)
         BOTTOMCut           : Word;    (* Dto. unten. *)
         InnerTilesX         : Word;    (* Anzahl an VOLLSTéNDIG sichtbaren Kacheln in X-Richtung. *)
         InnerTilesY         : Word;    (* Anzahl an VOLLSTéNDIG sichtbaren Kacheln in Y-Richtung. *)
         TilesWegLEFT        : Word;    (* Anzahl an unsichtbaren Kacheln links. *)
         TilesWegRIGHT       : Word;    (* Anzahl an unsichtbaren Kacheln rechts. *)
         AktX, AktY          : Integer; (* Aktuelle Koordinate beim Kacheln zeichnen. *)
         AktIndexMal2        : Word;    (* Aktueller Kachelindex mal 2. *)
         StartIndexMal2      : Word;    (* 1. Kachelindex mal 2. *)
         StartX, StartY      : Word;    (* 1. Position der Kachel. *)

         UseVRAMScroll       : Boolean; (* TRUE  : Scroll-Tiles im VIDEO-RAM. *)
                                        (* FALSE : Scroll-Tiles im normalen RAM. *)
   CONST DoScrollCalc        : Boolean = TRUE;  (* Ob Scroll-Variablen errechnet werden mÅssen. *)

         (* Clip-Index: *)
   VAR   SplitIndex          : Integer; (* SpriteN-Nr, ab der Sprites nicht           *)
                                        (* mehr geclippt werden. -1 <=> ALLE clippen. *)
         SplitIndex_Mal2     : Integer; (* FÅr Array-Adressierung. *)

         (* Sprite-Tafeln: *)
         SpriteN             : Array[0..NMAX] Of Word;
                                        (* Liste der Nummern der   *)
                                        (* zu zeichnenden Sprites. *)

         SpriteX             : Array[0..NMAX] Of Integer;
                                        (* X-Koordinaten. *)

         SpriteY             : Array[0..NMAX] Of Integer;
                                        (* Y-Koordinaten. *)

         NextSprite          : Array[0..LoadMAX] Of Word;
                                        (* Beim Animieren, nÑchster Sprite in der *)
                                        (* Bilderfolge.                           *)

         SpritePTR           : Array[0..LoadMAX] Of Pointer;
                                        (* Liste mit Zeigern auf Sprite- *)
                                        (* Struktur.                     *)

         SpriteAD            : Array[0..LoadMAX] Of Word;
                                        (* Normalisierte Segmentadressen. *)

         SpriteSIZEX         : ARRAY[0..LoadMAX] OF Word;
                                        (* Allozierte Spritegrî·e in X. *)

         SpriteSIZEY         : ARRAY[0..LoadMAX] OF Word;
                                        (* Allozierte Spritegrî·e in X. *)

         SpriteSIZE          : Array[0..LoadMAX] Of Word;
                                        (* Allozierte Spritegrî·e. *)
         (* Systemvariablen: *)
         OldMode             : Byte;    (* Start-Videomodus. *)
         PageAdr             : Word;    (* Segment der aktuellen Zeichenseite. *)
         PageOfs             : Word;    (* Offset der aktuellen Zeichenseite. *)
         BIOSCharSize        : Word Absolute $0000:$0485;
                                        (* Bios-Zeichenhoehe. *)

         (* Laufzeitverhalten: *)
         IsAT                : Byte;    (* Flag zum testen, ob Rechner >= AT (80286) ist. *)
         TimeFlag            : Byte;    (* Zeitflag fÅr ANIMATE, ob Zykluszeit abgelaufen ist. *)
         CycleTime           : LongInt; (* Zykluszeit fÅr einen ANIMATE-Zyklus. *)

         (* Hintergrunds-Variablen: *)
         BackgroundMode      : Byte;    (* Hintergr.-Modus: Static / Scrolling. *)

   TYPE  TBackTile           = Array[0..MaxTiles] Of Word;

   {$IFDEF  UseScrolling}
   VAR   BackTile            : TBackTile;   (* Kachelnspeicher fÅr akt. Hintergrund. *)
   {$ELSE}
   VAR   BackTile            : Array[0..1] Of Word;
                                        (* Sonst nur DUMMY. *)
   {$ENDIF}
   VAR   BackTileMal64       : ^TBackTile;  (* Dto. ALS ZEIGER, nur gleich als Ofs-Adresse abgelegt. *)
         BackTileMal64SEG    : Word;    (* SEGMENT-Adresse von oberem. *)

   VAR   XTiles, YTiles      : Integer; (* Breite,Hîhe des def. Bereiches. *)
         BackX1, BackY1      : Integer; (* Koordinaten des definierten *)
         BackX2, BackY2      : Integer; (* Bereiches.                  *)

   (* ƒƒ Prototypen der Prozeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   PROCEDURE VGAInitRoutines;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Initialisiert alles Nîtige.                           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE VGACloseRoutines;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Beendet alles ordnungsgemÑ·.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Init256N;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Initialisiert den 256N-Farben-Modus.                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ChangePage(P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Wechselt die Bildschirmseite.                         *)
    (* Eingabe  : P = Seitennummer (0..3).                              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE VRamToVRam(Source, Dest : Pointer; Len : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Kopiert Im Video-Ram Bytes (NUR DORT !).              *)
    (* Eingabe  : SOURCE = Zeiger Auf Quelle,                           *)
    (*            DEST   = Zeiger Auf Ziel,                             *)
    (*            LEN    = Anzahl Bytes * 4.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PutPixel(C : Byte; X, Y : Word; P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schreibt einen Punkt.                                 *)
    (* Eingabe  : C    = Farbe (0..255),                                *)
    (*            X, Y = Koordinaten (0..319 bzw. 0..199),              *)
    (*            P    = Seite (0..3).                                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetPixel(X, Y : Word; P : Byte) : Byte;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest eine Punktfarbe.                                *)
    (* Eingabe  : X, Y = Koordinaten (0..319 bzw. 0..199),              *)
    (*            P    = Seite (0..3).                                  *)
    (* RÅckgabe : Zeichenfarbe.                                         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Frame(C : Byte; X1, Y1, X2, Y2 : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Zeichnet eine Rahmen.                                 *)
    (* Eingabe  : C              = Farbe (0..255),                      *)
    (*            X1, Y1, X2, Y2 = Koordinaten (0..319 bzw. 0..199),    *)
    (*            P              = Seite (0..3).                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FillFrame(C : Byte; X1, Y1, X2, Y2 : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Zeichnet einen gefÅllten Rahmen.                      *)
    (* Eingabe  : C              = Farbe (0..255),                      *)
    (*            X1, Y1, X2, Y2 = Koordinaten (0..319 bzw. 0..199),    *)
    (*            P              = Seite (0..3).                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ClrScreen(C, P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Lîscht den Bildschirm.                                *)
    (* Eingabe  : C = Farbe (0..255),                                   *)
    (*            P = Seite (0..3).                                     *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteChar(CH : Char; C : Byte; X, Y : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schreibt ein Zeichen.                                 *)
    (* Eingabe  : CH   = AscII-Nr,                                      *)
    (*            C    = Farbe (0..255),                                *)
    (*            X, Y = Virtuelle Koordinaten,                         *)
    (*            P    = Seite (0..3).                                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteString(S : String; C : Byte; X, Y : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schreibt eine Zeichenkette.                           *)
    (* Eingabe  : CH   = AscII-Nr,                                      *)
    (*            C    = Farbe (0..255),                                *)
    (*            X, Y = Virtuelle Koordinaten,                         *)
    (*            P    = Seite (0..3).                                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadSprite(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest einen Sprite oder eine Spritebibliothek.        *)
    (* Eingabe  : AFName = Dateiname.                                   *)
    (*            NR     = LADENummer des Sprites.                      *)
    (* RÅckgabe : Anzahl der aus dem File gelesenen Sprites.            *)
    (* Hinweis  : ACHTUNG ! Diese Prozedur ÅberprÅft nur, ob sie Åber   *)
    (*            das Ende des SpriteLOAD-Arrays schreibt, nicht aber   *)
    (*            ob die Felder in die geschrieben wird auch leer       *)
    (*            sind (zu langsam !).                                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadTile(AFName : String; Nr : Integer; aInVRAM : Boolean) : Integer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest einen Sprite oder eine Spritebibliothek als     *)
    (*            Tiles ein.                                            *)
    (* Eingabe  : AFNAME  = Dateiname,                                  *)
    (*            NR      = Nummer der Tile, ab der geladen wird,       *)
    (*            AINVRAM = TRUE: "ScrollPage" im VRAM, sonst im RAM.   *)
    (* RÅckgabe : Anzahl der aus dem File gelesenen TILES.              *)
    (* Hinweis  : ACHTUNG ! Diese Prozedur ÅberprÅft nur, ob sie Åber   *)
    (*            das Ende des TILE-Arrays schreibt, nicht aber         *)
    (*            ob die Felder in die geschrieben wird auch leer       *)
    (*            sind (zu langsam !).                                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadTileScrollBackGround(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest die Daten fÅr einen Scroll-Hintergrund ein.     *)
    (* Eingabe  : AFNAME = Dateiname.                                   *)
    (*            NR     = Nummer im BACKTILE-Feld ("0" = 1. Nr).       *)
    (* RÅckgabe : Es wird in das Feld "BackTile[..]", beginnend         *)
    (*            ab der Nummer NR gelesen.                             *)
    (*            Die Breite und Hîhe wird mittels "SetScrollRange()"   *)
    (*            gleich gesetzt und STARTVIRTUALX und STARTVIRTUALY    *)
    (*            auf die linke obere Ecke des scrollbaren Bereichs     *)
    (*            gesetzt.                                              *)
    (* Hinweis  : ACHTUNG ! Diese Prozedur ÅberprÅft nur, ob sie Åber   *)
    (*            das Ende des BACKTILE-Arrays schreibt, nicht aber     *)
    (*            ob die Felder in die geschrieben wird auch leer       *)
    (*            sind (zu langsam !).                                  *)
    (*            Genaueres siehe Info zu ".TIL"-Dateien.               *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SaveTileScrollBackGround(AFName : String; ABr, AHo : Integer);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schreibt die Daten fÅr einen Scroll-Hintergrund.      *)
    (* Eingabe  : AFNAME   = Dateiname,                                 *)
    (*            ABR, AHO = Abmessungen in TILES(!).                   *)
    (* Hinweis  : Genaueres siehe Info zu ".TIL"-Dateien.               *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Animate; Far;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : 1 Bewegungszyklus, inclusive: Virtuellen Koordinaten, *)
    (*                                          Clipping an Bildschirm- *)
    (*                                          kanten,                 *)
    (*                                          Animationsfenster.      *)
    (* Hinweis  : Zeichnet auf die Seiten 2, 1, 0, 2, 1, 0, 2, ...      *)
    (* ---------------------------------------------------------------- *)

   {$IFDEF  UseScrolling}
   PROCEDURE AnimateSpecial; Far;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Analog wie "Animate", nur da· immer gescrollt wird    *)
    (*            und das immer Åber ganzen Schirm.                     *)
    (* ---------------------------------------------------------------- *)
   {$ENDIF}

   PROCEDURE SetCycleTime(MilliSek : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Setzt Zeit fÅr Bewegungszyklus.                       *)
    (* Eingabe  : MILLISEK = Zeit in Millisekunden.                     *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadPCXPic(AName : String; APage : Byte; AUsePal, ASetPal : Boolean) : Pointer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest eine PCX-Datei mit 320*200 Punkten ein          *)
    (*            und gibt diese auf dem Bildschirm aus.                *)
    (* Eingabe  : ANAME   = Dateiname,                                  *)
    (*            APAGE   = Seite, auf die geschrieben wird (0..3),     *)
    (*            AUSEPAL = TRUE  : Palette des Bildes benÅtzen,        *)
    (*                      FALSE : Palette des Bildes nicht benÅtzen.  *)
    (*            ASETPAL = TRUE  : Setzt Palette sofort,               *)
    (*                    = FALSE : Setzt Palette nicht.                *)
    (*                      Hat generell NUR Auswirkungen, wenn AUSEPAL *)
    (*                      auf TRUE gestellt ist !                     *)
    (* RÅckgabe : Wenn eine Palette geladen UND aktiviert wurde, wird   *)
    (*            ein Zeiger darauf zurÅckgegeben (^TPALETTE).          *)
    (* Hinweis  : Liest NUR (!) 320*200 ein !                           *)
    (* ---------------------------------------------------------------- *)

   FUNCTION LoadPCXPicToRAM(AName : String; Var Laenge : LongInt) : Pointer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest eine PCX-Datei mit 320*200 Punkten ins RAM ein. *)
    (* Eingabe  : ANAME  = Dateiname.                                   *)
    (* RÅckgabe : Zeiger auf das Bild.                                  *)
    (*            LAENGE = LÑnge der Datei.                             *)
    (* Hinweis  : Um das Bild anzuschauen, mu· man                      *)
    (*            'ShowPCXPicFromRAM(..)' aufrufen.                     *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ShowPCXPicFromRAM(APtr : Pointer; ALaenge : LongInt; APage : Byte; AUsePal, ASetPal : Boolean) : Pointer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Zeigt eine zuvor mit 'LoadPCXPicToRAM(..)' geladenes  *)
    (*            PCX-Datei auf dem Bildschirm.                         *)
    (* Eingabe  : APTR    = Zeiger auf Bild,                            *)
    (*            APAGE   = Seite, auf die geschrieben wird (0..3),     *)
    (*            AUSEPAL = TRUE  : Palette des Bildes benÅtzen,        *)
    (*                      FALSE : Palette des Bildes nicht benÅtzen.  *)
    (*            ASETPAL = TRUE  : Setzt Palette sofort,               *)
    (*                    = FALSE : Setzt Palette nicht.                *)
    (*                      Hat generell NUR Auswirkungen, wenn AUSEPAL *)
    (*                      auf TRUE gestellt ist !                     *)
    (* RÅckgabe : Wenn eine Palette geladen UND aktiviert wurde, wird   *)
    (*            ein Zeiger darauf zurÅckgegeben (^TPALETTE).          *)
    (* Hinweis  : NUR (!) fÅr 320*200 !                                 *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FreePCXPicFromRAM(APtr : Pointer; ALaenge : LongInt);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt RAM einer zuvor mit 'LoadPCXPicToRAM(..)'        *)
    (*            geladenen PCX-Datei frei.                             *)
    (* Eingabe  : APTR    = Zeiger auf Bild.                            *)
    (*            ALAENGE = LÑnge des Bildes im RAM.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CopySpritesToBkgPage(AFirstLOADNr, ALastLOADNr : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Kopiert aus SpriteN[..] Sprites auf BACKGROUNDPAGE.   *)
    (* Eingabe  : AFIRSTLOADNR = 1. LadeNummer,                         *)
    (*            ALASTLOADNR  = Letzte LadeNummer.                     *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ClearSpritesFromSpriteN(AFirstLOADNr, ALastLOADNr : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Lîscht Sprites aus SpriteN[..].                       *)
    (* Eingabe  : AFIRSTLOADNR = 1. LadeNummer,                         *)
    (*            ALASTLOADNR  = Letzte LadeNummer.                     *)
    (* ---------------------------------------------------------------- *)

   FUNCTION VGAGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.   *)
    (* Eingabe  : ERR_Error = Fehlernummer,                             *)
    (*            AS        = Eventueller zusÑtzlicher Text (Z.B.       *)
    (*                        Dateiname bei Fehler 'Nicht gefunden').   *)
    (* RÅckgabe : Fehlertext.                                           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WaitVRetrace;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Wartet auf den Beginn der vertikalen Retrace-Periode. *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WaitHRetrace;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Wartet auf den Beginn der horizontalen Retrace-       *)
    (*            Periode.                                              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ScreenOff;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schaltet den Bildschirm aus.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ScreenOn;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schaltet den Bildschirm an.                           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SaveImage(AName : String; AP : Byte; X, Y, ABr, AHo : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Speichert einen Bildschirm(-ausschnitt)               *)
    (*            als .IMG-Datei.                                       *)
    (* Eingabe  : ANAME = Dateiname,                                    *)
    (*            AP    = Seite von der gelesen werden soll,            *)
    (*            Xn Yn = Koordinaten des Ausschnitts.                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE LoadImage(AName : String; AP : Byte; X, Y : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : LÑdt eine .IMG-Datei auf den Bildschirm.              *)
    (* Eingabe  : ANAME = Dateiname,                                    *)
    (*            AP    = Seite auf die geladen wird,                   *)
    (*            X | Y = Linke obere Koordinate, an die geladen wird.  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GetImage(Var ASeg : Word; AP : Byte; X, Y, ABr, AHo : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Holt ein Bild aus dem Bildschirm in den Speicher.     *)
    (* Eingabe  : ASeg     = Segmentadresse des Bildes im Speicher      *)
    (*                       (Offset IMMER 0).                          *)
    (*            AP       = Seite von der gelesen werden soll,         *)
    (*            X|Y      = Linke obere Ecke des Ausschnitts           *)
    (*            ABr, AHo = Breite bzw. Hîhe des Ausschnitts, die      *)
    (*                       Werte MöSSEN (!!) durch 4 (!) teilbar      *)
    (*                       sein.                                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PutImage(ASeg : Word; AP : Byte; X, Y : Word; AFree : Boolean);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Kopiert ein Bild auf den Bildschirm.                  *)
    (* Eingabe  : ASEG  = Zeiger auf die normalisierte SEGMENTadresse   *)
    (*                    der Kopie, die mit 'GETIMAGE(..)' erstellt    *)
    (*                    wurde (Offset IMMER 0).                       *)
    (*            AP    = Seite auf die geladen wird,                   *)
    (*            X | Y = Linke obere Koordinate, an die geschrieben    *)
    (*                    werden soll.                                  *)
    (*            AFree = TRUE : Speicher wird freigegeben,             *)
    (*                    FALSE: Speicher bleibt erhalten.              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FreeImage(ASeg : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt den Speicher eines Bildes im Speicher frei.      *)
    (* Eingabe  : ASeg     = Segmentadresse des Bildes im Speicher      *)
    (*                       (Offset IMMER 0).                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FreeSpriteMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt den Speicher eines Sprites frei.                 *)
    (* Eingabe  : ANR = SpriteLADENummer, die freigegeben werden soll.  *)
    (* Hinweis  : Wenn in SpriteN[..] noch irgendwo ANR als Zeiger auf  *)
    (*            eine SpriteLADENummer steht, mu· dieser Eintrag in    *)
    (*            SpriteN[..] = 0 gesetzt werden, sonst Fehler !!!      *)
    (*            Dies ist z.B mîglich durch Aufruf der Prozedur        *)
    (*            CLEARLOADNRFROMSPRITEN(ANr).                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ClearLOADNrFromSpriteN(ANr : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Lîscht im GESAMTEN SpriteN[..]-Feld alle EintrÑge auf *)
    (*            die Åbergebene SpriteLADENummer ANR.                  *)
    (* Eingabe  : ANR = SpriteLADENummer, die freigegeben werden soll.  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FlipSprite(ANr : Word; AWay : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Dreht ein Sprite.                                     *)
    (* Eingabe  : ANR  = SpriteLADENummer, die gedreht werden soll      *)
    (*            AWAY = Drehachse, 0 = X-Achse (horizontal),           *)
    (*                              1 = Y-Achse (vertical).             *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetFreeNNr : Integer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Sucht einen freien Platz in SpriteN[..].              *)
    (* RÅckgabe : Die Nummer des freien Platzes, -1 wenn nichts mehr    *)
    (*            frei.                                                 *)
    (* Hinweis  : Gesucht wird entsprechend dem Flag SEARCHDIRECTION    *)
    (*            entweder von unten nach oben (UP) oder von oben       *)
    (*            nach unten (DOWN).                                    *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetFreeLoadNr : Integer;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Sucht einen freien Platz in SpritePTR[..].            *)
    (* RÅckgabe : Die Nummer des freien Platzes, -1 wenn nichts mehr    *)
    (*            frei.                                                 *)
    (* Hinweis  : Gesucht wird entsprechend dem Flag SEARCHDIRECTION    *)
    (*            entweder von unten nach oben (UP) oder von oben       *)
    (*            nach unten (DOWN).                                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FilledRectangle(AColor : Byte; AX1, AY1, AX2, AY2 : Integer; APage : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Zeichnet ein gefÅlltes Rechteck.                      *)
    (* Eingabe  : ACOLOR           = Zeichenfarbe,                      *)
    (*            AX1|AY1, AX2|AY2 = VIRTUELLE (!) Koordinaten des      *)
    (*                               Rechtecks,                         *)
    (*            APAGE            = Seite, auf die gezeichnet wird.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PutSpriteOnPage(ALOADNr, ArgX, ArgY : Word; APage : Byte; AClip : Boolean);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Zeichnet einen Sprite auf eine Seite.                 *)
    (* Eingabe  : ALOADNR   = Sprite-LADE(!)-Nummer,                    *)
    (*            ArgX|ArgY = VIRTUELLE (!) Koordinaten des Rechtecks,  *)
    (*            APAGE     = Seite, auf die gezeichnet wird.           *)
    (*            ACLIP     = TRUE  : Sprites clippen und Animations-   *)
    (*                                fenster verwenden,                *)
    (*                        FALSE : Nichts clippen (schneller (!)).   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Line(AX1, AY1, AX2, AY2 : Integer; AC, AP : Byte; AClip : Boolean);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Erzeugt eine Linie.                                  *)
    (*  Eingabe  : AX1|AY1 = Koordinaten des Startpunktes,              *)
    (*             AX2|AY2 = Koordinaten der Endpunktes,                *)
    (*             AC      = Farbe,                                     *)
    (*             AP      = Bildschirmseite (0..3).                    *)
    (*             CLIP    = TRUE, wenn an Win* geclippt werden soll.   *)
    (*  Hinweis  : Die Linie wird mit Hilfe des Bresenham-Algorithmus   *)
    (*             gezeichnet.                                          *)
    (*             Quelle : "PC-Intern 3.0", Tischer, S. 302, Listing   *)
    (*                      "V3220P.PAS", Prozedur "Line(..)".          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetAnimateWindow(AX1, AY1, AX2, AY2 : Integer);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt die grî·e des Animationsfensters.              *)
    (*  Eingabe  : AX1|AY1 = Koordinaten der linken oberen Ecke,        *)
    (*             AX2|AY2 = Koordinaten der rechten unteren Ecke.      *)
    (*  Hinweis  : Die mindestgrî·e mu· 32x32 Pixel sein, x1 und x2     *)
    (*             mÅssen ein vielfaches von 4 sein.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetScrollingBkGroundMode(AWhere : TStaticBkMode);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : éndert den Zustand der ScrollSeite.                  *)
    (*  Eingabe  : AWHERE = RAM  : Tiles werden im RAM abgelegt,        *)
    (*                      VRAM : Tiles werden im Video-RAM auf        *)
    (*                             der logischen Seite BACKGROUNDPAGE   *)
    (*                             abgelegt.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetStaticBackGroundMode(AWhere : TStaticBkMode);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : éndert den Zustand der Hintergrundseite.             *)
    (*  Eingabe  : AWHERE = RAM  : Hintergrund wird im normalen RAM     *)
    (*                             abgelegt,                            *)
    (*                      VRAM : Hintergrund wird im Video-RAM auf    *)
    (*                             der logischen Seite BACKGROUNDPAGE   *)
    (*                             abgelegt.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetScrollRange(AX1, AY1, AX2, AY2 : Integer);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt die Koordinaten des scrollbaren Breichs.       *)
    (*  Eingabe  : AX1|AY1 = Koordinaten der linken oberen Ecke,        *)
    (*             AX2|AY2 = Koordinaten der rechten unteren Ecke.      *)
    (*             Beide Koordinaten sind VIRTUELLE KOORDINATEN.        *)
    (*  Ausgabe  : BACKX1|BACKY1, BACKX2|BACKY2 = Die gerundeten        *)
    (*                                            Koordinaten,          *)
    (*             XTiles                       = Breite in Kacheln,    *)
    (*             YTiles                       = Hîhe in Kacheln.      *)
    (*  Hinweis  : Die Koordinaten mÅssen auf ein 16er Raster fallen,   *)
    (*             da die Kacheln immer 16x16 Pixel gro· sind.          *)
    (*             Wenn die Anzahl der Kacheln > MAXTILES ist, wird     *)
    (*             abgebrochen.                                         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetBackgroundMode(AMode : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt den Modus fÅr den Hintergrund.                 *)
    (*  Eingabe  : AMODE = Hintergrundsmodus, legale Werte sind         *)
    (*                     "Static"(0) und "Scrolling"(1).              *)
    (*  Ausgabe  : BACKGROUNDMODE = 0: Static,                          *)
    (*                              1: Scrolling.                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetSplitIndex(ANr : Integer);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt die Nummer in SpriteN[..], ab der nicht mehr   *)
    (*             geclippt wird.                                       *)
    (*  Eingabe  : ANR = Nummer in SpriteN[..].                         *)
    (*  Ausgabe  : Variable SPLITINDEX wurde gesetzt.                   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetSplitIndex : Integer;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die Nummer in SpriteN[..], ab der nicht mehr *)
    (*             geclippt wird.                                       *)
    (*  Ausgabe  : Die ermittelte Nummer.                               *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE UpDateBackTileToBackTileMal64;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Rechnet das Feld BACKTILE in BACKTILEMAL64 um.        *)
    (* ---------------------------------------------------------------- *)

   FUNCTION Hit(ANNr, ATestNNrLo, ATestNNrHi : Word) : Word;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob ein bestimmtes Sprite mit anderen         *)
    (*             kollidiert ist.                                      *)
    (*  Eingabe  : ANNR       = N-Nummer des zu testenden Sprites,      *)
    (*             ATESTNNRLO = Unterste N-Nr., ab der verglichen wird, *)
    (*             ATESTNNRHI = Oberste N-Nr., mit der verglichen wird. *)
    (*  RÅckgabe : N(!)-Nummer des Sprites, mit dem ANNR kollidiert     *)
    (*             ist, "0" als RÅckgabe bedeutet KEINE Kollision.      *)
    (*  Hinweis  : Es wird nur auf Rechteckkollision getestet, d.h.     *)
    (*             der Sprite wird nicht auf seine TATSéCHLICHE         *)
    (*             Kontur hin untersucht, das wÑre viel zu langsam.     *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   {$L UWVGA01a.OBJ}                    (* Normales "Animate". *)


   {$IFDEF  UseScrolling}
   {$L UWVGA01b.OBJ}                    (* "AnimateSpecial". *)
   {$ENDIF}

   (* ƒƒ Verschiedene Konstanten: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST (* Wichtige Offsetwerte innerhalb des Sprite-Headers: *)
         BreiteInB = 00;                (* WORD. Breite in Pixel Shr 2. *)
         HoeheInZ  = 02;                (* WORD. Hoehe in Pixeln. *)

         Translate = 04;                (* 4 * BYTE. Die einzelnen Ebenen. *)
         Plane0    = 08;                (* WORD. Zeiger auf Daten fÅr Plane 0. *)
         Plane1    = 10;                (* WORD. Zeiger auf Daten fÅr Plane 1. *)
         Plane2    = 12;                (* WORD. Zeiger auf Daten fÅr Plane 2. *)
         Plane3    = 14;                (* WORD. Zeiger auf Daten fÅr Plane 3. *)

         (* TemporÑre Variablen im Spriteheader: *)
         (* Von [16 bis 59[ (43 Bytes). *)

         (* Alt : *)
         AktEbene  = 16;                (* BYTE. Aktuelle Ebene. *)
         OfsX      = 17;                (* WORD. X-Koordinate der linken Ecke des Sprites. *)
         OfsScr    = 19;                (* WORD. Offset Adresse der linken oberen Ecke des Sprites. *)
         CntLines  = 21;                (* WORD. ZÑhler fÅr schon gezeichnete Zeilen. *)
         CntPl     = 23;                (* WORD. ZÑhler fÅr Ebenen. *)
         UpperY    = 25;                (* WORD. Y-Koordinate oben. *)

         (* TemporÑre Variablen im Spriteheader: *)
         PageHelpTab     : Array[0..2]  Of Word = (2,0,1);
         PageHelpTabMal2 : Array[0..2]  Of Word = (4,0,2);
         HelpTab         : Array[0..16] Of Byte = (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
         HelpTab2        : Array[0..16] Of Byte = (1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

   (* ƒƒ Verschiedene Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   VAR SPRHeader    : TSPRHeader;       (* Siehe TSPRHeader, oben. *)
       TILHeader    : TTILHeader;       (* Siehe TTILHeader, oben. *)
       IMGHeader    : TIMGHeader;       (* Siehe TIMGHeader, oben. *)
       PCXHeader    : TPCXHeader;       (* Siehe TPCXHeader, oben. *)
       PCXFarbSkala256 : TPalette;

        Global_WH1  : Word;
        Global_WH2  : Word;

   (* ƒƒ Prototypen der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   PROCEDURE CS_GAdr; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Tabelle der Grafikzeilen-Startadressen (Ofs-Anteil).  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CS_POfs_Adr; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Tabelle der Grafikseiten-Startadressen (Ofs-Anteil).  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CS_TranslateTab; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Tabelle der Ebenennummern.                            *)
    (* ---------------------------------------------------------------- *)

   (* ƒƒ RÅmpfe der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   PROCEDURE CS_GAdr; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     DW $0000,$0050,$00A0,$00F0,$0140,$0190,$01E0,$0230
     DW $0280,$02D0,$0320,$0370,$03C0,$0410,$0460,$04B0
     DW $0500,$0550,$05A0,$05F0,$0640,$0690,$06E0,$0730
     DW $0780,$07D0,$0820,$0870,$08C0,$0910,$0960,$09B0
     DW $0A00,$0A50,$0AA0,$0AF0,$0B40,$0B90,$0BE0,$0C30
     DW $0C80,$0CD0,$0D20,$0D70,$0DC0,$0E10,$0E60,$0EB0
     DW $0F00,$0F50,$0FA0,$0FF0,$1040,$1090,$10E0,$1130
     DW $1180,$11D0,$1220,$1270,$12C0,$1310,$1360,$13B0
     DW $1400,$1450,$14A0,$14F0,$1540,$1590,$15E0,$1630
     DW $1680,$16D0,$1720,$1770,$17C0,$1810,$1860,$18B0
     DW $1900,$1950,$19A0,$19F0,$1A40,$1A90,$1AE0,$1B30
     DW $1B80,$1BD0,$1C20,$1C70,$1CC0,$1D10,$1D60,$1DB0
     DW $1E00,$1E50,$1EA0,$1EF0,$1F40,$1F90,$1FE0,$2030
     DW $2080,$20D0,$2120,$2170,$21C0,$2210,$2260,$22B0
     DW $2300,$2350,$23A0,$23F0,$2440,$2490,$24E0,$2530
     DW $2580,$25D0,$2620,$2670,$26C0,$2710,$2760,$27B0
     DW $2800,$2850,$28A0,$28F0,$2940,$2990,$29E0,$2A30
     DW $2A80,$2AD0,$2B20,$2B70,$2BC0,$2C10,$2C60,$2CB0
     DW $2D00,$2D50,$2DA0,$2DF0,$2E40,$2E90,$2EE0,$2F30
     DW $2F80,$2FD0,$3020,$3070,$30C0,$3110,$3160,$31B0
     DW $3200,$3250,$32A0,$32F0,$3340,$3390,$33E0,$3430
     DW $3480,$34D0,$3520,$3570,$35C0,$3610,$3660,$36B0
     DW $3700,$3750,$37A0,$37F0,$3840,$3890,$38E0,$3930
     DW $3980,$39D0,$3A20,$3A70,$3AC0,$3B10,$3B60,$3BB0
     DW $3C00,$3C50,$3CA0,$3CF0,$3D40,$3D90,$3DE0,$3E30
     DW $3E80
    End;

   PROCEDURE CS_POfs_Adr; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     DW $0000, $3E80, $7D00, $BB80
    End;

   PROCEDURE CS_TranslateTab; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     DB 1, 2, 4, 8
    End;

   (* ƒƒ InterfaceƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   PROCEDURE VGAInitRoutines;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
        PH1 : Pointer;

    Function IsVGA : Boolean;           (* TRUE, wenn VGA-Karte installiert. *)
     Begin
     With Regs Do
      Begin
       AX := $1A00;
       Intr($10, Regs);
       IsVGA := (AL=$1A) And ((BL=7) Or (BL=8));
      End;
     End;

    Begin (* VGAInitRoutines. *)
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(VGACloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(VGAGetErrorMessage);

     If Not IsVGA Then                  (* Wenn keine VGA,     *)
      Begin
       ERR_Error := VGA_Error_NoVGA;    (* Fehlermeldung und   *)
       CriticalError('');               (* Prozedur verlassen. *)
      End;

     (* Testen, ob auch FARB-Bildschirm angeschlossen; falls nicht, *)
     (* mÅssten die Register des CRT und die STATUS Register an     *)
     (* einer anderen Portadresse eingeblendet werden( zu langsam): *)
     If (Port[$3CC] And 1) = 0 Then
      Begin
       ERR_Error := VGA_Error_NoColorDisplay;
       CriticalError('');               (* Prozedur verlassen. *)
      End;

     If Not Is386 Then                  (* Wenn nicht mind 80386. *)
      Begin
       ERR_Error := VGA_Error_No386;    (* Fehlermeldung und   *)
       CriticalError('');               (* Prozedur verlassen. *)
      End;

     (* Alten Videomodus auslesen, mu· VOR Init256N geschehen(!): *)
     Regs.AH := $F;
     Intr($10, Regs);
     OldMode := Regs.AL;

     SetCycleTime(0);                   (* Zykluszeit auf Minimum. *)
     SetBackGroundMode(STATIC);
     SetScrollRange(-16000, -16000, 16000-1, 16000-1);

     (* Die Hintergrundseite in normalen RAM belegen und lîschen: *)
     {$IFDEF BackGrPageInRAM}
     If MaxAvail < SizeOf(TRAMBackGrPageBuf) Then
      Begin
       ERR_Error := VGA_Error_NotEnoughMemory;
       CriticalError('');
      End;
     _GetMem(PH1, SizeOf(TRAMBackGrPageBuf));
     If (LongInt(PH1) mod 16) = 0 Then RAMBackGrPageBuf := PH1
      Else LongInt(RAMBackGrPageBuf) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);
     FillChar(RAMBackGrPageBuf^, SizeOf(TRAMBackGrPageBuf), 0);
     {$ENDIF}

     {$IFDEF ScrollPageInRAM}
     (* Die SCROLLSeite in normalen RAM belegen und lîschen: *)
     If MaxAvail < SizeOf(TRAMBackGrPageBuf) Then
      Begin
       ERR_Error := VGA_Error_NotEnoughMemory;
       CriticalError('');
      End;
     _GetMem(PH1, SizeOf(TRAMBackGrPageBuf));
     If (LongInt(PH1) mod 16) = 0 Then RAMScrollPageBuf := PH1
      Else LongInt(RAMScrollPageBuf) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);
     FillChar(RAMScrollPageBuf^, SizeOf(TRAMBackGrPageBuf), 0);
     {$ELSE}
     ScrollPageAdr := PSeg_Adr[ScrollPage];
     {$ENDIF}

     SetScrollingBkGroundMode(VRAM);

     (* BACKTILEMAL64-Speicher anfordern: *)
     {$IFDEF UseScrolling}
     If MaxAvail < SizeOf(TBackTile) Then
      Begin
       ERR_Error := VGA_Error_NotEnoughMemory;
       CriticalError('');
      End;
     _GetMem(PH1, SizeOf(TBackTile));
     If (LongInt(PH1) mod 16) = 0 Then BackTileMal64 := PH1
      Else LongInt(BackTileMal64) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);
     FillChar(BackTileMal64^, SizeOf(TBackTile), 0);
     BackTileMal64SEG := Seg(BackTileMal64^);
     {$ENDIF}

     (* Variablen initialisieren: *)
     _Page := 0;                         (* Aktuelle Zeichenseite. *)
     _PageMal2 := 0;

     If UseVRAMBackGround Then
      BackGroundAdr := PSeg_Adr[BackGroundPage]
     Else
      BackGroundAdr := Seg(RAMBackGrPageBuf^);
                                        (* Segmentadresse der Hintergrundseite. *)

     PageAdr := PSeg_Adr[_Page];
     PageOfs := POfs_Adr[_Page];

     FillChar(SpriteAD    , SizeOf(SpriteAD)    , 0);
     FillChar(SpritePTR   , SizeOf(SpritePTR)   , 0);
     FillChar(SpriteSIZE  , SizeOf(SpriteSIZE)  , 0);
     FillChar(NextSprite  , SizeOf(NextSprite)  , 0);
     FillChar(SpriteN     , SizeOf(SpriteN)     , 0);
     FillChar(SpriteX     , SizeOf(SpriteX)     , 0);
     FillChar(SpriteY     , SizeOf(SpriteY)     , 0);

     {$IFDEF  UseScrolling}
     FillChar(BackTile  , SizeOf(BackTile)      , 0);
     {$ENDIF}

     For IH1 := 0 To LoadMAX Do NextSprite[IH1] := IH1;

     SetSplitIndex(-1);                 (* Alle Sprites clippen. *)

     ERR_Error := ERR_Error_OK;
    End;

   PROCEDURE VGACloseRoutines;
    (* ---------------------------------------------------------------- *)
    Var RK : Char;
    Begin
     (* Schirm ausschalten: *)
     WaitHRetrace;
     ScreenOff;                         (* Bildschirm aus. *)

     (* Alle Seiten lîschen: *)
     WaitHRetrace; ClrScreen(0, 0);
     WaitHRetrace; ClrScreen(0, 1);
     WaitHRetrace; ClrScreen(0, 2);
     WaitHRetrace; ClrScreen(0, 3);

{    UNICloseRoutines;

     (* Palette wiederherstellen: *)
     PALCloseRoutines;
 }
     (* Alten Videomodus setzen: *)
     Regs.AL := OldMode;
     Regs.AH := 0;
     WaitHRetrace;
     Intr($10, Regs);

     (* Schirm wieder an. *)
     WaitHRetrace;
     ScreenOn;

(*   {$IFDEF ONEFILE}
     ONEFILECloseRoutines;
     {$ENDIF}
*)
     While KeyPressed Do RK := ReadKey; (* Ggf. Tastaturpuffer lîschen. *)
    End;

   PROCEDURE Init256N;
    (* ---------------------------------------------------------------- *)
    Begin
     Asm
      mov   ax, 13h                     (* Videomodus $13. *)
      int   10h                         (* Videomodus setzen. *)

      mov   dx, 3C4h                    (* Index der SEQUENCER REGISTER. *)
      mov   al, 4                       (* Index des MEMORY MODE REGISTERS. *)
      out   dx, al                      (* Register fÅr Daten aktivieren. *)
      inc   dx                          (* Datenadresse der SEQUENCER REGISTER. *)
      in    al, dx                      (* Daten einlesen nach AL. *)
      and   al, 0F7h                    (* Bit 3 = 0: Chain 4-Adressierung aus. *)
      or    al, 4                       (* Odd/Even-Adressierung aus. *)
      out   dx, al                      (* Ausschalten. *)

      mov   dx, 3C4h                    (* Index der SEQUENCER REGISTER. *)
      mov   al, 2                       (* Index des MAP MASK REGISTERS. *)
      out   dx, al                      (* Register fÅr Daten aktivieren. *)
      inc   dx                          (* Datenadresse der SEQUENCER REGISTER. *)
      mov   al, 0Fh                     (* Alle Ebenen zum Schreiben einschalten. *)
      out   dx, al                      (* Einschalten. *)
      mov   ax, 0A000h                  (* Bildschirmsegment (normalerweise $A000) *)
      mov   es, ax                      (* nach ES laden.                          *)
      sub   di, di                      (* DI := 0. *)
      mov   ax, di                      (* AX := DI = 0. *)

      mov   cx, 8000h                   (* $8000 Wiederholungen. *)
      cld                               (* Lîsche Richtungsflag => Alle String-    *)
                                        (* operationen nach aufsteigender Adresse. *)
      rep   stosw                       (* $8000 mal (CX) von AX nach ES:DI. *)

      mov   dx, CRTAddress              (* Index der CRT-CONTROLLER REGISTER. *)
      mov   al, 14h                     (* Index des UNDERLINE LOCATION REGISTERS. *)
      out   dx, al                      (* Register fÅr Daten aktivieren. *)
      inc   dx                          (* Datenadresse der CRT-CONTROLLER REGISTER. *)
      in    al, dx                      (* Daten einlesen nach AL. *)
      and   al, 0BFh                    (* Bit 6 = 0: WORDMODUS einschalten. *)
      out   dx, al                      (* Einschalten. *)

      dec   dx                          (* Index der CRT-CONTROLLER REGISTER. *)
      mov   al, 17h                     (* Index des MODE CONTROL REGISTERS. *)
      out   dx, al                      (* Register fÅr Daten aktivieren. *)
      inc   dx                          (* Datenadresse der CRT-CONTROLLER REGISTER. *)
      in    al, dx                      (* Daten einlesen nach AL. *)
      or    al, 40h                     (* Bit 6 = 0: WORDMODUS einschalten. *)
      out   dx, al                      (* Einschalten. *)
     End;

     ClrScreen(0, 0);                   (* Vorsorglich alle 4 Seiten lîschen. *)
     ClrScreen(0, 1);
     ClrScreen(0, 2);
     ClrScreen(0, 3);

     (* Seite einstellen  und auf sichtbare schalten: *)
     _Page := 0;
     If _Page > 0 Then ChangePage(_Page-1)
     Else ChangePage(2);
    End;

   PROCEDURE ChangePage(P : Byte); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     cli

     mov   dx, StatusReg                (* Index des INPUT STATUS #1 REGISTERS. *)
    @WaitNotHSyncLoop:
     in    al, dx                       (* Daten einlesen. *)
     and   al, 1                        (* Wenn Bit 1 = 0: HORIZ. Retrace INaktiv, *)
                                        (* wenn Bit 1 = 0: HORIZ. Retrace aktiv    *)
     jz    @WaitNotHSyncLoop            (* Wiederhole, bis INaktiv. *)
    @WaitHSyncLoop:
     in    al, dx
     and   al, 1
     jnz   @WaitHSyncLoop               (* Wiederhole, bis aktiv. *)

     mov   dx, CRTAddress		(* Index der CRT-CONTROLLER REGISTER. *)
     mov   al, 0Dh                      (* Index des START ADRESS LOW REGISTERS. *)
     out   dx, al                       (* Register fÅr Daten aktivieren. *)
     inc   dx                           (* Datenadresse der CRT-CONTROLLER REGISTER. *)

     mov   bl, P                        (* Seite (P) nach BL laden. *)
     mov   si, bx                       (* Seite nach SI. *)
     and   si, 3                        (* nur Bit 0 und 1 zÑhlt. *)
     shl   si, 1                        (* SI := SI * 2. *)
     add   si, OFFSET POfs_Adr              (* Aus Tabelle die Offset-Seiten-Adresse lesen. *)
     lodsw                              (* Laden von DS:SI nach AX. *)

     out   dx, al			(* LB der neuen Startadr. setzen. *)
     dec   dx
     mov   al, 0Ch
     out   dx, al
     inc   dx
     mov   al, ah			(* HB der neuen Startadr. setzen. *)
     out   dx, al
     sti

     mov   dx, StatusReg                (* Index des INPUT STATUS #1 REGISTERS. *)
    @2WaitNotHSyncLoop:
     in    al, dx                       (* Daten einlesen. *)
     and   al, 1                        (* Wenn Bit 1 = 0: HORIZ. Retrace INaktiv, *)
                                        (* wenn Bit 1 = 0: HORIZ. Retrace aktiv    *)
     jz    @2WaitNotHSyncLoop           (* Wiederhole, bis INaktiv. *)
    @2WaitHSyncLoop:
     in    al, dx
     and   al, 1
     jnz   @2WaitHSyncLoop              (* Wiederhole, bis aktiv. *)
    End;

   PROCEDURE VRamToVRam(Source, Dest : Pointer; Len : Word); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   ax, 4105h                    (* Writemode 1 einschalten. *)
     mov   dx, 3CEh
     out   dx, ax
     mov   ax, 0F02h                    (* Alle 4 Planes gleichzeitig ansprechen. *)
     sub   dx, 0Ah                      (* MOV DX, 3C4h. *)
     out   dx, ax

     mov   bx, ds

     les   di, Dest
     lds   si, Source
     mov   cx, Len

     cld
     rep   movsb

     mov   ds, bx

     mov   ax, 4005h
     add   dx, 0Ah                      (* MOV DX, 3C4h. *)
     out   dx, ax
    End;

   PROCEDURE PutPixel(C : Byte; X, Y : Word; P : Byte); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   di, Y                        (* Y-Wert lesen. *)
     mov   bx, X                        (* X-Wert lesen. *)
     shl   di, 1                        (* DI := DI * 2. *)
     mov   di, cs:[OFFSET CS_GAdr + di] (* Adresse der Zeile lesen. *)
     xor   ch, ch                       (* CH := 0. *)
     mov   cl, P                        (* CL := Zu verwendende Seite (P). *)
     mov   si, cx                       (* Seite nach SI. *)
     shl   si, 1                        (* SI := SI * 2. *)
     add   di, cs:[OFFSET CS_POfs_Adr + si] (* Zur Adresse der Zeile die *)
                                        (* der Seite addieren.       *)
     mov   ax, bx                       (* X-Wert nach AX. *)
     shr   ax, 1                        (* AX := AX / 2. *)
     shr   ax, 1                        (* AX := AX / 2. 2 mal ausfÅhren ! *)
     add   di, ax                       (* Zur Adresse der Zeile und der Seite *)
                                        (* die der Spalte addieren.            *)
     and   bx, 3                        (* Nur die 2 niedrigsten Bit wichtig. *)
     mov   ah, cs:[OFFSET CS_TranslateTab + bx]
                                        (* Ebene der X-Koordinate nach AH. *)
     mov   al, 2                        (* Index fÅr MAP MASK REGISTER. *)
     mov   dx, 3C4h                     (* Index der SEQUENCER REGISTER. *)

     push  ScreenSeg                    (* Bildschirmsegment nach *)
     pop   es                           (* ES laden.              *)

     cli                                (* Alle Interrupts unterbinden. *)
     out   dx, ax                       (* In Map Mask Register die Ebene der *)
                                        (* X-Koordinate freigeben.            *)
     mov   al, C                        (* Farbwert (C) laden. *)
     stosb                              (* Farbwert von AL nach ES:DI schreiben. *)
     sti                                (* Interrupts wieder freigeben. *)
    End;

   FUNCTION GetPixel(X, Y : Word; P : Byte) : Byte; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   di, Y                        (* Y-Wert lesen. *)
     mov   bx, X                        (* X-Wert lesen. *)
     shl   di, 1                        (* DI := DI * 2. *)
     mov   di, cs:[OFFSET CS_GAdr + di] (* Adresse der Zeile lesen. *)
     xor   ch, ch                       (* CH := 0. *)
     mov   cl, P                        (* CL := Zu verwendende Seite (P). *)
     mov   si, cx                       (* Seite nach SI. *)
     shl   si, 1                        (* SI := SI * 2. *)
     add   di, cs:[OFFSET CS_POfs_Adr + si] (* Zur Adresse der Zeile die *)
                                        (* der Seite addieren.       *)

     mov   ax, bx                       (* X-Wert nach AX. *)
     shr   ax, 1                        (* AX := AX / 2. *)
     shr   ax, 1                        (* AX := AX / 2. 2 mal ausfÅhren ! *)
     add   di, ax                       (* Zur Adresse der Zeile und der Seite *)
                                        (* die der Spalte addieren.            *)
     and   bl, 3                        (* Nur die 2 niedrigsten Bit wichtig. *)
     mov   al, 4                        (* Index fÅr READ MAP SELECT REGISTER. *)
     mov   ah, bl                       (* Die Ebene aus der gelesen wird nach AH. *)
     mov   dx, 3CEh                     (* Index der GRAPHIC CONTROLLER REGISTER. *)

     push  ScreenSeg                    (* Bildschirmsegment nach *)
     pop   es                           (* ES laden.              *)

     cli                                (* Alle Interrupts unterbinden. *)
     out   dx, ax                       (* *)

     mov   al, es:[di]                  (* Farbe von ES:DI nach AL lesen, *)
                                        (* AL wird von der Funktion zurÅckgegeben. *)
     sti                                (* Interrupts wieder freigeben. *)
    End;

   PROCEDURE Frame(C : Byte; X1, Y1, X2, Y2 : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     Line(X1, Y1, X2, Y1, C, P, FALSE); (* Oben. *)
     Line(X1, Y2, X2, Y2, C, P, FALSE); (* Unten. *)
     Line(X1, Y1, X1, Y2, C, P, FALSE); (* Links. *)
     Line(X2, Y1, X2, Y2, C, P, FALSE); (* Rechts. *)
    End;

   PROCEDURE FillFrame(C : Byte; X1, Y1, X2, Y2 : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     For IH1 := Y1 To Y2 Do Line(X1, IH1, X2, IH1, C, P, FALSE);
    End;

   PROCEDURE ClrScreen(C, P : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     (* Wenn normales RAM: *)
     If (P = BACKGROUNDPAGE) And (Not UseVRAMBackGround) Then
      FillChar(RAMBackGrPageBuf^, SizeOf(TRAMBackGrPageBuf), C)

     (* Wenn VRAM: *)
     Else
      Begin
       PortW[$3C4] := $0F02;
       FillChar(Mem[ScreenSeg:POfs_Adr[P]], $3E80, C);
      End;
    End;

   PROCEDURE WriteChar(CH : Char; C : Byte; X, Y : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    Type CharMatrix = Array[0..31] Of Byte;
    Var  FPtr       : Pointer Absolute $0000:$010C;
                                        (* INT 43h-Vektor. *)
         CharRow    : Byte;
         FontSeg,
         FontOfs,
         IH1, IH2   : Word;
    Begin
     FontSeg := Seg(FPtr^);             (* Segmentadresse Zeichensatz. *)
     FontOfs := Ofs(FPtr^) + BIOSCharSize * Byte(CH);
                                        (* Offsetadresse Matrix. *)
     (* Zeichensatz-Byte holen: *)
     For IH1 := 0 To BIOSCharSize-1 Do
      Begin
       CharRow := Mem[FontSeg:FontOfs];
       For IH2 := 0 To 7 Do
        Begin
         If (CharRow And $80) <> 0 Then
          PutPixel(C, X+IH2, Y+IH1, P); (* Punkt setzen. *)
         CharRow := CharRow Shl 1;      (* Punktreihe um 1 nach links schieben. *)
        End;
       Inc(FontOfs);                    (* NÑchste Punktreihe. *)
      End;
    End;

   PROCEDURE WriteString(S : String; C : Byte; X, Y : Integer; P : Byte);
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     For IH1 := 1 To Length(S) Do
      Begin
       WriteChar(S[IH1], C, X, Y, P);
       Inc(X, BIOSCharSize + 1);
      End;
    End;

   FUNCTION LoadSprite(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PXH1      : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}
        PH1, PH2  : Pointer;            (* Zeiger auf Speicher, normalisiert. *)
        IH1       : Integer;
        SPRCount  : Integer;            (* Gelesene Sprites. *)
        MemSize   : Word;
    Begin
     SPRCount := 0;

     (* Datei ôffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     {$I-}
     {$IFDEF ONEFILE}
     While Not _EOF(F) Do
     {$ELSE}
     While Not EOF(F) Do                (* Je 1 Spritedatei aus ggf Bibliothek lesen. *)
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Wenn Åber LOADMax hinaus geschrieben wird, abbrechen: *)
       If Nr > LOADMax Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := VGA_Error_SpriteLOADArrayIsFull;
         CriticalError('');
        End;

       (* Lesen, Header: *)
       {$I-}

       {$IFDEF ONEFILE}
       PXH1 := @SPRHeader;
       _BlockRead(F, PXH1, SizeOf(SPRHeader));
       {$ELSE}
       BlockRead(F, SPRHeader, SizeOf(SPRHeader));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Header auswerten: *)
       If (SPRHeader.Kennung <> 'UK') Or (SPRHeader.Art <> 'SPR') Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := VGA_Error_NoSPRFile;
         CriticalError('');
        End;

       (* Header erstellen: *)
       SpriteStruct.BreiteInBytes := SPRHeader.Breite Div 4;
       SpriteStruct.HoeheInZ := SPRHeader.Hoehe;
       SpriteStruct.Translate[1] := 1;
       SpriteStruct.Translate[2] := 2;
       SpriteStruct.Translate[3] := 4;
       SpriteStruct.Translate[4] := 8;
       SpriteStruct.PlaneDatPtr[0] := SizeOf(TSpriteStruct);
       SpriteStruct.PlaneDatPtr[1] := SizeOf(TSpriteStruct) +     ((SPRHeader.Breite Div 4) * SPRHeader.Hoehe);
       SpriteStruct.PlaneDatPtr[2] := SizeOf(TSpriteStruct) + 2 * ((SPRHeader.Breite Div 4) * SPRHeader.Hoehe);
       SpriteStruct.PlaneDatPtr[3] := SizeOf(TSpriteStruct) + 3 * ((SPRHeader.Breite Div 4) * SPRHeader.Hoehe);

       FreeSpriteMem(Nr);               (* Eventuellen alten Speicher freigeben. *)

       (* Speicher anfordern und Header hineinkopieren: *)
       MemSize := SizeOf(TSpriteStruct) + SPRHeader.Breite * SPRHeader.Hoehe + 15;
       _GetMem(PH1, MemSize);

       (* Tafeln bezeichnen: *)
       SpriteSIZE [Nr] := MemSize;
       SpriteSIZEX[Nr] := SPRHeader.Breite;
       SpriteSIZEY[Nr] := SPRHeader.Hoehe;
       SpritePTR  [Nr] := PH1;

       If (LongInt(PH1) Mod 16) = 0 Then PH2 := PH1
        Else LongInt(PH2) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);

       (* Header auf Heap bringen: *)
       Move(SpriteStruct, PH2^, SizeOf(TSpriteStruct));
       LongInt(PH1) := LongInt(PH2) + SizeOf(TSpriteStruct);

       (* Rest vom Sprite auf Heap bringen: *)
       {$I-}

       {$IFDEF ONEFILE}
       _BlockRead(F, PH1, SPRHeader.Breite * SPRHeader.Hoehe);
       {$ELSE}
       BlockRead(F, PH1^, SPRHeader.Breite * SPRHeader.Hoehe);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* SpriteNummer zuordnen: *)
       SpriteAD[Nr] := (LongInt(PH2) Shr 16) + (LongInt(PH2) And 65535) Shr 4;

       (* NÑchstes Sprite: *)
       Inc(Nr);
       Inc(SPRCount);
      End;
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Datei schlie·en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;

     LoadSprite := SPRCount;
    End;

   FUNCTION LoadTile(AFName : String; Nr : Integer; aInVRAM : Boolean) : Integer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PXH1      : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}
        PH1, PH2  : Pointer;            (* Zeiger auf Speicher, normalisiert. *)
        PH3       : Pointer;            (* Zeiger zum Tiles Einlesen in Speicher. *)
        SPRCount  : Integer;            (* Gelesene Sprites. *)
    Begin
     SPRCount  := 0;

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     {$I-}
     {$IFDEF ONEFILE}
     While Not _EOF(F) Do
     {$ELSE}
     While Not EOF(F) Do                (* Je 1 Spritedatei aus ggf Bibliothek lesen. *)
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Lesen, Header: *)
       {$I-}

       {$IFDEF ONEFILE}
       PXH1 := @SPRHeader;
       _BlockRead(F, PXH1, SizeOf(SPRHeader));
       {$ELSE}
       BlockRead(F, SPRHeader, SizeOf(SPRHeader));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Header auswerten: *)
       If (SPRHeader.Kennung <> 'UK') Or (SPRHeader.Art <> 'SPR') Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := VGA_Error_NoSPRFile;
         CriticalError('');
        End;

       (* Header auswerten: *)
       If (SPRHeader.Breite <> 16) Or (SPRHeader.Hoehe <> 16) Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := VGA_Error_SPRNoTileSize;
         CriticalError('');
        End;

       (* Testen, ob maximale Anzahl an verschiedenen Tiles Åberschritten: *)
       If Nr > 249 Then                 (* 0..249. *)
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := VGA_Error_SPRTooManyDifTiles;
         CriticalError('');
        End;

       (* Speicher anfordern, an den Sprite geladen wird: *)
       _GetMem(PH1, 16*16);

       (* Daten einlesen; Rest vom Sprite auf Heap bringen: *)
       {$I-}

       {$IFDEF ONEFILE}
       _BlockRead(F, PH1, 16*16);
       {$ELSE}
       BlockRead(F, PH1^, 16*16);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Wenn KEIN ScrollPage-RAM erlaubt ist, auch keines zulassen: *)

       {$IFNDEF ScrollPageInRAM}
        aInVRAM := TRUE;
       {$ENDIF}

       If aInVRAM Then
        Begin
         (* Von Tile in Speicher nun Tile auf SCROLLPAGE schreiben,       *)
         (* dabei umwandeln von Ebenen "000000....0", "111111....1", ...  *)
         (* nach "0123 0123 0123....0123", "0123 0123 0123....0123", ...: *)
         PH2 := PH1;                            (* Quell-Zeiger. *)
         PH3 := Ptr(SCROLLPAGEADR, Nr*4*16);    (* Ziel-Zeiger. *)

         PortW[$3C4] := $0102;          (* Ebene 0. *)
         Move(PH2^, PH3^, 16*4);
         Inc(LongInt(PH2), 16*4);

         Port[$3C5] := 2;               (* Ebene 1. *)
         Move(PH2^, PH3^, 16*4);
         Inc(LongInt(PH2), 16*4);

         Port[$3C5] := 4;               (* Ebene 2. *)
         Move(PH2^, PH3^, 16*4);
         Inc(LongInt(PH2), 16*4);

         Port[$3C5] := 8;               (* Ebene 3. *)
         Move(PH2^, PH3^, 16*4);
         Inc(LongInt(PH2), 16*4);
        End

       Else                             (* In RAM kopieren. *)
        Begin
         LongInt(PH2) := LongInt(RAMScrollPageBuf) + Nr*16*16;
         Move(PH1^, PH2^, 16*16);
        End;

       (* Speicher wieder freigeben: *)
       FreeMem(PH1, 16*16);

       (* NÑchstes Sprite: *)
       Inc(Nr);
       Inc(SPRCount);
      End;
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Datei schlie·en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;

     LoadTile := SPRCount;
    End;

   FUNCTION LoadTileScrollBackGround(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PHX1      : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}
        IH1       : Integer;            (* Allgemeine Laufvariable. *)
        Cnt, Size : Word;               (* Zum einlesen der Daten. *)
        Rst       : Word;
        MaxSize   : Word;
        FileS     : LongInt;            (* Grî·e der Datei. *)
    Begin
     (* Datei ôffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Grî·e der Datei lesen und dadurch errechnen, ob nicht zu gro· *)
     (* fÅr das BACKTILE-Feld ist:                                    *)

     {$I-}

     {$IFDEF ONEFILE}
     FileS := _FileSize(F);             (* Grî·e der Datei in Bytes. *)
     {$ELSE}
     FileS := FileSize(F);              (* Grî·e der Datei in Bytes. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     FileS := FileS - SizeOf(TILHeader);
     If (FileS Div 2) > SizeOf(TBackTile) Then   (* Da Word-EintrÑge. *)
      Begin
       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       ERR_Error := VGA_Error_TooManyTilesInTILFile;
       CriticalError('');
      End;

     (* Header einlesen: *)

     {$IFDEF ONEFILE}
     PHX1 := @TILHeader;
     _BlockRead(F, PHX1, SizeOf(TILHeader));
     {$ELSE}
     BlockRead(F, TILHeader, SizeOf(TILHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Header auswerten: *)
     If (TILHeader.Kennung <> 'UK') Or (TILHeader.Art <> 'TIL') Then
      Begin
       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       ERR_Error := VGA_Error_NoSPRFile;
       CriticalError('');
      End;

     (* Daten in Feld einlesen, dabei beachten, da· wenn grî·er als *)
     (* 64k, man mehrere BLOCKREAD-Aufrufe Braucht:                 *)

     MaxSize := 65535;
     Cnt := FileS Div MaxSize;
     Rst := FileS Mod MaxSize;
     If Cnt = 0 Then Size := Rst Else Size := MaxSize;

     If Rst > 0 Then Inc(Cnt);

     For IH1 := 1 To Cnt Do
      Begin
       If (IH1 = Cnt) And (Rst > 0) Then Size := Rst;

       {$I-}

       {$IFDEF ONEFILE}
       PHX1 := @BackTile[NR];
       _BlockRead(F, PHX1, Size);
       {$ELSE}
       BlockRead(F, BackTile[NR], Size);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* NÑchsten Block: *)
       Inc(NR, Size);                   (* In BACKTILE[..] weitergehen. *)
      End;

     (* Datei schlie·en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     UpDateBackTileToBackTileMal64;     (* Die Nummern gleich in Adressen umrechnen. *)

     (* Alles OK, Scrollfenster an linke obere Ecke des Hintergrunds setzen: *)
     SetScrollRange(-16000, -16000, -16000+16*TILHeader.BreiteInT-1, -16000+16*TILHeader.HoeheInT-1);
     StartVirtualX := - 16000;
     StartVirtualY := - 16000;

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;

     LoadTileScrollBackGround := FileS;
    End;

   PROCEDURE SaveTileScrollBackGround(AFName : String; ABr, AHo : Integer);
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PHX1      : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}
        IH1       : Integer;            (* Allgemeine Laufvariable. *)
        Cnt, Size : Word;               (* Zum einlesen der Daten. *)
        Rst       : Word;
        MaxSize   : Word;
        Nr        : Word;
        FileS     : LongInt;            (* Grî·e der zu schreibenden Datei. *)
    Begin
     (* Werte errechnen: *)
     Nr := 0;                           (* Beim 1. Element anfangen. *)
     FileS := ABr * AHo * 2;            (* Grî·e in Bytes (*2 weil WORD). *)

     (* Datei ôffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AFName);
     {$ELSE}
     Assign(F, AFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
{    _Rwrite(F, 1);                     (* BlockRead-LÑnge : 1 Byte. *)
}    {$ELSE}
     Rewrite(F, 1);                     (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Header fÅllen: *)
     With TILHeader Do
      Begin
       Kennung   := 'UK';
       Version   := 1;
       Art       := 'TIL';
       BreiteInT := ABr;
       HoeheInT  := AHo;
       FillChar(Dummy, SizeOf(Dummy), 0);
      End;

     (* Header schreiben: *)

     {$IFDEF ONEFILE}
     PHX1 := @TILHeader;
     _BlockWrite(F, PHX1, SizeOf(TILHeader));
     {$ELSE}
     BlockWrite(F, TILHeader, SizeOf(TILHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Header auswerten: *)
     If (TILHeader.Kennung <> 'UK') Or (TILHeader.Art <> 'TIL') Then
      Begin
       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       ERR_Error := VGA_Error_NoSPRFile;
       CriticalError('');
      End;

     (* Daten aus Feld schreibem, dabei beachten, da· wenn grî·er als *)
     (* 64k, man mehrere BLOCKWRITE-Aufrufe Braucht:                  *)

     MaxSize := 65535;
     Cnt := FileS Div MaxSize;
     Rst := FileS Mod MaxSize;
     If Cnt = 0 Then Size := Rst Else Size := MaxSize;

     If Rst > 0 Then Inc(Cnt);

     For IH1 := 1 To Cnt Do
      Begin
       If (IH1 = Cnt) And (Rst > 0) Then Size := Rst;

       {$I-}

       {$IFDEF ONEFILE}
       PHX1 := @BackTile[NR];
       _BlockWrite(F, PHX1, Size);
       {$ELSE}
       BlockWrite(F, BackTile[NR], Size);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* NÑchsten Block: *)
       Inc(NR, Size);                   (* In BACKTILE[..] weitergehen. *)
      End;

     (* Datei schlie·en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE Animate; External;
    (* ---------------------------------------------------------------- *)

   {$IFDEF  UseScrolling}
   PROCEDURE AnimateSpecial; External;
    (* ---------------------------------------------------------------- *)
   {$ENDIF}

   PROCEDURE SetCycleTime(MilliSek : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     If Integer(MilliSek) < 0 Then Exit;
     TimeFlag := $80;
     CycleTime := LongInt(MilliSek) * LongInt(1000);
     If (MilliSek <> 0) And AT Then
      IsAT := 0                         (* Ja, Zeitueberwachung soll benutzt werden. *)
     Else IsAT := $80;                  (* Nein, keine moeglich oder nicht gewuenscht. *)
    End;

   FUNCTION LoadPCXPic(AName : String; APage : Byte; AUsePal, ASetPal : Boolean) : Pointer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PH1       : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}

        PDatenIn4er     : Pointer;      (* Hier ist das Bild gespeichert, nach   *)
                                        (* Ebenen geordnet, also E0-Daten, E1... *)
        PBlockDaten     : Pointer;      (* Zeiger auf 1 geladenen Block. *)
        PEbenen         : Array[0..3] Of ^Byte;
        AktEbene        : Byte;

        IH1, IH2        : Integer;
        PB1             : ^Byte;
        WH1, WH2, WH3   : Word;

        Zaehler         : Integer;
        BlockSize       : LongInt;      (* LÑnge der gepacketen (!) PIXELDaten. *)
        PixelCount      : Word;         (* Anzahl gezeichneter Punkte. *)
    Begin
     LoadPCXPic := Nil;

     (* Anzahl der Blocks lesen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AName);
     {$ELSE}
     Assign(F, AName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Header lesen: *)
     PB1 := @PCXHeader;
     {$I-}

     {$IFDEF ONEFILE}
     PH1 := PB1;
     _BlockRead(F, PH1, SizeOf(PCXHeader));
     {$ELSE}
     BlockRead(F, PB1^, SizeOf(PCXHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* DatensÑtze lesen: *)
     _GetMem(PDatenIn4er, 64000);        (* Speicher fÅr 1 Bild reservieren. *)
     LongInt(PEbenen[0]) := LongInt(PDatenIn4er);
     LongInt(PEbenen[1]) := LongInt(PDatenIn4er) + 16000; (* = ((320 * 200) Div 4); *)
     LongInt(PEbenen[2]) := LongInt(PDatenIn4er) + 32000; (* = 2 * ((320 * 200) Div 4); *)
     LongInt(PEbenen[3]) := LongInt(PDatenIn4er) + 48000; (* = 3 * ((320 * 200) Div 4); *)

     (* Gepacktes Bild in RAM laden (dort auch noch gepackt): *)

     (* Grî·e der gepackten PIXEL-Daten: *)
     {$I-}

     {$IFDEF ONEFILE}
     BlockSize := _FileSize(F) - SizeOf(PCXHeader);
     {$ELSE}
     BlockSize := FileSize(F) - SizeOf(PCXHeader);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     {If PCXHeader.Version >= 5 Then} BlockSize := BlockSize - SizeOf(TPalette);

     (* Speicher fÅr Gepacktes holen: *)
     _GetMem(PBlockDaten, BlockSize);

     (* Daten lesen: *)
     {$I-}

     {$IFDEF ONEFILE}
     _BlockRead(F, PBlockDaten, BlockSize);
     {$ELSE}
     BlockRead(F, PBlockDaten^, BlockSize);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Lade Farbskala, wenn gewÅnscht und mîglich: *)
     If AUsePal And (PCXHeader.Version >= 5 ) Then
      Begin
       PB1 := @PCXFarbSkala256;
       {$I-}

       {$IFDEF ONEFILE}
       PH1 := PB1;
       _BlockRead(F, PH1, SizeOf(PCXFarbSkala256));
       {$ELSE}
       BlockRead(F, PB1^, SizeOf(PCXFarbSkala256));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

       (* FÅr VGA durch 4 teilen ("DIV 4"): *)
       For IH1 := 1 To 768 Do
        Begin
         PB1^ := PB1^ Div 4;
         Inc(PB1);
        End;

       If ASetPal Then SetPalette(PCXFarbSkala256);
       LoadPCXPic := @PCXFarbSkala256;
      End;

     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Ein Satz entpacken und gleich in die richtigen Ebenen verteilen: *)

     PB1        := PBlockDaten;
     AktEbene   := 0;
     PixelCount := 0;                   (* Anzahl gezeichneter Punkte. *)

     While PixelCount < 64000 Do
      Begin
       If PB1^ >= 192 Then
        Begin
         (* ZÑhler sind die 6 niedrigsten Bits: *)
         Zaehler := PB1^ - 192;

         (* Raster-Daten ist das nÑchste Byte: *)
         Inc(PB1);

         (* ZAEHLER mal ausgeben: *)
         For IH1 := 1 To Zaehler Do
          Begin
           PEbenen[AktEbene]^ := PB1^;
           Inc(PEbenen[AktEbene]);
           Inc(AktEbene); If AktEbene = 4 Then AktEbene := 0;
           Inc(PixelCount);
          End;
        End

       (* Wenn kein ZÑhler-Byte, gleich schreiben: *)
       Else
        Begin
         PEbenen[AktEbene]^ := PB1^;
         Inc(PEbenen[AktEbene]);
         Inc(AktEbene); If AktEbene = 4 Then AktEbene := 0;
         Inc(PixelCount);
        End;

       (* NÑchstes Byte: *)
       Inc(PB1);
      End;                              (* Von FOR. *)

     (* ----- Wenn auf BACKGROUNDPAGE, entscheiden, ob in RAM oder VRAM: *)

     (* In RAM: *)
     If (APage = BACKGROUNDPAGE) And (Not UseVRAMBackGround) Then
      Begin
       Move(PDatenIn4er^, RAMBackGrPageBuf^, SizeOf(TRAMBackGrPageBuf));
      End

     (* In VRAM: *)
      Else
       Begin
        (* PBLOCKDATEN^ Ebenenweise auf Schirm bringen: *)
        WH1 := Seg(PDatenIn4er^);
        WH2 := Ofs(PDatenIn4er^);
        WH3 := POfs_Adr[APage];

        Asm
         cld                            (* String aufwÑrts. *)
         mov   es, ScreenSeg            (* ES = ZielSegment. *)
         mov   ds, WH1                  (* DS = QuellSegment. *)
         mov   si, WH2                  (* SI = QuellOffset. *)
         mov   dx, 3C4h                 (* Index der SEQUENCER REGISTER. *)

         (* 1. Ebene: *)
         mov   ax, 0102h                (* 1. Ebene (Nr 0). *)
         out   dx, ax                   (* Ebene wÑhlen. *)
         mov   di, WH3                  (* DI = ZielOffset. *)
         mov   cx, ScreenSize  / 4      (* BYTES -> WORDS. *)
         db    0F3h, 66h, 0A5h          (* "rep movsd", CX mal kopieren. *)

         (* 2. Ebene: *)
         mov   ax, 0202h                (* 2. Ebene (Nr 1). *)
         out   dx, ax                   (* Ebene wÑhlen. *)
         mov   di, WH3                  (* DI = ZielOffset. *)
         mov   cx, ScreenSize  / 4      (* BYTES -> WORDS. *)
         db    0F3h, 66h, 0A5h          (* "rep movsd", CX mal kopieren. *)

         (* 3. Ebene: *)
         mov   ax, 0402h                (* 3. Ebene (Nr 2). *)
         out   dx, ax                   (* Ebene wÑhlen. *)
         mov   di, WH3                  (* DI = ZielOffset. *)
         mov   cx, ScreenSize  / 4      (* BYTES -> WORDS. *)
         db    0F3h, 66h, 0A5h          (* "rep movsd", CX mal kopieren. *)

         (* 4. Ebene: *)
         mov   ax, 0802h                (* 4. Ebene (Nr 3). *)
         out   dx, ax                   (* Ebene wÑhlen. *)
         mov   di, WH3                  (* DI = ZielOffset. *)
         mov   cx, ScreenSize  / 4      (* BYTES -> WORDS. *)
         db    0F3h, 66h, 0A5h          (* "rep movsd", CX mal kopieren. *)

         mov   ax, SEG @Data
         mov   ds, ax
        End;
       End;

     FreeMem(PDatenIn4er, 64000);       (* Speicher fÅr 1 Bild freigeben. *)
     FreeMem(PBlockDaten, BlockSize);

     ERR_Error := ERR_Error_OK;
    End;

   FUNCTION LoadPCXPicToRAM(AName : String; Var Laenge : LongInt) : Pointer;
    (* ---------------------------------------------------------------- *)
    Var {$IFNDEF ONEFILE}
        F         : File;
        {$ENDIF}

        PH1 : Pointer;
    Begin
     (* Datei ôffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AName);
     {$ELSE}
     Assign(F, AName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* DateilÑnge bestimmen: *)
     {$I-}

     {$IFDEF ONEFILE}
     Laenge := _FileSize(F);
     {$ELSE}
     Laenge := FileSize(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Grî·er als 65528 Bytes (= 64 KByte-$08), dann Ende: *)
     If Laenge > 65528 Then
      Begin
       ERR_Error := VGA_Error_FileSizeTooBig;
       CriticalError(AName);
      End;

     (* Speicher fÅr Datei belegen: *)
     _GetMem(PH1, Laenge);

     (* Daten einlesen: *)
     {$I-}

     {$IFDEF ONEFILE}
     _BlockRead(F, PH1, Laenge);
     {$ELSE}
     BlockRead(F, PH1^, Laenge);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Datei schlie·en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* RÅckgabe: *)
     LoadPCXPicToRAM := PH1;
     ERR_Error := ERR_Error_Ok;
    End;

   FUNCTION ShowPCXPicFromRAM(APtr : Pointer; ALaenge : LongInt; APage : Byte; AUsePal, ASetPal : Boolean) : Pointer;
    (* ---------------------------------------------------------------- *)
    Var PDatenIn4er     : Pointer;      (* Hier ist das Bild gespeichert, nach   *)
                                        (* Ebenen geordnet, also E0-Daten, E1... *)
        PBlockDaten     : Pointer;      (* Zeiger auf 1 geladenen Block. *)
        PEbenen         : Array[0..3] Of ^Byte;
        AktEbene        : Byte;

        IH1, IH2        : Integer;
        PB1             : ^Byte;
        WH1, WH2, WH3   : Word;

        Zaehler         : Integer;
        BlockSize       : LongInt;      (* LÑnge der gepacketen (!) PIXELDaten. *)
        PixelCount      : Word;         (* Anzahl gezeichneter Punkte. *)
        FilePTR         : ^Byte;
    Begin
     ShowPCXPicFromRAM := Nil;

     FilePTR := APtr;

     (* Header lesen: *)
     Move(FilePTR^, PCXHeader, SizeOf(PCXHeader));
     Inc(FilePTR, SizeOf(PCXHeader));

     (* DatensÑtze lesen: *)
     _GetMem(PDatenIn4er, 64000);        (* Speicher fÅr 1 Bild reservieren. *)
     LongInt(PEbenen[0]) := LongInt(PDatenIn4er);
     LongInt(PEbenen[1]) := LongInt(PDatenIn4er) + 16000; (* = ((320 * 200) Div 4); *)
     LongInt(PEbenen[2]) := LongInt(PDatenIn4er) + 32000; (* = 2 * ((320 * 200) Div 4); *)
     LongInt(PEbenen[3]) := LongInt(PDatenIn4er) + 48000; (* = 3 * ((320 * 200) Div 4); *)

     (* Gepacktes Bild in RAM laden (dort auch noch gepackt): *)

     (* Grî·e der gepackten PIXEL-Daten: *)
     BlockSize := ALaenge - SizeOf(PCXHeader);;
     If PCXHeader.Version >= 5 Then BlockSize := BlockSize - SizeOf(TPalette);

     (* Speicher fÅr Gepacktes holen: *)
     _GetMem(PBlockDaten, BlockSize);

     (* Daten lesen: *)
     Move(FilePTR^, PBlockDaten^, BlockSize);
     Inc(FilePTR, BlockSize);

     (* Lade Farbskala, wenn gewÅnscht und mîglich: *)
     If AUsePal And (PCXHeader.Version >= 5 ) Then
      Begin
       Move(FilePTR^, PCXFarbSkala256, SizeOf(PCXFarbSkala256));

       (* FÅr VGA durch 4 teilen ("DIV 4"): *)
       For IH1 := 1 To 768 Do
        Begin
         PB1^ := PB1^ Div 4;
         Inc(PB1);
        End;

       If ASetPal Then SetPalette(PCXFarbSkala256);
       ShowPCXPicFromRAM := @PCXFarbSkala256;
      End;

     (* Ein Satz entpacken und gleich in die richtigen Ebenen verteilen: *)

     PB1        := PBlockDaten;
     AktEbene   := 0;
     PixelCount := 0;                   (* Anzahl gezeichneter Punkte. *)

     While PixelCount < 64000 Do
      Begin
       If PB1^ >= 192 Then
        Begin
         (* ZÑhler sind die 6 niedrigsten Bits: *)
         Zaehler := PB1^ - 192;

         (* Raster-Daten ist das nÑchste Byte: *)
         Inc(PB1);

         (* ZAEHLER mal ausgeben: *)
         For IH1 := 1 To Zaehler Do
          Begin
           PEbenen[AktEbene]^ := PB1^;
           Inc(PEbenen[AktEbene]);
           Inc(AktEbene); If AktEbene = 4 Then AktEbene := 0;
           Inc(PixelCount);
          End;
        End

       (* Wenn kein ZÑhler-Byte, gleich schreiben: *)
       Else
        Begin
         PEbenen[AktEbene]^ := PB1^;
         Inc(PEbenen[AktEbene]);
         Inc(AktEbene); If AktEbene = 4 Then AktEbene := 0;
         Inc(PixelCount);
        End;

       (* NÑchstes Byte: *)
       Inc(PB1);
      End;                              (* Von FOR. *)

     (* PBLOCKDATEN^ Ebenenweise auf Schirm bringen: *)
     WH1 := Seg(PDatenIn4er^);
     WH2 := Ofs(PDatenIn4er^);
     WH3 := POfs_Adr[APage];

     Asm
      mov   es, ScreenSeg               (* ES = ZielSegment. *)

      mov   ds, WH1                     (* DS = QuellSegment. *)
      mov   si, WH2                     (* SI = QuellOffset. *)

      cld                               (* String aufwÑrts. *)

      (* Ebenen ausgeben: *)
      mov   cx, 4                       (* Alle Ebenen durch. *)
      mov   ah, 1                       (* 1. Ebene (Nr 0). *)
      mov   al, 2                       (* AL = Index Map Mask Register. *)
      mov   dx, 3C4h                    (* Index der SEQUENCER REGISTER. *)

     @EineEbene:
      mov   bx, cx                      (* CX zwischenspeichern. *)

      mov   di, WH3                     (* DI = ZielOffset. *)

      out   dx, ax                      (* Ebene wÑhlen. *)

      mov   cx, ScreenSize  / 2           (* BYTES -> WORDS. *)

      (* Alle Daten von 1 Ebene ausgeben: *)

      (* CX = Anzahl Bytes,                       *)
      (* DS = Spritedaten-Segment,                *)
      (* SI = Spritedaten-Offset.                 *)
      (* ES = Bildschirm-Segment,                 *)
      (* DI = Bildschirm-Offset,                  *)

      rep   movsw                       (* CX mal kopieren. *)

      mov   cx, bx                      (* gespeichertes CX zurÅck. *)

      shl   ah, 1                       (* NÑchste Ebene anwÑhlen. *)

      loop  @EineEbene

      mov   ax, SEG @Data
      mov   ds, ax
     End;

     FreeMem(PDatenIn4er, 64000);       (* Speicher fÅr 1 Bild freigeben. *)
     FreeMem(PBlockDaten, BlockSize);

     ERR_Error := ERR_Error_OK;
    End;

   PROCEDURE CopySpritesToBkgPage(AFirstLOADNr, ALastLOADNr : Word);
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2   : Integer;
    Begin
     (* Alles richtig Åbergeben: *)
     If (AFirstLOADNr < 1) Or (AFirstLOADNr > LoadMAX) Or
        (ALastLOADNr  < 1) Or (ALastLOADNr  > LoadMAX) Or
        (AFirstLOADNr > ALastLOADNr) Then
      Begin
       ERR_Error := VGA_Error_InvalidArgumentValues;
       Exit;
      End;

     Global_WH1 := AFirstLOADNr;
     Global_WH2 := ALastLOADNr;

     (* Kopieren: *)
     Asm
      (*------------ SPRITES AUSGEBEN: ------------*)

      (* Voreinstellungen: *)
      push  ScreenSeg
      pop   es                          (* ES = Bildschirm-Segment. *)

      mov   si, NMAX * 2

      push  bp

     @_Zeichne:

      (* Hier: ES = Grafiksegment,             *)
      (*       SI = Spritepositionsnummer * 2, *)
      (*       BX = Spriteladenummer.          *)

     @_SZeich:
      mov   bx, [si + OFFSET SpriteN]   (* BX = SpriteN[?] = Spriteladenummer. *)
      shl   bx, 1                       (* BX = Spriteladenummer * 2. *)

      (* Schauen, ob kopieren: *)
      push  ds
      mov   ax, SEG @Data
      mov   ds, ax

      mov   ax, Global_WH1              (* AFirstLOADNr -> AX. *)
      shl   ax, 1
      mov   cx, Global_WH2              (* ALastLOADNr  -> CX. *)
      shl   cx, 1
      cmp   bx, ax
      jb    @_NichtKopieren
      cmp   bx, cx
      ja    @_NichtKopieren

     @_Kopieren:
      pop   ds
      jmp   @_Aktiv

     @_NichtKopieren:
      pop   ds
      jmp   @_NoSprite

      (* Jetzt: "SpriteN[?] := SpriteN[NextSprite[?]]" berechnen: *)
      mov   bx, [bx + OFFSET NextSprite](* AX = NextSprite[SpriteN[?]]. *)
      mov   [si + OFFSET SpriteN], bx   (* als neue SpriteN[?] Åbernehmen. *)
      shl   bx,1

      jnz   @_Aktiv
      jmp   @_NoSprite

     @_Aktiv:
      push  si                          (* Spritepositionsnummer * 2 retten. *)

      mov   di, [si + OFFSET SpriteY]
      shl   di, 1
      mov   di, cs:[di + OFFSET CS_GAdr](* Aktuelle Zeile ermitteln. *)

      add   di, BackGroundPage * ScreenSize
                                        (* Seitenoffset addieren. *)

      mov   dx, [si + OFFSET SpriteX]   (* Aktuells Spalte ermitteln. *)
      mov   ax, dx                      (* FÅr [OFSX] speichern. *)
      shr   dx, 1
      shr   dx, 1
      add   di, dx

      (* !!! Ab hier: DS = ^SpriteDaten !!! *)
      mov   ds, [bx + OFFSET SpriteAD]

      mov   bx, di                      (* BX = ^BildschirmOffset. *)
      mov   [OfsScr], bx

      mov   WORD PTR [CntLines], 0      (* 0 Zeilen gezeichnet. *)
      mov   WORD PTR [CntPl],    0      (* Um 0 Planes verschoben. *)

      (* Jetzt: Ebene ermitteln: *)
      mov   [OfsX], ax

      (* DS = ^SpriteDaten,      *)
      (* ES = ^Bildschirm,       *)
      (* BX = ^Bildschirmoffset. *)

      (* IN _AH_ STEHT IMMER: AKTUELLE EBENE !!! *)

      xor   bp, bp

     @_EineZeile:                        (* Komplette Zeile mit allen Ebenen. *)

      mov   ax, [OfsX]
      and   ax, 3
      mov   di, ax
      mov   ah, Translate[di]

     (* ---- PLANE 0: *)
     @_Plane0Pointer:

      mov   si, [Plane0]                (* Zeiger auf Daten. *)
      add   si, bp

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @_Pl0:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @_Pl0                       (* Ja, nichts zu tun. *)
      jcxz  @_L0                        (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @_Pl0                       (* NÑchstes Byte. *)
     @_L0:

     (* ---- PLANE 1: *)
     @_Plane1Pointer:

      mov   si, [Plane1]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @_P1NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @_P1NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @_Pl1:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @_Pl1                       (* Ja, nichts zu tun. *)
      jcxz  @_L1                        (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @_Pl1                       (* NÑchstes Byte. *)
     @_L1:

     (* ---- PLANE 2: *)
     @_Plane2Pointer:

      mov   si, [Plane2]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @_P2NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @_P2NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @_Pl2:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @_Pl2                       (* Ja, nichts zu tun. *)
      jcxz  @_L2                        (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @_Pl2                       (* NÑchstes Byte. *)
     @_L2:

     (* ---- PLANE 3: *)
     @_Plane3Pointer:

      mov   si, [Plane3]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @_P3NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @_P3NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @_Pl3:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @_Pl3                       (* Ja, nichts zu tun. *)
      jcxz  @_L3                        (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @_Pl3                       (* NÑchstes Byte. *)
     @_L3:

      (* Jetzt: Eine Zeile fertig. *)

      add   bp, [BreiteInB]

      mov   bx, [OfsScr]                (* + 1 Zeile. *)
      add   bx, LineSize
      sub   bx, [CntPl]                 (* Ggf. Verschiebungen abziehen. *)
      mov   [OfsScr], bx
      mov   WORD PTR [CntPl], 0

      inc   WORD PTR [CntLines]         (* 1 Zeile weniger bis zum Ziel. *)

      mov   bx, [CntLines]
      cmp   bx, [HoeheInZ]              (* Schon alle Zeilen durch ? *)

      jne   @_EineZeile                 (* Nein, springe. *)

     @_SpriteFertig:
      pop   si
      mov   ax, SEG @Data
      mov   ds, ax

     @_NoSprite:
      dec   si
      dec   si
      js    @_Fertig
      jmp   @_Zeichne

     @_Fertig:
      pop   bp
     End;

     (* Ende: *)
     ERR_Error := ERR_Error_OK;
    End;

   PROCEDURE ClearSpritesFromSpriteN(AFirstLOADNr, ALastLOADNr : Word);
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2 : Integer;
    Begin
     (* Alles richtig Åbergeben: *)
     If (AFirstLOADNR < 1) Or (AFirstLOADNr > LoadMAX) Or
        (ALastLOADNR  < 1) Or (ALastLOADNr  > LoadMAX) Or
        (AFirstLOADNR > ALastLOADNr) Then
      Begin
       ERR_Error := VGA_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Austragen: *)
     For IH1 := 1 To NMAX Do
      Begin
       If (SpriteN[IH1] >= AFirstLOADNr) And (SpriteN[IH1] <= ALastLOADNr) Then
        Begin
         SpriteN[IH1] := 0;
         SpriteX[IH1] := 0;
         SpriteY[IH1] := 0;
        End;
      End;

     (* Ende: *)
     ERR_Error := ERR_Error_OK;
    End;

   FUNCTION VGAGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      VGA_Error_NoVGA                 : S := S + 'Keine VGA-Karte vorhanden.';
      VGA_Error_NoPCXFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das PCX-Format fÅr Bilder.';
      VGA_Error_NoPCX320_200Points    : S := S + 'PCX-Datei ' + UpString(AS + C) + 'hat nicht das Format 320 * 200 Punkte.';
      VGA_Error_NoPCX256Color         : S := S + 'PCX-Datei ' + UpString(AS + C) +  'hat keine 256 Farben.';
      VGA_Error_InvalidSpriteLoadNr   : S := S + 'UngÅltige Sprite-LOADNummer.';
      VGA_Error_NoSPRFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das SPR/LIB-Format ' +
                                                 'fÅr Sprites/Spritebibliotheken.';
      VGA_Error_NoIMGFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das IMG-Format fÅr Bildauschnitte.';
      VGA_Error_InvalidArgumentValues : S := S + 'öbergebene Werte nicht zugelassen';
      VGA_Error_SpriteNArrayIsFull    : S := S + 'SPRITE-N-Feld ist voll.';
      VGA_Error_NotEnoughMemory       : S := S + 'Nicht genug Speicher zur VerfÅgung.';
      VGA_Error_SpriteLOADArrayIsFull : S := S + 'SPRITE-LOAD-Feld ist voll.';
      VGA_Error_FileSizeTooBig        : S := S + 'Datei ist zu gro·.';
      VGA_Error_No386                 : S := S + 'Es mu· mindestens ein 80386 Prozessor vorhanden sein.';
      VGA_Error_BackgroundToBig       : S := S + 'Grî·e des Hinterund Åberschreitet maximale Kachelanzahl.';
      VGA_Error_InvalidCoordinates    : S := S + 'Die Åbergebenen Koordinaten haben ungÅltige Werte.';
      VGA_Error_InvalidMode           : S := S + 'Falscher Modus fÅr Hintergrund.';
      VGA_Error_SPRNoTileSize         : S := S + 'Grî·e der geladenen Kachel ist ungÅltig.';
      VGA_Error_SPRTooManyDifTiles    : S := S + 'Maximale Anzahl an verschiedenen Kacheln ist erreicht.';
      VGA_Error_TooManyTilesInTILFile : S := S + 'Zu viele Kacheln fÅr den Hintergrund zu laden.';
      VGA_Error_NoColorDisplay        : S := S + 'Es ist kein Farbbildschirm angeschlossen.';

      Else                              S := '';
     End;

     VGAGetErrorMessage := S;
    End;

   PROCEDURE WaitVRetrace; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   dx, StatusReg

    @WaitNotVSyncLoop:                  (* Falls noch aktiv, warte bis Ende. *)
     in    al, dx
     and   al, 8
     jnz   @WaitNotVSyncLoop

    @WaitVSyncLoop:                     (* Warte bis Beginn. *)
     in    al, dx
     and   al, 8
     jz    @WaitVSyncLoop
    End;

   PROCEDURE WaitHRetrace; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   dx, StatusReg

    @WaitNotHSyncLoop:                  (* Falls noch aktiv, warte bis Ende. *)
     in    al, dx
     and   al, 1
     jz    @WaitNotHSyncLoop

    @WaitHSyncLoop:                     (* Warte bis Beginn. *)
     in    al, dx
     and   al, 1
     jnz   @WaitHSyncLoop
    End;

   PROCEDURE ScreenOff;
    (* ---------------------------------------------------------------- *)
    Begin
     Port[$3C4] := 1;
     Port[$3C5] := Port[$3C5] Or $20;
    End;

   PROCEDURE ScreenOn;
    (* ---------------------------------------------------------------- *)
    Begin
     Port[$3C4] := 1;
     Port[$3C5] := Port[$3C5] And $DF;
    End;

   PROCEDURE SaveImage(AName : String; AP : Byte; X, Y, ABr, AHo : Word);
    (* ---------------------------------------------------------------- *)
    Var F             : File;
        WH1           : Word;
        IH1, IH2      : Integer;
        PBH1          : ^Byte;
        PH1           : Pointer;
    Begin
     (* Ggf. aussteigen: *)
     If (Not (AP In [0..3])) Or (ABr Mod 4 <> 0) Or (AHo Mod 4 <> 0) Then
      Begin
       ERR_Error := VGA_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Datei ôffnen: *)
     Assign(F, AName);
     {$I-}
     Rewrite(F, 1);                     (* BlockRead-LÑnge : 1 Byte. *)
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Header fÅllen: *)
     With SPRHeader Do
      Begin
       Kennung := 'UK';
       Version := 1;
       Art     := 'IMG';
       Breite  := ABr;
       Hoehe   := AHo;
       FillChar(Dummy, SizeOf(Dummy), 0);
      End;

     (* Header schreiben: *)
     {$I-}
     BlockWrite(F, SPRHeader, SizeOf(SPRHeader));
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Bild erstellen: *)
     GetImage(WH1, AP, X, Y, ABr, AHo);

     (* Zeiger setzen: *)
     PH1 := Ptr(WH1, 0);                (* Zeiger auf Daten. *)
     PBH1 := PH1;
     Inc(PBH1, SizeOf(SPRHeader));      (* Direkt zu DATEN springen. *)

     (* Speicher auf Diskette schreiben: *)
     {$I-}
     BlockWrite(F, PBH1^, ABr * AHo);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Datei schlie·en: *)
     {$I-}
     Close(F);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Speicher freigeben: *)
     PBH1 := PH1;
     IH1  := Word(PBH1^) * 4;           (* Breite. *)
     Inc(PBH1, 2);
     IH2  := Word(PBH1^);               (* Hîhe. *)
     Dec(PBH1, 2);

     FreeMem(PBH1, SizeOf(SPRHeader) + IH1 * IH2 + 15);

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE LoadImage(AName : String; AP : Byte; X, Y : Word);
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PXH1      : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}

        BH1       : Byte;
        ASeg      : Word;               (* Segment, an das geladen wird. *)
        PBH1      : ^Byte;
        PH1, PH2  : Pointer;
        IH1, IH2  : Integer;
        MemSize   : Word;
    Begin
     If Not (AP In [0..3]) Then
      Begin
       ERR_Error := VGA_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Datei ôffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, AName);
     {$ELSE}
     Assign(F, AName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Lesen, Header: *)
     {$I-}

     {$IFDEF ONEFILE}
     PXH1 := @SPRHeader;
     _BlockRead(F, PH1, SizeOf(SPRHeader));
     {$ELSE}
     BlockRead(F, SPRHeader, SizeOf(SPRHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Header auswerten: *)
     If (SPRHeader.Kennung <> 'UK') Or (SPRHeader.Art <> 'IMG') Then
      Begin
       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

       ERR_Error := VGA_Error_NoSPRFile;
       CriticalError('');
      End;

     (* Header erstellen: *)
     SpriteStruct.BreiteInBytes := SPRHeader.Breite Div 4;
     SpriteStruct.HoeheInZ := SPRHeader.Hoehe;
     SpriteStruct.Translate[1] := 1;
     SpriteStruct.Translate[2] := 2;
     SpriteStruct.Translate[3] := 4;
     SpriteStruct.Translate[4] := 8;
     SpriteStruct.PlaneDatPtr[0] := SizeOf(TSpriteStruct);
     SpriteStruct.PlaneDatPtr[1] := SizeOf(TSpriteStruct) +     ((SPRHeader.Breite Div 4) * SPRHeader.Hoehe);
     SpriteStruct.PlaneDatPtr[2] := SizeOf(TSpriteStruct) + 2 * ((SPRHeader.Breite Div 4) * SPRHeader.Hoehe);
     SpriteStruct.PlaneDatPtr[3] := SizeOf(TSpriteStruct) + 3 * ((SPRHeader.Breite Div 4) * SPRHeader.Hoehe);

     (* Speicher anfordern und Header hineinkopieren: *)
     MemSize := SizeOf(TSpriteStruct) + SPRHeader.Breite * SPRHeader.Hoehe + 15;
     _GetMem(PH1, MemSize);

     If (LongInt(PH1) mod 16) = 0 Then PH2 := PH1
      Else LongInt(PH2) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);

     ASeg := (LongInt(PH2) Shr 16) + (LongInt(PH2) And 65535) Shr 4;

     (* Header auf Heap bringen: *)
     Move(SpriteStruct, PH2^, SizeOf(TSpriteStruct));
     LongInt(PH1) := LongInt(PH2) + SizeOf(TSpriteStruct);

     (* Rest vom Sprite auf Heap bringen: *)
     {$I-}

     {$IFDEF ONEFILE}
     _BlockRead(F, PH1, SPRHeader.Breite * SPRHeader.Hoehe);
     {$ELSE}
     BlockRead(F, PH1^, SPRHeader.Breite * SPRHeader.Hoehe);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* Ausgeben: *)                    (* Wie in 'ANIMATE'. *)
     Asm
      (* Voreinstellungen: *)
      mov   ax, ScreenSeg
      mov   es, ax                      (* ES = Bildschirm-Segment. *)

      (*------------ BILD AUSGEBEN: ------------*)

      push  bp                          (* BP auf Stack sichern. *)

      (* Hier: ES = Grafiksegment,             *)

      (* In DI steht am ENDE die Bildschirm-ADRESSE,      *)
      (* an die der Sprite geschrieben wird (links oben). *)

      mov   di, Y                       (* Y-Koordinate nach DI. *)

      push  di                          (* Y-Koordinate retten. *)

      shl   di, 1                       (* DI := DI * 2. *)
      mov   di, cs:[di + OFFSET CS_GAdr](* Aktuelle Zeile ermitteln. *)

      xchg  ax, bx                      (* BX zwischenspeichern. *)

      xor   bh, bh
      mov   bl, AP                      (* BX := AP. *)
      shl   bx, 1                       (* BX := BX * 2. *)
      add   di, cs:[bx + OFFSET CS_POfs_Adr](* Seitenoffset addieren. *)

      xchg  bx, ax                      (* BX wieder zurÅckholen. *)

      mov   dx, X                       (* Aktuelle Spalte ermitteln. *)

     @XOK:
      mov   ax, dx                      (* FÅr [OFSX] in AX speichern. *)

      shr   dx, 1                       (* DX := DX / 2. *)
      shr   dx, 1                       (* DX := DX / 2. *)
      add   di, dx                      (* Spaltenadresse dazuaddieren. *)

      (* ---------------------------------- *)
      (* !!! Ab hier: DS = ^SpriteDaten !!! *)
      (* ---------------------------------- *)
      mov   ds, [ASeg]                  (* DS zeigt auf normalisierte Segment- *)
                                        (* Adresse der Kopie des Bildes.       *)

      pop   WORD PTR [UpperY]           (* Gerettete Y-Koordinate zurÅck. *)

      (* Jetzt: Ebene ermitteln: *)
      mov   [OfsX], ax                  (* Bytes vom linken Rand bis zum linken Sprite-Rand. *)

      mov   bx, di                      (* BX = ^BildschirmOffset. *)
      mov   [OfsScr], bx                (* Ofs-Wert der linken oberen Ecke sichern. *)

      mov   ax, [HoeheInZ]
      (* CntLines zÑhlt rÅckwÑrts ! *)
      mov   WORD PTR [CntLines], AX     (* 0 Zeilen gezeichnet. *)
      mov   WORD PTR [CntPl],    0      (* Um 0 Planes verschoben. *)

      (* DS = ^SpriteDaten,      *)
      (* ES = ^Bildschirm,       *)
      (* BX = ^Bildschirmoffset. *)

      (* IN _AH_ STEHT IMMER: AKTUELLE EBENE !!! *)

      xor   bp, bp                      (* BP := 0. *)

      jmp @L5                           (* öberspringe die Sprungleiste. *)

     @ToSpriteFertig:
      jmp   @SpriteFertig               (* Sprungleiste zu @SpriteFertig. *)

     @L5:

     (*------- Eine Zeile ausgeben: -------*)
     @EineZeile:                        (* Komplette Zeile mit allen Ebenen. *)

      mov   di, [OfsX]                  (* Ermittle die aktuell benîtigte *)
      and   di, 3                       (* Ebene der ganz linken Spalte.  *)
      mov   ah, Translate[di]

     (* ---- PLANE 0: *)
     @Plane0Pointer:

      mov   si, [Plane0]                (* Zeiger auf Daten fÅr die 1. Ebene. *)
      add   si, bp

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax                      (* In AH steht aktuelle Ebene. *)

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl0:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl0                        (* Ja, nichts zu tun. *)
      jcxz  @L0                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl0                        (* NÑchstes Byte. *)
     @L0:

     (* ---- PLANE 1: *)
     @Plane1Pointer:

      mov   si, [Plane1]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @P1NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      je    @P1NichtE3                  (* Nicht weiterschalten. *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @P1NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl1:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl1                        (* Ja, nichts zu tun. *)
      jcxz  @L1                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl1                        (* NÑchstes Byte. *)
     @L1:

     (* ---- PLANE 2: *)
     @Plane2Pointer:

      mov   si, [Plane2]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @P2NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      je    @P2NichtE3                  (* Nicht weiterschalten. *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @P2NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl2:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl2                        (* Ja, nichts zu tun. *)
      jcxz  @L2                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl2                        (* NÑchstes Byte. *)
     @L2:

     (* ---- PLANE 3: *)
     @Plane3Pointer:

      mov   si, [Plane3]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @P3NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      je    @P3NichtE3                  (* Nicht weiterschalten. *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @P3NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl3:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl3                        (* Ja, nichts zu tun. *)
      jcxz  @L3                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl3                        (* NÑchstes Byte. *)
     @L3:

      (* Jetzt: Eine Zeile fertig. *)

      add   bp, [BreiteInB]             (* BX := BX + Breite eines Sprites *)
                                        (* in BYTES (= Pixel / 4).         *)

      mov   bx, [OfsScr]                (* Offset der linken Seite der *)
                                        (* aktuellen Zeile laden.      *)
      add   bx, LineSize                (* + 1 Zeile. *)
      sub   bx, [CntPl]                 (* Ggf. Verschiebungen abziehen. *)
      mov   [OfsScr], bx                (* Neue Offset speichern. *)
      mov   WORD PTR [CntPl], 0         (* EbenenzÑhler wieder auf 0. *)

      dec   WORD PTR [CntLines]         (* 1 Zeile weniger bis zum Ziel. *)

      mov   bx, [CntLines]              (* Teste, ob schon alle Zeilen *)
      or    bx, bx                      (* gezeichnet wurden.          *)

      jnz   @EineZeile                  (* Nein, springe. *)

     @SpriteFertig:                     (* Sprite fertig gezeichnet. *)
      mov   ax, SEG @Data               (* Das Datensegment wieder   *)
      mov   ds, ax                      (* zurÅckholen.              *)

     @NoSprite:                         (* SpriteN[ALoadNr] ist leer (=0). *)

     @Fertig:
      pop   bp                          (* BP zurÅckholen. *)

     End;                               (* Von 'ASM'. *)

     (* Speicher freigeben: *)
     PBH1 := Ptr(ASeg, 0);
     IH1  := Word(PBH1^) * 4;           (* Breite. *)
     Inc(PBH1, 2);
     IH2  := Word(PBH1^);               (* Hîhe. *)
     Dec(PBH1, 2);

     FreeMem(PBH1, SizeOf(IMGHeader) + IH1 * IH2 + 15);

     (* Datei schlie·en: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Close(F);
     {$ELSE}
     Close(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AName);

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE GetImage(Var ASeg : Word; AP : Byte; X, Y, ABr, AHo : Word);
    (* ---------------------------------------------------------------- *)
    Var BH1      : Byte;
        WH1      : Word;
        IH1, IH2 : Integer;
        PH1, PH2 : Pointer;
    Begin
     (* Ggf. aussteigen: *)
     If (Not (AP In [0..3])) Or (ABr Mod 4 <> 0) Or (AHo Mod 4 <> 0) Then
      Begin
       ERR_Error := VGA_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Speicher anfordern: *)
     _GetMem(PH1, SizeOf(IMGHeader) + ABr * AHo + 15);
     If (LongInt(PH1) mod 16) = 0 Then PH2 := PH1
      Else LongInt(PH2) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);

     ASeg := (LongInt(PH2) Shr 16) + (LongInt(PH2) And 65535) Shr 4;
     WH1  := ASeg;

     (* Header schreiben: *)
     With IMGHeader Do
      Begin
       BreiteInBytes  := ABr Div 4;
       HoeheInZ       := AHo;
       Translate[1]   := 1;
       Translate[2]   := 2;
       Translate[3]   := 4;
       Translate[4]   := 8;
       PlaneDatPtr[0] := SizeOf(IMGHeader);
       PlaneDatPtr[1] := SizeOf(IMGHeader) +     (ABr Div 4) * AHo;
       PlaneDatPtr[2] := SizeOf(IMGHeader) + 2 * (ABr Div 4) * AHo;
       PlaneDatPtr[3] := SizeOf(IMGHeader) + 3 * (ABr Div 4) * AHo;
       FillChar(Dummy, SizeOf(Dummy), 0);
      End;

     Move(IMGHeader, PH2^, SizeOf(IMGHeader));
     LongInt(PH1) := LongInt(PH2) + SizeOf(IMGHeader);

     (* Daten lesen: *)

     Asm
      (* Voreinstellungen: *)
      mov   ax, ScreenSeg
      mov   es, ax                      (* ES = Bildschirm-Segment. *)

      (* Lesemodus 0 einstellen: *)
      mov   dx, 3CEh                    (* Index der REGISTER DES GRAPHICS CONTROLLERS. *)
      mov   al, 5                       (* Index des MODE REGISTERS. *)
      out   dx, al                      (* Register ansprechen. *)
      inc   dx
      in    al, dx                      (* Inhalt auslesen. *)
      and   al, 247                     (* Bit 3 = 0: LESEMODUS 0. *)
      out   dx, al                      (* Setzen. *)

      (*------------ BILD AUSGEBEN: ------------*)

      push  bp

      (* In DI steht am Ende die Bildschirm-ADRESSE,      *)
      (* an die der Sprite geschrieben wird (links oben). *)

      mov   di, Y                       (* Y-Koordinate nach DI. *)
      shl   di, 1                       (* DI := DI * 2. *)

      mov   di, cs:[di + OFFSET CS_GAdr](* Aktuelle Zeile ermitteln. *)

      xor   bh, bh
      mov   bl, AP                      (* Auf "AP" zeichnen. *)
      shl   bx, 1                       (* BX := BX * 2. *)
      add   di, cs:[bx + OFFSET CS_POfs_Adr](* Seitenoffset addieren. *)

      mov   dx, X                       (* Aktuelle Spalte ermitteln. *)

      mov   cx, dx                      (* FÅr [OFSX] in CX speichern. *)

      shr   dx, 1                       (* DX := DX / 2. *)
      shr   dx, 1                       (* DX := DX / 2. *)
      add   di, dx                      (* Spaltenadresse dazuaddieren. *)

      (* ------------------------------------------------------ *)
      (* Ab hier: DS = SEG(SpriteDaten) !!! *)

      mov   bx, ax                      (* SpriteN[?] (oben errechnet). *)

      mov   ax, WH1
      mov   ds, ax

      (* ------------------------------------------------------ *)
      (* Im weiteren werden folgende Register wie folgt belegt: *)
      (*                                                        *)
      (*  AH = Aktuelle Ebene                                   *)
      (*  DI = Offset des Schirms an (SpriteX[?]|SpriteY[?])    *)
      (*  DS = Segment der SpriteDaten                          *)
      (*  ES = Bildschirmsegment                                *)
      (*  BP = Anzahl noch zu zeichnender Ebenen                *)
      (*  BX = Aktueller Schirmoffset                           *)
      (*  CX = ZÑhler der noch zu zeichnenden Bytes pro Zeile   *)
      (*  DX = ZÑhler der noch zu zeichnenden Zeilen            *)
      (* ------------------------------------------------------ *)

      mov   bp, 4                       (* 4 Ebenen Zeichnen. *)

      (* Start-Ebene ermitteln: *)
      mov   ax, cx                      (* [OFSX] aus CX (oben gespeichert). *)
      and   ax, 3                       (* Ermittle die aktuell benîtigte Ebene der ganz linken Spalte. *)
      mov   ah, al                      (* In AH steht aktuelle Ebene (0..3). *)

      mov   si, [Plane0]                (* Zeiger auf Daten fÅr die 1. Ebene. *)

     @Ebene:                            (* Ebene anwÑhlen. *)

      (* Ebene zum LESEN auswÑhlen: *)
      mov   dx, 3CEh                    (* Index der REGISTER DES GRAPHICS CONTROLLERS. *)
      mov   al, 4                       (* Index des READ MAP SELECT REGISTERS. *)
      out   dx, ax                      (* Register ansprechen. *)
                                        (* In AH steht die aktuelle EBENE. *)

      mov   dx, [HoeheInZ]

      (* ALLE Zeilen mit 1 Ebene durchmachen: *)
      mov   bx, di                      (* Offset des SCHIRMS. *)

      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)

      (* Eine Zeile in der aktuellen Ebene zeichnen: *)
     @EineZeile:                        (* Eine Zeile in einer Ebene. *)
      mov   cx, [BreiteInB]
      inc   cx

     @Pl0:
      inc   si
      mov   al, es:[bx+si]              (* Punkt vom Schirm holen. *)
      dec   si
      mov   ds:[si], al                 (* Punkt in Speicher. *)
      inc   si
      loop  @Pl0

      (* Auf nÑchste Zeile bringen: *)
      add   bx, ((XMAX + 1) / 4)        (* In nÑchste Zeile. *)
      sub   bx, [BreiteInB]

      dec   si                          (* Da CX 1 mehr als Breite,           *)
                                        (* nun SI wieder auf richtigen Platz. *)
      dec   dx
      jnz   @EineZeile                  (* Noch nicht alle Zeilen. *)

      (* Jetzt nÑchste Ebene wÑhlen: *)
      inc   ah                          (* AH := AH + 1. *)

      cmp   ah, 4
      jnae  @OverChangePlane            (* Wenn man NICHT Ebene von vorne mu·. *)

      inc   di                          (* Schirmoffset +1. *)
      xor   ah, ah                      (* 1.Ebene (= 0). *)

     @OverChangePlane:                  (* Ebene Nicht Ñndern. *)
      dec   bp
      jnz   @Ebene                      (* Alle Zeilen mit nÑchster Ebene. *)

      (* Sprite fertig: *)
      mov   ax, SEG @Data               (* Das Datensegment wieder   *)
      mov   ds, ax                      (* zurÅckholen.              *)

      pop   bp                          (* BP zurÅckholen. *)
     End;                               (* Von 'ASM'. *)

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE PutImage(ASeg : Word; AP : Byte; X, Y : Word; AFree : Boolean);
    (* ---------------------------------------------------------------- *)
    Var PBH1     : ^Byte;
        IH1, IH2 : Integer;
    Begin
     If Not (AP In [0..3]) Then
      Begin
       ERR_Error := VGA_Error_InvalidArgumentValues;
       Exit;
      End;

     (* Ausgeben: *)                    (* Wie in 'ANIMATE'. *)
     Asm
      (* Voreinstellungen: *)
      mov   ax, ScreenSeg
      mov   es, ax                      (* ES = Bildschirm-Segment. *)

      (*------------ BILD AUSGEBEN: ------------*)

      push  bp

      (* In DI steht am Ende die Bildschirm-ADRESSE,      *)
      (* an die der Sprite geschrieben wird (links oben). *)

      mov   di, Y                       (* Y-Koordinate nach DI. *)
      shl   di, 1                       (* DI := DI * 2. *)

      mov   di, cs:[di + OFFSET CS_GAdr](* Aktuelle Zeile ermitteln. *)

      xor   bh, bh
      mov   bl, AP                      (* Auf "AP" zeichnen. *)
      shl   bx, 1                       (* BX := BX * 2. *)
      add   di, cs:[bx + OFFSET CS_POfs_Adr](* Seitenoffset addieren. *)

      mov   dx, X                       (* Aktuelle Spalte ermitteln. *)

      mov   cx, dx                      (* FÅr [OFSX] in CX speichern. *)

      shr   dx, 1                       (* DX := DX / 2. *)
      shr   dx, 1                       (* DX := DX / 2. *)
      add   di, dx                      (* Spaltenadresse dazuaddieren. *)

      (* ------------------------------------------------------ *)
      (* Ab hier: DS = SEG(SpriteDaten) !!! *)

      mov   bx, ax                      (* SpriteN[?] (oben errechnet). *)
      mov   ds, [ASeg]                  (* DS zeigt auf normalisierte Segment- *)
                                        (* Adresse des aktuellen Sprites.      *)

      (* ------------------------------------------------------ *)
      (* Im weiteren werden folgende Register wie folgt belegt: *)
      (*                                                        *)
      (*  AH = Aktuelle Ebene                                   *)
      (*  DI = Offset des Schirms an (SpriteX[?]|SpriteY[?])    *)
      (*  DS = Segment der SpriteDaten                          *)
      (*  ES = Bildschirmsegment                                *)
      (*  BP = Anzahl noch zu zeichnender Ebenen                *)
      (*  BX = Aktueller Schirmoffset                           *)
      (*  CX = ZÑhler der noch zu zeichnenden Bytes pro Zeile   *)
      (*  DX = ZÑhler der noch zu zeichnenden Zeilen            *)
      (* ------------------------------------------------------ *)

      mov   bp, 4                       (* 4 Ebenen Zeichnen. *)

      mov   bx, cx                      (* [OFSX] aus CX (oben gespeichert). *)
      and   bx, 3                       (* Ermittle die aktuell benîtigte Ebene der ganz linken Spalte. *)
      mov   ah, Translate[bx]           (* In AH steht aktuelle Ebene. *)

      mov   si, [Plane0]                (* Zeiger auf Daten fÅr die 1. Ebene. *)

     @Ebene:                            (* Ebene anwÑhlen. *)

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax                      (* In AH steht aktuelle Ebene. *)

      mov   dx, [HoeheInZ]

      (* ALLE Zeilen mit 1 Ebene durchmachen: *)
      mov   bx, di                      (* Offset des SCHIRMS. *)

      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)

      (* Eine Zeile in der aktuellen Ebene zeichnen: *)
     @EineZeile:                        (* Eine Zeile in einer Ebene. *)
      mov   cx, [BreiteInB]
      inc   cx

     @Pl0:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl0                        (* Ja, nichts zu tun. *)
      jcxz  @L0                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl0                        (* NÑchstes Byte. *)
     @L0:

      (* Auf nÑchste Zeile bringen: *)
      add   bx, ((XMAX + 1) / 4)        (* In nÑchste Zeile. *)
      sub   bx, [BreiteInB]

      dec   si                          (* Da CX 1 mehr als Breite,           *)
                                        (* nun SI wieder auf richtigen Platz. *)
      dec   dx
      jnz   @EineZeile                  (* Noch nicht alle Zeilen. *)


      (* Jetzt nÑchste Ebene wÑhlen: *)
      shl   ah, 1

      cmp   ah, 16
      jnae  @OverChangePlane            (* Wenn man NICHT Ebene von vorne mu·. *)

      inc   di                          (* Schirmoffset +1. *)
      mov   ah, 1                       (* 1.Ebene. *)

     @OverChangePlane:                  (* Ebene Nicht Ñndern. *)
      dec   bp
      jnz   @Ebene                      (* Alle Zeilen mit nÑchster Ebene. *)

      (* Sprite fertig: *)
      mov   ax, SEG @Data               (* Das Datensegment wieder   *)
      mov   ds, ax                      (* zurÅckholen.              *)

      pop   bp                          (* BP zurÅckholen. *)

     End;                               (* Von 'ASM'. *)

     (* Speicher freigeben: *)
     If AFree Then
      Begin
       PBH1 := Ptr(ASeg, 0);
       IH1  := Word(PBH1^) * 4;         (* Breite. *)
       Inc(PBH1, 2);
       IH2  := Word(PBH1^);             (* Hîhe. *)
       Dec(PBH1, 2);

       FreeMem(PBH1, SizeOf(IMGHeader) + IH1 * IH2 + 15);
      End;

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE FreeSpriteMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     If (ANr < 1) Or (ANr > LoadMAX) Then
      ERR_Error := VGA_Error_InvalidSpriteLoadNr        (* Falsches Argument. *)
     Else
      If SpritePTR[ANr] <> Nil Then
       Begin
        FreeMem(SpritePTR[ANr],SpriteSIZE[ANr]);(* Zeiger freigeben. *)
        SpritePTR [ANr] := Nil;         (* Definierte Werte eintragen. *)
        SpriteSIZE[ANr] := 0;
        SpriteAD  [ANr] := 0;
       End;
    End;

   PROCEDURE ClearLOADNrFromSpriteN(ANr : Word);
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     If (ANr < 1) Or (ANr > LoadMAX) Then
      ERR_Error := VGA_Error_InvalidSpriteLoadNr        (* Falsches Argument. *)
     Else
      For IH1 := 1 To NMAX Do
       If SpriteN[IH1] = ANr Then SpriteN[IH1] := 0;
    End;

   PROCEDURE FlipSprite(ANr : Word; AWay : Byte);
    (* ---------------------------------------------------------------- *)
    Var PBH1, PBH2, PBH3 : ^Byte;
        Breite, Hoehe    : Word;
        IH1, IH2, IH3    : Integer;
    Begin
     (* Auf Sprite zeigen: *)
     PBH1 := SpritePTR[ANr];

     (* Breite und Hîhe auslesen: *)
     Breite := 4 * Word(PBH1^);
     Inc(PBH1, 2);
     Hoehe := Word(PBH1^);

     (* Pixeldaten anfahren: *)
     PBH1 := SpritePTR[ANr];
     Inc(PBH1, SizeOf(TSpriteStruct));

     (* Sprite, ohne die Ebeneneinteilung in TemporÑren Speicher schreiben: *)
     _GetMem(Pointer(PBH2), Breite * Hoehe);
    End;

   FUNCTION GetFreeNNr : Integer;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     (* Alles durchsuchen: *)
     If SearchDirection = Up Then
      Begin
       For IH1 := 1 To NMAX Do If SpriteN[IH1] = 0 Then Break;
      End
     Else
      Begin
       For IH1 := NMAX-1 DownTo 0 Do If SpriteN[IH1] = 0 Then Break;
      End;

     (* Wert zurÅckgeben: *)
     If (IH1 > 0) And (IH1 < NMAX) Then GetFreeNNr := IH1
     Else
      Begin
       GetFreeNNr := -1;

       ERR_Error := VGA_Error_SpriteNArrayIsFull;
       CriticalError('');
      End;
    End;

   FUNCTION GetFreeLoadNr : Integer;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     (* Alles durchsuchen: *)
     If SearchDirection = Up Then
      Begin
       For IH1 := 1 To LoadMAX Do If SpritePTR[IH1] = Nil Then Break;
      End
     Else
      Begin
       For IH1 := LoadMAX-1 DownTo 0 Do If SpritePTR[IH1] = Nil Then Break;
      End;

     (* Wert zurÅckgeben: *)
     If (IH1 > 0) And (IH1 < LoadMAX) Then GetFreeLoadNr := IH1
     Else
      Begin
       GetFreeLoadNr := -1;

       ERR_Error := VGA_Error_SpriteLOADArrayIsFull;
       CriticalError('');
      End;
    End;

   PROCEDURE FilledRectangle(AColor : Byte; AX1, AY1, AX2, AY2 : Integer; APage : Byte);
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2 : Integer;
    Begin
     (* Virtuelle => absolute Koordinaten: *)
     AX1 := AX1 - StartVirtualX;
     AY1 := AY1 - StartVirtualY;
     AX2 := AX2 - StartVirtualX;
     AY2 := AY2 - StartVirtualY;

     (* Clippen: *)
     (* X: *)
     If AX1 > XMAX Then Exit;
     If AX1 < 0    Then AX1 := 0;
     If AX2 < 0    Then Exit;
     If AX2 > XMAX Then AX2 := XMAX;

     (* Y: *)
     If AY1 > YMAX Then Exit;
     If AY1 < 0    Then AY1 := 0;
     If AY2 < 0    Then Exit;
     If AY2 > YMAX Then AY2 := YMAX;

     (* Zeichnen: *)
     For IH2 := AY1 To AY2 Do
      For IH1 := AX1 To AX2 Do
       PutPixel(AColor, IH1, IH2, APage);
    End;

   PROCEDURE PutSpriteOnPage(ALOADNr, ArgX, ArgY : Word; APage : Byte; AClip : Boolean);
    (* ---------------------------------------------------------------- *)
    Begin
     If AClip Then Asm

      { Hier mit CLIPPING ... }

     End                                (* Von 'ASM'. *)

     (* ----------------------------------------- *)
     (* ---------- Wenn NICHT CLIPPEN: ---------- *)
     (* ----------------------------------------- *)
     Else Asm
      (* Voreinstellungen: *)
      mov   ax, ScreenSeg
      mov   es, ax                      (* ES = Bildschirm-Segment. *)

      (*------------ SPRITES AUSGEBEN: ------------*)

      push  bp                          (* BP auf Stack sichern. *)

     @Zeichne:

      (* Hier: ES = Grafiksegment,             *)
      (*       BX = Spriteladenummer.          *)

     @SZeich:
      mov   bx, ALOADNr                 (* BX = Spriteladenummer. *)
      shl   bx, 1                       (* BX = Spriteladenummer * 2. *)

      jnz   @Aktiv                      (* Wenn BX <> 0 => Sprite AKTIV. *)
      jmp   @NoSprite                   (* Wenn BX = 0  => Sprite INAKTIV. *)

     @Aktiv:

      (* In DI steht am Ende die Bildschirm-ADRESSE,      *)
      (* an die der Sprite geschrieben wird (links oben). *)

      mov   di, ArgY                    (* Y-Koordinate nach DI. *)

      push  di                          (* Y-Koordinate retten. *)

      shl   di, 1                       (* DI := DI * 2. *)
      mov   di, cs:[di + OFFSET CS_GAdr](* Aktuelle Zeile ermitteln. *)

      xchg  ax, bx                      (* BX zwischenspeichern. *)

      xor   bh, bh
      mov   bl, APage                   (* BX := APage. *)
      shl   bx, 1                       (* BX := BX * 2. *)
      add   di, cs:[bx + OFFSET CS_POfs_Adr](* Seitenoffset addieren. *)

      xchg  bx, ax                      (* BX wieder zurÅckholen. *)

      mov   dx, ArgX                    (* Aktuelle Spalte ermitteln. *)

     @XOK:
      mov   ax, dx                      (* FÅr [OFSX] in AX speichern. *)

      shr   dx, 1                       (* DX := DX / 2. *)
      shr   dx, 1                       (* DX := DX / 2. *)
      add   di, dx                      (* Spaltenadresse dazuaddieren. *)

      (* ---------------------------------- *)
      (* !!! Ab hier: DS = ^SpriteDaten !!! *)
      (* ---------------------------------- *)
      mov   ds, [bx + OFFSET SpriteAD]  (* DS zeigt auf normalisierte Segment- *)
                                        (* Adresse des aktuellen Sprites.      *)

      pop   WORD PTR [UpperY]           (* Gerettete Y-Koordinate zurÅck. *)

      (* Jetzt: Ebene ermitteln: *)
      mov   [OfsX], ax                  (* Bytes vom linken Rand bis zum linken Sprite-Rand. *)

      mov   bx, di                      (* BX = ^BildschirmOffset. *)
      mov   [OfsScr], bx                (* Ofs-Wert der linken oberen Ecke sichern. *)

      mov   ax, [HoeheInZ]
      (* CntLines zÑhlt rÅckwÑrts ! *)
      mov   WORD PTR [CntLines], AX     (* 0 Zeilen gezeichnet. *)
      mov   WORD PTR [CntPl],    0      (* Um 0 Planes verschoben. *)

      (* DS = ^SpriteDaten,      *)
      (* ES = ^Bildschirm,       *)
      (* BX = ^Bildschirmoffset. *)

      (* IN _AH_ STEHT IMMER: AKTUELLE EBENE !!! *)

      xor   bp, bp                      (* BP := 0. *)

      jmp @L5                           (* öberspringe die Sprungleiste. *)

     @ToSpriteFertig:
      jmp   @SpriteFertig               (* Sprungleiste zu @SpriteFertig. *)

     @L5:

     (*------- Eine Zeile ausgeben: -------*)
     @EineZeile:                        (* Komplette Zeile mit allen Ebenen. *)

      mov   di, [OfsX]                  (* Ermittle die aktuell benîtigte *)
      and   di, 3                       (* Ebene der ganz linken Spalte.  *)
      mov   ah, Translate[di]

     (* ---- PLANE 0: *)
     @Plane0Pointer:

      mov   si, [Plane0]                (* Zeiger auf Daten fÅr die 1. Ebene. *)
      add   si, bp

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax                      (* In AH steht aktuelle Ebene. *)

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl0:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl0                        (* Ja, nichts zu tun. *)
      jcxz  @L0                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl0                        (* NÑchstes Byte. *)
     @L0:

     (* ---- PLANE 1: *)
     @Plane1Pointer:

      mov   si, [Plane1]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @P1NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      je    @P1NichtE3                  (* Nicht weiterschalten. *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @P1NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl1:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl1                        (* Ja, nichts zu tun. *)
      jcxz  @L1                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl1                        (* NÑchstes Byte. *)
     @L1:

     (* ---- PLANE 2: *)
     @Plane2Pointer:

      mov   si, [Plane2]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @P2NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      je    @P2NichtE3                  (* Nicht weiterschalten. *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @P2NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl2:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl2                        (* Ja, nichts zu tun. *)
      jcxz  @L2                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl2                        (* NÑchstes Byte. *)
     @L2:

     (* ---- PLANE 3: *)
     @Plane3Pointer:

      mov   si, [Plane3]                (* Zeiger auf Daten. *)
      add   si, bp

      shl   ah, 1
      cmp   ah, 8
      jna   @P3NichtE3
      mov   ah, 1                       (* Wenn Letzte Ebene,  *)
      je    @P3NichtE3                  (* Nicht weiterschalten. *)
      inc   WORD PTR [OfsScr]           (* Schirmzeiger + 1.   *)
      Inc   WORD PTR [CntPl]
     @P3NichtE3:

      mov   bx, [OfsScr]

      mov   al, 2                       (* Ebene anwÑhlen. *)
      mov   dx, 3C4h
      out   dx, ax

      mov   cx, [BreiteInB]

      (* Jetzt ausgeben: *)

      inc   cx
      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
     @Pl3:
      lodsb                             (* 1 Byte holen. *)
      or    al, al                      (* Ist es = 0 ? *)
      loopz @Pl3                        (* Ja, nichts zu tun. *)
      jcxz  @L3                         (* Alle Bytes durch ? *)
      mov   es:[bx+si], al              (* öbertragen. *)
      jmp   @Pl3                        (* NÑchstes Byte. *)
     @L3:

      (* Jetzt: Eine Zeile fertig. *)

      add   bp, [BreiteInB]             (* BX := BX + Breite eines Sprites *)
                                        (* in BYTES (= Pixel / 4).         *)

      mov   bx, [OfsScr]                (* Offset der linken Seite der *)
                                        (* aktuellen Zeile laden.      *)
      add   bx, LineSize                (* + 1 Zeile. *)
      sub   bx, [CntPl]                 (* Ggf. Verschiebungen abziehen. *)
      mov   [OfsScr], bx                (* Neue Offset speichern. *)
      mov   WORD PTR [CntPl], 0         (* EbenenzÑhler wieder auf 0. *)

      dec   WORD PTR [CntLines]         (* 1 Zeile weniger bis zum Ziel. *)

      mov   bx, [CntLines]              (* Teste, ob schon alle Zeilen *)
      or    bx, bx                      (* gezeichnet wurden.          *)

      jnz   @EineZeile                  (* Nein, springe. *)

     @SpriteFertig:                     (* Sprite fertig gezeichnet. *)
      mov   ax, SEG @Data               (* Das Datensegment wieder   *)
      mov   ds, ax                      (* zurÅckholen.              *)

     @NoSprite:                         (* SpriteN[ALoadNr] ist leer (=0). *)

     @Fertig:
      pop   bp                          (* BP zurÅckholen. *)

     End;                               (* Von 'ASM'. *)
    End;

   PROCEDURE Line(AX1, AY1, AX2, AY2 : Integer; AC, AP : Byte; AClip : Boolean);
    (* ---------------------------------------------------------------- *)
    Var X, Y         : Integer;
        D, DX, DY    : Integer;
        AIncr, BIncr : Integer;
        XIncr, YIncr : Integer;

    Procedure SwapInt(Var I1, I2: Integer);
     (* -------------------------------------------------------------- *)
     (* Aufgabe  : Vertauscht zwei Integer-Variablen.                  *)
     (* Eingabe  : I1, I2 = Die zu vertauschenden Variablen.           *)
     (* RÅckgabe : I1, I2 = Die vertauschten Variablen.                *)
     (* -------------------------------------------------------------- *)
     Var Dummy : Integer;
     Begin
      Dummy := I2;
      I2    := I1;
      I1    := Dummy;
     End;

    Begin                               (* Hauptprozedur. *)
     If Abs(AX2-AX1) < Abs(AY2-AY1) Then(* öber X- oder Y-Achse laufen ? *)
      Begin                             (* öber die Y-Achse. *)
       If AY1 > AY2 Then                (* AY1 grî·er AY2 ? *)
        Begin
         SwapInt(AX1, AX2);             (* Ja, AX1 mit AX2 und      *)
         SwapInt(AY1, AY2);             (* AY1 mit AY2 vertauschen. *)
        End;

       If AX2 > AX1 Then XIncr := 1     (* Spalteninkrement festlegen. *)
        Else XIncr := -1;

       DY := AY2 - AY1;
       DX := Abs(AX2-AX1);
       D  := 2 * DX - DY;
       AIncr := 2 * (DX - DY);
       BIncr := 2 * DX;
       X := AX1;
       Y := AY1;

       PutPixel(AC, X, Y, AP);            (* Ersten Punkt setzen. *)
       For Y := AY1+1 To AY2 Do         (* Line auf X-Achse durchlaufen. *)
        Begin
         If D >= 0 Then
          Begin
           Inc(X, XIncr);
           Inc(D, AIncr);
          End
         Else Inc(D, BIncr);
         PutPixel(AC, X, Y, AP);
        End;
      End

     Else                               (* öber die X-Achse. *)
      Begin
       If AX1 > AX2 Then                (* AX1 grî·er AX2 ? *)
        Begin
         SwapInt(AX1, AX2);             (* Ja, AX1 mit AX2 und      *)
         SwapInt(AY1, AY2);             (* AY1 mit AY2 vertauschen. *)
        End;

       If AY2 > AY1 Then YIncr := 1     (* Zeileninkrement festlegen. *)
        Else YIncr := -1;

       DX := AX2 - AX1;
       DY := Abs(AY2-AY1);
       D  := 2 * DY - DX;
       AIncr := 2 * (DY - DX);
       BIncr := 2 * DY;
       X := AX1;
       Y := AY1;

       PutPixel(AC, X, Y, AP);            (* Ersten Punkt setzen. *)
       For X := AX1+1 To AX2 Do         (* Line auf X-Achse durchlaufen. *)
        Begin
         If D >= 0 Then
          Begin
           Inc(Y, YIncr);
           Inc(D, AIncr);
          End
         Else Inc(D, BIncr);
         PutPixel(AC, X, Y, AP);
        End;
      End;
    End;

   PROCEDURE SetAnimateWindow(AX1, AY1, AX2, AY2 : Integer);
    (* ---------------------------------------------------------------- *)
    Begin
     If (AX1 Mod 4) <> 0 Then AX1 := AX1 + 4 - (AX1 Mod 4);
     WinXMIN      := AX1;
     WinYMIN      := AY1;
     WinWidth     := Succ(AX2-AX1) And $FFFC;   (* Weite auf Vielfaches von 4 bringen. *)
     If (WinWidth Mod 4) <> 0 Then WinWidth := WinWidth - (WinWidth Mod 4);
     WinHeight    := Succ(AY2-AY1) And $FFFC;
     WinXMAX      := WinXMIN + WinWidth  - 1;
     WinYMAX      := WinYMIN + WinHeight - 1;
     WinWidthDiv4 := WinWidth Shr 2;

     (* "WinOfsXMinYMin" bestimmen: *)
     Asm
      mov   di, WinYMIN                 (* Oberer Rand. *)
      shl   di, 1                       (* DI := DI * 2, wegen ARRAY-Adressierung. *)
      mov   di, cs:[di + OFFSET CS_GAdr](* Offset des oberen Randes. *)
      mov   ax, WinXMIN                 (* Linker Rand. *)
      shr   ax, 2                       (* Pixel -> Bytes. *)
      add   di, ax                      (* X-Wert zu Y-Wert => Linke obere Ecke. *)
      mov   WinOfsXMinYMin, di          (* Merke in globaler Variablen. *)
     End;
    End;

   PROCEDURE SetStaticBackGroundMode(AWhere : TStaticBkMode);
    (* ---------------------------------------------------------------- *)
    Begin
     If AWhere = RAM Then
      Begin
       UseVRAMBackGround := FALSE;
       BackGroundAdr     := Seg(RAMBackGrPageBuf^);
      End
     Else                               (* = "If AWhere = VRAM". *)
      Begin
       UseVRAMBackGround := TRUE;
       BackGroundAdr := PSeg_Adr[BackGroundPage];
      End;
    End;

   PROCEDURE SetScrollingBkGroundMode(AWhere : TStaticBkMode);
    (* ---------------------------------------------------------------- *)
    Begin
     If AWhere = RAM Then
      Begin
       UseVRAMScroll := FALSE;
       ScrollPageAdr := Seg(RAMScrollPageBuf^);
      End
     Else                               (* = "If AWhere = VRAM". *)
      Begin
       UseVRAMScroll := TRUE;
       ScrollPageAdr := PSeg_Adr[ScrollPage]
      End;

     (* Wenn es NICHT mîglich ist, ScrollPage ins RAM zu verlagern, *)
     (* dies auch nicht zulassen:                                   *)

     {$IFNDEF ScrollPageInRAM}
      UseVRAMScroll := TRUE;
      ScrollPageAdr := PSeg_Adr[ScrollPage]
     {$ENDIF}
    End;

   PROCEDURE SetScrollRange(AX1, AY1, AX2, AY2 : Integer);
    (* ---------------------------------------------------------------- *)
    Begin
     BackX1 := AX1 And $FFF0;
     BackX2 := AX2 Or  $F;
     BackY1 := AY1 And $FFF0;
     BackY2 := AY2 Or  $F;
     XTiles := Succ(BackX2 - BackX1) Shr 4;
     YTiles := Succ(BackY2 - BackY1) Shr 4;
     If (XTiles Or YTiles) <= 0         Then ERR_Error := VGA_Error_InvalidCoordinates
     Else If XTiles * YTiles > MaxTiles Then ERR_Error := VGA_Error_BackgroundToBig;
    End;

   PROCEDURE SetBackgroundMode(AMode : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     If (AMode <> STATIC) And (AMode <> SCROLLING)
     Then ERR_Error := VGA_Error_InvalidMode
     Else Backgroundmode := AMode;

     (* Wenn scrolling, MU· (!) Hintergrund im NORMALEN RAM sein: *)
     If AMode = Scrolling Then SetStaticBackgroundMode(RAM);
    End;

   PROCEDURE SetSplitIndex(ANr : Integer);
    (* ---------------------------------------------------------------- *)
    Begin
     IF ANr > NMAX Then ANr := -1;
     SplitIndex      := ANr;
     SplitIndex_Mal2 := ANr*2;
    End;

   FUNCTION GetSplitIndex : Integer;
    (* ---------------------------------------------------------------- *)
    Begin
     GetSplitIndex := SplitIndex;
    End;

   PROCEDURE UpDateBackTileToBackTileMal64;
    (* ---------------------------------------------------------------- *)
    Var LIH1 : LongInt;
    Begin
     For LIH1 := 0 To MaxTiles Do
      Word(BackTileMal64^[LIH1]) := Word(BackTile[LIH1]) * 64;
    End;

    Var WH1                     : Word;
        NNR2                    : Word;
        Xa_1, Ya_1, Xb_1, Yb_1,
        Xa_2, Ya_2, Xb_2, Yb_2  : Integer;

   FUNCTION Hit(ANNr, ATestNNrLo, ATestNNrHi : Word) : Word;
    (* ---------------------------------------------------------------- *)
    (* KEINE LOKALEN VARIABLEN !! *)
    Label _SkipThisSprite;
    Begin
     Hit := 0;                          (* Vorgabe: KEINE Kollision. *)
     If ANNr = 0 Then Exit;

     (* Sprite 1: *)
     Xa_1 := SpriteX[ANNr];
     Ya_1 := SpriteY[ANNr];
     Xb_1 := SpriteX[ANNr] + SpriteSIZEX[SpriteN[ANNr]];
     Yb_1 := SpriteY[ANNr] + SpriteSIZEY[SpriteN[ANNr]];

     For WH1 := ATestNNrLo To ATestNNrHi Do
      Begin
       (* Sprite 2: *)
       NNr2 := SpriteN[WH1];
       If (NNr2 = 0) Or (ANNr = WH1) Then Goto _SkipThisSprite;
       Xa_2 := SpriteX[WH1];
       Ya_2 := SpriteY[WH1];
       Xb_2 := SpriteX[WH1] + SpriteSIZEX[NNr2];
       Yb_2 := SpriteY[WH1] + SpriteSIZEY[NNr2];

       If (* LINKE OBERE ECKE von 1 in 2: *)
          ((Xa_1 > Xa_2) And (Xa_1 < Xb_2) And (Ya_1 > Ya_2) And (Ya_1 < Yb_2)) Or
          (* LINKE UNTERE ECKE von 1 in 2: *)
          ((Xa_1 > Xa_2) And (Xa_1 < Xb_2) And (Yb_1 > Ya_2) And (Yb_1 < Yb_2)) Or
          (* RECHTE OBERE ECKE von 1 in 2: *)
          ((Xb_1 > Xa_2) And (Xb_1 < Xb_2) And (Ya_1 > Ya_2) And (Ya_1 < Yb_2)) Or
          (* RECHTE UNTERE ECKE von 1 in 2: *)
          ((Xb_1 > Xa_2) And (Xb_1 < Xb_2) And (Yb_1 > Ya_2) And (Yb_1 < Yb_2)) Or

          (* LINKE OBERE ECKE von 2 in 1: *)
          ((Xa_2 > Xa_1) And (Xa_2 < Xb_1) And (Ya_2 > Ya_1) And (Ya_2 < Yb_1)) Or
          (* LINKE UNTERE ECKE von 2 in 1: *)
          ((Xa_2 > Xa_1) And (Xa_2 < Xb_1) And (Yb_2 > Ya_1) And (Yb_2 < Yb_1)) Or
          (* RECHTE OBERE ECKE von 2 in 1: *)
          ((Xb_2 > Xa_1) And (Xb_2 < Xb_1) And (Ya_2 > Ya_1) And (Ya_2 < Yb_1)) Or
          (* RECHTE UNTERE ECKE von 2 in 1: *)
          ((Xb_2 > Xa_1) And (Xb_2 < Xb_1) And (Yb_2 > Ya_1) And (Yb_2 < Yb_1)) Then
        Begin
         Hit := WH1;
        End;
       _SkipThisSprite:
      End;
    End;

   PROCEDURE FreePCXPicFromRAM(APtr : Pointer; ALaenge : LongInt);
    (* ---------------------------------------------------------------- *)
    Begin
     If APtr <> Nil Then FreeMem(APtr, ALaenge);
    End;

   PROCEDURE FreeImage(ASeg : Word);
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2 : Integer;
        PBH1     : ^Byte;
    Begin
     (* Speicher freigeben: *)
     PBH1 := Ptr(ASeg, 0);
     IH1  := Word(PBH1^) * 4;           (* Breite. *)
     Inc(PBH1, 2);
     IH2  := Word(PBH1^);               (* Hîhe. *)
     Dec(PBH1, 2);

     If PBH1 <> Nil Then FreeMem(PBH1, SizeOf(IMGHeader) + IH1 * IH2 + 15);

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

  (* ƒƒ INITIALISIERUNGSƒTEIL: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   BEGIN
    VGAInitRoutines;
   END.

 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)