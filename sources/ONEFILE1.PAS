 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)
 (*  Programm : ONEFILE                                                    *)
 (*             Lesen, Packen und Entpacken vieler Dateien in EINE Datei.  *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : ONEFILE1.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 14.09.1994 Uwe Keim - Anfang.                              *)
 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

 UNIT OneFile1;

  {$A-,B-,D+,E+,F+,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE KEYFILE}                     (* Codiere Datei AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- ôFFENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   {$IFDEF KEYFILE}
   USES KEYFile1;
   {$ENDIF}

   (* ƒƒ Verschiedene ErklÑrungen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ----------------------------------------------------------- *)
   (*  Allgemeine Hinweise:                                       *)
   (*  ~~~~~~~~~~~~~~~~~~~~                                       *)
   (*                                                             *)
   (*  Diese Unit dient dazu, aus einer gro·en Datei mit mehreren *)
   (*  verschiedenen kleinen Dateien zu lesen, die sich so        *)
   (*  ansprechen lassen, als wÑren sie einzelne Dateien.         *)
   (*                                                             *)
   (*  GRENZEN: - Zugriff nur mîglich auf die Dateien als         *)
   (*  ~~~~~~~~   typenlose (File) Dateien,                       *)
   (*           - Grî·e der Dateien nicht verÑnderbar,            *)
   (*           - SCHREIBEN nur innerhalb der Datei mîglich,      *)
   (*             vergrî·ern der Dateien NICHT mîglich.           *)
   (*             (ACHTUNG: Keine öberprÅfung, ob Åber Datei-     *)
   (*             Ende hinausgeschrieben wird !)                  *)
   (*           - Nur EINE Unter-Datei kann gleichzeitig offen    *)
   (*             sein.                                           *)
   (*                                                             *)
   (*  Folgende Funktionen werden unterstÅtzt:                    *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                    *)
   (*   - Assign                                                  *)
   (*   - Reset                                                   *)
   (*   - Close                                                   *)
   (*   - Read                                                    *)
   (*   - BlockRead                                               *)
   (*   - Write                                                   *)
   (*   - BlockWrite                                              *)
   (*   - FileSize                                                *)
   (*   - FilePos                                                 *)
   (*   - Eof                                                     *)
   (*   - Seek                                                    *)
   (*                                                             *)
   (*  ZusÑtzliche Funktionen:                                    *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~                                    *)
   (*   - AssignMAIN                                              *)
   (*   - ResetMAIN                                               *)
   (*   - CloseMAIN                                               *)
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (*  Aufbau einer Multi-Files-Datei '????????.DAT':             *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~             *)
   (*                                                             *)
   (*  Die Datei beginnt mit einem Header, der Informationen zur  *)
   (*  gesamten Datei enthÑlt, dem -->                            *)
   (*                                                             *)
   (*  HAUPT-HEADER (= "TMAINHEADER"):                            *)
   (*  ~~~~~~~~~~~~                                               *)
   (*  00..01  DB  'U', 'K'      =  Kennung                       *)
   (*  02..02  DB  1             =  Version                       *)
   (*  03..05  DB  'D', 'A', 'T' =  Art                           *)
   (*  06..09  DD  ?             =  LÑnge der GESAMTEN Datei      *)
   (*  10..21  DB 'XXXXXXXX.XXX' =  Dateiname der Haupt-Datei     *)
   (*                               mit Punkt und Extension       *)
   (*  22..23  DW  ?             =  Anzahl an Unter-Dateien       *)
   (*  24..49  DB  ?             =  Dummy, fÅr spÑtere            *)
   (*                               Erweiterungen frei            *)
   (*                                                             *)
   (*  Es schlie·t sich direkt an der Haupt-Header eine Liste     *)
   (*  an, die Infos zu den einzelnen Unter-Dateien enthÑlt und   *)
   (*  die genausoviele Elemente (1 Element = 1 "TMAINFOLLOW"-    *)
   (*  Record) hat, wie Unter-Dateien -->                         *)
   (*                                                             *)
   (*  UNTER-LISTE (= "TMAINFOLLOW"):                             *)
   (*  ~~~~~~~~~~~                                                *)
   (*  00..01  DW  ?             =  Nummer der Unter-Datei (1..n) *)
   (*  02..13  DB 'XXXXXXXX.XXX' =  Dateiname der Unter-Datei     *)
   (*                               mit Punkt und Extension       *)
   (*  14..17  DD  ?             =  Start-Position in der         *)
   (*                               Haupt-Datei                   *)
   (*  18..18  DB  0/1           =  Ob letzter Eintrag in der     *)
   (*                               Liste ist. 0 = Nein, 1 = Ja   *)
   (*  19..49  DB  ?             =  Dummy, fÅr spÑtere            *)
   (*                               Erweiterungen frei            *)
   (*                                                             *)
   (*  Jetzt folgen die einzelnen Unter-Dateien, die alle mit     *)
   (*  einem Header vor den eigentlichen Daten beginnen -->       *)
   (*                                                             *)
   (*  UNTER-HEADER (= "TSUBHEADER"):                             *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                             *)
   (*  00..01  DB  'U', 'K'      =  Kennung                       *)
   (*  02..02  DB  1             =  Version                       *)
   (*  03..05  DB  'S', 'U', 'B' =  Art                           *)
   (*  06..09  DD  ?             =  LÑnge der UNTER- Datei        *)
   (*  10..21  DB 'XXXXXXXX.XXX' =  Dateiname der Unter-Datei     *)
   (*                               mit Punkt und Extension       *)
   (*  22..49  DB  ?             =  Dummy, fÅr spÑtere            *)
   (*                               Erweiterungen frei            *)
   (* ----------------------------------------------------------- *)

   (* ƒƒ Verschiedene Konstanten, Typen und Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   TYPE (* Header der Haupt-Datei: *)
        TMAINHeader = Record
                       Kennung : Array[1..2] Of Char;   (* 'UK'. *)
                       Version : Byte;                  (* Versionsnummer. *)
                       Art     : Array[1..3] Of Char;   (* 'DAT'. *)
                       Laenge  : LongInt;               (* GesamtlÑnge der Haupt-Datei. *)
                       FName   : Array[1..12] Of Char;  (* Name der Unter-Datei. *)
                       AnzSUB  : Word;                  (* Anzahl an Unter-Dateien (1..n), 0 = Keine. *)
                       Dummy   : Array[1..26] Of Byte;  (* Frei fÅr spÑtere Erweiterungen. *)
                      End;

        (* Liste, direkt nach dem MAIN-Header: *)
        TMAINFollow = Record
                       Nr    : Word;                    (* Nummer der Unter-Datei (1..n). *)
                       FName : Array[1..12] Of Char;    (* Name der Unter-Datei. *)
                       Start : LongInt;                 (* Start-Position der Unter-Datei, zur Haupt-Datei. *)
                       Last  : Boolean;                 (* TRUE = Letztes Element in Liste. *)
                       Dummy : Array[1..31] Of Byte;    (* Frei fÅr spÑtere Erweiterungen. *)
                      End;

        (* Header der Unter-Dateien: *)
        TSUBHeader  = Record
                       Kennung : Array[1..2] Of Char;   (* 'UK'. *)
                       Version : Byte;                  (* Versionsnummer. *)
                       Art     : Array[1..3] Of Char;   (* 'SUB'. *)
                       Laenge  : LongInt;               (* GesamtlÑnge der Unter-Datei. *)
                       FName   : Array[1..12] Of Char;  (* Name der Unter-Datei. *)
                       Dummy   : Array[1..28] Of Byte;  (* Frei fÅr spÑtere Erweiterungen. *)
                      End;

        (* Aktuelle Infos und Zustand: *)
        TFileStatus = Record
                       (* Zustand der Haupt-Datei: *)
                       Assigned  : Boolean;     (* Ob schon was zugewiesen ist. *)
                       Open      : Boolean;     (* Ob Haupt-Datei offen ist. *)
                       MAINFName : String[12];  (* Name der Hauptdatei. *)

                       {$IFDEF KEYFILE}
                       F         : TKEYFileStatus;(* Die Dateivariable. *)
                       {$ELSE}
                       F         : File;        (* Die Dateivariable. *)
                       {$ENDIF}

                       MHeader   : TMAINHeader; (* Der aktuelle Haupt-Header. *)

                       (* Allgemeine Infos: *)
                       RecSize   : Word;        (* Grî·e eines BLOCKREADRECORDS. *)

                       (* Zustand der aktuellen Unter-Datei: *)
                       SUBAssign : Boolean;     (* Ob Unter-Datei zugewiesen ist. *)
                       SUBOpen   : Boolean;     (* Ob Unter-Datei offen ist. *)
                       SUBFName  : String[12];  (* Name der Unter-Datei. *)
                       SUBFPos   : LongInt;     (* Position, relativ zur Unter-Datei. *)
                       SUBFSize  : LongInt;     (* LÑnge der Unter-Datei. *)
                       SUBEOF    : Boolean;     (* Wenn am Ende der Unter-Datei. *)
                       SUBNr     : Word;        (* Nummer der Unter-Datei (1..n). *)
                       SUBStart  : LongInt;     (* Start-Position der Unter-Datei, zur Haupt-Datei. *)

                       SFollow   : TMAINFollow; (* Der aktuelle MAIN-Follow-Header. *)
                       SHeader   : TSUBHeader;  (* Der aktuelle Unter-Header. *)
                      End;

   VAR F                     : TFileStatus;     (* Aktueller Status. *)

   (* ƒƒ Prototypen der Prozeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE AssignMAIN(Var AF : TFileStatus; AName : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ordnet einer Datei-Variablen eine Haupt-Datei zu.    *)
    (*  Eingabe  : ANAME = Name der Haupt-Datei.                        *)
    (*  RÅckgabe : AF    = Die entsprechenden Infos zu ANAME werden     *)
    (*                     eingetragen.                                 *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ResetMAIN(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : ôffnet eine Haupt-Datei.                             *)
    (*  RÅckgabe : AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CloseMAIN(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schlie·t eine Haupt-Datei.                           *)
    (*  RÅckgabe : AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _Assign(Var AF : TFileStatus; AName : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ordnet einer Datei-Variablen eine Unter-Datei zu.    *)
    (*  Eingabe  : ANAME = Name der Unter-Datei in der Haupt-Datei.     *)
    (*  RÅckgabe : AF    = Die entsprechenden Infos zu ANAME werden     *)
    (*                     eingetragen.                                 *)
    (*  Hinweis  : Die Haupt-Datei in AF mu· vorher zugewiesen worden   *)
    (*             sein, mit "AssignMAIN()".                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _Reset(Var AF : TFileStatus; ARecSize : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : ôffnet eine Unter-Datei in der Haupt-Datei.          *)
    (*  Eingabe  : ARECSIZE = Grî·e des Records, der mit _BLOCKREAD     *)
    (*                        eingelesen wird.                          *)
    (*  RÅckgabe : AF       = Die entsprechenden Infos zu ARECSIZE      *)
    (*                        werden eingetragen.                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _Close(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schlie·t eine Unter-Datei in der Haupt-Datei.        *)
    (*  RÅckgabe : AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _Read(Var AF : TFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Lie·t ein 1 Byte aus einer Unter-Datei.              *)
    (*  RÅckgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen,                                *)
    (*             ABUF   = Das gelesene Byte.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _BlockRead(Var AF : TFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Lie·t eine Anzahl Bytes aus einer Unter-Datei.       *)
    (*  Eingabe  : ACOUNT = Anzahl von Records die gelesen werden.      *)
    (*  RÅckgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen,                                *)
    (*             ABUF   = Die gelesenen Bytes werden ab ABUF^         *)
    (*                      geschrieben.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _Write(Var AF : TFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt ein 1 Byte in eine Unter-Datei.             *)
    (*  Eingabe  : ABUF   = Das zu schreibende Byte.                    *)
    (*  RÅckgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _BlockWrite(Var AF : TFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt eine Anzahl Bytes in eine Unter-Datei.      *)
    (*  Eingabe  : ABUF   = Die Bytes ab ABUF^ werden geschrieben,      *)
    (*             ACOUNT = Anzahl von Records die geschrieben werden.  *)
    (*  RÅckgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen.                                *)
    (* ---------------------------------------------------------------- *)

   FUNCTION _FileSize(Var AF : TFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die Grî·e einer Unter-Datei in einer         *)
    (*             Haupt-Datei.                                         *)
    (*  RÅckgabe : LÑnge der Unter-Datei in Bytes,                      *)
    (*             AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   FUNCTION _FilePos(Var AF : TFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die aktuelle, relative Position des Datei-   *)
    (*             Zeigers in einer Unter-Datei.                        *)
    (*  RÅckgabe : LÑnge der Unter-Datei in Bytes,                      *)
    (*             AF = Die entsprechenden Infos werden eingetragen.    *)
    (*  Hinweise : Wenn die Position am Anfang der Datei steht          *)
    (*             (d.h. vor der ersten Komponente), dann liefert       *)
    (*             FilePos den Wert 0 zurÅck; steht sie auf dem Ende    *)
    (*             der Datei (Eof= True), dann ist FilePos(F)           *)
    (*             identisch mit FileSize(F).                           *)
    (* ---------------------------------------------------------------- *)

   FUNCTION _EOF(Var AF : TFileStatus) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : PrÅft, ob das Ende einer Unter-Datei erreicht ist.   *)
    (*  RÅckgabe : TRUE  : Ende der Datei erreicht,                     *)
    (*             FALSE : Ende der Datei noch nicht erreicht,          *)
    (*             AF    = Die entsprechenden Infos werden eingetragen. *)
    (*  Hinweise : EOF ist TRUE, wenn FilePos(F) identisch mit          *)
    (*             FileSize(F) ist.                                     *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _Seek(Var AF : TFileStatus; AN : LongInt);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt den Positionszeiger in einer Unter-Datei auf   *)
    (*             eine bestimmte Position.                             *)
    (*  Eingabe  : AN = Position, von 0 .. _FileSize(F).                *)
    (*  RÅckgabe : AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE ONEFILEInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles Nîtige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ONEFILECloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgemÑ·.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ONEFILEGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert Text zum aktuellen Fehler in ERR_Error.      *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                            *)
    (*             AS        = Eventueller zusÑtzlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  RÅckgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   USES Crt,
        UweERR01,
        UweUNI01;

   (* ƒƒ Verschiedene Konstanten, Typen und Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST (* Eigene Fehlercodes: 0200-0249: *)
         ONEFILE_Error_NoDATFile             = 0200;
         ONEFILE_Error_No2ndOpenAllowed      = 0201;

   VAR MAINHeader : TMAINHeader;
       MAINFollow : TMAINFollow;
       SUBHeader  : TSUBHeader;

       {$IFDEF KEYFILE}
       PXH1       : Pointer;
       {$ENDIF}

   (* ƒƒ Prototypen der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE GetMAINFollow(AFName : String; Var AF : TFileStatus; Var AH : TMAINFollow); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert einen MAIN-Follow-Block zu einer             *)
    (*             Unter-Datei.                                         *)
    (*  Eingabe  : AFNAME = Name der Unter-Datei, mit '.' und           *)
    (*                      Extension,                                  *)
    (*             AF     = Aktuelle Status-Record,                     *)
    (*             AH     = Der zueÅckgelieferte Header.                *)
    (*  Hinweis  : Die Haupt-Datei MU· (!) geîffnet sein.               *)
    (*             Wenn der Test einen Fehler findet, wird              *)
    (*             "CRITICALERROR()" aufgerufen.                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GetSUBHeaderToMAINFollow(Var AF : TFileStatus; AMF : TMAINFollow; Var ASH : TSUBHeader); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert zu einem MAIN-Follow-Block den dazugehîrigen *)
    (*             Unter-Header.                                        *)
    (*  Eingabe  : AF  = Aktuelle Status-Record,                        *)
    (*             AMF = Der MAIN-Follow-Block,                         *)
    (*             ASH = Der zurÅckgelieferte Header.                   *)
    (*  Hinweis  : Die Haupt-Datei MU· (!) geîffnet sein.               *)
    (*             Wenn der Test einen Fehler findet, wird              *)
    (*             "CRITICALERROR()" aufgerufen.                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE TestMAINHeader(Var AH : TMAINHeader; Var AF : TFileStatus); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Header korrekt ist (Kennung, Art, ...).   *)
    (*  Eingabe  : AH = Der zu testende Header,                         *)
    (*             AF = Der dazugehîrige Status-Record.                 *)
    (*  Hinweis  : Wenn der Test einen Fehler findet, wird              *)
    (*             "CRITICALERROR()" aufgerufen.                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE TestMAINFollow(Var AH : TMAINFollow; Var AF : TFileStatus); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Follow korrekt ist (Kennung, Art, ...).   *)
    (*  Eingabe  : AH = Der zu testende Follow-Block,                   *)
    (*             AF = Der dazugehîrige Status-Record.                 *)
    (*  Hinweis  : Wenn der Test einen Fehler findet, wird              *)
    (*             "CRITICALERROR()" aufgerufen.                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE TestSUBHeader(Var AH : TSUBHeader; Var AF : TFileStatus); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Header korrekt ist (Kennung, Art, ...).   *)
    (*  Eingabe  : AH = Der zu testende Header,                         *)
    (*             AF = Der dazugehîrige Status-Record.                 *)
    (*  Hinweis  : Wenn der Test einen Fehler findet, wird              *)
    (*             "CRITICALERROR()" aufgerufen.                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ClearAllSUBInfos(Var AF : TFileStatus); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Lîscht in einem Status-Record alle Infos Åber eine   *)
    (*             Unter-Datei.                                         *)
    (*  Eingabe  : AF = Der dazugehîrige Status-Record.                 *)
    (* ---------------------------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   (* ƒƒ RÅmpfe der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE GetMAINFollow(AFName : String; Var AF : TFileStatus; Var AH : TMAINFollow);
    (* ---------------------------------------------------------------- *)
    Var WH1 : Word;
        HH1 : TMainFollow;
        CH1 : Array[1..12] Of Char;
    Begin
     (* Name auf definierte 12 Zeichen LÑnge bringen, Rest mit "0" auffÅllen. *)
     FillChar(CH1, SizeOf(CH1), 0);
     Move(AFName[1], CH1, SizeOf(AFName));

     (* An Anfang der Unter-Liste fahren: *)
     {$I-}

     {$IFDEF KEYFILE}
     _K_Seek(AF.F, SizeOf(MainHeader));
     {$ELSE}
     Seek(AF.F, SizeOf(MainHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

     HH1.Last := False;

     (* Alle EintrÑge durch: *)
     While Not HH1.Last Do
      Begin
       {$I-}

       {$IFDEF KEYFILE}
       PXH1 := @HH1;
       _K_BlockRead(AF.F, PXH1, SizeOf(HH1));
       {$ELSE}
       BlockRead(AF.F, HH1, SizeOf(HH1));
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

       (* Wenn Name gleich: *)
       If HH1.FName = CH1 Then
        Begin
         AH := HH1;                     (* Header Åbergeben. *)

         Exit;
        End;
      End;

     (* Wenn jetzt noch nichts gefunden: *)
     CloseMAIN(AF);

     ERR_Error := ONEFILE_Error_NoDATFile;
     CriticalError(AF.MAINFName);
    End;

   PROCEDURE GetSUBHeaderToMAINFollow(Var AF : TFileStatus; AMF : TMAINFollow; Var ASH : TSUBHeader);
    (* ---------------------------------------------------------------- *)
    Begin
     (* SUB-Header anfahren: *)
     {$I-}

     {$IFDEF KEYFILE}
     _K_Seek(AF.F, AMF.Start);             (* StartPosition des Headers lesen. *)
     {$ELSE}
     Seek(AF.F, AMF.Start);             (* StartPosition des Headers lesen. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

     (* SUB-Header lesen: *)
     {$I-}

     {$IFDEF KEYFILE}
     PXH1 := @ASH;
     _K_BlockRead(AF.F, PXH1, SizeOf(ASH));
     {$ELSE}
     BlockRead(AF.F, ASH, SizeOf(ASH));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

     (* Auf Name testen: *)
     If AMF.FName <> ASH.FName Then
      Begin
       CloseMAIN(AF);

       ERR_Error := ONEFILE_Error_NoDATFile;
       CriticalError(AF.MAINFName);
      End;
    End;

   PROCEDURE TestMAINHeader(Var AH : TMAINHeader; Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     If (AH.Kennung <> 'UK') Or (AH.Art <> 'DAT') Or
        (AH.FName <> AF.MAINFName) Or (_K_FileSize(AF.F) <> AH.Laenge) Then
     {$ELSE}
     If (AH.Kennung <> 'UK') Or (AH.Art <> 'DAT') Or
        (AH.FName <> AF.MAINFName) Or (FileSize(AF.F) <> AH.Laenge) Then
     {$ENDIF}

      Begin
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

       CloseMAIN(AF);

       ERR_Error := ONEFILE_Error_NoDATFile;
       CriticalError(AF.MAINFName);
      End;
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   PROCEDURE TestMAINFollow(Var AH : TMAINFollow; Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   PROCEDURE TestSUBHeader(Var AH : TSUBHeader; Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     If (AH.Kennung <> 'UK') Or (AH.Art <> 'SUB') Then
      Begin
       CloseMAIN(AF);

       ERR_Error := ONEFILE_Error_NoDATFile;
       CriticalError(AF.MAINFName);
      End;
    End;

   PROCEDURE ClearAllSUBInfos(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     With AF Do
      Begin
       SUBAssign := FALSE;
       SUBOpen   := FALSE;
       FillChar(SUBFName, SizeOf(SUBFName), 0);
       SUBFPos   := 0;
       SUBFSize  := 0;
       SUBEOF    := FALSE;
       SUBNr     := 0;
       SUBStart  := 0;

       FillChar(SFollow, SizeOf(SFollow), 0);
       FillChar(SHeader, SizeOf(SHeader), 0);
      End;
    End;

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   (* ƒƒ InterfaceƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE AssignMAIN(Var AF : TFileStatus; AName : String);
    (* ---------------------------------------------------------------- *)
    Begin
     With AF Do
      Begin
       (* Zustand der Haupt-Datei: *)
       Assigned  := TRUE;               (* Ob schon was zugewiesen ist. *)
       Open      := FALSE;              (* Ob Haupt-Datei offen ist. *)
       MAINFName := AName;              (* Name der Hauptdatei. *)
       FillChar(MHeader, SizeOf(MHeader), 0);

       (* Allgemeine Infos: *)
       RecSize   := 0;                  (* Grî·e eines BLOCKREADRECORDS. *)

       (* Zustand der aktuellen Unter-Datei: *)
       SUBOpen   := FALSE;              (* Ob Unter-Datei offen ist. *)
       SUBFName  := '';                 (* Name der Unter-Datei. *)
       SUBFPos   := 0;                  (* Position, relativ zur Unter-Datei. *)
       SUBFSize  := 0;                  (* LÑnge der Unter-Datei. *)
       SUBEOF    := FALSE;              (* Wenn am Ende der Unter-Datei. *)
       SUBNr     := 0;                  (* Nummer der Unter-Datei (1..n). *)
       SUBStart  := 0;                  (* Start-Position der Unter-Datei, zur Haupt-Datei. *)
       FillChar(SHeader, SizeOf(SHeader), 0);
      End;

     (* Physikalisch zuweisen: *)
     {$IFDEF KEYFILE}
     _K_Assign(AF.F, AF.MAINFName);
     {$ELSE}
     Assign(AF.F, AF.MAINFName);
     {$ENDIF}
    End;

   PROCEDURE ResetMAIN(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     (* Physikalischer Reset: *)
     {$I-}

     {$IFDEF KEYFILE}
     _K_Reset(AF.F, 1);                  (* Intern: BlockReadSize = 1 Byte. *)
     {$ELSE}
     Reset(AF.F, 1);                    (* Intern: BlockReadSize = 1 Byte. *)
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

     (* Reset eintragen: *)
     AF.Open := TRUE;                   (* Haupt-Datei offen. *)

     (* Daten in MAIN-Header einlesen: *)
     {$I-}

     {$IFDEF KEYFILE}
     PXH1 := @AF.MHeader;
     _K_BlockRead(AF.F, PXH1, SizeOf(AF.MHeader));
     {$ELSE}
     BlockRead(AF.F, AF.MHeader, SizeOf(AF.MHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

     (* Daten in AF Åbertragen: *)

    End;

   PROCEDURE CloseMAIN(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     If AF.Open Then                    (* Nur, wenn OFFEN. *)
      Begin
       (* Physikalisches Close: *)
       {$I-}

       {$IFDEF KEYFILE}
       _K_Close(AF.F);
       {$ELSE}
       Close(AF.F);
       {$ENDIF}

       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);

       (* Reset eintragen: *)
       AF.Open := FALSE;                (* Haupt-Datei geschlossen. *)
      End;
    End;

   PROCEDURE _Assign(Var AF : TFileStatus; AName : String);
    (* ---------------------------------------------------------------- *)
    Begin
     (* Alle Infos zu SUB lîschen: *)
     ClearAllSUBInfos(AF);

     (* Infos eintragen: *)
     With AF Do
      Begin
       SUBAssign := TRUE;               (* Assign. *)

       SUBFName := AName;
       While Length(SUBFName) < 12 Do SUBFName := SUBFName + #0;
      End;
    End;

   PROCEDURE _Reset(Var AF : TFileStatus; ARecSize : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     (* Suche MAIN-Follow: *)
     GetMAINFollow(AF.SUBFName, AF, AF.SFollow);

     (* Suche Unter-Header: *)
     GetSUBHeaderToMAINFollow(AF, AF.SFollow, AF.SHeader);

     AF.RecSize := ARecSize;

     (* Infos eintragen: *)
     With AF Do
      Begin
       SUBOpen  := TRUE;
       SUBFPos  := 0;
       SUBFSize := SHeader.Laenge;
       SUBEOF   := _EOF(AF);
       SUBNr    := SFollow.Nr;
       SUBStart := SFollow.Start;
      End;

     (* Auf Anfang der Unter-Daten fahren: *)
     {$I-}

     {$IFDEF KEYFILE}
     _K_Seek(AF.F, AF.SUBStart + SizeOf(SUBHeader));
     {$ELSE}
     Seek(AF.F, AF.SUBStart + SizeOf(SUBHeader));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   PROCEDURE _Close(Var AF : TFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     ClearAllSUBInfos(AF);
    End;

   PROCEDURE _Read(Var AF : TFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     PXH1 := @ABuf;
     _K_BlockRead(AF.F, PXH1, 1);          (* 1 Byte einlesen. *)
     {$ELSE}
     BlockRead(AF.F, ABuf, 1);          (* 1 Byte einlesen. *)
     {$ENDIF}

     Inc(AF.SUBFPos);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   PROCEDURE _BlockRead(Var AF : TFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     _K_BlockRead(AF.F, ABuf, AF.RecSize * ACount);
     {$ELSE}
     BlockRead(AF.F, ABuf^, AF.RecSize * ACount);
     {$ENDIF}

     Inc(AF.SUBFPos, AF.RecSize * ACount);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   PROCEDURE _Write(Var AF : TFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     PXH1 := @ABuf;
     _K_BlockWrite(AF.F, PXH1, 1);         (* 1 Byte einlesen. *)
     {$ELSE}
     BlockWrite(AF.F, ABuf, 1);         (* 1 Byte einlesen. *)
     {$ENDIF}

     Inc(AF.SUBFPos);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   PROCEDURE _BlockWrite(Var AF : TFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     _K_BlockWrite(AF.F, ABuf, AF.RecSize * ACount);
     {$ELSE}
     BlockWrite(AF.F, ABuf^, AF.RecSize * ACount);
     {$ENDIF}

     Inc(AF.SUBFPos, AF.RecSize * ACount);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   FUNCTION _FileSize(Var AF : TFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    Begin
     _FileSize := AF.SUBFSize;
    End;

   FUNCTION _FilePos(Var AF : TFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    Begin
     _FilePos := AF.SUBFPos;
    End;

   FUNCTION _EOF(Var AF : TFileStatus) : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     _EOF := ((_FilePos(AF) = _FileSize(AF)) Or (_K_EOF(AF.F)));
     {$ELSE}
     _EOF := ((_FilePos(AF) = _FileSize(AF)) Or (Eof(AF.F)));
     {$ENDIF}

     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   PROCEDURE _Seek(Var AF : TFileStatus; AN : LongInt);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}

     {$IFDEF KEYFILE}
     _K_Seek(AF.F, AF.SUBStart + SizeOf(SUBHeader) + AN);
     {$ELSE}
     Seek(AF.F, AF.SUBStart + SizeOf(SUBHeader) + AN);
     {$ENDIF}

     AF.SUBFPos := AN;
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.MAINFName);
    End;

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE ONEFILEInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Anfangswerte besetzen: *)
     FillChar(F, SizeOf(F), 0);

     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(ONEFILECloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(ONEFILEGetErrorMessage);
    End;

   PROCEDURE ONEFILECloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   FUNCTION ONEFILEGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      ONEFILE_Error_NoDATFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das DAT-Format.';
      ONEFILE_Error_No2ndOpenAllowed      : S := S + 'Mehr als 1 Unter-Dateien offen nicht erlaubt.';

      Else                                  S := '';
     End;

     ONEFILEGetErrorMessage := S;
    End;

  (* ƒƒ INITIALISIERUNGSƒTEIL: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   BEGIN
    ONEFILEInitRoutines;
   END.

 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)