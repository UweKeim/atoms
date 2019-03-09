 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)
 (*  Programm : UWEVOHS1                                                   *)
 (*             Player fÅr Sound-Blaster VOC-Dateien mit Hilfe des Treiber *)
 (*             "CT-VOICE.DRV"                                             *)
 (*             UND (!)                                                    *)
 (*             Player von HSC-Dateien mit Hilfe der Unit "ADVHSC.TPU".    *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UWEVOHS1.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 11. Februar 1995                                           *)
 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

 UNIT UweVOHS1;

  {$A-,B-,E+,F+,G+,I-,N+,O-,P-,Q-,R-,S-,T-,V-,X+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE ONEFILE}                     (* Ob alles aus 1 gro·en Datei gelesen wird. *)
  {$undef  ONHARDWAREERRORSTOP}         (* Ob bei z.B. falschem Port gestoppt *)
                                        (* wird, oder ob einfach globaler     *)
                                        (* Schalter auf aus gestellt wird.    *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ELSE}
  {$D-,L-,Y-}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- ôFFENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   USES UweERR01

        {$IFDEF ONEFILE}
        ,
        ONEFile1;
        {$ELSE}
        ;
        {$ENDIF}

   (* ƒƒ Verschiedene ErklÑrungen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ----------------------------------------------------------- *)
   (*  Hinweis : Es sind hier keine Routinen mehr zur Erkennung   *)
   (*            und Einstellung der SB-Konfiguration vorhanden;  *)
   (*            diese sind separat in Unit "CFGSB01.PAS".        *)
   (*                                                             *)
   (*  Ein einbindendes Programm mu· am Anfang die Zeilen         *)
   (*                                                             *)
   (*   "VOCInitRoutines;"                                        *)
   (*                                                             *)
   (*  stehen haben, damit der VOC-Treiber geladen wird.          *)
   (*  Dies kann aber NICHT HIER in der Init-Routine geschehen,   *)
   (*  da, wenn ONEFILE benutzt wird, dieser ja noch nicht offen  *)
   (*  ist und erst vom einbindenden Prog. geîffnet werden mu·.   *)
   (* ----------------------------------------------------------- *)

   (* ƒƒ Verschiedene Konstanten, Variablen, Typen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

         (* VOC-Treiber: *)
   CONST VOCDriverFile       = 'CT-VOICE.DRV';

         (*  Anfangs-LautstÑrke: *)
         DefaultVolume       = 7;       (* FÅr alles (VOC, FM, MAIN). *)

         (* Vordefinierte Standard-Werte: *)
   CONST IO_Port             : Word = $220;     (* IO-Port-Adresse. *)
         IRQ_Number          : Word = 7;        (* Nummer des IRQs. *)
         DMA_Chanel          : Word = 1;        (* Nummer des DMA-Kanals. *)
         SB_Type             : Byte = 1;        (* 1 = SB normal. *)

         (* VOC-Felder: *)
   CONST VOCMAX              = 10;      (* Maximale Anzahl an VOC-Sounds. *)

   VAR   VOCN                : Array[0..VOCMAX] Of Pointer;
                                        (* EnthÑlt Zeiger auf VOC-Sounds. *)
         VOCSize             : Array[0..VOCMAX] Of Word;
         VOCMode             : Array[0..VOCMAX] Of Byte;
         VOCSampleRate       : Array[0..VOCMAX] Of Word;

         (* HSC-Felder: *)
   CONST HSCMAX              = 1;       (* Maximale Anzahl an HSC-Sounds. *)

   VAR   HSCN                : Array[0..HSCMAX] Of Pointer;
                                        (* EnthÑlt Zeiger auf HSC-Sounds. *)
         HSCSize             : Array[0..HSCMAX] Of Word;
         HSCMode             : Array[0..HSCMAX] Of Byte;
         HSCSampleRate       : Array[0..HSCMAX] Of Word;

         (* Globale Schalter: *)
   CONST HSC_Possible        : Boolean = TRUE;  (* Ob HSC-Musik Åberhaupt mîglich. *)
         VOC_Possible        : Boolean = TRUE;  (* Ob VOC-Sounds Åberhaupt mîglich. *)

   (* ƒƒ Prototypen der Prozeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ∞∞ SYSTEM-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE VOHSInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles Nîtige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE VOHSCloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgemÑ·.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION VOHSGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.  *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                            *)
    (*             AS        = Eventueller zusÑtzlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  RÅckgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

   (* ∞∞ VOC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE LoadVOCFile(AFName : String; ANr : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : LÑdt aus einer VOC-Datei 1 oder mehrere Samples      *)
    (*             in den Speicher.                                     *)
    (*  Eingabe  : AFNAME = VollstÑndiger Dateiname mit Extension,      *)
    (*             ANR    = Nummer im VOCN[..]-Feld, an die geladen     *)
    (*                      werden soll.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PlayVOCFile(ANr : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Spielt ein VOC-Sound ab.                             *)
    (*  Eingabe  : ANR = Nummer im VOCN[..]-Feld.                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE DoneVOCPlay;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet das Ausgeben von VOC-Sounds.                 *)
    (*  Hinweise : Es wird alles abgeschlossen,                         *)
    (*             Speicher fÅr die VOC-Sounds wird freigegeben         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE VOCUserRoutine(APtr : Pointer);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt eine Routine ein, die an jedem Anfang eines    *)
    (*             untergeordneten Datenblocks aufgerufen wird.         *)
    (*  Eingabe  : APTR = Zeiger auf Benutzerroutine.                   *)
    (*  Hinweis  : FÅr Programmier-Details siehe "Das SB Buch", S. 295. *)
    (* ---------------------------------------------------------------- *)

   FUNCTION VOCVolume(AWert, AKanal : Word) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt die LautstÑrke fÅr die VOC-Ausgabe (DSP-Chip)  *)
    (*             fest.                                                *)
    (*  Eingabe  : AWERT  = LautstÑrke-Wert, [0..15],                   *)
    (*             AKANAL = Kanal. 0 = Linker Kanal (wenn Stereo),      *)
    (*                             1 = Rechter Kanal (wenn Stereo).     *)
    (*                             Wenn Mono, 1 (?) eingeben.           *)
    (*  RÅckgabe : TRUE   = Alles OK,                                   *)
    (*             FALSE  = Fehler aufgetreten.                         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FreeVOCMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt den Speicher eines VOC-Sounds frei.              *)
    (* Eingabe  : ANR = Nummer des Sounds im VOCN[..]-Feld.             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE StopVOCIO;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet Abspielen oder Aufnehmen eines VOC-Blocks.   *)
    (* ---------------------------------------------------------------- *)

   (* ∞∞ HSC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE LoadHSCFile(AFName : String; ANr : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : LÑdt aus einer HSC-Datei 1 oder mehrere Samples      *)
    (*             in den Speicher.                                     *)
    (*  Eingabe  : AFNAME = VollstÑndiger Dateiname mit Extension,      *)
    (*             ANR    = Nummer im HSCN[..]-Feld, an die geladen     *)
    (*                      werden soll.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PlayHSCFile(ANr : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Spielt ein HSC-Sound ab.                             *)
    (*  Eingabe  : ANR = Nummer im HSCN[..]-Feld.                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE DoneHSCPlay;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet das Ausgeben von HSC-Sounds.                 *)
    (*  Hinweise : Es wird alles abgeschlossen,                         *)
    (*             Speicher fÅr die HSC-Sounds wird freigegeben         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE HSCUserRoutine(APtr : Pointer);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt eine Routine ein, die an jedem Anfang eines    *)
    (*             untergeordneten Datenblocks aufgerufen wird.         *)
    (*  Eingabe  : APTR = Zeiger auf Benutzerroutine.                   *)
    (*  Hinweis  : FÅr Programmier-Details siehe "Das SB Buch", S. 295. *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE HSCVolume(AWert, AKanal : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt die LautstÑrke fÅr die HSC-Ausgabe fest.       *)
    (*  Eingabe  : AWERT  = LautstÑrke-Wert, [0..15],                   *)
    (*             AKANAL = Kanal. 0 = Linker Kanal (wenn Stereo),      *)
    (*                             1 = Rechter Kanal (wenn Stereo).     *)
    (*                             Wenn Mono, 1 (?) eingeben.           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE HSCFadeOut;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Blendet Musik langsam aus.                           *)
    (*  Hinweis  : Wartet nicht (!) auf das Ende des Ausblendens.       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE HSCStopSong;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : HÑlt Abspielen an.                                   *)
    (*  Hinweis  : Erneutes Starten durch "PlayHSCFile(..).             *)
    (* ---------------------------------------------------------------- *)

   (* ∞∞ SONSTIGE ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   FUNCTION MasterVolume(AWert, AKanal : Word) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt die LautstÑrke fÅr alles fest.                 *)
    (*  Eingabe  : AWERT  = LautstÑrke-Wert, [0..15],                   *)
    (*             AKANAL = Kanal. 0 = Linker Kanal (wenn Stereo),      *)
    (*                             1 = Rechter Kanal (wenn Stereo).     *)
    (*                             Wenn Mono, 1 (?) eingeben.           *)
    (*  RÅckgabe : TRUE   = Alles OK,                                   *)
    (*             FALSE  = Fehler aufgetreten.                         *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   {$L UWVOHS1a.OBJ}                    (* Assembler-Modul einbinden. *)

   USES Crt,
        UweUNI01, AdvHSC;

   (* ƒƒ Verschiedene Konstanten, Variablen, Typen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST (* Fehler-Codes: *)

         (* Eigene Fehlercodes: 0700-0749: *)
         VOC_Error_VOCArrayIsFull        = 0700;
         VOC_Error_NoVOCFile             = 0701;
         VOC_Error_NoVOCDriver           = 0702;
         VOC_Error_NoSBCard              = 0703;
         VOC_Error_WrongIOPort           = 0704;
         VOC_Error_WrongIRQOrDMA         = 0705;

   TYPE  PT                  = Record   (* Ermîglicht die einfache Behandlung von Pointern. *)
                                OffSet  : Word;
                                Segment : Word;
                               End;

   CONST VOCDriverPtr        : Pointer = Nil;

   VAR   StatusWord          : Word;            (* Status-Wort wÑhrend Abspielen. *)

   (* ƒƒ Prototypen der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ∞∞ SYSTEM-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   (* ∞∞ VOC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   (* ∞∞ HSC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE FreeHSCMem(ANr : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Gibt den Speicher eines VOC-Sounds frei.              *)
    (* Eingabe  : ANR = Nummer des Sounds im VOCN[..]-Feld.             *)
    (* ---------------------------------------------------------------- *)

   (* ∞∞ CT-VOICE-TREIBER-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   FUNCTION LoadCT_VOICEDriver(AFName : String) : Pointer; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : LÑdt den CT-VOICE Treiber in den Speicher.           *)
    (*  Eingabe  : AFNAME = VollstÑndiger (!) Name der Treiber-Datei,   *)
    (*                     inclusive Pfad und Erweiterung.              *)
    (*  RÅckgabe : Zeiger auf den geladenen Treiber.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE InitCTDriver(AIO, AIRQ, ADMA : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert den Treiber.                           *)
    (*  Eingabe  : AIO  = I/O-Port,                                     *)
    (*             AIRQ = IRQ-Nummer,                                   *)
    (*             ADMA = DMA-Adresse.                                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CallVOCDriver; Far; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ruft den CT-VOICE Treiber auf.                       *)
    (*  Eingabe  : Alle Register die gesetzt sind.                      *)
    (*  Ausgabe  : Alle Register kînnten verÑndert werden.              *)
    (*  Hinweis  : Ist External-Prozedur, sollte nur direkt von         *)
    (*             Assembler aus aufgerufen werden, wenn man            *)
    (*             schon alle Register gesetzt hat.                     *)
    (*             Diese Prozedur war nîtig, da mit dem integrierten    *)
    (*             Assembler keine indirekten Far-Calls realisiert      *)
    (*             werden kînnen.                                       *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetCTVersion : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt die Treiberversion.                        *)
    (*  RÅckgabe : Hi() = Nummer vor dem Punkt,                         *)
    (*             Lo() = Nummer hinter dem Punkt.                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetIOPort(ANr : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : WÑhlt den IO-Port aus.                               *)
    (*  Eingabe  : ANR  = IO-Port.                                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetIRQNr(ANr : Word); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : WÑhlt den SB-IRQ aus.                                *)
    (*  Eingabe  : ANR   = IRQ-Nummer.                                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION SetDMACh(ANr : Word) : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : WÑhlt den DMA-Kanal aus.                             *)
    (*  Eingabe  : ANR  = DMA-Kanal.                                    *)
    (*  RÅckgabe : 0      = Alles OK,                                   *)
    (*             0FFFFh = Falscher Wert.                              *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetSBType : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt die angeschlossenen Soundblaster-Karte.    *)
    (*  RÅckgabe : 1 = Normaler Soundblaster,                           *)
    (*             2 = Vorherige Version des Soundblaster Pro,          *)
    (*             3 = Soundblaster 2.0.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ResetMIXER; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : FÅhrt einen Reset des Mixers durch.                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetSpeaker(AOn : Boolean); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schaltet den Lautsprecher an oder aus.               *)
    (*  Eingabe  : AON = True: AN, False: AUS.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetStatusWord(APtr : Pointer); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Teilt dem Treiber die Adresse des Statuswortes mit.  *)
    (*  Eingabe  : APTR = Zeiger auf Status-Wort.                       *)
    (*  Hinweise : Statuswort mu· STATISCHE Variable sein, also NICHT   *)
    (*             auf Stack.                                           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PlayVOCVBlock(APtr : Pointer); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Start des Abspielens eines VOC-Blocks.               *)
    (*  Eingabe  : APTR = Zeiger auf Block.                             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE DoneCTDriver; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schaltet den Treiber aus.                            *)
    (* ---------------------------------------------------------------- *)

   FUNCTION PauseVOCPlay : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Unterbricht das Abspielen eines VOC-Blocks.          *)
    (*  RÅckgabe : 0 = Abspielen unterbrochen,                          *)
    (*             1 = Es wurde nichts gespielt.                        *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ContVOCPlay : Word; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt das Abspielen eines VOC-Blocks fort.           *)
    (*  RÅckgabe : 0 = Abspielen wird fortgesetzt,                      *)
    (*             1 = Es wurde nichts unterbrochen.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GetSampleRate(Var AMin, AMax : Word; AStereo, APlay : Boolean); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt die maximalen und minimalen Sample-Raten.  *)
    (*  Eingabe  : ASTEREO = True : Ermittle fÅr Stereo,                *)
    (*                       False: Ermittle fÅr Mono.                  *)
    (*             APLAY   = True : Ermittle fÅr Wiedergabe,            *)
    (*                       False: Ermittle fÅr Aufnahme               *)
    (*  RÅckgabe : AMIN    = Minimale Sample-Rate,                      *)
    (*             AMAX    = Maximale Sample-Rate.                      *)
    (* ---------------------------------------------------------------- *)

   (* ƒƒ RÅmpfe der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ SYSTEM-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ VOC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ HSC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE FreeHSCMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     If HSCN[ANr] = NIL Then Exit;
     FreeMem(HSCN[ANr], HSCSIZE[ANr]);  (* Freigeben. *)
     HSCN[ANr]    := Nil;
     HSCSIZE[ANr] := 0;
    End;

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ CT-VOICE-TREIBER-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   FUNCTION LoadCT_VOICEDriver(AFName : String) : Pointer;
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PXH1      : Pointer;
        {$ELSE}
        F         : File;
        {$ENDIF}
        SH1       : String[8];
        DRVSize   : LongInt;
        PH1       : Pointer;
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

     (* Fahre ID an: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Seek(F, 2);
     {$ELSE}
     Seek(F, 2);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Lese ID: *)
     {$I-}

     {$IFDEF ONEFILE}
     PXH1 := @SH1;
     _BlockRead(F, PXH1, 9);
     {$ELSE}
     BlockRead(F, SH1, 9);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     SH1[0] := #8;

     (* Fahre wieder an Dateianfang: *)
     {$I-}

     {$IFDEF ONEFILE}
     _Seek(F, 0);
     {$ELSE}
     Seek(F, 0);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Teste ID: *)
     If SH1 <> 'CT-VOICE' Then
      Begin
       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       ERR_Error := VOC_Error_NoVOCDriver;
       CriticalError('');
      End;

     (* Grî·e bestimmen: *)
     {$I-}

     {$IFDEF ONEFILE}
     DRVSize := _FileSize(F);
     {$ELSE}
     DRVSize := FileSize(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Speicher an OFFSET 0 (!!!) anfordern: *)
     PH1 := MemAllocSeg(DRVSize + 16);

     (* Lese Treiber ein: *)
     {$I-}

     {$IFDEF ONEFILE}
     _BlockRead(F, PH1, DRVSize);
     {$ELSE}
     BlockRead(F, PH1^, DRVSize);
     {$ENDIF}

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
     LoadCT_VOICEDriver := PH1;
     ERR_Error := ERR_Error_Ok;
    End;

   PROCEDURE InitCTDriver(AIO, AIRQ, ADMA : Word);
    (* ---------------------------------------------------------------- *)
    Var ResetResult : Word;
    Begin
     SetIOPort(AIO);
     SetIRQNr (AIRQ);
     SetDMACh (ADMA);

     Asm
      mov   bx, 3                       (* Funktion 3. *)
      call  CallVOCDriver               (* Rufe Treiber auf. *)
      mov   ResetResult, ax
     End;

     Case ResetResult Of
      0 : ERR_Error := ERR_Error_Ok;
      1 : Begin
           {$IFDEF ONHARDWAREERRORSTOP}
           ERR_Error := VOC_Error_NoSBCard;
           CriticalError('');
           {$ELSE}
           HSC_Possible := FALSE;
           VOC_Possible := FALSE;
           {$ENDIF}
          End;
      2 : Begin
           {$IFDEF ONHARDWAREERRORSTOP}
           ERR_Error := VOC_Error_WrongIOPort;
           CriticalError('');
           {$ELSE}
           HSC_Possible := FALSE;
           VOC_Possible := FALSE;
           {$ENDIF}
          End;
      3 : Begin
           {$IFDEF ONHARDWAREERRORSTOP}
           ERR_Error := VOC_Error_WrongIRQOrDMA;
           CriticalError('');
           {$ELSE}
           HSC_Possible := FALSE;
           VOC_Possible := FALSE;
           {$ENDIF}
          End;
     End;

     ResetMIXER;
     SetStatusWord(@StatusWord);
     SB_Type := GetSBType;
    End;

   PROCEDURE CallVOCDriver; External;
    (* ---------------------------------------------------------------- *)

   FUNCTION GetCTVersion : Word; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   bx, 0                        (* Funktion 0. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
                                        (* RÅckgabe in AX. *)
    End;

   PROCEDURE SetIOPort(ANr : Word); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   ax, ANr
     mov   bx, 1                        (* Funktion 1. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
    End;

   PROCEDURE SetIRQNr(ANr : Word); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   ax, ANr
     mov   bx, 2                        (* Funktion 2. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
    End;

   FUNCTION SetDMACh(ANr : Word) : Word; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   ax, ANr
     mov   bx, 19                       (* Funktion 19. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
                                        (* RÅckgabe in AX. *)
    End;

   FUNCTION GetSBType : Word; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   bx, 20                       (* Funktion 20. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
                                        (* RÅckgabe in AX. *)
    End;

   PROCEDURE ResetMIXER; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     call  GetCTVersion                 (* ermittle Treiber-Version. *)
     cmp   ax, 0121h                    (* Nur (!) in Version 1.21 unterstÅtzt. *)
     jne   @Exit                        (* Wenn nicht diese Version, Ende. *)

     mov   bx, 23                       (* Funktion 23. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
    @Exit:
    End;

   PROCEDURE SetSpeaker(AOn : Boolean); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     sub   ah, ah
     mov   al, AOn
     mov   bx, 4                        (* Funktion 4. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
    End;

   PROCEDURE SetStatusWord(APtr : Pointer);
    (* ---------------------------------------------------------------- *)
    Var HSeg, HOfs : Word;
    Begin
     HSeg := Seg(APtr^);
     HOfs := Ofs(APtr^);

     Asm
      mov   di, HSeg
      mov   es, di
      mov   di, HOfs
      mov   bx, 5                       (* Funktion 5. *)
      call  CallVOCDriver               (* Rufe Treiber auf. *)
     End;
    End;

   PROCEDURE PlayVOCVBlock(APtr : Pointer);
    (* ---------------------------------------------------------------- *)
    Var HSeg, HOfs : Word;
    Begin
     HSeg := Seg(APtr^);
     HOfs := Ofs(APtr^);

     Asm
      mov   di, HSeg
      mov   es, di
      mov   di, HOfs
      mov   bx, 6                       (* Funktion 6. *)
      call  CallVOCDriver               (* Rufe Treiber auf. *)
     End;
    End;

   PROCEDURE DoneCTDriver; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   bx, 9                        (* Funktion 9. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
    End;

   FUNCTION PauseVOCPlay : Word; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   bx, 10                       (* Funktion 10. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
                                        (* RÅckgabe in AX. *)
    End;

   FUNCTION ContVOCPlay : Word; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   bx, 11                       (* Funktion 11. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
                                        (* RÅckgabe in AX. *)
    End;

   PROCEDURE GetSampleRate(Var AMin, AMax : Word; AStereo, APlay : Boolean);
    (* ---------------------------------------------------------------- *)
    Var WH1, WH2 : Word;
    Begin
     Asm
      sub   ah, ah
      mov   dh, ah
      mov   al, APlay
      mov   dl, AStereo

      mov   bx, 26                      (* Funktion 26. *)
      call  CallVOCDriver               (* Rufe Treiber auf. *)

      mov   WH1, ax
      mov   WH2, dx
     End;

     AMin := WH1;
     AMax := WH2;
    End;

   (* ƒƒ InterfaceƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ SYSTEM-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE VOHSInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(VOHSCloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(VOHSGetErrorMessage);

     (* Variablen initialisieren: *)
     FillChar(VOCN, SizeOf(VOCN         ), 0);
     FillChar(VOCN, SizeOf(VOCSize      ), 0);
     FillChar(VOCN, SizeOf(VOCMode      ), 0);
     FillChar(VOCN, SizeOf(VOCSampleRate), 0);

     (* Lade VOC-Treiber: *)
     VOCDriverPtr := LoadCT_VOICEDriver(VOCDriverFile);

     (* Initialisere Soundblaster-Karte: *)
     InitCTDriver(IO_Port, IRQ_Number, DMA_Chanel);

     (* Alle LautstÑrken auf DEFAULT: *)
     VOCVolume(DefaultVolume, 0);
     VOCVolume(DefaultVolume, 1);
     HSCVolume(DefaultVolume, 0);
     HSCVolume(DefaultVolume, 1);
     MASTERVolume(DefaultVolume, 0);
     MASTERVolume(DefaultVolume, 1);
    End;

   PROCEDURE VOHSCloseRoutines;
    (* ---------------------------------------------------------------- *)
    Const LowestVolume = 0;
    Begin
     MASTERVolume(LowestVolume, 0);
     MASTERVolume(LowestVolume, 1);

     DoneVOCPlay;
     StopVOCIO;
     DoneHSCPlay;
     HSCStopSong;
    End;

   FUNCTION VOHSGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      VOC_Error_VOCArrayIsFull        : S := S + 'VOC-Feld ist voll.';
      VOC_Error_NoVOCFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das VOC-Format fÅr Voicedaten.';
      VOC_Error_NoVOCDriver           : S := S + 'VOC-Treiber fehlerhaft.';
      VOC_Error_NoSBCard              : S := S + 'Keine Soundblaster-Karte gefunden.';
      VOC_Error_WrongIOPort           : S := S + 'Falscher IO-Port fÅr die Soundblaster-Karte eingestellt';
      VOC_Error_WrongIRQOrDMA         : S := S + 'Falsche IRQ-Nummer oder DMA-Kanal fÅr Soundblaster eingestellt.';

      Else                              S := '';
     End;

     VOHSGetErrorMessage := S;
    End;

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ VOC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE LoadVOCFile(AFName : String; ANr : Byte);
    (* ---------------------------------------------------------------- *)
    Type TVOCHeader = Record   (* Siehe auch S.281, "Das SB Buch". *)
                       FileType       : Array[0..$13] Of Char;
                       StartDataBlock : Word;
                       Version        : Word;
                       IdentifyCode   : Word;
                      End;
    Var {$IFDEF ONEFILE}
        PXH1           : Pointer;
        {$ELSE}
        F              : File;
        {$ENDIF}
        VOCHeader      : TVOCHeader;
        WH1            : Word;
        ASize          : LongInt;
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

     (* Lesen, HAUPT-Header: *)
     {$I-}

     {$IFDEF ONEFILE}
     PXH1 := @VOCHeader;
     _BlockRead(F, PXH1, SizeOf(VOCHeader));
     {$ELSE}
     BlockRead(F, VOCHeader, SizeOf(VOCHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Header auswerten: *)
     If (VOCHeader.Version Xor $FFFF) + $1234 <> VOCHeader.IdentifyCode Then
      Begin
       {$I-}

       {$IFDEF ONEFILE}
       _Close(F);
       {$ELSE}
       Close(F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

       ERR_Error := VOC_Error_NoVOCFile;
       CriticalError(AFName);
      End;

     (* Trage Header-Werte in Tafeln ein: *)
    {VOCMode      [ANr] := VOCHeader.Mode;
     VOCSampleRate[ANr] := VOCHeader.SampleRate;}

     (* Bestimme Grî·e des Headers und Åberspringe ihn: *)

     {$I-}

     {$IFDEF ONEFILE}
     _Seek(F, $14);
     {$ELSE}
     Seek(F, $14);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     {$I-}

     {$IFDEF ONEFILE}
     PXH1 := @WH1;
     _BlockRead(F, PXH1, 2);
     {$ELSE}
     BlockRead(F, WH1, 2);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     {$I-}

     {$IFDEF ONEFILE}
     _Seek(F, WH1);
     {$ELSE}
     Seek(F, WH1);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Bestimme Grî·e der Datei: *)
     {$I-}

     {$IFDEF ONEFILE}
     ASize := _FileSize(F) - WH1;
     {$ELSE}
     ASize := FileSize(F) - WH1;
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Ggf. LÑnge begrenzen: *)
     If ASize > 65528 Then ASize := 65528;
     VOCSize[ANr] := ASize;

     (* Ggf. alten Speicher freigeben: *)
     FreeVOCMem(ANr);

     (* Speicher anfordern: *)
     _GetMem(VOCN[ANr], VOCSize[ANr]);

     (* Lese Datei ein: *)
     {$I-}

     {$IFDEF ONEFILE}
     _BlockRead(F, VOCN[ANr], VOCSize[ANr]);
     {$ELSE}
     BlockRead(F, VOCN[ANr]^, VOCSize[ANr]);
     {$ENDIF}

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
    End;

   PROCEDURE PlayVOCFile(ANr : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     StopVOCIO;                         (* Halte ggf. noch laufendes Sample an. *)
     PlayVOCVBlock(VOCN[ANr]);
    End;

   PROCEDURE DoneVOCPlay;
    (* ---------------------------------------------------------------- *)
    Begin
     SetSpeaker(FALSE);                 (* Lautsprecher ausschalten. *)
     DoneCTDriver;                      (* Treiber ausschalten. *)
    End;

   PROCEDURE VOCUserRoutine(APtr : Pointer);
    (* ---------------------------------------------------------------- *)
    Var HSeg, HOfs : Word;
    Begin
     HSeg := Seg(APtr^);
     HOfs := Ofs(APtr^);

     Asm
      mov   di, HSeg
      mov   es, di
      mov   di, HOfs
      mov   bx, 13                      (* Funktion 13. *)
      call  CallVOCDriver               (* Rufe Treiber auf. *)
     End;
    End;

   FUNCTION VOCVolume(AWert, AKanal : Word) : Boolean; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     (* Wenn zu gro·er Wert, begrenzen: *)
     cmp   AWert, 15                    (* Grî·er als maximal zulÑssig ? *)
     jle   @ValueOK                     (* Nein. *)
     mov   AWert, 15                    (* Ja, begrenzen. *)
    @ValueOK:

     (* SB-Typ ermitteln: *)
     call  GetSBType                    (* Wert in AX. *)

     mov   dx, AKanal                   (* Lese, welcher Kanal zu setzen ist. *)
     cmp   ax, 1                        (* Ist mindestens SB Pro ? *)
     jg    @StereoPossible              (* JA, mindestens SB Pro. *)
     mov   dx, 1                        (* NEIN, Mono-SB => DX auf 1. *)
    @StereoPossible:

     mov   cx, AWert                    (* Zu setzender Wert. *)
     mov   ax, 1                        (* LautstÑrke des DSP Ñndern. *)
     mov   bx, 21                       (* Funktion 20. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)

     (* RÅckgabe: *)
     cmp   ax, 0FFFFh                   (* Ist Fehler aufgetreten.  ? *)
     jne   @KeinFehler                  (* NEIN. *)

    @Fehler:
     mov   ax, FALSE                    (* JA. *)
     jmp   @Ende

    @KeinFehler:
     mov   ax, TRUE                     (* Kein Fehler. *)

     @Ende:
    End;

   PROCEDURE FreeVOCMem(ANr : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     If VOCN[ANr] = NIL Then Exit;
     FreeMem(VOCN[ANr], VOCSIZE[ANr]);  (* Freigeben. *)
     VOCN[ANr]    := Nil;
     VOCSIZE[ANr] := 0;
    End;

   PROCEDURE StopVOCIO; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   bx, 8                        (* Funktion 8. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)
    End;

   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞ HSC-ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)
   (* ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   PROCEDURE LoadHSCFile(AFName : String; ANr : Byte);
    (* ---------------------------------------------------------------- *)
    Var {$IFDEF ONEFILE}
        PXH1           : Pointer;
        {$ELSE}
        F              : File;
        {$ENDIF}
        ASize          : LongInt;
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

     (* Bestimme Dateigrî·e: *)
     {$I-}

     {$IFDEF ONEFILE}
     ASize := _FileSize(F);
     {$ELSE}
     ASize := FileSize(F);
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     (* Ggf. LÑnge begrenzen: *)
     If ASize > 65528 Then ASize := 65528;
     HSCSize[ANr] := ASize;

     (* Ggf. alten Speicher freigeben: *)
     FreeHSCMem(ANr);

     (* Speicher anfordern: *)
     _GetMem(HSCN[ANr], HSCSize[ANr]);

     (* Lese Datei ein: *)
     {$I-}

     {$IFDEF ONEFILE}
     _BlockRead(F, HSCN[ANr], HSCSize[ANr]);
     {$ELSE}
     BlockRead(F, HSCN[ANr]^, HSCSize[ANr]);
     {$ENDIF}

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
    End;

   PROCEDURE PlayHSCFile(ANr : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     If HSC_Possible And (HSCN[ANr] <> NIL) Then PlaySongMemory(HSCN[ANr]);
    End;

   PROCEDURE DoneHSCPlay;
    (* ---------------------------------------------------------------- *)
    Begin
     HSCVolume(0, 0);
     HSCVolume(0, 1);
     If HSC_Possible Then StopSong;
    End;

   PROCEDURE HSCUserRoutine(APtr : Pointer);
    (* ---------------------------------------------------------------- *)
    Begin
     SetUserIRQ(TRUE, APtr);
    End;

   PROCEDURE HSCVolume(AWert, AKanal : Word); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm                                 (* S. 467, SB-Buch ! *)
     cmp   BYTE PTR HSC_Possible, FALSE (* Ob HSC mîglich. *)
     je    @Finished

     (* Wenn zu gro·er Wert, begrenzen: *)
     cmp   AWert, 15                    (* Grî·er als maximal zulÑssig ? *)
     jle   @ValueOK                     (* Nein. *)
     mov   AWert, 15                    (* Ja, begrenzen. *)
    @ValueOK:

     (* SB-Typ ermitteln: *)
     call  GetSBType                    (* Wert in AX. *)
     cmp   ax, 1                        (* Ist mindestens SB Pro ? *)
     jg    @StereoPossible              (* JA, mindestens SB Pro. *)

     (* MONO: *)                        (* Mono, kopiere Lo- in Hi-Nibble. *)
    @MonoPossible:
     mov   ax, AWert                    (* Ist WORD, BYTE reicht aber. *)
     mov   bl, al                       (* kopiere Wert zum shift-en. *)
     shl   bl, 4                        (* In Hi-Nibble. *)
     or    al, bl                       (* Hi-Nibble in AL setzen. *)
     mov   ah, al                       (* Endwert in AH ! *)

    @SetMixerMONO:
     mov   dx, IO_Port                  (* Basis-Adresse lesen. *)
     add   dx, 4                        (* Mixer-Chip: Register-Auswahl. *)
     mov   al, 26h                      (* FM-LautstÑrke. *)
     out   dx, al                       (* Spreche Register an. *)

     inc   dx                           (* Mixer-Chip: Register-Daten. *)
     mov   al, ah                       (* Lese neue Werte fÅr Links & Rechts. *)
     out   dx, al                       (* Spreche Register an. *)
     jmp   @Finished                    (* Alles fertig. *)

     (* STEREO: *)
    @StereoPossible:

    @SetMixerSTEREO:
     mov   dx, IO_Port                  (* Basis-Adresse lesen. *)
     add   dx, 4                        (* Mixer-Chip: Register-Auswahl. *)
     mov   al, 26h                      (* FM-LautstÑrke. *)
     out   dx, al                       (* Spreche Register an. *)

     inc   dx                           (* Mixer-Chip: Register-Daten. *)
     in    al, dx                       (* Lese aktuelle LautstÑrke-Werte. *)

     cmp   WORD PTR AKanal, 0           (* Linker Kanal ? *)
     jne   @RightChannel

    @LeftChannel:
     mov   bx, AWert                    (* Lese Wert. *)
     shl   bl, 4                        (* Wert in Hi-Nibble. *)

     and   al, 0Fh                      (* Lîsche frÅhere Einstellung vom LINKEN Kanal. *)
     or    al, bl                       (* Setze neuen Wert des LINKEN Kanals. *)
     out   dx, al                       (* Spreche Register an. *)

    @RightChannel:
     mov   bx, AWert                    (* Lese Wert. *)

     and   al, 0F0h                     (* Lîsche frÅhere Einstellung vom RECHTEN Kanal. *)
     or    al, bl                       (* Setze neuen Wert des RECHTEN Kanals. *)
     out   dx, al                       (* Spreche Register an. *)

    @Finished:                          (* Ende. *)

    End;

   PROCEDURE HSCFadeOut;
    (* ---------------------------------------------------------------- *)
    Begin
     If HSC_Possible Then FadeSong;
    End;

   PROCEDURE HSCStopSong;
    (* ---------------------------------------------------------------- *)
    Begin
     If HSC_Possible Then StopSong;
    End;

   (* ∞∞ SONSTIGE ROUTINEN: ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞ *)

   FUNCTION MasterVolume(AWert, AKanal : Word) : Boolean; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     (* Wenn zu gro·er Wert, begrenzen: *)
     cmp   AWert, 15                    (* Grî·er als maximal zulÑssig ? *)
     jle   @ValueOK                     (* Nein. *)
     mov   AWert, 15                    (* Ja, begrenzen. *)
    @ValueOK:

     (* SB-Typ ermitteln: *)
     call  GetSBType                    (* Wert in AX. *)

     mov   dx, AKanal                   (* Lese, welcher Kanal zu setzen ist. *)
     cmp   ax, 1                        (* Ist mindestens SB Pro ? *)
     jg    @StereoPossible              (* JA, mindestens SB Pro. *)
     mov   dx, 1                        (* NEIN, Mono-SB => DX auf 1. *)
    @StereoPossible:

     mov   cx, AWert                    (* Zu setzender Wert. *)
     mov   ax, 0                        (* MASTER-LautstÑrke Ñndern. *)
     mov   bx, 21                       (* Funktion 20. *)
     call  CallVOCDriver                (* Rufe Treiber auf. *)

     (* RÅckgabe: *)
     cmp   ax, 0FFFFh                   (* Ist Fehler aufgetreten.  ? *)
     jne   @KeinFehler                  (* NEIN. *)

    @Fehler:
     mov   ax, FALSE                    (* JA. *)
     jmp   @Ende

    @KeinFehler:
     mov   ax, TRUE                     (* Kein Fehler. *)

     @Ende:
    End;

  (* ƒƒ INITIALISIERUNGSƒTEIL: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   BEGIN
   END.

 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)