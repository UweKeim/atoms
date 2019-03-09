 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)
 (*  Programm : ATOMIX                                                     *)
 (*             Spielprogramm, angelehnt an das Amiga- und C-64-Programm.  *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : ATOMIX02.PAS                                               *)
 (*             Das Hauptprogramm                                          *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 1.0                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 24. Juni 1994                                              *)
 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

 PROGRAM ATOMIX;

  (*ƒƒ COMPILER-EINSTELLUNGEN: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

  {$A+,B-,D-,E+,F+,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE ONEFILE}                     (* Ob alles aus 1 gro·en Datei gelesen wird. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (*ƒƒ DEKLARATIONSTEIL: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

   USES Crt, Dos,

        {$IFDEF ONEFILE}
        ONEFile1,
        {$ENDIF}

        INIPars1,
        UweVOHS1,
	UweVGA01,
	UwePAL01,
        UweERR01,
        UweUNI01;

   {$L UWEMAU1A.OBJ}                    (* EnthÑlt den Handler. *)

   (* ƒƒ Verschiedene ErklÑrungen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ----------------------------------------------------------- *)
   (* HINWEIS: In UWEVGA01.PAS mu· LOADMAX > 310 sein !!!!.       *)
   (*          In UWEVGA01.PAS mu· NMAX    > 040 sein !!!!.       *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (* Aufbau einer Level-Datei '????????.LEV':                    *)
   (*                                                             *)
   (* 00..01  DB  'U', 'K'  =  Kennung                            *)
   (* 02..02  DB  1         =  Version                            *)
   (* 03..04  DW  ?         =  Breite in Feldern                  *)
   (* 05..06  DW  ?         =  Hoehe in Feldern                   *)
   (* 07..26  DB  0         =  Name der Verbindung                *)
   (* 27..29  DB  ?         =  Dummy, fÅr spÑtere                 *)
   (*                          Erweiterungen frei                 *)
   (* 30..EOF DB  <MA>,<AT> =  FÅr jedes Feld gibt es 3 Byte:     *)
   (*             <WN>         <MA> : Nummer des Mauernelements,  *)
   (*                                 wobei 0..49 eine Frei-      *)
   (*                                 flÑche und 50..99 eine      *)
   (*                                 Mauer reprÑsentiert.        *)
   (*                          <AR> : Nummer des Atoms, wobei 0   *)
   (*                                 bedeutet, da· sich dort     *)
   (*                                 kein Atom befindet.         *)
   (*                                 Atomnummern: 100..149.      *)
   (*                          <WN> : Aussehen der Atome beim     *)
   (*                                 Gewinnen.                   *)
   (* ----------------------------------------------------------- *)

   (* ƒƒ Verschiedene Konstanten: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST (* ZusÑtzliche Fehler-Codes: 5000-5049: *)
	 ATO_Error_NoLEVFile               = 5000;
	 ATO_Error_SizeOfLEVFieldTooBig    = 5001;
	 ATO_Error_TooManySpritesInLEVFile = 5002;
	 ATO_Error_LevelNIsFull            = 5003;
	 ATO_Error_NotAllFilesComplete     = 5004;
         ATO_Error_NoHiScoreFile           = 5005;
         ATO_Error_NoEnoughHeapMem         = 5006;

	 (* Dateien: *)
	 CountFiles = 5;
	 Files      : Array[1..CountFiles] Of String[12] = ('ATOMIX.EXE',
                                                            'ATOMIX.INI',
							    'ATOMIX.DAT',
                                                            'ATOMIX.DOC',
                                                            'SETUP.EXE');

	 (* Level Variablen: *)
	 LevelMAX            = 30;

	 (* Feld Variablen: *)
	 ElementSizeX        = 16;      (* PixelBREITE eines Feldelements. *)
	 ElementSizeY        = 16;      (* PixelHOEHE  eines Feldelements. *)

	 FieldMAXX    = 20;
	 FieldMAXY    = 20;

	 MauerStart   = 050;            (* Erste LOAD-Nr, mit der MAUERN beginnen. *)

	 SmallStart   = 200;            (* Erste LOAD-Nr, mit der KLEINE ATOME beginnen. *)
	 SmallEnde    = 299;            (* Letzte LOAD-Nr, der KLEINEN ATOME. *)

	 (* Cursor: *)
	 CursorLoadNr = 20;             (* CURSOR. *)

         (* Mem: *)
         HeapMemNeeded = 000001;        (* Benîtigte Menge an DOS-RAM. *)

         (* Tastatur: *)
         __Stop       : Boolean = FALSE;(* "ESC". *)
         __Left       : Boolean = FALSE;(* "LEFT". *)
         __Right      : Boolean = FALSE;(* "RIGHT". *)
         __Up         : Boolean = FALSE;(* "UP". *)
         __Down       : Boolean = FALSE;(* "DOWN". *)
         __Space      : Boolean = FALSE;(* "SPACE". *)
         __Pause      : Boolean = FALSE;(* "P". *)
         __F1         : Boolean = FALSE;(* "F1". *)
         __F10        : Boolean = FALSE;(* "F10". *)
         __Shift      : Boolean = FALSE;(* "SHIFT". *)

	 (* Zeit: *)
	 TimeIntAktiv : Boolean = FALSE;(* TRUE, wenn eingeklinkt. *)
	 UseTime      : Boolean = TRUE; (* Ob Zeit ein/aus. *)
         TimeString   : String  = 'TIME_OFF';
                                        (* Wenn dieser String in der Kommando-  *)
                                        (* Zeile eingegeben wird, wird die Zeit *)
                                        (* ausgeschaltet.                       *)

         (* High-Score: *)
         Write_HighScore     : Boolean = FALSE;

         (* Sound/Musik: *)
         HSC_On              : Boolean = TRUE;  (* Ob HSC-Musik momentan erlaubt. *)
         VOC_On              : Boolean = TRUE;  (* Ob VOC-Sounds momentan erlaubt. *)

         (* Cheat: *)

         (* Wenn Cheat ein ist, kann mit 'SHIFT'+'F10' *)
         (* ein Level Åbersprungen werden.             *)

	 UseCheat     : Boolean = FALSE;(* Ob Cheat ein/aus. *)
         CheatString  : String  = 'CHEAT_ON';
                                        (* Wenn dieser String in der Kommando- *)
                                        (* Zeile eingegeben wird, wird Cheat   *)
                                        (* zugelassen.                         *)
         UseEasyPass  : Boolean = FALSE;(* Wenn TRUE, ist das Passwort des Levels *)
                                        (* die NUMMER des Levels.                 *)

         PassDist     = 4;              (* Alle wieviel Level es ein Passwort gibt. *)

	 (* Spieler: *)
	 NrOfPlayers  : Byte    = 1;    (* Spieleranzahl. *)
	 AktPlayer    : Byte    = 1;    (* Aktueller Spieler. *)

	 (* Punkte: *)
	 PntsOf1Atom  = 1000;           (* Punkte pro Atom. *)
	 PntsOf1Sek   = 10;             (* Punkte pro Sekunde. *)

         ScoreFName   : String = 'ATOMIX.HIG';
	 Score        : Array[1..2] Of LongInt = (0, 0);
					(* Momentane PunkteZahl der Spieler 1 und 2. *)

	 ScoreSpriteN : Array[1..2] Of Word = (0, 0);
					(* SpriteN[..]-Nummer der Score-Werte. *)
	 ScoreSprLOAD : Array[1..2] Of Word = (0, 0);
					(* SpriteLOAD[..]-Nummer der Score-Werte. *)

   (* ƒƒ Verschiedene Typen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   TYPE TAField = Array[1..FieldMAXX, 1..FieldMAXY] Of Word;

   (* ƒƒ Verschiedene Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   VAR {ERR_Error     : Integer;          (* Globale Fehlervariable. *)}

       SpriteStruct  : TSpriteStruct;

       (* Daten der gespeicherten Levels: *)
       LevelN        : Array[0..LevelMAX] Of Pointer;
					(* Feld mit Zeigern auf einzelne Levels, *)
					(* die noch genauso (!) wie auf Disk im  *)
					(* Speicher stehen.                      *)

       LevelMEMSIZE  : Array[0..LevelMAX] Of Integer;
					(* Anzahl Bytes die von betreffendem Zeiger *)
					(* reserviert wurden.                       *)

       (* Daten des aktiven Sprites: *)
       AktivSpriteX  : Word;
       AktivSpriteY  : Word;            (* Aktives Feld in dem ATOMFELD. *)
       AktivSpriteL  : Word;            (* Ladenummer des aktiven Sprites (Atom bzw. Cursor). *)
       AktivSpriteN  : Word;            (* N-Nummer des aktiven Sprites (Atom bzw. Cursor). *)
       AktivSpriteC  : Boolean;         (* TRUE, wenn aktiver Sprite (Atom bzw. Cursor) Cursor ist. *)

       (* Daten zum aktuellen Spielfeld: *)
       WALLFieldL    : TAField;         (* Daten Åber Position der Mauern (LOAD-Nummern). *)

       ATOMFieldL    : TAField;         (* Daten Åber Position der Atome (LOAD-Nummern). *)
       ATOMFieldN    : TAField;         (* Daten Åber Position der Atome (N-Nummern). *)

       WINField      : TAField;         (* Aufbau des Feldes, wie es gewinnt. *)

       WINInfoL      : Integer;         (* Abmessungen des Gewinnfeldes. *)
       WINInfoR      : Integer;         (* Abmessungen des Gewinnfeldes. *)
       WINInfoO      : Integer;         (* Abmessungen des Gewinnfeldes. *)
       WINInfoU      : Integer;         (* Abmessungen des Gewinnfeldes. *)

       PWINChk       : Pointer;         (* Zeiger auf Gewinnfeld. *)
       SizeWINChk    : Integer;         (* Grî·e des belegten Platzes. *)

       FieldOriginX  : Word;            (* Koordinaten des Feldes. *)
       FieldOriginY  : Word;            (* Koordinaten des Feldes. *)

       FieldInfoX    : Word;            (* Info zum Feld. Elemente in X. *)
       FieldInfoY    : Word;            (* Info zum Feld. Elemente in Y. *)
       FieldInfoName : String;          (* Info zum Feld. Name der Verbindung. *)

       (* Daten Åber Cursor: *)
       CursorL       : Integer;         (* LOAD-Nummer des Cursors. *)
       CursorN       : Integer;         (* N-Nummer des Cursors. *)

       (* Daten Åber Blinkring: *)
       BlinkRingL    : Word;            (* LOAD-Nummer des Blinkrings. *)
       BlinkRingN    : Word;            (* N-Nummer des Blinkrings. *)

       (* Palette: *)
       HPal          : TPalette;        (* Aktuelle Palette. *)

       (* Tastatur: *)
       OldInt9       : Procedure;       (* Alter Tastatur-Interrupt. *)

       (* Maus: *)
       MAUSAKTIV     : Boolean;         (* Wird beim initialisieren der Maus gesetzt, *)
                                        (* gibt an, ob Maus benutzbar ist.            *)

       (* Zeit, allgemein: *)
       Ticks, Time   : Word;
       SaveInt8      : Pointer;         (* Alter Timer-Interrupt. *)

       TimeNumbers   : Array[0..9] Of Word;
					(* SpriteLOADNummern der Ziffern '0' bis '9'. *)
       TimeDoublePnt : Word;            (* SpriteLOADNummer des Zeichens ':'. *)
       TimeSpriteN   : Array[1..4] Of Word;
					(* EnthÑlt die SPRITEN[..]-Nummern *)
					(* der Zeitanzeige. Z.B.: '7:10'.  *)
       TimeParts     : Array[1..4] Of Byte;
					(* EnthÑlt die Ziffern der PlÑtze. *)

       (* HintergrundBilder: *)
       BackPics      : Array[1..10] Of Word;

   (* ƒƒ Prototypen der Prozeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   FUNCTION LoadLevel(AFName : String; Nr : Integer) : Integer; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest eine LevelDatei oder eine Levelbibliothek.      *)
    (* Eingabe  : AFNAME = Dateiname.                                   *)
    (*            NR     = 1. Nummer in LevelN[..].                     *)
    (* RÅckgabe : Anzahl der aus dem File gelesenen Levels.             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE AktivateLevel(AL_Nr : Byte); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Aktiviert einen Level aus LevelN[..].                 *)
    (* Eingabe  : AL_NR = Levelnummer,                                  *)
    (* Hinweise : Die ATOM-Sprites werden in SpriteN[..]  eingetragen,  *)
    (*            dabei werden auch die Felder SpriteX[..] und          *)
    (*            SpriteY[..] gemÑ· den Variablen FieldOriginX bzw.     *)
    (*            FieldOriginY richtig besetzt.                         *)
    (*            Die MAUER-Sprites werden DIREKT auf die Hintergrund-  *)
    (*            seite geschrieben.                                    *)
    (*            Au·erdem gesetzt werden die Felder WALLFIELD[..],     *)
    (*            ATOMFIELD[..] und WINFIELD[..].                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE InsertSmallAtoms; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schreibt die kleinen Atome gemÑ· dem aktuellen        *)
    (*            WINField in frei PlÑtze von SPRITEN[..].              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FreeLevel; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Lîscht einen Leveleintrag.                            *)
    (* Hinweise : Folgende Felder werden gelîscht:                      *)
    (*             SpriteN[..], SpriteX[..], SpriteY[..],               *)
    (*             WALLField, ATOMField, WINField.                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetCursor(AX, AY : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Initialisiert den Cursor.                             *)
    (* Eingabe  : AX|AY    = Feldplatz.                                 *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FocusAtomAtCursor; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : WÑhlt das Atom unter dem Cursor aus, wenn vorhanden.  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ReleaseAktivAtom; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt das aktive Atom frei.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MoveAktivSprite(Var ADirection : Byte; AFact : Byte); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Bewegt das aktuelle Sprite.                           *)
    (* Eingabe  : ADIRECTION = Die gewÅnschte Richtung (1..8).          *)
    (*            AFACT      = Anzahl der Pixel um die in 1 Zyklus      *)
    (*                         verschoben werden soll.                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MostLeftInWINField : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Sucht den PLATZ (!) des am meisten links gelegenen    *)
    (*            Atoms im ATOMWINFIELD.                                *)
    (* RÅckgabe : X-Wert des Platzes.                                   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MostRightInWINField : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Sucht den PLATZ (!) des am meisten rechts gelegenen   *)
    (*            Atoms im ATOMWINFIELD.                                *)
    (* RÅckgabe : X-Wert des Platzes.                                   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MostObenInWINField : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Sucht den PLATZ (!) des am meisten oben gelegenen     *)
    (*            Atoms im ATOMWINFIELD.                                *)
    (* RÅckgabe : Y-Wert des Platzes.                                   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MostUntenInWINField : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Sucht den PLATZ (!) des am meisten unten gelegenen    *)
    (*            Atoms im ATOMWINFIELD.                                *)
    (* RÅckgabe : Y-Wert des Platzes.                                   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION TestMolekuel(AFirst : Boolean) : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Testet, ob das verlangte MolekÅl gebaut wurde.        *)
    (* Eingabe  : AFIRST = TRUE, wenn zum 1. Mal pro Level aufgerufen.  *)
    (* RÅckgabe : TRUE, wenn MolekÅl vollendet, sonst FALSE.            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Won; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Meldet, wenn gewonnen.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Lost; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Meldet, wenn verloren, da Zeit zuende.                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE RegisterBlinkRing(ALoad_Nr : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Registriert den Blinkring.                            *)
    (* Eingabe  : ALOAD_NR = LadeNummer des 1. Blink-Sprites            *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ATOMIXGetErrorMessage(AS : String) : String; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.   *)
    (* Eingabe  : ERR_Error = Fehlernummer,                             *)
    (*            AS        = Eventueller zusÑtzlicher Text (Z.B.       *)
    (*                        Dateiname bei Fehler 'Nicht gefunden').   *)
    (* RÅckgabe : Fehlertext.                                           *)
    (* ---------------------------------------------------------------- *)

   FUNCTION CountSpriteN : Integer; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : ZÑhlt die Anzahl der belegten SpriteN-PlÑtze.         *)
    (* RÅckgabe : Anzahl der PlÑtze.                                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetTimeBase(Min, Sek : Byte); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Startet den Countdown.                                *)
    (* Eingabe  : MIN = Anzahl Minuten,                                 *)
    (*            SEK = Anzahl Sekunfen.                                *)
    (*            Die Gesamtanzahl an Sekunden wird in der globalen     *)
    (*            Variablen TIME eingetragen, die dann immer erniedrigt *)
    (*            wird.                                                 *)
    (*            Au·erdem wird die globale Variable TICKS benÅtzt,     *)
    (*            die 18.2 mal pro Sekunde um 10 erhîht wird, also in   *)
    (*            1 Sekunde 184 ist. Dann wieder auf 0 und TIME -= 1;.  *)
    (* Hinweise : Klinkt sich in den Timerinterrupt ein.                *)
    (* Ausgabe  : Wenn Zeit abgelaufen, wird wieder aus Timerinterrupt  *)
    (*            ausgeklinkt.                                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE TimeInt; Interrupt; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Interrupt-Handler zur Prozedur SETTIMEBASE (s.o.).    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE StopTimeInt; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Klinkt den Timer-Handler.                             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE LOADINGSpriteData; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Daten fÅr die Ebenen des "LOADING ..."-Sprites.       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MakeLOADINGSprite(ALoadNr : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Erstellt den "LOADING ..."-Sprite.                    *)
    (* Eingabe  : ALOADNR = Die LADE-Nummer des zu erstellenden         *)
    (*                      Sprites.                                    *)
    (* ---------------------------------------------------------------- *)

    PROCEDURE MakeScores(AFirst : Boolean); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Erstellt die Sprites der Punkte.                      *)
    (* Eingabe  : AFIRST      = Beim 1. Aufruf mit TRUE aufrufen,       *)
    (*                          danach immer mit FALSE.                 *)
    (*            SCORE[1, 2] = Aktuelle Punktezahl.                    *)
    (* RÅckgabe : SCORESPRITEN[1, 2] werden gesetzt.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE TestAllFiles; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Testet, ob alle benîtigten Dateien vorhanden sind.    *)
    (* RÅckgabe : Beendet ggf. Programm mit Fehlermeldung.              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MakeTimeNumbers; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Erzeugt die Ziffern '0' bis '9' und den ':' fÅr die   *)
    (*            Zeitanzeige.                                          *)
    (* RÅckgabe : Globale Variablen TIMENUMBERS und TIMEDOUBLEPNT       *)
    (*            enthalten die entsprechenden LOAD-Nummern.            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ScoreList; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : LÑdt die HighScore-Liste von Diskette, zeigt sie an,  *)
    (*            LÑ·t ggf. eingeben und speichert sie ggf. ab.         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION AskExit : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Titelbild, Einleitung, usw.                          *)
    (*  RÅckgabe : TRUE  = Ja, beenden,                                 *)
    (*             FALSE = Nein, weitermachen.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE LoadingSequence; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Zeigt den "LOADING..."-Sprite und testet auf ggf.    *)
    (*             eingeschalteten CHEAT und ZEIT-aus und gibt dies     *)
    (*             auf den Schirm aus.                                  *)
    (*             Erledigt au·erdem alle sonstigen Ladeaufgaben.       *)
    (* ---------------------------------------------------------------- *)

   {$F+}
   PROCEDURE TrapCtrlAltDel; Interrupt; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Der neue Tastatur-Handler.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE InstallTrap; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Installiert den Tastatur-Handler "TRAPCTRLALTDEL".    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE UnInstallTrap; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : DEinstalliert den Tastatur-Handler "TRAPCTRLALTDEL".  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetUpMausAndHandler; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Installiert alles, was fÅr die Maus nîtig ist.        *)
    (*            Z.B. Treiber initialisieren, Handler einbinden, ...   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CloseUpMausAndHandler; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Beendet alles, was mit der Maus zu tun hat.           *)
    (*            Z.B. Treiber deaktivieren, Handler austragen, ...     *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MAUSAssHandler; Far; External;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Der eigentliche Interrupt-Handler, der dann          *)
    (*             wiederum "MAUSINTERRUPTHANDLER" aufruft.             *)
    (*  Hinweis  : Darf NIE direkt aufgerufen werden !                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MAUSInterruptHandler(AFlags, AButtons, X, Y : Integer); Far; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Der Interrupt-Handler.                               *)
    (*  Eingabe  : AFLAGS   = Statusflags,                              *)
    (*             ABUTTONS = Knîpfestatus,                             *)
    (*             X | Y    = Aktuelle Position.                        *)
    (*  Hinweis  : Die Prozedur wird von der externen Funktion          *)
    (*             "MAUSAssHandler" aufgerufen, NIE direkt aufrufen !   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Init; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Initialisiert das Programm.                           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Main; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Hauptteil des Programms, ruft alles auf.              *)
    (* Sub-Proc : (F) CalculatePassword(ANr : Integer) : Word;          *)
    (*             - - - - - - - - - - - - - - - - - - - - - -          *)
    (*             Aufgabe  : Errechnet aus PASS[ANR] und KEY das       *)
    (*                        Passwort.                                 *)
    (*             Eingabe  : ANR = Levelnummer (1..30).                *)
    (*             RÅckgabe : Das errechnete Passwort.                  *)
    (*                                                                  *)
    (*            (F) EnterPassword : Word;                             *)
    (*             - - - - - - - - - - - - -                            *)
    (*             Aufgabe  : Lie·t Passwort ein und ÅberprÅft dieses.  *)
    (*             RÅckgabe : 0      = Passwort war nicht richtig,      *)
    (*                        SONST. = zum Passwort zugehîrige          *)
    (*                                 Levelnummer.                     *)
    (*                                                                  *)
    (*            (F) TellPassword(ANr : Word) : Word;                  *)
    (*             - - - - - - - - - - - - - - - - - -                  *)
    (*             Aufgabe  : Meldet das aktuelle Passwort.             *)
    (*             Eingabe  : ANR   = Nummer des Levels in LevelN[..].  *)
    (*             RÅckgabe : 1 = Mit ESC abgebrochen.                  *)
    (*                                                                  *)
    (*            (F) PauseGame : Word;                                 *)
    (*             - - - - - - - - - - - - -                            *)
    (*             Aufgabe  : Pausiert des Spiel.                       *)
    (*             RÅckgabe : 1 = Mit ESC abgebrochen.                  *)
    (*                                                                  *)
    (*            (F) EXELevel(ANr : Word) : Word;                      *)
    (*             - - - - - - - - - - - - - - - - - - - -              *)
    (*             Aufgabe  : FÅhrt einen Level aus.                    *)
    (*             Eingabe  : ANR   = Nummer des Levels in LevelN[..].  *)
    (*             RÅckgabe : 0        = Level gewonnen,                *)
    (*                        1        = Mit ESC abgebrochen.           *)
    (*                        100 + xx = Passwort fÅr Level xx          *)
    (*                                   eingegeben (1<X<30).           *)
    (*                                                                  *)
    (*            (P) WholeGameWon;                                     *)
    (*             - - - - - - - -                                      *)
    (*             Aufgabe  : Zeigt Bild, da· man gesamtes Spiel        *)
    (*                        gewonnen hat.                             *)
    (*                                                                  *)
    (*            (P) EndGame;                                          *)
    (*             - - - - - -                                          *)
    (*             Aufgabe  : Beendet das gesamte Spiel.                *)
    (*                                                                  *)
    (*            (F) AtomixIntro : Integer;                            *)
    (*             - - - - - - - - - - - - -                            *)
    (*             Aufgabe  : Titelbild, Einleitung, usw.               *)
    (*             RÅckgabe : 0 = Normal beendet,                       *)
    (*                        1 = Mit ESC beendet.                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Done; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Beendet das Programm.                                 *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ParseINIFile; Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schaut die INI Datei ATOMIX.INI im aktuellen          *)
    (*            Verzeichnis an und wertet deren Inhalt aus.           *)
    (* ---------------------------------------------------------------- *)

   (* ƒƒ ProzedurrÅmpfe: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   FUNCTION LoadLevel(AFName : String; Nr : Integer) : Integer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PH1       : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}

	LEVHeader : Record
		     Kennung : Array[01..02] Of Char;
		     Version : Byte;
		     Breite  : Word;
		     Hoehe   : Word;
		     Name    : Array[01..20] Of Char;
		     Dummy   : Array[01..03] Of Byte;
		    End;
	PBH1      : ^Byte;

	LCount    : Integer;            (* Aktuelle LevelN[..]-Nummer. *)

    Begin
     LCount := 0;

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
     While Not _EOF(F) Do               (* Je 1 Leveldatei aus ggf Bibliothek lesen. *)
     {$ELSE}
     While Not EOF(F) Do                (* Je 1 Leveldatei aus ggf Bibliothek lesen. *)
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       If LCount > LevelMAX Then
	Begin
	 {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

	 {$I+}
	 ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         ERR_Error := ATO_Error_LevelNIsFull;
         CriticalError('');
	End;

       (* Header einlesen: *)
       {$I-}

       {$IFDEF ONEFILE}
       PH1 := @LEVHeader;
       _BlockRead(F, PH1, SizeOf(LEVHeader));
       {$ELSE}
       BlockRead(F, LEVHeader, SizeOf(LEVHeader));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* Header auswerten: *)
       If LEVHeader.Kennung <> 'UK' Then
	Begin
	 {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

	 {$I+}
	 ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

	 ERR_Error := ATO_Error_NoLEVFile;
         CriticalError(AFName);
	End;

       If (LEVHeader.Breite > FieldMAXX) Or (LEVHeader.Hoehe > FieldMAXY) Then
	Begin
	 {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

	 {$I+}
	 ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

         CriticalError('');
	 ERR_Error := ATO_Error_SizeOfLEVFieldTooBig;
	End;

       (* Speicher fÅr Leveldatei anfordern: *)
       LevelMEMSIZE[Nr] := LEVHeader.Breite * LEVHeader.Hoehe * 3 + SizeOf(LEVHeader);
       _GetMem(LevelN[Nr], LevelMEMSIZE[Nr]);
       PBH1 := LevelN[Nr];              (* Hilfszeiger gleichsetzen. *)

       (* Header kopieren: *)
       Move(LEVHeader, PBH1^, SizeOf(LEVHeader));
       Inc(PBH1, SizeOf(LEVHeader));

       (* Daten unverÑndert von Disk einlesen: *)
       {$I-}

       {$IFDEF ONEFILE}
       PH1 := PBH1;
       _BlockRead(F, PH1, LEVHeader.Breite * LEVHeader.Hoehe * 3);
       {$ELSE}
       BlockRead(F, PBH1^, LEVHeader.Breite * LEVHeader.Hoehe * 3);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       (* NÑchstes Sprite: *)
       Inc(Nr);
       Inc(LCount);
      End;
    {$I+}

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

     LoadLevel := LCount;
    End;

   PROCEDURE AktivateLevel(AL_Nr : Byte);
    (* ---------------------------------------------------------------- *)
    Var LEVHeader : Record
		     Kennung : Array[01..02] Of Char;
		     Version : Byte;
		     Breite  : Word;
		     Hoehe   : Word;
		     Name    : Array[01..20] Of Char;
		     Dummy   : Array[01..03] Of Byte;
		    End;
	IH1, IH2  : Integer;
	IH3       : Integer;
	BH1       : Byte;
	PBH1      : ^Byte;

	LevelMinX : Integer;            (* Minimale X-Koordinate, an   *)
					(* der ein Feld beginnen kann. *)

    Begin
     (* Zeiger setzen: *)
     PBH1 := LevelN[AL_Nr];

     (* Header einlesen: *)
     Move(PBH1^, LEVHeader, SizeOf(LEVHeader));
     Inc(PBH1, SizeOf(LEVHeader));

     (* Infos eintragen: *)
     FieldInfoX := LEVHeader.Breite;
     FieldInfoY := LEVHeader.Hoehe;
     FieldInfoName := '';
     For IH1 := 1 To 20 Do
      FieldInfoName := FieldInfoName + LEVHeader.Name[IH1];

     (* Koordinaten des Feldes berechnen: *)
     LevelMinX    := SpriteSIZEX[31] + 5;      (* [31] = Rahmen mit kl. Atomen. *)
     FieldOriginX := LevelMinX + ((XMAX - LevelMinX) - (FieldInfoX * ElementSIZEX)) Div 2;
     FieldOriginY := (YMAX - (FieldInfoY * ElementSIZEY)) Div 2;

     (* Leerzeichen am Ende lîschen: *)
     While FieldInfoName[Length(FieldInfoName)] = ' ' Do
      Delete(FieldInfoName, Length(FieldInfoName), 1);

     For IH2 := 1 To LEVHeader.Hoehe Do
      For IH1 := 1 To LEVHeader.Breite Do
       Begin
	BH1 := PBH1^;
	Inc(PBH1);

	If BH1 <> 0 Then                (* Mauer belegen. *)
	 Begin
	  WALLFieldL[IH1, IH2] := BH1;

	  (* Hintergrund mit schwarzen Rechtecken fÅllen, dort wo Mauern: *)
	  FilledRectangle(0, FieldOriginX + ElementSizeX * (IH1 - 1),
			     FieldOriginY + ElementSizeY * (IH2 - 1),
			     FieldOriginX + ElementSizeX * (IH1 - 1) - 1 + ElementSizeX,
			     FieldOriginY + ElementSizeY * (IH2 - 1) - 1 + ElementSizeX,
			     BackGroundPage);

	  (* Sprite direkt auf Hintergrund: *)
	  PutSpriteOnPage(BH1, FieldOriginX + ElementSizeX * (IH1 - 1),
			       FieldOriginY + ElementSizeY * (IH2 - 1),
			       BackGroundPage, FALSE);
	 End;

	BH1 := PBH1^;
	Inc(PBH1);

	If BH1 <> 0 Then                (* Atom belegen. *)
	 Begin
	  IH3 := GetFreeNNr;
	  ATOMFieldL[IH1, IH2] := BH1;
	  ATOMFieldN[IH1, IH2] := IH3;

	  SpriteN[IH3] := BH1;       (* LADENummer schreiben. *)
	  SpriteX[IH3] := FieldOriginX + SpriteSIZEX[BH1] * (IH1 - 1);
	  SpriteY[IH3] := FieldOriginY + SpriteSIZEY[BH1] * (IH2 - 1);
	 End;

	BH1 := PBH1^;
	Inc(PBH1);

	If BH1 <> 0 Then                (* WINField belegen. *)
	 WINField[IH1, IH2] := BH1;
       End;

     (* RÅckgabe: *)
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE InsertSmallAtoms;
    (* ---------------------------------------------------------------- *)
    Const WinXMin    = 000 + 006;
	  WinYMin    = 125 + 012 + 016;
	  WinXMax    = 000 + 071;
	  WinYMax    = 125 + 070;
	  WinSizeX   = WinXMax - WinXMin + 1;
	  WinSizeY   = WinYMax - WinYMin + 1;

	  SmallSizeX = 008;
	  SmallSizeY = 008;

    Var IH1, IH2, IH3 : Integer;
	AX, AY        : Integer;        (* Linke obere Ecke des MOLEKöLS. *)
	Breite, Hoehe : Word;
    Begin
     (* Breite und Hoehe des MOLEKöLS berechnen: *)

     Breite := MostRightInWINField - MostLeftInWINField + 1;
     Hoehe  := MostUntenInWINField - MostObenInWINField + 1;

     Breite := Breite * SmallSizeX;
     Hoehe  := Hoehe  * SmallSizeY;

     (* Position berechnen: *)
     AX := WinXMin + (WinSizeX - Breite) Div 2;
     AY := WinYMin + (WinSizeY - Hoehe ) Div 2;

     (* Freien Platz in SPRITEN[..] suchen: *)
     IH3 := GetFreeNNr;

     (* EinfÅgeschleife: *)
     For IH2 := 1 To FieldInfoY Do
      For IH1 := 1 To FieldInfoX Do
       Begin
	(* <> 0 ? Ja : EinfÅgen: *)
	If WINField[IH1, IH2] <> 0 Then
	 Begin
	  SpriteN[IH3] := WINField[IH1, IH2]+100;
	  SpriteX[IH3] := AX + (IH1-1)*SpriteSIZEX[WINField[IH1, IH2]+100];
	  SpriteY[IH3] := AY + (IH2-1)*SpriteSIZEY[WINField[IH1, IH2]+100];
	 End;

	(* NÑchster freier Platz: *)
	IH3 := GetFreeNNr;
       End;
    End;

   PROCEDURE FreeLevel;
    (* ---------------------------------------------------------------- *)
    Begin
     FillChar(SpriteN, SizeOf(SpriteN), 0);
     FillChar(SpriteX, SizeOf(SpriteX), 0);
     FillChar(SpriteY, SizeOf(SpriteY), 0);

     FillChar(WALLFieldL, SizeOf(WALLFieldL), 0);
     FillChar(ATOMFieldL, SizeOf(ATOMFieldL), 0);
     FillChar(ATOMFieldN, SizeOf(ATOMFieldN), 0);
     FillChar(WINField,  SizeOf(WINField) , 0);

     FreeMem(PWINChk, SizeWINChk);
    End;

   PROCEDURE SetCursor(AX, AY : Word);
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     IH1 := GetFreeNNr;

     AktivSpriteL := CursorLoadNr;
     AktivSpriteN := IH1;
     AktivSpriteX := 1;
     AktivSpriteY := 1;
     AktivSpriteC := TRUE;

     CursorL := CursorLoadNr;
     CursorN := IH1;

     SpriteN[IH1] := CursorLoadNr;
     SpriteX[IH1] := FieldOriginX + SpriteSIZEX[CursorLoadNr] * (AX-1);
     SpriteY[IH1] := FieldOriginY + SpriteSIZEY[CursorLoadNr] * (AY-1);
    End;

   PROCEDURE FocusAtomAtCursor;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Ist Åberhaupt Atom da ? : *)
     If (ATOMFieldN[AktivSpriteX, AktivSpriteY] = 0) Or
	(ATOMFieldL[AktivSpriteX, AktivSpriteY] = 0) Then
     Exit;

     (* Cursor als inaktiv und Austragen: *)
     AktivSpriteC := FALSE;
     SpriteN[AktivSpriteN] := 0;

     (* Atom als aktiv: *)
     AktivSpriteL := ATOMFieldL[AktivSpriteX, AktivSpriteY];
     AktivSpriteN := ATOMFieldN[AktivSpriteX, AktivSpriteY];
     (* AktivSpriteX bleibt gleich ! *)
     (* AktivSpriteY bleibt gleich ! *)

     (* Blinkring an: *)
     SpriteN[BlinkRingN] := BlinkRingL;
     SpriteX[BlinkRingN] := SpriteX[AktivSpriteN];
     SpriteY[BlinkRingN] := SpriteY[AktivSpriteN];
    End;

   PROCEDURE ReleaseAktivAtom;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Ist Åberhaupt Atom gewÑhlt ? : *)
     If AktivSpriteC = TRUE Then Exit;

     (* Cursor als AKTIV und eintragen: *)
     SpriteN[CursorN] := CursorL;
     SpriteX[CursorN] := SpriteX[AktivSpriteN];
     SpriteY[CursorN] := SpriteY[AktivSpriteN];

     AktivSpriteL := CursorL;
     AktivSpriteN := CursorN;
     AktivSpriteC := TRUE;

     (* Blinkring aus: *)
     SpriteN[BlinkRingN] := 0;
    End;

   PROCEDURE MoveAktivSprite(Var ADirection : Byte; AFact : Byte);
    (* ---------------------------------------------------------------- *)
    Var BH1, BH2 : Byte;

    Function TestMauerOrAtom(ADirection : Byte; X, Y : Word) : Boolean;
    (* FALSE, wenn in die Richtung ADIRECTION ein *)
    (* Hindernis liegt, sonst TRUE.               *)

    (* Richtungen: 00000001b, 1d : Links,             *)
    (*             00000010b, 2d : Oben,              *)
    (*             00000100b, 4d : Rechts,            *)
    (*             00001000b, 8d : Unten.             *)
    Begin
     Case ADirection Of
      1 : Dec(X);
      4 : Inc(X);
      2 : Dec(Y);
      8 : Inc(Y);
     End;

     TestMauerOrAtom := FALSE;

     If (X > 1) And
	(X < FieldInfoX) And
	(Y > 1) And
	(Y < FieldInfoY) And
	(ATOMFieldL[X,Y] = 0) And
	(WALLFieldL[X,Y] < MauerStart) Then (* Ab 50: MAUER. *)
	 TestMauerOrAtom := TRUE;
    End;

    Begin                               (* MAIN-PRC. *)
     (*--- CURSOR AKTIV: ---*)
     If AktivSpriteC Then         (* Wenn Cursor aktiv. *)
      Begin
       If ADirection And 1 = 1 Then
	    Begin
             If (AktivSpriteX > 1) Then
	      Begin
               Dec(SpriteX[AktivSpriteN], AFact);
               BH1 := ((SpriteX[AktivSpriteN] - FieldOriginX) Mod 16) Div AFact;
               For BH2 := 1 To BH1 Do
                Begin
                 Dec(SpriteX[AktivSpriteN], AFact);
                 Animate;
		End;
               ADirection := ADirection And (255-1);
	       Dec(AktivSpriteX);
	      End
             Else ADirection := ADirection And (255-1);
	    End
       Else If ADirection And 4 = 4 Then
	    Begin
	     If (AktivSpriteX < FieldInfoX) Then
	      Begin
               Inc(SpriteX[AktivSpriteN], AFact);
               BH1 := (16 Div AFact) - ((SpriteX[AktivSpriteN] - FieldOriginX) Mod 16) Div AFact;
               For BH2 := 1 To BH1 Do
                Begin
                 Inc(SpriteX[AktivSpriteN], AFact);
                 Animate;
		End;
	       ADirection := ADirection And (255-4);
	       Inc(AktivSpriteX);
	      End
             Else ADirection := ADirection And (255-4);
	    End
       Else If ADirection And 2 = 2 Then
	    Begin
	     If (AktivSpriteY > 1) Then
              Begin
               Dec(SpriteY[AktivSpriteN], AFact);
               BH1 := ((SpriteY[AktivSpriteN] - FieldOriginY) Mod 16) Div AFact;
               For BH2 := 1 To BH1 Do
                Begin
                 Dec(SpriteY[AktivSpriteN], AFact);
                 Animate;
		End;
	       ADirection := ADirection And (255-2);
	       Dec(AktivSpriteY);
	      End
	     Else ADirection := ADirection And (255-2);
	    End
       Else If ADirection And 8 = 8 Then
	    Begin
	     If (AktivSpriteY < FieldInfoY) Then
              Begin
               Inc(SpriteY[AktivSpriteN], AFact);
               BH1 := (16 Div AFact) - ((SpriteY[AktivSpriteN] - FieldOriginY) Mod 16) Div AFact;
               For BH2 := 1 To BH1 Do
                Begin
                 Inc(SpriteY[AktivSpriteN], AFact);
                 Animate;
		End;
	       ADirection := ADirection And (255-8);
	       Inc(AktivSpriteY);
	      End
	     Else ADirection := ADirection And (255-8);
	    End;
       End

     (*--- ATOM AKTIV: ---*)
     Else (* NOT AktivSpriteC *)  (* Wenn Atom aktiv. *)
      Begin
       Case ADirection Of
	1 : Begin                       (* LINKS. *)
             If (AktivSpriteX > 1) And
                (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Then
              Begin
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := 0;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := 0;
               While (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Do
                Begin
     	         Dec(SpriteX[AktivSpriteN], AFact);
   	         Dec(SpriteX[BlinkRingN], AFact);
                 BH1 := ((SpriteX[AktivSpriteN] - FieldOriginX) Mod 16) Div AFact;
                 For BH2 := 1 To BH1 Do
                  Begin
   		   Dec(SpriteX[AktivSpriteN], AFact);
   		   Dec(SpriteX[BlinkRingN], AFact);
                   Animate;
                  End;
		  Dec(AktivSpriteX);
                End;
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := AktivSpriteL;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := AktivSpriteN;
               ADirection := 0;
              End
             Else ADirection := 0;
	    End;
	4 : Begin
             If (AktivSpriteX < FieldInfoX) And
                (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Then
              Begin
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := 0;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := 0;
               While (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Do
                Begin
     	         Inc(SpriteX[AktivSpriteN], AFact);
   	         Inc(SpriteX[BlinkRingN], AFact);
                 BH1 := (16 Div AFact) - ((SpriteX[AktivSpriteN] - FieldOriginX) Mod 16) Div AFact;
                 For BH2 := 1 To BH1 Do
                  Begin
   		   Inc(SpriteX[AktivSpriteN], AFact);
   		   Inc(SpriteX[BlinkRingN], AFact);
                   Animate;
                  End;
		  Inc(AktivSpriteX);
                End;
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := AktivSpriteL;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := AktivSpriteN;
               ADirection := 0;
              End
             Else ADirection := 0;
            End;
	2 : Begin
             If (AktivSpriteY > 1) And
                (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Then
              Begin
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := 0;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := 0;
               While (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Do
                Begin
     	         Dec(SpriteY[AktivSpriteN], AFact);
   	         Dec(SpriteY[BlinkRingN], AFact);
                 BH1 := ((SpriteY[AktivSpriteN] - FieldOriginY) Mod 16) Div AFact;
                 For BH2 := 1 To BH1 Do
                  Begin
   		   Dec(SpriteY[AktivSpriteN], AFact);
   		   Dec(SpriteY[BlinkRingN], AFact);
                   Animate;
                  End;
		  Dec(AktivSpriteY);
                End;
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := AktivSpriteL;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := AktivSpriteN;
               ADirection := 0;
              End
             Else ADirection := 0;
	    End;
	8 : Begin
             If (AktivSpriteY < FieldInfoY) And
                (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Then
              Begin
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := 0;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := 0;
               While (TestMauerOrAtom(ADirection, AktivSpriteX, AktivSpriteY)) Do
                Begin
     	         Inc(SpriteY[AktivSpriteN], AFact);
   	         Inc(SpriteY[BlinkRingN], AFact);
                 BH1 := (16 Div AFact) - ((SpriteY[AktivSpriteN] - FieldOriginY) Mod 16) Div AFact;
                 For BH2 := 1 To BH1 Do
                  Begin
   		   Inc(SpriteY[AktivSpriteN], AFact);
   		   Inc(SpriteY[BlinkRingN], AFact);
                   Animate;
                  End;
		  Inc(AktivSpriteY);
                End;
	       ATOMFieldL[AktivSpriteX, AktivSpriteY] := AktivSpriteL;
	       ATOMFieldN[AktivSpriteX, AktivSpriteY] := AktivSpriteN;
               ADirection := 0;
              End
             Else ADirection := 0;
	    End;
       End;
      End;
    End;

   FUNCTION MostLeftInWINField : Word;
    (* ---------------------------------------------------------------- *)
    (* Sucht den PLATZ (!) des am meisten Links gelegenen Atoms. *)
    Var IH1, IH2 : Integer;
	Left     : Integer;
    Begin
     Left := FieldInfoX;
     For IH2 := 1 To FieldInfoY Do
      For IH1 := 1 To FieldInfoX Do
       Begin
	If (WINField[IH1, IH2] <> 0) And (IH1 < Left) Then Left := IH1;
	If Left = 1 Then
	 Begin
	  MostLeftInWINField := Left;
	  Exit;
	 End;
       End;
     MostLeftInWINField := Left;
    End;

   FUNCTION MostRightInWINField : Word;
    (* ---------------------------------------------------------------- *)
    (* Sucht den PLATZ (!) des am meisten Rechts gelegenen Atoms. *)
    Var IH1, IH2 : Integer;
	Right    : Integer;
    Begin
     Right := 1;
     For IH2 := 1 To FieldInfoY Do
      For IH1 := 1 To FieldInfoX Do
       Begin
	If (WINField[IH1, IH2] <> 0) And (IH1 > Right) Then Right := IH1;
	If Right = FieldInfoX Then
	 Begin
	  MostRightInWINField := Right;
	  Exit;
	 End;
       End;
     MostRightInWINField := Right;
    End;

   FUNCTION MostObenInWINField : Word;
    (* ---------------------------------------------------------------- *)
    (* Sucht den PLATZ (!) des am meisten Oben gelegenen Atoms. *)
    Var IH1, IH2 : Integer;
	Oben     : Integer;
    Begin
     Oben := FieldInfoY;
     For IH2 := 1 To FieldInfoY Do
      For IH1 := 1 To FieldInfoX Do
       Begin
	If (WINField[IH1, IH2] <> 0) And (IH2 < Oben) Then Oben := IH2;
	If Oben = 1 Then
	 Begin
	  MostObenInWINField := Oben;
	  Exit;
	 End;
       End;
     MostObenInWINField := Oben;
    End;

   FUNCTION MostUntenInWINField : Word;
    (* ---------------------------------------------------------------- *)
    (* Sucht den PLATZ (!) des am meisten Unten gelegenen Atoms. *)
    Var IH1, IH2 : Integer;
	Unten    : Integer;
    Begin
     Unten := 1;
     For IH2 := 1 To FieldInfoY Do
      For IH1 := 1 To FieldInfoX Do
       Begin
	If (WINField[IH1, IH2] <> 0) And (IH2 > Unten) Then Unten := IH2;
	If Unten = FieldInfoY Then
	 Begin
	  MostUntenInWINField := Unten;
	  Exit;
	 End;
       End;
     MostUntenInWINField := Unten;
    End;

   FUNCTION TestMolekuel(AFirst : Boolean) : Boolean;
    (* ---------------------------------------------------------------- *)

    Function ATOMFieldToMem(X, Y, SizeX, SizeY : Word) : Pointer;
     (* Legt das ATOMFIELD von X|Y bis X+SIZEX|Y+SIZEY *)
     (* ab dem Zeiger ab, der zurÅckgegeben wird.      *)
     Var PH1      : Pointer;
	 PH2      : ^Word;
	 IH1, IH2 : Integer;
     Begin
      _GetMem(PH1, SizeX*SizeY*2);
      FillChar(PH1^, SizeX*SizeY*2, 0); (* Mit '0'en initialisieren. *)
      PH2 := PH1;

      For IH2 := Y To Y+SizeY-1 Do
       Begin
	For IH1 := X To X+SizeX-1 Do
	 Begin
	  PH2^ := ATOMFieldL[IH1, IH2];
	  Inc(PH2);

	  If IH1+1 > FieldInfoX Then Break;
	 End;
	If IH2+1 > FieldInfoY Then Break;
       End;

      ATOMFieldToMem := PH1;
     End;

    Function WINFieldToMem(X, Y, SizeX, SizeY : Word) : Pointer;
     (* Legt das WINFIELD von X|Y bis X+SIZEX|Y+SIZEY *)
     (* ab dem Zeiger ab, der zurÅckgegeben wird.     *)
     Var PH1      : Pointer;
	 PH2      : ^Word;
	 IH1, IH2 : Integer;
     Begin
      _GetMem(PH1, SizeX*SizeY*2);
      PH2 := PH1;

      For IH2 := Y To Y+SizeY-1 Do
       For IH1 := X To X+SizeX-1 Do
	Begin
	 PH2^ := WINField[IH1, IH2];
	 Inc(PH2);
	End;

      WINFieldToMem := PH1;
     End;

    Function MostLeftInATOMField : Word;
     (* Sucht den PLATZ (!) des am meisten Links gelegenen Atoms. *)
     Var IH1, IH2 : Integer;
	 Left     : Integer;
     Begin
      Left := FieldInfoX;
      For IH2 := 1 To FieldInfoY Do
       For IH1 := 1 To FieldInfoX Do
	Begin
	 If (ATOMFieldL[IH1, IH2] <> 0) And (IH1 < Left) Then Left := IH1;
	 If Left = 1 Then
	  Begin
	   MostLeftInATOMField := Left;
	   Exit;
	  End;
	End;
      MostLeftInATOMField := Left;
     End;

    Function MostObenInATOMField : Word;
     (* Sucht den PLATZ (!) des am meisten Oben gelegenen Atoms. *)
     Var IH1, IH2 : Integer;
	 Oben     : Integer;
     Begin
      Oben := FieldInfoY;
      For IH2 := 1 To FieldInfoY Do
       For IH1 := 1 To FieldInfoX Do
	Begin
	 If (ATOMFieldL[IH1, IH2] <> 0) And (IH2 < Oben) Then Oben := IH2;
	 If Oben = 1 Then
	  Begin
	   MostObenInATOMField := Oben;
	   Exit;
	  End;
	End;
      MostObenInATOMField := Oben;
     End;

    Function CmpP1UndP2(P1, P2 : Pointer; Size : Word) : Boolean;
     (* True, Wenn SIZE WORDS ab P1 gleich SIZE WORDS ab P2 sind. *)
     Var IH1, IH2 : Integer;
	 PH1, PH2 : ^Word;
     Begin
      PH1 := P1;
      PH2 := P2;
      CmpP1UndP2 := True;
      For IH1 := 1 To Size Do
       Begin
	If PH1^ <> PH2^ Then
	 Begin
	  CmpP1UndP2 := FALSE;
	  Exit;
	 End;
	Inc(PH1); Inc(PH2);
       End;
     End;

    (* ---------------------------------------------------------------- *)

    Var ATOMInfoL : Integer;
	ATOMInfoR : Integer;
	ATOMInfoO : Integer;
	ATOMInfoU : Integer;
	PATOMChk  : Pointer;
	B1        : Boolean;

    Begin                               (* MAIN-FUNKTION. *)
     (* Beim 1. Aufruf Winfield-Zeiger^ fÅllen: *)
     If AFirst Then
      Begin
       (* Schablonenabmessungen im WINField bestimmen: *)
       WINInfoL := MostLeftInWINField;
       WINInfoR := MostRightInWINField;
       WINInfoO := MostObenInWINField;
       WINInfoU := MostUntenInWINField;

       PWINChk := WINFieldToMem(WINInfoL, WINInfoO, WINInfoR-WINInfoL+1, WINInfoU-WINInfoO+1);
       SizeWINChk := (WINInfoR-WINInfoL+1) * (WINInfoU-WINInfoO+1) * 2;
      End

     (* Nicht 1. Aufruf, jeweils AtomstÑnde testen: *)
     Else
      Begin
       B1 := False;

       (* Schablonenabmessungen im ATOMField bestimmen: *)
       ATOMInfoL := MostLeftInATOMField;
       ATOMInfoO := MostObenInATOMField;

       PATOMChk := ATOMFieldToMem(ATOMInfoL, ATOMInfoO, WINInfoR-WINInfoL+1, WINInfoU-WINInfoO+1);

       (* Vergleichen: *)
       If CmpP1UndP2(PWINChk, PATOMChk, ((WINInfoR-WINInfoL+1)*(WINInfoU-WINInfoO+1))) Then
	B1 := TRUE;

       (* Speicher freigeben: *)
       FreeMem(PATOMChk, SizeWINChk);

       TestMolekuel := B1;
      End;
    End;

   PROCEDURE Won;
    (* ---------------------------------------------------------------- *)

    Procedure GivePoints;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : Vergibt bei einem gewonnen Level Punkte.              *)
     (* ---------------------------------------------------------------- *)
     Var SH1, SH2 : String;
	 Code     : Integer;
	 IH1, IH2 : Integer;
     Begin
      SetCycleTime(00);
      If UseTime Then StopTimeInt;      (* ZÑhler ggf. anhalten. *)
      UnInstallTrap;

      While KeyPressed Do ReadKey;

      For IH1 := Time DownTo 1 Do
       Begin
        Delay(10);
	Dec(Time);

	Str((Time Div 60):1, SH1);        (* Minuten. *)
	Str((Time Mod 60)  , SH2);        (* Sekunden. *)
	If Length(SH2) = 1 Then SH2 := '0' + SH2;
	SH1 := SH1 + ':' + SH2;

	Val(SH1[1], TimeParts[1], Code);
	Val(SH1[3], TimeParts[3], Code);
	Val(SH1[4], TimeParts[4], Code);

	SpriteN[TimeSpriteN[1]] := TimeNumbers  [TimeParts[1]];(* Minuten. *)
	SpriteN[TimeSpriteN[3]] := TimeNumbers  [TimeParts[3]];(* 10er Sekunden. *)
	SpriteN[TimeSpriteN[4]] := TimeNumbers  [TimeParts[4]];(* 1er Sekunden. *)

	(* Punkte vergeben: *)
	Score[AktPlayer] := Score[AktPlayer] + PntsOf1Sek;
	Str(Score[AktPlayer]:8, SH1);
	MakeTextSprite(SH1, 1{C}, 1{Dis}, 1{Ori}, ScoreSprLOAD[AktPlayer]{SprLNr}, 4{FntNr});

	Animate;
       End;
     End;

    Procedure ExplodeAtoms;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : LÑsst alle Atome der Reihe nach explodieren.          *)
     (* ---------------------------------------------------------------- *)
     Var IH1, IH2, IH3 : Integer;
	 WH1           : Word;
	 SH1           : String;
     Begin
      While KeyPressed Do ReadKey;

      SetCycleTime(55);

      For IH2 := 1 To FieldMAXY Do
       For IH1 := 1 To FieldMAXX Do
	Begin
	 WH1 := AtomFieldN[IH1, IH2];
	 If WH1 <> 0 Then
	  Begin
	   (* Punkte vergeben: *)
	   Score[AktPlayer] := Score[AktPlayer] + PntsOf1Atom;
	   Str(Score[AktPlayer]:8, SH1);
	   MakeTextSprite(SH1, 1{C}, 1{Dis}, 1{Ori}, ScoreSprLOAD[AktPlayer]{SprLNr}, 4{FntNr});

	   For IH3 := 10 To 18 Do
	    Begin
	     SpriteN[WH1] := IH3;       (* Auf Explosion. *)

	     Animate;
	    End;
	   SpriteN[WH1] := 0;
	  End;
	End;
      GivePoints;                       (* Verbleibende Zeit punkten. *)
     End;

    Var BH1 : Byte;

    Begin
     (* BlinkRing aus: *)
     SpriteN[BlinkRingN] := 0;

     (* Cursor aus: *)
     SpriteN[CursorN] := 0;

     (* Atome explodieren lassen: *)
     ExplodeAtoms;
    End;

   PROCEDURE Lost;
    (* ---------------------------------------------------------------- *)
    Var WH1, WH2, WH3 : Word;
	IH1, IH2, IH3 : Integer;
        Count         : Integer;
    Begin
     (* Bildschirm vorbereiten: *)
     SetPalette(ZeroColors);
     ClrScreen(0, BackGroundPage);

     (* Sprites erstellen und positionieren: *)
     IH1 := GetFreeLoadNr;
     MakeTextSprite('TIME OUT' , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
     IH2 := GetFreeLoadNr;
     MakeTextSprite('AND'      , 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 1{FntNr});
     IH3 := GetFreeLoadNr;
     MakeTextSprite('GAME OVER', 1{C}, 1{Dis}, 1{Ori}, IH3{SprLNr}, 1{FntNr});

     WH1 := GetFreeNNr;
     SpriteN[WH1] := IH1;
     SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
     SpriteY[WH1] := 074;
     WH2 := GetFreeNNr;
     SpriteN[WH2] := IH2;
     SpriteX[WH2] := (319 - SpriteSIZEX[IH2]) Div 2;
     SpriteY[WH2] := (199 - SpriteSIZEY[IH2]) Div 2;
     WH3 := GetFreeNNr;
     SpriteN[WH3] := IH3;
     SpriteX[WH3] := (319 - SpriteSIZEX[IH3]) Div 2;
     SpriteY[WH3] := 110;

     Animate;

     FadeToPalette(HPal, 40);

     (* Warte auf Taste oder Maustaste: *)
     __Space := FALSE;
     While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
     For Count := 1 To 50 Do
      Begin
       If KeyPressed Or __Space Then Break;
       Delay(100);
      End;
     __Space := FALSE;

     While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)

     FadeToPalette(ZeroColors, 40);

     FreeSpriteMem(IH1);
     FreeSpriteMem(IH2);
     FreeSpriteMem(IH3);

     SpriteN[WH1] := 0;                 (* MöSSEN wieder dereferenziert *)
     SpriteN[WH2] := 0;                 (* werden, sonst ABSTURTZ !     *)
     SpriteN[WH3] := 0;

     (* Wieder zurÅck: *)
     WaitVRetrace;
     ChangePage(_Page);

     ClrScreen(0, {_Page}1-_Page);
    End;

   PROCEDURE RegisterBlinkRing(ALoad_Nr : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     BlinkRingN := GetFreeNNr;
     BlinkRingL := ALoad_Nr;
    End;

   FUNCTION AtomixGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
	C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      ATO_Error_NoLEVFile               : S := S + 'Datei ' + UpString(NameString(AS) + ExtString(AS) + C) +
			        	       'ist keine LEV-Datei.';
      ATO_Error_SizeOfLEVFieldTooBig    : S := S + 'Grî·e des Spielfeldes in Datei'
					       + UpString(NameString(AS) + ExtString(AS) + C) + 'zu gro·.';
      ATO_Error_TooManySpritesInLEVFile : S := S + 'Zu viele Sprites in der LEV-Datei'
					       + UpString(NameString(AS) + ExtString(AS) + C) + '.';
      ATO_Error_LevelNIsFull            : S := S + 'LEVELN[..] ist voll.';
      ATO_Error_NoHiScoreFile           : S := S + 'Datei ' + UpString(NameString(AS) + ExtString(AS) + C) +
						 'ist keine Hiscore-Datei.';
      ATO_Error_NoEnoughHeapMem         : S := S + 'Nicht genug Speicher. Es werden '+ AS + ' Bytes zusÑtzlich benîtigt.';

      Else                                S := '';
     End;

     AtomixGetErrorMessage := S;
    End;

   FUNCTION CountSpriteN : Integer;
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2 : Integer;
    Begin
     IH1 := 0;
     For IH2 := 0 To NMAX Do
      If SpriteN[IH2] <> 0 Then Inc(IH1);

     CountSpriteN := IH1;
    End;

   PROCEDURE SetTimeBase(Min, Sek : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     InLine($FA);
     Time := 60*Min+Sek;
     GetIntVec(8, SaveInt8);
     SetIntVec(8, @TimeInt);
     Ticks := 0;
     TimeIntAktiv := TRUE;
     InLine($FB);
    End;

   PROCEDURE TimeInt;
    (* ---------------------------------------------------------------- *)
    Begin
     InLine($9C/$FF/$1E/SaveInt8);      (* Alten Interrupt aufrufen. *)

     Inc(Ticks, 10);
     If Ticks > 182 Then                (* Wenn 1 Sekunde abgelaufen. *)
      Begin
       Ticks := 0;                      (* Ticks wieder von vorne. *)
       If Time > 0 Then Dec(Time)       (* Zeit - 1 Sekunde. *)
       Else StopTimeInt;                (* Wenn Zeit abgelaufen, wieder alten *)
					(* Handler installieren.              *)
      End;
    End;

   PROCEDURE StopTimeInt;
    (* ---------------------------------------------------------------- *)
    Begin
     If TimeIntAktiv Then
      Begin
       InLine($FA);
       SetIntVec(8, SaveInt8);
       TimeIntAktiv := FALSE;
       InLine($FB);
      End;
    End;

   PROCEDURE LOADINGSpriteData; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     (* Ebene 000: *)
     DB 118,118,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,118,000,000,118,000,000,118,118,000,118,000,118,118,118,000,000,118,000,000,000,000,000,000,000
     DB 000,000,000,000,118,000,000,118,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,000,118,000,000,118,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,000,118,000,118,118,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,000,118,000,118,000,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,000,118,000,118,118,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,118,118,000,118,118,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,118,118,000,000,118,000,000,118,000,118,000,118,000,118,000,118,000,000,118,000,000,118,000,118,000,118
     DB 000,000,000,118,118,000,000,118,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,118,000,118,000,118
     DB 118,118,118,118,000,118,000,118,000,118,000,118,118,118,118,118,118,118,118,118,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000

     (* Ebene 1: *)
     DB 118,118,000,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,118,118,000,118,118,000,000,118,118,000,118,000,118,118,000,000,000,118,118,000,000,000,000,000,000
     DB 118,000,000,000,118,118,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,118,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,118,118,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,118,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,118,000,118,000,118
     DB 118,000,000,000,000,000,000,000,118,000,118,000,118,000,118,000,118,000,118,000,118,118,000,000,118,000,118,000,118
     DB 118,000,000,000,118,118,000,118,118,118,118,000,118,000,118,000,118,000,118,000,118,000,000,000,118,000,118,000,118
     DB 118,118,118,000,118,118,000,118,000,000,000,118,118,000,118,000,118,000,118,000,000,000,000,000,118,000,118,000,118
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000

     (* Ebene 2: *)
     DB 118,118,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,118,000,000,118,118,000,118,118,118,118,118,118,000,118,000,000,118,118,118,000,000,000,000,000,000
     DB 118,000,000,000,000,118,000,000,118,000,118,000,118,000,118,000,118,000,000,000,118,118,118,000,000,000,000,000,000
     DB 118,000,000,000,000,118,000,000,118,000,000,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,000,118,000,000,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,000,118,000,000,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,118,118,000,000,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,000,118,000,000,000,118,000,118,000,118,000,118,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,118,000,118,000,000,000,118,000,118,000,118,000,118,000,118,118,000,000,118,000,118,000,118
     DB 118,000,000,000,000,118,118,000,118,000,000,000,118,000,118,000,118,000,118,000,118,118,000,000,118,000,118,000,118
     DB 118,000,000,000,000,118,118,000,118,000,118,000,118,000,118,000,118,000,118,000,000,000,000,000,118,000,118,000,118
     DB 118,118,118,000,118,000,000,118,118,000,118,118,118,118,118,118,118,118,118,000,000,000,000,000,118,000,118,000,118
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000

     (* Ebene 3: *)
     DB 118,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
     DB 118,000,000,000,118,000,000,118,000,000,118,000,000,118,000,118,000,118,000,000,118,000,118,000,000,000,000,000,000
     DB 118,000,000,118,000,118,118,000,118,000,000,118,000,000,000,000,118,118,000,000,000,118,118,000,000,000,000,000,000
     DB 118,000,000,118,000,118,118,000,118,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,000,118,118,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,000,118,118,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,000,118,118,118,000,000,000,000,000,000,000,000,000,118,000,118,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,118,000,118,118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,118,000,118,118,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000
     DB 118,000,000,118,000,118,118,000,118,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,118,000,118,000,118
     DB 118,000,118,118,000,118,118,000,118,000,000,118,000,000,000,000,000,000,000,000,000,000,000,000,118,000,118,000,118
     DB 118,118,118,000,118,000,118,118,118,000,118,000,118,118,118,118,118,118,118,118,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,118,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,118,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,000,000,000,000,000,000,000,000,000
     DB 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,118,118,000,000,000,000,000,000,000
    End;

   PROCEDURE MakeLOADINGSprite(ALoadNr : Word);
    (* ---------------------------------------------------------------- *)
    Var PH1, PH2 : Pointer;
	PBH1     : ^Byte;
	MemSize  : Word;

    Begin                               (* HAUPTPROZEDUR. *)
     (* Header erstellen: *)
     SpriteStruct.BreiteInBytes := 29;
     SpriteStruct.HoeheInZ := 27;
     SpriteStruct.Translate[1] := 1;
     SpriteStruct.Translate[2] := 2;
     SpriteStruct.Translate[3] := 4;
     SpriteStruct.Translate[4] := 8;
     SpriteStruct.PlaneDatPtr[0] := SizeOf(SpriteStruct);
     SpriteStruct.PlaneDatPtr[1] := SizeOf(SpriteStruct) + 783;
     SpriteStruct.PlaneDatPtr[2] := SizeOf(SpriteStruct) + 1566;
     SpriteStruct.PlaneDatPtr[3] := SizeOf(SpriteStruct) + 2349;

     FreeSpriteMem(ALoadNr);            (* Eventuellen alten Speicher freigeben. *)

     (* Speicher anfordern und Header hineinkopieren: *)
     MemSize := SizeOf(TSpriteStruct) + 3147;
     _GetMem(PH1, MemSize);

     (* Tafeln bezeichnen: *)
     SpriteSIZE [ALoadNr] := MemSize;
     SpriteSIZEX[ALoadNr] := 116;
     SpriteSIZEY[ALoadNr] := 27;
     SpritePTR  [ALoadNr] := PH1;

     If (LongInt(PH1) mod 16) = 0 Then PH2 := PH1
      Else LongInt(PH2) := LongInt(PH1) + (16-LongInt(PH1) Mod 16);

     (* Header auf Heap bringen: *)
     Move(SpriteStruct, PH2^, SizeOf(TSpriteStruct));
     LongInt(PH1) := LongInt(PH2) + SizeOf(TSpriteStruct);

     (* Rest vom Sprite auf Heap bringen: *)
     Move(@LOADINGSpriteData^, PH1^, 3132);

     (* SpriteNummer zuordnen: *)
     SpriteAD[ALoadNr] := (LongInt(PH2) Shr 16) + (LongInt(PH2) And 65535) Shr 4;
    End;

   PROCEDURE MakeTimeNumbers;
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2 : Integer;
    Begin
     (* '0' bis '9': *)
     For IH1 := 0 To 9 Do
      Begin
       IH2 := GetFreeLOADNr;
       MakeTextSprite(Chr(48+IH1), 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 5{FntNr});
       TimeNumbers[IH1] := IH2;
      End;
     (* Doppelpunkt ':': *)
     IH2 := GetFreeLOADNr;
     MakeTextSprite(':', 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 5{FntNr});
     TimeDoublePnt := IH2;
    End;

   PROCEDURE ScoreList;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PXH1     : Pointer;
        {$ELSE}
        F        : File;
        {$ENDIF}

        BH1, BH2 : Byte;
        WH1, WH2 : Word;
        IH1, IH2 : Integer;
        SH1, SH2 : String;
        SH3, SH4 : String;
        PFarbe   : Pointer;
        Farbe    : TPalette;
        Dummy    : Array[1..50] Of Char;
        CurScore : LongInt;             (* Beim Einlesen aus Datei. *)
        Code     : Integer;
        InputY   : Word;
        ModNr    : Byte;                (* Nummer des Eintrags, der geÑndert wurde. *)
        ECode    : Byte;
        ScrFound : Boolean;             (* Wenn Platz zum Eintragen gefunden. *)
        Count    : Integer;
    Begin
     InputY := 0;
     ScrFound := FALSE;

     (* Ggf. Zeit aus: *)
     If UseTime Then StopTimeInt;

     (* Alle Sprites austragen: *)
     FillChar(SpriteN, SizeOf(SpriteN), 0);

     (* Bildschirm vorbereiten: *)
     FadeToPalette(ZeroColors, 40);
     ClrScreen(0, _Page);

     (* Alte Bilder weg: *)
     FreeImage(BackPics[1]);
     FreeImage(BackPics[2]);
{    PutImage(BackPics[1], BackGroundPage, 0, 0, TRUE);
     PutImage(BackPics[2], BackGroundPage, 0, 0, TRUE)}

     PFarbe := LoadPCXPic('ATOMI4.PCX', BackGroundPage, TRUE, FALSE);
     If PFarbe <> Nil Then Move(PFarbe^, Farbe, SizeOf(Farbe))
      Else Move(HPal, Farbe, SizeOf(Farbe));

     (* Sprites erstellen: *)

     (* Aktueller Spieler: *)
     WH1 := GetFreeNNr;
     IH1 := GetFreeLoadNr;
     Str(AktPlayer:1, SH1);
     MakeTextSprite('PLAYER ' + SH1, 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
     SpriteN[WH1] := IH1;
     SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
     SpriteY[WH1] := 046;
     CopySpritesToBkgPage(IH1, IH1);
     FreeSpriteMem(IH1); SpriteN[WH1] := 0;

     (* Kopfzeile: *)
     WH1 := GetFreeNNr;
     IH1 := GetFreeLoadNr;
     MakeTextSprite('RANK  PLAYERS NAME     SCORE  ', 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 3{FntNr});
     SpriteN[WH1] := IH1;
     SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
     SpriteY[WH1] := 072;
     CopySpritesToBkgPage(IH1, IH1);
     FreeSpriteMem(IH1); SpriteN[WH1] := 0;

     (* Datei ôffnen: *)

     {$IFDEF ONEFILE}
     _Assign(F, ScoreFName);
     {$ELSE}
     Assign(F, ScoreFName);
     {$ENDIF}

     {$I-}

     {$IFDEF ONEFILE}
     _Reset(F, 1);                      (* BlockRead-LÑnge : 1 Byte. *)
     {$ELSE}
     Reset(F, 1);                       (* BlockRead-LÑnge : 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

     (* Teste, ob OK: *)
     {$I-}

     {$IFDEF ONEFILE}
     If _FileSize(F) <> 214 Then
     {$ELSE}
     If FileSize(F) <> 214 Then
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

       ERR_Error := ATO_Error_NoHiScoreFile;
       CriticalError(ScoreFName);
      End;
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

     For BH1 := 1 To 8 Do             (* 8 EintrÑge. *)
      Begin
       (* 1 Zeile einlesen: *)
       {$I-}

       {$IFDEF ONEFILE}
       PXH1 := @Dummy;
       If BH1 < 8 Then _BlockRead(F, PXH1, 27)(* 1 Zeile einlesen. *)
        Else _BlockRead(F, PXH1, 25);
       {$ELSE}
       If BH1 < 8 Then BlockRead(F, Dummy, 27)(* 1 Zeile einlesen. *)
        Else BlockRead(F, Dummy, 25);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);
       SH2[0] := #25;                 (* LÑnge = 25 Zeichen. *)
       For IH1 := 1 To 25 Do SH2[IH1] := Dummy[IH1];

       (* Punktezahl ermitteln: *)
       Val(Copy(SH2, Length(SH2)-5, 6), CurScore, Code);

       (* Teste, ob OK: *)
       If Code <> 0 Then
        Begin
         {$I-}

         {$IFDEF ONEFILE}
         _Close(F);
         {$ELSE}
         Close(F);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

         ERR_Error := ATO_Error_NoHiScoreFile;
         CriticalError(ScoreFName);
        End;
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

       If (Score[AktPlayer] >= CurScore) And (Not ScrFound) Then
        Begin
         ScrFound := TRUE;
         Str(Score[AktPlayer], SH2);
         While Length(SH2) < 6 Do SH2 := '0' + SH2;
         SH2 := '                   ' + SH2;
         InputY := 077 + 10 * BH1;    (* Wo nachher eingegeben wird. *)
         ModNr := BH1;
        End;

       WH1 := GetFreeNNr;
       IH1 := GetFreeLoadNr;
       Str(BH1:1, SH1);
       MakeTextSprite(SH1+'. '+SH2, 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 3{FntNr});
       SpriteN[WH1] := IH1;
       SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
       SpriteY[WH1] := 077 + 10 * BH1;
       CopySpritesToBkgPage(IH1, IH1);
       FreeSpriteMem(IH1); SpriteN[WH1] := 0;
      End;                            (* Von Einleseschleife. *)

     (* VOC-Sound laden: *)
     LoadVOCFile('SCREAM.VOC', 1);

     (* Ggf. NAMEN einlesen: *)
     If InputY > 0 Then
      Begin
       (* Press-Return: *)
       WH1 := GetFreeNNr;
       IH1 := GetFreeLoadNr;
       MakeTextSprite('TYPE NAME AND PRESS RETURN', 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 3{FntNr});
       SpriteN[WH1] := IH1;
       SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
       SpriteY[WH1] := 175;
       CopySpritesToBkgPage(IH1, IH1);
       FreeSpriteMem(IH1); SpriteN[WH1] := 0;

       Animate;

       FadeToPalette(Farbe, 40);

       (* VOC-Sound abspielen: *)
       If (VOC_Possible And VOC_On) Then PlayVOCFile(1);

       SetTypmRate(OldDelay, OldSpeed);       (* Alte Raten ggf. wieder setzen. *)

       While KeyPressed Do ReadKey;   (* Tastaturpuffer lîschen. *)

       ReadString(SH1, {Length}17, {Col}1, {Ver}1, {X}060, {Y}InputY, {Chars}0,
                  {FntNr}3, {CsrChar}'~', {ExitCode}ECode, {UpCase}TRUE);

       While KeyPressed Do ReadKey;   (* Tastaturpuffer lîschen. *)

       (* Eingelesen String formatieren und Punktezahl dazu: *)
       While Length(SH1) < 17 Do SH1 := SH1 + ' ';
       SH1[0] := #17;                 (* LÑnge 17. *)

       (* Neuer String ausgeben: *)
       WH1 := GetFreeNNr;
       IH1 := GetFreeLoadNr;
       Str(ModNr:1, SH2);             (* Eintrag-Nummer. *)
       Str(Score[AktPlayer], SH3);    (* PunkteZahl. *)
       While Length(SH3) < 6 Do SH3 := '0' + SH3;
       MakeTextSprite(SH2+'. '+SH1+'  '+SH3, 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 3{FntNr});
       SpriteN[WH1] := IH1;
       SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
       SpriteY[WH1] := InputY;
       CopySpritesToBkgPage(IH1, IH1);
       FreeSpriteMem(IH1); SpriteN[WH1] := 0;

       (* Eingelesen String formatieren und Punktezahl dazu: *)
       SH1 := SH1 + '  ' + SH3;
       For IH1 := 1 To 25 Do Dummy[IH1] := SH1[IH1];

       Animate;

       (* Wenn Eingabe mit ESC beendet, NICHTS schreiben: *)
       If (ECode <> 0) And (Write_HighScore = TRUE) Then (* Wenn NICHT mit ESC beendet. *)
        Begin
         (* Stelle anfahren: *)
         {$I-}

         {$IFDEF ONEFILE}
         _Seek(F, (ModNr-1) * 27);    (* Zeichen anfahren. *)
         {$ELSE}
         Seek(F, (ModNr-1) * 27);     (* Zeichen anfahren. *)
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

         (* Schreiben: *)
         {$I-}

         {$IFDEF ONEFILE}
         PXH1 := @Dummy;
         _BlockWrite(F, PXH1, 25);
         {$ELSE}
         _BlockWrite(F, Dummy, 25);
         {$ENDIF}

         {$I+}
         ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

        End;
       FadeToPalette(ZeroColors, 40);
       If (VOC_Possible And VOC_On) Then StopVOCIO;
      End

      Else                             (* Wenn nichts eingetragen wird. *)
       Begin
        (* Press-Return: *)
        WH1 := GetFreeNNr;
        IH1 := GetFreeLoadNr;
        MakeTextSprite('PRESS ANY KEY', 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 3{FntNr});
        SpriteN[WH1] := IH1;
        SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
        SpriteY[WH1] := 175;
        CopySpritesToBkgPage(IH1, IH1);
        FreeSpriteMem(IH1); SpriteN[WH1] := 0;

        Animate;

        FadeToPalette(Farbe, 40);

        (* VOC-Sound abspielen: *)
        If (VOC_Possible And VOC_On) Then PlayVOCFile(1);

        (* Warte auf Taste oder Maustaste: *)
        __Space := FALSE;
        While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
        For Count := 1 To 50 Do
         Begin
          If KeyPressed Or __Space Then Break;
          Delay(100);
         End;
        __Space := FALSE;

        FadeToPalette(ZeroColors, 40);
        If (VOC_Possible And VOC_On) Then StopVOCIO;
      End;

      {$I-}

      {$IFDEF ONEFILE}
      _Close(F);
      {$ELSE}
      Close(F);
      {$ENDIF}

      {$I+}
      ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ScoreFName);

      (* VOC-Sound freigeben: *)
      FreeVOCMem(1);
    End;

    PROCEDURE MakeScores(AFirst : Boolean);
    (* ---------------------------------------------------------------- *)
     Var SH1 : String;
     Begin
      (* Punkte von Spieler 1 schreiben: *)
      If AFirst Then
       Begin
	ScoreSpriteN[1] := GetFreeNNr;
	ScoreSprLOAD[1] := GetFreeLoadNr;
       End;
      Str(Score[1]:8, SH1);
      MakeTextSprite(SH1, 1{C}, 1{Dis}, 1{Ori}, ScoreSprLOAD[1]{SprLNr}, 4{FntNr});
      If AFirst Then
       Begin
	SpriteN[ScoreSpriteN[1]] := ScoreSprLOAD[1] ;
	SpriteX[ScoreSpriteN[1]] := (SpriteSIZEX[31]-SpriteSIZEX[ScoreSprLOAD[1]]) Div 2;
	SpriteY[ScoreSpriteN[1]] := 017;
       End;

      If NrOfPlayers = 2 Then
       Begin
	(* Punkte von Spieler 2 schreiben: *)
	If AFirst Then
	 Begin
	  ScoreSpriteN[2] := GetFreeNNr;
	  ScoreSprLOAD[2]  := GetFreeLoadNr;
	 End;
	Str(Score[2]:8, SH1);
	MakeTextSprite(SH1, 1{C}, 1{Dis}, 1{Ori}, ScoreSprLOAD[2]{SprLNr}, 4{FntNr});
	If AFirst Then
	 Begin
	  SpriteN[ScoreSpriteN[2]] := ScoreSprLOAD[2] ;
	  SpriteX[ScoreSpriteN[2]] := (SpriteSIZEX[31]-SpriteSIZEX[ScoreSprLOAD[2]]) Div 2;
	  SpriteY[ScoreSpriteN[2]] := 017;
	 End;
       End;
      End;

   PROCEDURE TestAllFiles;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
	BH1 : Boolean;
	S   : String;
    Begin
     BH1 := TRUE;

     (* Schaue alle Dateien durch: *)
     For IH1 := 1 To CountFiles Do
      Begin
       If Not FileExists(Files[IH1]) Then
	Begin
	 BH1 := FALSE;
	 Break;
	End;
      End;

     (* Wenn Dateien fehlen: *)
     If BH1 = FALSE Then
      Begin
       ERR_Error := ERR_Error_FileNotFound;
       CriticalError(Files[IH1]);
      End;
    End;

   FUNCTION AskExit : Boolean;
    (* ---------------------------------------------------------------- *)
    Var WH1 : Word;
	IH1 : Integer;
        PH1 : Word;
        Rk  : Char;
    Begin
     FadeToPalette(ZeroColors, 40);

     (* Seite 3 kopieren, dann lîschen: *)
     GetImage(PH1, BackGroundPage, 0, 0, XMAX+1, YMAX+1);
     WaitVRetrace;
     ClrScreen(0, BackGroundPage);

     (* Sprites erstellen: *)

     WH1 := GetFreeNNr;
     IH1 := GetFreeLoadNr;
     MakeTextSprite('REALLY QUIT ?', 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
     SpriteN[WH1] := IH1;
     SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2 + 3;
     SpriteY[WH1] := 79;
     CopySpritesToBkgPage(IH1, IH1);
     FreeSpriteMem(IH1); SpriteN[WH1] := 0;

     WH1 := GetFreeNNr;
     IH1 := GetFreeLoadNr;
     MakeTextSprite('PRESS Y/N !', 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
     SpriteN[WH1] := IH1;
     SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
     SpriteY[WH1] := 105;
     CopySpritesToBkgPage(IH1, IH1);
     FreeSpriteMem(IH1); SpriteN[WH1] := 0;

     (* Auf Seite 3 wechseln: *)
     WaitVRetrace;
     ChangePage(BackGroundPage);
     FadeToPalette(HPal, 40);

     (* Warte auf Taste: *)
     Rk := #0;
     While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
     Repeat
      If KeyPressed Then Rk := UpCase(ReadKey);
     Until (Rk In ['Y', 'N']);     (* Auf Tastendruck warten. *)

     FadeToPalette(ZeroColors, 40);
     While KeyPressed Do ReadKey;      (* Tastaturpuffer lîschen. *)

     (* Seite 3 wieder besetzen: *)
     ClrScreen(0, BackGroundPage);
     PutImage(PH1, BackGroundPage, 0, 0, TRUE);

     (* Wieder zurÅck: *)
     WaitVRetrace;
     ChangePage(_Page);

     If (RK = 'Y') {Or MR} Then AskExit := TRUE;
     If (RK = 'N') {Or ML} Then
      Begin
       AskExit := FALSE;
       FadeToPalette(HPal, 40);
      End;
    End;

   PROCEDURE LoadingSequence;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
        WH1 : Word;
        SH1 : String;
    Begin
     (* Daten laden: *)
     LoadPalette('ATOMIX.PAL', 1);
     HPal := PALField[1];
     SetPalette(HPal);

     (* "Loading..." zeigen: *)
     WH1 := GetFreeNNr;
     IH1 := GetFreeLoadNr;
     MakeLoadingSprite(IH1);
     SpriteN[WH1] := IH1;
     SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
     SpriteY[WH1] := (199 - SpriteSIZEY[IH1]) Div 2;
     CopySpritesToBkgPage(IH1, IH1);
     FreeSpriteMem(IH1); SpriteN[WH1] := 0;

     Animate;

     (* Fonts laden: *)
     LoadFont('ATOMIX.FNT',1);          (* 5 StÅck ! *)

     (* Ggf. auf Cheat und/oder Time hinweisen: *)
     If UseCheat Or (Not UseTime) Then
      Begin
       (* Text erstellen: *)
       SH1 := '';
       If UseCheat Then SH1 := SH1 + 'CHEAT AKTIV !';
       If UseCheat And (Not UseTime) Then SH1 := SH1 + '      ';
       If Not UseTime Then SH1 := SH1 + 'ZEIT INAKTIV !';

       (* Sprite erstellen: *)
       WH1 := GetFreeNNr;
       IH1 := GetFreeLoadNr;
       MakeTextSprite(SH1, 118{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
       SpriteN[WH1] := IH1;
       SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
       SpriteY[WH1] := 199 - SpriteSIZEY[IH1];
       CopySpritesToBkgPage(IH1, IH1);
       FreeSpriteMem(IH1); SpriteN[WH1] := 0;
      End;

     Animate;

     (* Daten laden: *)
     IH1 := LoadLevel('ATOMIX.LEV', 1);
     IH1 := LoadSprite('ATOMIX.SPR', 1);

     (* Blinkring verketten: *)
     NextSprite[21] := 22;
     NextSprite[22] := 23;
     NextSprite[23] := 24;
     NextSprite[24] := 21;

     (* Explosion verketten: *)
     NextSprite[10] := 11;
     NextSprite[11] := 12;
     NextSprite[12] := 13;
     NextSprite[13] := 14;
     NextSprite[14] := 15;
     NextSprite[15] := 16;
     NextSprite[16] := 17;
     NextSprite[17] := 18;
     NextSprite[18] := 18;

     (* Nummern der Zeit erstellen: *)
     MakeTimeNumbers;
    End;

   {$F+}
   PROCEDURE TrapCtrlAltDel; {Interrupt; Far;}
    (* ---------------------------------------------------------------- *)
    Begin
     Case Port[$60] Of
      001 : __Stop  := True;            (* "ESC". *)
      075 : __Left  := True;            (* "LEFT". *)
      077 : __Right := True;            (* "RIGHT". *)
      072 : __Up    := True;            (* "UP". *)
      080 : __Down  := True;            (* "DOWN". *)
      057 : __Space := True;            (* "SPACE". *)
      025 : __Pause := True;            (* "P". *)
      059 : __F1    := True;            (* "F1". *)
      068 : __F10   := True;            (* "F10". *)
      196 : __F10   := False;           (* "F10". *)
      042,
      054 : __Shift := True;            (* "Shift"-MAKEcode. *)
      170,
      182 : __Shift := False;           (* "Shift"-BREAKcode. *)
      050 : If HSC_Possible Then       (* 'M'. *)
             Begin
              If HSC_On = TRUE Then
               (* Musik anhalten: *)
               Begin
                HSC_On := FALSE;
                HSCStopSong;
               End
              Else
               Begin
                HSC_On := TRUE;
                PlayHSCFile(1);
               End;
             End;
      031 : If VOC_Possible Then       (* 'S'. *)
             Begin
              If VOC_On = TRUE Then
               Begin
                VOC_On := FALSE;
                StopVOCIO;
               End
              Else
               Begin
                VOC_On := TRUE;
                PlayVOCFile(1);
               End;
             End;
     End;

     (* Clean up as BIOS would (from Ohlsen & Stoker, TP Advanced Techniques): *)
     Inline($E4/$61/                    (* IN    AL, 61h *)
            $8A/$E0/                    (* MOV   AH, AL  *)
            $0C/$80/                    (* OR    AL, 80h *)
            $E6/$61/                    (* OUT   61h, AL *)
            $86/$E0/                    (* XCHG  AL, AH  *)
            $E6/$61/                    (* OUT   61h, AL *)
            $B0/$20/                    (* MOV   AL, 20h *)
            $E6/$20);                   (* OUT   20h, AL *)
    End;

   PROCEDURE InstallTrap;
    (* ---------------------------------------------------------------- *)
    Var PH1 : Pointer;
    Begin
     (* Testen, ob schon installiert: *)
     GetIntVec($09, PH1);
     If PH1 <> @TrapCtrlAltDel Then
      Begin
       (* Alle Werte auf 0: *)
       __Stop  := FALSE;                (* "ESC". *)
       __Left  := FALSE;                (* "LEFT". *)
       __Right := FALSE;                (* "RIGHT". *)
       __Up    := FALSE;                (* "UP". *)
       __Down  := FALSE;                (* "DOWN". *)
       __Space := FALSE;                (* "SPACE". *)
       __Pause := FALSE;                (* "P". *)
       __F1    := FALSE;                (* "F1". *)
       __F10   := FALSE;                (* "F10". *)
       __Shift := FALSE;                (* "SHIFT". *)

       (* Neue Routine installieren: *)
       GetIntVec($09, @OldInt9);
       SetIntVec($09, @TrapCtrlAltDel);
      End;
    End;

   PROCEDURE UnInstallTrap;
    (* ---------------------------------------------------------------- *)
    Begin
     SetIntVec($09, @OldInt9);
    End;

   PROCEDURE SetUpMausAndHandler;
    (* ---------------------------------------------------------------- *)
    Var OK : Byte;
    Begin
     (* Treiber aktivieren: *)
     Asm
     (* Reset: *)
      xor   ax, ax
      int   33h
      or    ax, ax
      jnz   @TreiberVorh
      mov   OK, 1                       (* Fehler zurÅck. *)
      jmp   @Ende

     @TreiberVorh:

      mov   OK, 0                       (* Alles OK. Return-Wert. *)

      @Ende:
     End;

     MAUSAKTIV := OK = 0;

     If Not MAUSAKTIV Then Exit;

     (* Bewegungs-Bereich festlegen: *)
     Asm
      (* Horizontalen Bewegungsbereich festlegen: *)
      mov   ax, 0007h
      mov   cx, 000
      mov   dx, 319
      int   33h

      (* Vertikalen Bewegungsbereich festlegen: *)
      mov   ax, 0008h
      mov   cx, 000
      mov   dx, 199
      int   33h
     End;

     (* Interrupt-Handler installieren: *)
     Regs.AX := $000C;                  (* Fkt 0Ch, Event-Handler installieren. *)
     Regs.CX := $0007;                  (* Bits 0..2 an = Auf BetÑtigen und loslassen des linken Knopfes *)
                                        (*                und auf Bewegung.                              *)
     Regs.DX := Ofs(MAUSAssHandler);    (* Offsetadresse des Handlers. *)
     Regs.ES := Seg(MAUSAssHandler);    (* Segmentadresse des Handlers. *)

     Intr($33, Regs);                   (* Handler installieren. *)

     (* Maus-Cursor platzieren auf (0|0): *)
     Asm
      mov   ax, 4h
      mov   cx, 0
      mov   dx, 0
      int   33h
     End;
    End;

   PROCEDURE CloseUpMausAndHandler;
    (* ---------------------------------------------------------------- *)
    Var OK : Byte;
    Begin
     If Not MAUSAKTIV Then Exit;

     (* Reset: *)
     Asm
      mov   ax, 21h
      int   33h

      cmp   ax, 0FFFFh
      je    @Error

      mov   OK, 0                       (* Kein Fehler, 0 zurÅck. *)
      jmp   @Ende

     @Error:
      mov   OK, 1                       (* Kein Fehler, 0 zurÅck. *)

     @Ende:
     End;

     (* Maustreiber deaktivieren: *)
     Regs.AX := $001F;
     Intr($33, Regs);
    {If Regs.AX = $001F Then            (* Wenn kein Fehler. *)
      SetIntVec($33, Ptr(Regs.ES, Regs.BX));}
    End;

   PROCEDURE MAUSInterruptHandler(AFlags, AButtons, X, Y : Integer);
    (* ---------------------------------------------------------------- *)
    Const Factor = 10;
    Begin
     (* Alle Interrupts sperren: *)
     Inline($FA);                       (* "CLI". *)

     (* Wenn bewegt: *)
     If AFlags And 001 = 001 Then
      Begin
       Regs.AX := $000B;
       Intr($33, Regs);
       If Integer(Regs.CX) > Factor Then __Right := TRUE
       Else If Integer(Regs.CX) < -Factor Then __Left := TRUE;
       If Integer(Regs.DX) > Factor Then __Down := TRUE
       Else If Integer(Regs.DX) < -Factor Then __Up := TRUE;
      End;
     If AFlags And 002 = 002 Then __Space := TRUE;

     (* Alle Interrupts freigeben: *)
     Inline($FB);                       (* "STI". *)
    End;

   PROCEDURE Main;
    (* ---------------------------------------------------------------- *)
    Const Fact = 4;                     (* Anzahl Pixel, um die Sprite in einem *)
                                        (* Zyklus verschoben wird.              *)
	  (* Passwîrter: *)
	  Key  = 3256;                  (* VerschlÅsselung der Passwîrter. *)

	  TimeSek : Array[1..30] Of Word = (120, 240, 400, 240, 360, 060,
                                            420, 300, 240, 300, 180, 080,
                                            240, 420, 420, 300, 300, 060,
                                            270, 210, 300, 240, 180, 150,
                                            300, 180, 300, 240, 180, 060);

	  Pass : Array[1..30] Of Word = (7461, 0234, 1895, 3474, 0246,
					 6456, 4327, 8647, 4359, 1245,
					 6011, 1212, 6344, 2354, 9369,
					 7656, 0456, 5353, 5437, 1234,
					 6651, 7542, 1634, 4235, 0545,
					 2256, 5435, 6438, 4855, 7340);

    Var   Ch          : Char;
	  WH1         : Word;
	  IH1, IH2    : Integer;
	  Moved       : Byte;           (*    2    *)
					(*         *)
					(* 1  0  4 *)
					(*         *)
					(*    8    *)

    Function CalculatePassword(ANr : Integer) : Word;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : Errechnet aus PASS[ANR] und KEY das Passwort.         *)
     (* Eingabe  : ANR = Levelnummer (1..30).                            *)
     (* RÅckgabe : Das errechnete Passwort.                              *)
     (* ---------------------------------------------------------------- *)
     Begin
      If UseEasyPass Then CalculatePassword := ANr
      Else CalculatePassword := Word(Pass[ANr] * Key);
     End;

    Function EnterPassword : Word;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : LÑsst ein Passwort eingeben und ÅberprÅft dieses.     *)
     (* RÅckgabe : 0      = Passwort war nicht richtig,                  *)
     (*            SONST. = zum Passwort zugehîrige Levelnummer.         *)
     (* ---------------------------------------------------------------- *)
     Var BH1, ExitCode : Byte;
	 Code          : Integer;
	 SH1, SH2      : String;
	 WH1, WH2, WH3 : Word;
	 IH1, IH2, IH3 : Integer;
	 SaveSprites   : Array[0..NMAX] Of Word;
	 PH1           : Word;
     Begin
      (* Sprites erstellen und positionieren: *)
      IH1 := GetFreeLoadNr;
      MakeTextSprite('INPUT'    , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
      IH2 := GetFreeLoadNr;
      MakeTextSprite('PASSWORD:', 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 1{FntNr});

      WH1 := GetFreeNNr;
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 060;
      WH2 := GetFreeNNr;
      SpriteN[WH2] := IH2;
      SpriteX[WH2] := (319 - SpriteSIZEX[IH2]) Div 2;
      SpriteY[WH2] := 075;

      SpriteN[WH1] := 0;                (* Gleich wieder weg. *)

      (* Seite 3 kopieren, dann lîschen: *)
      GetImage(PH1, BackGroundPage, 0, 0, XMAX+1, YMAX+1);
      WaitVRetrace;
      ClrScreen(0, BackGroundPage);

      (* Alle Sprites freigeben, dabei merken, welche: *)
      Move(SpriteN, SaveSprites, SizeOf(SaveSprites));
      FillChar(SpriteN, SizeOf(SpriteN), 0);
      SpriteN[WH1] := IH1;
      SpriteN[WH2] := IH2;
      WaitVRetrace;

      (* Text Einlesen: *)
      While KeyPressed Do ReadKey;   (* Tastaturpuffer lîschen. *)

      ReadString(SH1, {Length}5, {Col}1, {Ver}1, {X}112, {Y}130, {Chars}2,
	         {FntNr}1, {CsrChar}'~', {ExitCode}ExitCode, {UpCase}FALSE);

      While KeyPressed Do ReadKey;   (* Tastaturpuffer lîschen. *)

      (* Freigegebene Sprites wieder besetzen: *)
      WaitVRetrace;
      Move(SaveSprites, SpriteN, SizeOf(SpriteN));

      (* Seite 3 wieder besetzen: *)
      PutImage(PH1, BackGroundPage, 0, 0, TRUE);

      SpriteN[WH1] := 0;                (* MöSSEN wieder dereferenziert *)
      SpriteN[WH2] := 0;                (* werden, sonst ABSTURTZ !     *)

      FreeSpriteMem(IH1);
      FreeSpriteMem(IH2);

      (* Auswerten: *)
      EnterPassword := 0;

      Val(SH1, WH1, Code);
      If (Code = 0) And (ExitCode <> 0) Then
       For IH1 := 1 To 30 Do
	If (WH1 = CalculatePassword(IH1)) And (IH1 Mod PassDist = 0) Then
	 Begin
	  EnterPassword := IH1;
	  Break;
	 End;

      (* Wieder zurÅck: *)
      WaitVRetrace;
      ChangePage(_Page);
     End;

    Function TellPassword(ANr : Word) : Word;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : Meldet das aktuelle Passwort.                         *)
     (* Eingabe  : ANR   = Nummer des Levels in LevelN[..].              *)
     (* RÅckgabe : 1 = Mit ESC abgebrochen.                              *)
     (* ---------------------------------------------------------------- *)
     Var SH1, SH2      : String;
	 WH1, WH2, WH3 : Word;
	 IH1, IH2, IH3 : Integer;
     Begin
      TellPassword := 0;

      (* Bildschirm vorbereiten: *)
      SetPalette(ZeroColors);
      ClrScreen(0, BackGroundPage);

      (* Sprites erstellen und positionieren: *)
      Str(ANr, SH1);
      If Length(SH1) = 1 Then SH1 := '0' + SH1;
      Str(Word(CalculatePassword(ANr)), SH2);
      While Length(SH2) < 4 Do SH2 := '0' + SH2;

      IH1 := GetFreeLoadNr;
      MakeTextSprite('PASSWORD FOR'   , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
      IH2 := GetFreeLoadNr;
      MakeTextSprite('LEVEL '+SH1+': ', 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 1{FntNr});
      IH3 := GetFreeLoadNr;
      MakeTextSprite(SH2              , 1{C}, 1{Dis}, 1{Ori}, IH3{SprLNr}, 1{FntNr});

      WH1 := GetFreeNNr;
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 060;
      WH2 := GetFreeNNr;
      SpriteN[WH2] := IH2;
      SpriteX[WH2] := (319 - SpriteSIZEX[IH2]) Div 2;
      SpriteY[WH2] := 075;
      WH3 := GetFreeNNr;
      SpriteN[WH3] := IH3;
      SpriteX[WH3] := (319 - SpriteSIZEX[IH3]) Div 2;
      SpriteY[WH3] := 130;

      Animate;

      FadeToPalette(HPal, 40);

      (* Warte auf Taste oder Maustaste: *)
      __Space := FALSE;
      While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
      Repeat Until KeyPressed Or __Space;(* Auf Tastendruck warten. *)
      __Space := FALSE;

      (* Bei 'ESC' beenden: *)
      If KeyPressed Then
       If (ReadKey = #27) Then
        If AskExit Then                 (* Wenn 'ESC', Spiel beenden. *)
         Begin
          TellPassword := 1;

      	  FreeSpriteMem(IH1);
	  FreeSpriteMem(IH2);
	  FreeSpriteMem(IH3);

	  SpriteN[WH1] := 0;            (* MöSSEN wieder dereferenziert *)
	  SpriteN[WH2] := 0;            (* werden, sonst ABSTURTZ !     *)
	  SpriteN[WH3] := 0;

	  Exit;
         End;

      FadeToPalette(ZeroColors, 40);
      While KeyPressed Do ReadKey;      (* Tastaturpuffer lîschen. *)

      FreeSpriteMem(IH1);
      FreeSpriteMem(IH2);
      FreeSpriteMem(IH3);

      SpriteN[WH1] := 0;                (* MöSSEN wieder dereferenziert *)
      SpriteN[WH2] := 0;                (* werden, sonst ABSTURTZ !     *)
      SpriteN[WH3] := 0;

      (* Wieder zurÅck: *)
      WaitVRetrace;
      ChangePage(_Page);
     End;

    Function PauseGame : Word;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : LÑsst ein Passwort eingeben und ÅberprÅft dieses.     *)
     (* RÅckgabe : 1 = Mit ESC abgebrochen.                              *)
     (* ---------------------------------------------------------------- *)
     Var SH1, SH2    : String;
	 WH1, WH2    : Word;
	 IH1, IH2    : Integer;
	 SaveSprites : Array[0..NMAX] Of Word;
         PH1         : Word;
     Begin
      PauseGame := 0;
      FadeToPalette(ZeroColors, 40);

      (* Sprites erstellen und positionieren: *)
      IH1 := GetFreeLoadNr;
      MakeTextSprite('GAME PAUSED'    , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
      IH2 := GetFreeLoadNr;
      MakeTextSprite('PRESS ANY KEY !', 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 1{FntNr});

      WH1 := GetFreeNNr;
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 074;
      WH2 := GetFreeNNr;
      SpriteX[WH2] := (319 - SpriteSIZEX[IH2]) Div 2;
      SpriteY[WH2] := 110;

      SpriteN[WH1] := 0;                (* Gleich wieder weg. *)

      (* Seite 3 kopieren, dann lîschen: *)
      GetImage(PH1, BackGroundPage, 0, 0, XMAX+1, YMAX+1);
      WaitVRetrace;
      ClrScreen(0, BackGroundPage);

      (* Alle Sprites freigeben, dabei merken, welche: *)
      Move(SpriteN, SaveSprites, SizeOf(SaveSprites));
      FillChar(SpriteN, SizeOf(SpriteN), 0);
      SpriteN[WH1] := IH1;
      SpriteN[WH2] := IH2;
      WaitVRetrace;

      Animate;
      FadeToPalette(HPal, 40);

      (* Warte auf Taste oder Maustaste: *)
      __Space := FALSE;
      While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
      Repeat Until KeyPressed Or __Space;(* Auf Tastendruck warten. *)
      __Space := FALSE;

      (* Freigegebene Sprites wieder besetzen: *)
      WaitVRetrace;
      Move(SaveSprites, SpriteN, SizeOf(SpriteN));

      FadeToPalette(ZeroColors, 40);
      While KeyPressed Do ReadKey;      (* Tastaturpuffer lîschen. *)

      (* Seite 3 wieder besetzen: *)
      PutImage(PH1, BackGroundPage, 0, 0, TRUE);

      SpriteN[WH1] := 0;
      SpriteN[WH2] := 0;

      FreeSpriteMem(IH1);
      FreeSpriteMem(IH2);

      (* Wieder zurÅck: *)
      WaitVRetrace;
      ChangePage(_Page);
      Animate;
      FadeToPalette(HPal, 40);
     End;

    Function EXELevel(ANr : Word) : Word;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : FÅhrt einen Level aus.                                *)
     (* Eingabe  : ANR   = Nummer des Levels in LevelN[..].              *)
     (* RÅckgabe : 0        = Level gewonnen,                            *)
     (*            1        = Mit ESC abgebrochen.                       *)
     (*            2        = Level verloren, weil Zeit zuende.          *)
     (*            100 + xx = Passwort fÅr Level xx eingegeben (1<X<30). *)
     (* ---------------------------------------------------------------- *)
     Var WH1, WH2    : Word;
	 IH1, IH2    : Integer;
	 SH1, SH2    : String;
	 BH1         : Byte;
	 Cheat       : Boolean;
	 Code        : Integer;                 (* FÅr 'VAL(..);'. *)
     Begin
      Cheat := False;

      ClrScreen(0, BackGroundPage);

      (* Bild zeigen: *)
      If ANr In [6, 12, 18, 24, 30] Then PutImage(BackPics[2], BackGroundPage, 0, 0, FALSE)
      Else PutImage(BackPics[1], BackGroundPage, 0, 0, FALSE);

      (* Cursor eintragen: *)
      SetCursor(1, 1);

      (* Blinkring eintragen: *)
      RegisterBlinkRing({BlinkringLoadNr}21);
      SpriteN[BlinkRingN] := 1;         (* Als belegt kennzeichnen, damit *)
					(* nicht Åberschrieben.           *)

      (* Level aktivieren: *)
      AktivateLevel(ANr);
      SpriteX[CursorN] := FieldOriginX;
      SpriteY[CursorN] := FieldOriginY;

      (* -------------------------- *)
      (* Ab hier:                   *)
      (*                            *)
      (* Alles, was nur einmal      *)
      (* gezeichnet werden mu·,     *)
      (* erst als Sprite erstellen, *)
      (* dann auf Hintergrundseite  *)
      (* kopieren und dann wieder   *)
      (* aus SpriteN[..] lîschen.   *)

      (* Kleinen Rahmen zeichnen: *)
      WH1 := GetFreeNNr;
      SpriteN[WH1] := 31;
      SpriteX[WH1] := 0;
      SpriteY[WH1] := 125;
      FilledRectangle(0, 0, 125, SpriteSIZEX[31]-1, 125+SpriteSIZEY[31]-1, BackGroundPage);
      CopySpritesToBkgPage(31, 31);
      SpriteN[WH1] := 0;

      (* Namen einsetzen: *)
      SH1 := ''; SH2 := '';
      BH1 := Pos(' ', FieldInfoName) Or Pos('-', FieldInfoName);
      If BH1 <> 0 Then
       Begin
	SH1 := Copy(FieldInfoName, 001, BH1-1);
	SH2 := Copy(FieldInfoName, BH1+1, Length(FieldInfoName)-BH1);
       End
      Else SH1 := FieldInfoName;

      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite(SH1 , 167{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (76 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 137;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      If SH2 <> '' Then                 (* Wenn 2 Zeilen Text. *)
       Begin
	WH1 := GetFreeNNr;
	IH1 := GetFreeLoadNr;
	MakeTextSprite(SH2 , 167{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
	SpriteN[WH1] := IH1;
	SpriteX[WH1] := (76 - SpriteSIZEX[IH1]) Div 2;
	SpriteY[WH1] := 143;
	CopySpritesToBkgPage(IH1, IH1);
	FreeSpriteMem(IH1); SpriteN[WH1] := 0;
       End;

      (* Kleine Atome einsetzen: *)
      InsertSmallAtoms;
      CopySpritesToBkgPage(SmallStart, SmallEnde);
      ClearSpritesFromSpriteN(SmallStart, SmallEnde);

      (* Spieler 1 schreiben: *)
      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite('PLAYER 1' , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 4{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (SpriteSIZEX[31]-SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 007;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      (* Spieler 2 schreiben: *)
      If NrOfPlayers = 2 Then
       Begin
	WH1 := GetFreeNNr;
	IH1 := GetFreeLoadNr;
	MakeTextSprite('PLAYER 2' , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 4{FntNr});
	SpriteN[WH1] := IH1;
	SpriteX[WH1] := (SpriteSIZEX[31]-SpriteSIZEX[IH1]) Div 2;
	SpriteY[WH1] := 037;
	CopySpritesToBkgPage(IH1, IH1);
	FreeSpriteMem(IH1); SpriteN[WH1] := 0;
       End;

      (* 'Level' schreiben: *)
      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite('LEVEL' , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 4{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := 3;
      SpriteY[WH1] := 067;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      (* Levelnummer: *)
      WH2 := GetFreeNNr;                (* MUSS (!) WH2 sein, damit X-Wert korrekt berechnet werden kann (4 Zeilen unten). *)
      IH2 := GetFreeLoadNr;             (* MUSS (!) IH2 sein, damit X-Wert korrekt berechnet werden kann (4 Zeilen unten). *)
      Str(ANr:2, SH1);
      MakeTextSprite(SH1, 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 5{FntNr});
      SpriteN[WH2] := IH2;
      SpriteX[WH2] := SpriteX[WH1] + SpriteSIZEX[IH1] + 20;
      SpriteY[WH2] := SpriteY[WH2];
      CopySpritesToBkgPage(IH2, IH2);
      FreeSpriteMem(IH2); SpriteN[WH2] := 0;

      (* 'Time' schreiben: *)
      If UseTime Then
       Begin
	SetTimeBase(TimeSek[ANr] Div 60, TimeSek[ANr] Mod 60);

	WH1 := GetFreeNNr;
	IH1 := GetFreeLoadNr;
	MakeTextSprite('TIME', 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 4{FntNr});
	SpriteN[WH1] := IH1;
	SpriteX[WH1] := (SpriteSIZEX[31]-SpriteSIZEX[IH1]) Div 2;
	SpriteY[WH1] := 092;
	CopySpritesToBkgPage(IH1, IH1);
	FreeSpriteMem(IH1); SpriteN[WH1] := 0;

	(* Zeit schreiben: *)
	Str((Time Div 60):1, SH1);       (* Minuten. *)
	Str((Time Mod 60)  , SH2);       (* Sekunden. *)
	If Length(SH2) = 1 Then SH2 := '0' + SH2;
	SH1 := SH1 + ':' + SH2;

	Val(SH1[1], TimeParts[1], Code);
	Val(SH1[3], TimeParts[3], Code);
	Val(SH1[4], TimeParts[4], Code);

	TimeSpriteN[1] := GetFreeNNr;   (* Minuten. *)
	SpriteN[TimeSpriteN[1]] := TimeNumbers[TimeParts[1]];
	SpriteX[TimeSpriteN[1]] := 010;
	SpriteY[TimeSpriteN[1]] := 102;

	TimeSpriteN[2] := GetFreeNNr;  (* Doppelpunkt ':'. *)
	SpriteN[TimeSpriteN[2]] := TimeDoublePnt;
	SpriteX[TimeSpriteN[2]] := 025;
	SpriteY[TimeSpriteN[2]] := 102;

	TimeSpriteN[3] := GetFreeNNr;   (* 10er Sekunden. *)
	SpriteN[TimeSpriteN[3]] := TimeNumbers[TimeParts[3]];
	SpriteX[TimeSpriteN[3]] := 040;
	SpriteY[TimeSpriteN[3]] := 102;

	TimeSpriteN[4] := GetFreeNNr;   (* 1er Sekunden. *)
	SpriteN[TimeSpriteN[4]] := TimeNumbers[TimeParts[4]];
	SpriteX[TimeSpriteN[4]] := 055;
	SpriteY[TimeSpriteN[4]] := 102;
       End;                             (* Von 'IF TIME'. *)

      (* Ende von: auf Hintergrund- *)
      (* seite schreiben.           *)
      (*                            *)
      (* -------------------------- *)

      (* Punktezahl: *)
      FreeSpriteMem(ScoreSprLOAD[1]);   (* Alte ggf. freigeben. *)
      FreeSpriteMem(ScoreSprLOAD[2]);
      MakeScores(TRUE);

      (* Zykluszeit auf SpriteAnzahl anpassen, so da· immer gleiche *)
      (* Geschwindigkeit:                                           *)
      If (30-CountSpriteN*3) > 0 Then SetCycleTime(30-CountSpriteN*3)
      Else SetCycleTime(0);

      Moved := 0;
      TestMolekuel(TRUE);                (* PWINChk belegen. *)

      (* BlinkRing-Dummy wieder freigeben: *)
      SpriteN[BlinkRingN] := 0;         (* Wieder derefrenzieren. *)

      SetPalette(ZeroColors);
      Animate;
      FadeToPalette(HPal, 60);

      InstallTrap;                      (* Tastatur-Handler. *)

      (* Maus-Cursor platzieren auf (0|0): *)
      If MAUSAKTIV Then
       Begin
        Asm
         mov   ax, 4h
         mov   cx, 0
         mov   dx, 0
         int   33h
        End;

        (* Position der Maus ermitteln: *)
        Regs.AX := $000B;
        Intr($33, Regs);
       End;

      (*ƒƒƒƒƒƒƒƒƒƒƒƒ Hauptschleife: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

      While 1 = 1 Do Begin
       Animate;                     (* HAUPT-ANIMATION. *)

       (* Zeit schreiben: *)
       If UseTime Then
	Begin
	 Str((Time Div 60):1, SH1);     (* Minuten. *)
	 Str((Time Mod 60)  , SH2);     (* Sekunden. *)
	 If Length(SH2) = 1 Then SH2 := '0' + SH2;
	 SH1 := SH1 + ':' + SH2;

	 Val(SH1[1], TimeParts[1], Code);
	 Val(SH1[3], TimeParts[3], Code);
	 Val(SH1[4], TimeParts[4], Code);

	 SpriteN[TimeSpriteN[1]] := TimeNumbers  [TimeParts[1]];(* Minuten. *)
	 SpriteN[TimeSpriteN[3]] := TimeNumbers  [TimeParts[3]];(* 10er Sekunden. *)
	 SpriteN[TimeSpriteN[4]] := TimeNumbers  [TimeParts[4]];(* 1er Sekunden. *)
	End;

       (* Bewege, Wenn <> 0: *)
       If Boolean(Moved) Then MoveAktivSprite(Moved, Fact);

       (* Verloren: *)
       If UseTime And (Time = 0) Then   (* Verloren. *)
	Begin
	 StopTimeInt;
         UnInstallTrap;                 (* Tastatur-Handler. *)
	 FreeLevel;                     (* Alle Atome weg. *)

	 (* Nur verloren, wenn KEIN Bonuslevel: *)
	 If Not (ANr In [6, 12, 18, 24, 30]) Then
	  Begin
	   Lost;                        (* Ausgabe: 'Verloren'. *)
	   ExeLevel := 2;
	  End
	 Else
	  Begin
	   If (ANr Mod PassDist) = 0 Then(* Alle PASSDIST. Level 1 Passwort. *)
            If TellPassword(ANr) = 1 Then ExeLevel := 1
	   Else ExeLevel := 0;
	  End;

	 While KeyPressed Do ReadKey;   (* Tastaturpuffer lîschen. *)

	 Exit;
	End;

       If Moved = 0 Then                (* MolekÅl nur testen, wenn sich nichts bewegt. *)
	(* Gewonnen: *)
        If TestMolekuel(FALSE) Or (Cheat And UseCheat) Then
	 Begin                          (* Wenn MolekÅl fertig. *)
	  If UseTime Then StopTimeInt;
          UnInstallTrap;                (* Tastatur-Handler. *)
	  Won;
	  Ch := #0;
	  ExeLevel := 0;

	  While KeyPressed Do ReadKey;  (* Tastaturpuffer lîschen. *)

	  Break;
	 End;

       (* EVENT-HANDLER: *)
       If __Left Then
        Begin
         __Left := FALSE;
         If AktivSpriteC Then
          Begin
           If (Moved And 4 = 0) Then Moved := Moved Or 1;
          End
	 Else If Moved = 0 Then Moved := 1;
        End;

       If __Right Then
        Begin
         __Right := FALSE;
         If AktivSpriteC Then
          Begin
           If (Moved And 1 = 0) Then Moved := Moved Or 4;
          End
	 Else If Moved = 0 Then Moved := 4;
        End;

       If __Up Then
        Begin
         __Up := FALSE;
         If AktivSpriteC Then
          Begin
           If (Moved And 8 = 0) Then Moved := Moved Or 2;
          End
	 Else If Moved = 0 Then Moved := 2;
        End;

       If __Down Then
        Begin
         __Down := FALSE;
         If AktivSpriteC Then
          Begin
           If (Moved And 2 = 0) Then Moved := Moved Or 8;
          End
	 Else If Moved = 0 Then Moved := 8;
        End;

       If __F1 Then
        Begin
         __F1 := False;
	 If UseTime Then StopTimeInt;
         UnInstallTrap;       (* Tastatur-Handler. *)
	 WH1 := EnterPassword;
	 If (WH1 <> 0) And (WH1 <> ANr) Then
	  Begin               (* Passwort richtig: *)
	   SetPalette(ZeroColors);
	   ExeLevel := 100 + WH1;
	   SpriteN[BlinkRingN] := 0;
	   FreeLevel;

	   Exit;
	  End
 	 Else                 (* Passwort falsch: *)
	  Begin
	   If UseTime Then SetTimeBase(Time Div 60, Time Mod 60);
           InstallTrap;       (* Tastatur-Handler. *)
	  End;
	 End;

       If (__F10) And (__Shift) Then
        Begin
         __F10 := False;
         If UseCheat Then Cheat := TRUE;
        End;

       If __Stop Then
        Begin
         __Stop := False;
 	 If UseTime Then StopTimeInt;
         UnInstallTrap;                 (* Tastatur-Handler. *)
         If AskExit Then                (* ESC. *)
          Begin
           ExeLevel := 1;
       	   Exit;
          End
         Else                           (* Nicht aufhîren. *)
          Begin
	   If UseTime Then SetTimeBase(Time Div 60, Time Mod 60);
           InstallTrap;                 (* Tastatur-Handler. *)
          End;
        End;

       If __Space Then
        Begin
         __Space := False;
         If Moved = 0 Then      (* SPACE. *)
          If AktivSpriteC Then FocusAtomAtCursor
   	  Else ReleaseAktivAtom;
        End;

       If __Pause Then
        Begin
         __Pause := False;
         If UseTime Then StopTimeInt;
         UnInstallTrap;        (* Tastatur-Handler. *)
         PauseGame;
 	 If UseTime Then SetTimeBase(Time Div 60, Time Mod 60);
         InstallTrap;          (* Tastatur-Handler. *)
        End;
      End;                              (* Von "WHILE". *)

      If UseTime Then StopTimeInt;
      UnInstallTrap;                    (* Tastatur-Handler. *)

      FadeToPalette(ZeroColors, 60);
      FreeLevel;

      (* Passwort mitteilen: *)
      If (ANr Mod PassDist) = 0 Then    (* Alle PassDist. Level 1 Passwort. *)
       If TellPassword(ANr) = 1 Then ExeLevel := 1;
     End;

    Procedure WholeGameWon;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : Zeigt Bild, da· man gesamtes Spiel gewonnen hat.      *)
     (* ---------------------------------------------------------------- *)
     Var WH1, WH2   : Word;
	 IH1, IH2   : Integer;
     Begin
      (* Bildschirm vorbereiten: *)
      SetPalette(ZeroColors);
      ClrScreen(0, BackGroundPage);

      (* Sprites erstellen und positionieren: *)
      IH1 := GetFreeLoadNr;
      MakeTextSprite('CONGRATULATIONS !'      , 1{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 1{FntNr});
      IH2 := GetFreeLoadNr;
      MakeTextSprite('YOU WON !'              , 1{C}, 1{Dis}, 1{Ori}, IH2{SprLNr}, 1{FntNr});

      WH1 := GetFreeNNr;
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 074;
      WH2 := GetFreeNNr;
      SpriteN[WH2] := IH2;
      SpriteX[WH2] := (319 - SpriteSIZEX[IH2]) Div 2;
      SpriteY[WH2] := 110;

      Animate;

      FadeToPalette(HPal, 40);

      (* Warte auf Taste oder Maustaste: *)
      __Space := FALSE;
      While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
      Repeat Until KeyPressed Or __Space;(* Auf Tastendruck warten. *)
      __Space := FALSE;

      FadeToPalette(ZeroColors, 40);

      FreeSpriteMem(IH1);
      FreeSpriteMem(IH2);

      SpriteN[WH1] := 0;                (* MöSSEN wieder dereferenziert *)
      SpriteN[WH2] := 0;                (* werden, sonst ABSTURTZ !     *)

      (* Wieder zurÅck: *)
      WaitVRetrace;
      ChangePage(_Page);

      ClrScreen(0, {_Page}1-_Page);
     End;


    Procedure EndGame;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : Beendet das gesamte Spiel.                            *)
     (* ---------------------------------------------------------------- *)
     Begin
      If UseTime Then StopTimeInt;
      UnInstallTrap;                    (* Tastatur-Handler. *)
      WaitHRetrace;
      SetPalette(ZeroColors);
     End;

    Function AtomixIntro : Integer;
     (* ---------------------------------------------------------------- *)
     (* Aufgabe  : Titelbild, Einleitung, usw.                           *)
     (* RÅckgabe : 0 = Normal beendet,                                   *)
     (*            1 = Mit ESC beendet.                                  *)
     (* ---------------------------------------------------------------- *)
     Var WH1    : Word;
	 IH1    : Integer;
         PFarbe : Pointer;
         Farbe  : TPalette;
         Count  : Integer;
     Begin
      AtomixIntro := 0;

      (* Bildschirm vorbereiten: *)
      SetPalette(ZeroColors);
      PFarbe := LoadPCXPic('ATOMI3.PCX', BackGroundPage, TRUE, FALSE);
      If PFarbe <> Nil Then Move(PFarbe^, Farbe, SizeOf(Farbe))
       Else Move(HPal, Farbe, SizeOf(Farbe));

      (* Sprites erstellen: *)

      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite('VERSION 1.0', 254{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2 + 3;
      SpriteY[WH1] := 100 + 3;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite('VERSION 1.0', 126{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 100;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite('(C) SEPTEMBER 1994 UWE KEIM', 254{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2 + 3;
      SpriteY[WH1] := 180 + 3;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      WH1 := GetFreeNNr;
      IH1 := GetFreeLoadNr;
      MakeTextSprite('(C) SEPTEMBER 1994 UWE KEIM', 126{C}, 1{Dis}, 1{Ori}, IH1{SprLNr}, 2{FntNr});
      SpriteN[WH1] := IH1;
      SpriteX[WH1] := (319 - SpriteSIZEX[IH1]) Div 2;
      SpriteY[WH1] := 180;
      CopySpritesToBkgPage(IH1, IH1);
      FreeSpriteMem(IH1); SpriteN[WH1] := 0;

      Animate;

      (* VOC-Sound laden: *)
      LoadVOCFile('LAUGHTER.VOC', 1);

      (* Aufblenden: *)
      FadeToPalette(Farbe, 40);

      (* VOC-Sound abspielen: *)
      If (VOC_Possible And VOC_On) Then PlayVOCFile(1);

      (* Warte auf Taste oder Maustaste: *)
      __Space := FALSE;
      While KeyPressed Do ReadKey;       (* Ggf. Tastaturpuffer lîschen. *)
      For Count := 1 To 50 Do
       Begin
        If KeyPressed Or __Space Then Break;
        Delay(100);
       End;
      __Space := FALSE;

      If KeyPressed Then Case ReadKey Of
       #27 : Begin
	      AtomixIntro := 1;         (* 'ESC'. *)
              FadeToPalette(ZeroColors, 40);
              If (VOC_Possible And VOC_On) Then StopVOCIO;
              FreeVOCMem(1);            (* VOC-Sound freigeben. *)

	      Exit;
	     End;
       End;

      FadeToPalette(ZeroColors, 40);
      If (VOC_Possible And VOC_On) Then StopVOCIO;
      FreeVOCMem(1);                    (* VOC-Sound freigeben. *)

      While KeyPressed Do ReadKey;      (* Tastaturpuffer lîschen. *)
     End;

    BEGIN                               (* MAIN. *)
     (* ---------------------------------------------------------------- *)

     (* Daten laden: *)
     LoadingSequence;

     (* Intro: *)
     If AtomixIntro = 1 Then
      Begin
       EndGame;
       Exit;
      End;

     (* Hintergrundbild laden: *)
     LoadPCXPic('ATOMI1.PCX', 3{_Page}, FALSE, FALSE);
     GetImage(BackPics[1], 3{_Page}, 0, 0, XMAX+1, YMAX+1);

     LoadPCXPic('ATOMI2.PCX', 3{_Page}, FALSE, FALSE);
     GetImage(BackPics[2], 3{_Page}, 0, 0, XMAX+1, YMAX+1);

     (* Musik laden und spielen: *)
     LoadHSCFile('ATOMIX.HSC', 1);
     If (HSC_Possible And HSC_On) Then PlayHSCFile(1);

     (* Einzelne Levels: *)
     IH1 := 1;
     While IH1 <= 30 Do
      Begin
       WH1 := EXELevel(IH1);

       If WH1 In [1, 2] Then
	Begin
         If (HSC_Possible And HSC_On) Then DoneHSCPlay; (* Musik anhalten. *)
         If (VOC_Possible And VOC_On) Then StopVOCIO;
         ScoreList;
	 EndGame;
	 Exit;
	End

       Else If WH1 > 100 Then
	Begin
	 WH1 := WH1 - 100;
	 IH1 := WH1;
	 Dec(IH1);                      (* Weil gleich wieder INC(IH1). *)
	End;

       Inc(IH1);

       (* Gesamtes Spiel gewonnen ?: *)
       If (IH1 >  30) And (WH1 = 0) Then
	Begin
         If (HSC_Possible And HSC_On) Then DoneHSCPlay;     (* Musik anhalten. *)
         If (VOC_Possible And VOC_On) Then StopVOCIO;
	 WholeGameWon;
         ScoreList;
	 EndGame;
	 Exit;
	End;
      End;
    If (HSC_Possible And HSC_On) Then DoneHSCPlay;     (* Musik anhalten. *)
    If (VOC_Possible And VOC_On) Then StopVOCIO;
   End;

   PROCEDURE Init;
    (* ---------------------------------------------------------------- *)
    Var Delay, Speed : Integer;
        BH1          : Byte;
        SH1          : String;
    Begin
     TestAllFiles;

     (* Fehler-Routinen einfÅgen: *)

     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(Done);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(ATOMIXGetErrorMessage);

     {$IFDEF ONEFILE}
     AssignMAIN(F, 'ATOMIX.DAT');
     ResetMAIN(F);
     {$ENDIF}

     ParseINIFile;                      (* Mu· VOR VOHSInitRoutines stehen. *)

     (* NACH (!!!) OneFile, CT-VOICE & Co. intialisieren: *)
     If VOC_Possible Or HSC_Possible Then VOHSInitRoutines;

     ERR_Error := ERR_Error_Ok;

     (* Grafik initialisieren: *)
     SetStaticBackgroundMode(VRAM);
     SetBackgroundMode(STATIC);
     Init256N;

     SetUpMausAndHandler;

     Delay := 0;
     Speed := 0;
     SetTypmRate(Delay, Speed);

     (* Felder mit definiertem Startwert fÅllen: *)
     FillChar(WALLFieldL, SizeOf(WALLFieldL), 0);

     FillChar(ATOMFieldL, SizeOf(ATOMFieldL), 0);
     FillChar(ATOMFieldN, SizeOf(ATOMFieldN), 0);

     FillChar(WINField,  SizeOf(WINField),  0);

     FillChar(LevelN, SizeOf(LevelN), 0);
     FillChar(LevelMEMSIZE, SizeOf(LevelMEMSIZE), 0);

     Ticks := 0;
     Time  := 0;
     TimeIntAktiv := False;

     SearchDirection := Up;

     (* Testen, ob CHEAT oder TIME an / aus: *)
     BH1 := 1;
     While BH1 <= ParamCount Do
      Begin
       If ParamStr(BH1) = CheatString Then UseCheat := TRUE
       Else If ParamStr(BH1) = TimeString Then UseTime := FALSE;
       Inc(BH1);
      End;

     (* Testen, ob genug Speicher: *)
     If MemAvail < HeapMemNeeded Then
      Begin
       ERR_Error := ATO_Error_NoEnoughHeapMem;
       Str(HeapMemNeeded-MemAvail, SH1);
       CriticalError(SH1);
      End;

     (* JETZT (!!) alten INT 9h auslesen: *)
     GetIntVec($09, @OldInt9);
    End;

   PROCEDURE Done;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Alles was auf HEAP noch liegt mu· NICHT freigegeben werden, *)
     (* Da TURBO-PASCAL ja alles wieder an DOS freigibt.            *)

     (* Ggf. Maus deaktivieren: *)
     CloseUpMausAndHandler;

     {$IFDEF ONEFILE}
     CloseMAIN(F);
     {$ENDIF}
    End;

   PROCEDURE ParseINIFile;
    (* ---------------------------------------------------------------- *)
    Var SH1  : String;
        IH1  : Integer;
        Code : Integer;
    Begin
     OpenINIFile('ATOMIX.INI');

     HSC_Possible := FALSE;
     VOC_Possible := FALSE;

     If ExistsGroup('[Soundblaster]') Then
      Begin
       SH1 := GetString('[Soundblaster]', 'DMA');
       If SH1 <> '' Then
        Begin
         Val(SH1, IH1, Code);
         If Code = 0 Then DMA_Chanel := IH1;
        End;

       SH1 := GetString('[Soundblaster]', 'IRQ');
       If SH1 <> '' Then
        Begin
         Val(SH1, IH1, Code);
         If Code = 0 Then IRQ_Number := IH1;
        End;

       SH1 := GetString('[Soundblaster]', 'PORT');
       If SH1 <> '' Then
        Begin
         If SH1[1] <> '$' Then SH1 := '$' + SH1;
         Val(SH1, IH1, Code);
         If Code = 0 Then IO_Port := IH1;
        End;

       (* Ist Åberhaupt SB vorhanden ? (Mu· als LETZTES getestet werden): *)
       SH1 := GetString('[Soundblaster]', 'TYP');
       If SH1 <> '' Then
        If UpString(SH1) <> 'NONE' Then
         Begin
          HSC_Possible := TRUE;
          VOC_Possible := TRUE;
         End;
      End;

     SH1 := GetString('[Musik]', 'Musik');
     If SH1 <> '' Then
      Begin
       If UpString(SH1) = 'AN' Then HSC_On := TRUE
       Else                         HSC_On := FALSE;
      End
     Else HSC_On := FALSE;

     SH1 := GetString('[Sound-Effekte]', 'Sound');
     If SH1 <> '' Then
      Begin
       If UpString(SH1) = 'AN' Then VOC_On := TRUE
       Else                         VOC_On := FALSE;
      End
     Else VOC_On := FALSE;

     SH1 := GetString('[HighScore]', 'Schreibe_HighScore');
     If SH1 <> '' Then
      Begin
       If UpString(SH1) = 'AN' Then Write_HighScore := TRUE
       Else                         Write_HighScore := FALSE;
      End
     Else Write_HighScore := FALSE;

     CloseINIFile;
    End;

  (* ƒƒ HAUPTPROGRAMM: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   BEGIN
    Init;
    Main;
    Done;
    CallAllErrorProcs;                  (* Darf NICHT in "Done" stehen, da *)
                                        (* sonst Rekursion.                *)
   END.

 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)