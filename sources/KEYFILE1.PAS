 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)
 (*  Programm : KEYFILE                                                    *)
 (*             Verschl걌selt eine Datei                                   *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : KEYFILE1.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 18.09.1994 Uwe Keim - Anfang.                              *)
 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)

 UNIT KEYFile1;

  {$A-,B-,D+,E+,F+,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- 섺FENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   (* 컴 Verschiedene Erkl꼛ungen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* ----------------------------------------------------------- *)
   (*  Allgemeine Hinweise:                                       *)
   (*  ~~~~~~~~~~~~~~~~~~~~                                       *)
   (*                                                             *)
   (*  Diese Unit dient dazu, eine Datei zu verschl걌seln.        *)
   (*                                                             *)
   (*  GRENZEN: - Zugriff nur m봥lich auf die Dateien als         *)
   (*  ~~~~~~~~   typenlose (File) Dateien,                       *)
   (*           - Gr붳e der Dateien nicht ver꼗derbar,            *)
   (*           - SCHREIBEN nur innerhalb der Datei m봥lich,      *)
   (*             vergr붳ern der Dateien NICHT m봥lich.           *)
   (*             (ACHTUNG: Keine 쉇erpr갽ung, ob 갶er Datei-     *)
   (*             Ende hinausgeschrieben wird !)                  *)
   (*           - Nur EINE Unter-Datei kann gleichzeitig offen    *)
   (*             sein.                                           *)
   (*                                                             *)
   (*  Folgende Funktionen werden unterst걎zt:                    *)
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
   (* ----------------------------------------------------------- *)

   (* ----------------------------------------------------------- *)
   (*  Aufbau einer Verschl걌selten Datei '????????.XXX':         *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~             *)
   (*                                                             *)
   (*  Die Datei beginnt mit einem Header, der Informationen zur  *)
   (*  Verschl걌selung enth꼕t, dem -->                           *)
   (*                                                             *)
   (*  HAUPT-HEADER (= "TKEYHEADER"):                             *)
   (*  ~~~~~~~~~~~~                                               *)
   (*  00..01  DB  'U', 'K'      =  Kennung                       *)
   (*  02..02  DB  1             =  Version                       *)
   (*  03..05  DB  'K', 'E', 'Y' =  Art                           *)
   (*  06..06  DB  ?             =  Schl걌sel                     *)
   (*  07..49  DB  ?             =  Dummy, f걊 sp꼝ere            *)
   (*                               Erweiterungen frei            *)
   (*                                                             *)
   (*  Es schlie�t sich direkt an der Haupt-Header dann die       *)
   (*  verschl걌selte Datei an, deren L꼗ge genau der L꼗ge ohne  *)
   (*  eine Verschl걌selung entspricht.                           *)
   (* ----------------------------------------------------------- *)

   (* 컴 Verschiedene Konstanten, Typen und Variablen: 컴컴컴컴컴컴컴컴� *)

   CONST (* Eigene Fehlercodes: 0900-0949: *)
         KEYFILE_Error_NoKEYFile             = 0900;

   TYPE (* Header der Haupt-Datei: *)
        TKEYHeader = Record
                      Kennung : Array[1..2] Of Char;   (* 'UK'. *)
                      Version : Byte;                  (* Versionsnummer. *)
                      Art     : Array[1..3] Of Char;   (* 'KEY'. *)
                      Key     : Byte;                  (* Der Schl걌sel. *)
                      Dummy   : Array[1..43] Of Byte;  (* Frei f걊 sp꼝ere Erweiterungen. *)
                     End;

        (* Aktuelle Infos und Zustand: *)
        TKeyFileStatus = Record
                          (* Zustand der Haupt-Datei: *)
                          Assigned  : Boolean;     (* Ob schon was zugewiesen ist. *)
                          Open      : Boolean;     (* Ob Haupt-Datei offen ist. *)
                          F         : File;        (* Die Dateivariable. *)
                          KEYFName  : String[12];

                          KHeader   : TKEYHeader;  (* Der aktuelle Haupt-Header. *)

                          (* Allgemeine Infos: *)
                          RecSize   : Word;        (* Gr붳e eines BLOCKREADRECORDS. *)
                         End;

   VAR K_F             : TKEYFileStatus;  (* Aktueller Status. *)

   (* 컴 Prototypen der Prozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE _K_Assign(Var AF : TKEYFileStatus; AName : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ordnet einer Datei-Variablen eine Unter-Datei zu.    *)
    (*  Eingabe  : ANAME = Name der Unter-Datei in der Haupt-Datei.     *)
    (*  R갷kgabe : AF    = Die entsprechenden Infos zu ANAME werden     *)
    (*                     eingetragen.                                 *)
    (*  Hinweis  : Die Haupt-Datei in AF mu� vorher zugewiesen worden   *)
    (*             sein, mit "AssignMAIN()".                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_Reset(Var AF : TKEYFileStatus; ARecSize : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : 셟fnet eine Unter-Datei in der Haupt-Datei.          *)
    (*  Eingabe  : ARECSIZE = Gr붳e des Records, der mit _BLOCKREAD     *)
    (*                        eingelesen wird.                          *)
    (*  R갷kgabe : AF       = Die entsprechenden Infos zu ARECSIZE      *)
    (*                        werden eingetragen.                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_Close(Var AF : TKEYFileStatus);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schlie�t eine Unter-Datei in der Haupt-Datei.        *)
    (*  R갷kgabe : AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_Read(Var AF : TKEYFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Lie�t ein 1 Byte aus einer Unter-Datei.              *)
    (*  R갷kgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen,                                *)
    (*             ABUF   = Das gelesene Byte.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_BlockRead(Var AF : TKEYFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Lie�t eine Anzahl Bytes aus einer Unter-Datei.       *)
    (*  Eingabe  : ACOUNT = Anzahl von Records die gelesen werden.      *)
    (*  R갷kgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen,                                *)
    (*             ABUF   = Die gelesenen Bytes werden ab ABUF^         *)
    (*                      geschrieben.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_Write(Var AF : TKEYFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt ein 1 Byte in eine Unter-Datei.             *)
    (*  Eingabe  : ABUF   = Das zu schreibende Byte.                    *)
    (*  R갷kgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen.                                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_BlockWrite(Var AF : TKEYFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt eine Anzahl Bytes in eine Unter-Datei.      *)
    (*  Eingabe  : ABUF   = Die Bytes ab ABUF^ werden geschrieben,      *)
    (*             ACOUNT = Anzahl von Records die geschrieben werden.  *)
    (*  R갷kgabe : AF     = Die entsprechenden Infos werden             *)
    (*                      eingetragen.                                *)
    (* ---------------------------------------------------------------- *)

   FUNCTION _K_FileSize(Var AF : TKEYFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die Gr붳e einer Unter-Datei in einer         *)
    (*             Haupt-Datei.                                         *)
    (*  R갷kgabe : L꼗ge der Unter-Datei in Bytes,                      *)
    (*             AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   FUNCTION _K_FilePos(Var AF : TKEYFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die aktuelle, relative Position des Datei-   *)
    (*             Zeigers in einer Unter-Datei.                        *)
    (*  R갷kgabe : L꼗ge der Unter-Datei in Bytes,                      *)
    (*             AF = Die entsprechenden Infos werden eingetragen.    *)
    (*  Hinweise : Wenn die Position am Anfang der Datei steht          *)
    (*             (d.h. vor der ersten Komponente), dann liefert       *)
    (*             FilePos den Wert 0 zur갷k; steht sie auf dem Ende    *)
    (*             der Datei (Eof= True), dann ist FilePos(F)           *)
    (*             identisch mit FileSize(F).                           *)
    (* ---------------------------------------------------------------- *)

   FUNCTION _K_EOF(Var AF : TKEYFileStatus) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Pr갽t, ob das Ende einer Unter-Datei erreicht ist.   *)
    (*  R갷kgabe : TRUE  : Ende der Datei erreicht,                     *)
    (*             FALSE : Ende der Datei noch nicht erreicht,          *)
    (*             AF    = Die entsprechenden Infos werden eingetragen. *)
    (*  Hinweise : EOF ist TRUE, wenn FilePos(F) identisch mit          *)
    (*             FileSize(F) ist.                                     *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _K_Seek(Var AF : TKEYFileStatus; AN : LongInt);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt den Positionszeiger in einer Unter-Datei auf   *)
    (*             eine bestimmte Position.                             *)
    (*  Eingabe  : AN = Position, von 0 .. _FileSize(F).                *)
    (*  R갷kgabe : AF = Die entsprechenden Infos werden eingetragen.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MakeKEYFile(ASourceName, ADestName : String; AKey : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Erzeugt aus einer normalen Datei eine Codierte,      *)
    (*             mit dem dazugeh봱igen KEY-HEADER (s.o.).             *)
    (*  Eingabe  : ASOURCENAME = Name der uncodierten Datei,            *)
    (*             ADESTNAME   = Name der Datei, die in die codiert     *)
    (*                           geschrieben wird,                      *)
    (*             AKEY        = Schl걌sel, mit dem codiert wird.       *)
    (* ---------------------------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE KEYFILEInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles N봳ige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE KEYFILECloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgem꾞.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION KEYFILEGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert Text zum aktuellen Fehler in ERR_Error.   *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                         *)
    (*             AS        = Eventueller zus꼝zlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  R갷kgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   Uses Crt,
        UweERR01,
        UweUNI01;

   (* 컴 Verschiedene Konstanten, Typen und Variablen: 컴컴컴컴컴컴컴컴� *)

   VAR KEYHeader : TKEYHeader;

   (* 컴 Prototypen der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE TestKEYHeader(Var AH : TKEYHeader; Var AF : TKEYFileStatus); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Header korrekt ist (Kennung, Art, ...).   *)
    (*  Eingabe  : AH = Der zu testende Header,                         *)
    (*             AF = Der dazugeh봱ige Status-Record.                 *)
    (*  Hinweis  : Wenn der Test einen Fehler findet, wird              *)
    (*             "CRITICALERROR()" aufgerufen.                        *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE KEYDecode(Var Buf : Pointer; ASize : Word; AKey : Byte); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Decodiert einen Speicherbereich.                     *)
    (*  Eingabe  : BUF   = Zeiger auf den Speicherbereich,              *)
    (*             ASIZE = Gr붳e des Speicherbereichs,                  *)
    (*             AKEY  = Schl걌sel zum decodieren.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE KEYCode(Var Buf : Pointer; ASize : Word; AKey : Byte); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Codiert einen Speicherbereich.                       *)
    (*  Eingabe  : BUF   = Zeiger auf den Speicherbereich,              *)
    (*             ASIZE = Gr붳e des Speicherbereichs,                  *)
    (*             AKEY  = Schl걌sel zum codieren.                      *)
    (* ---------------------------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   { Keine. }

   (* 컴 R걅pfe der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE TestKEYHeader(Var AH : TKEYHeader; Var AF : TKEYFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     If (AH.Kennung <> 'UK') Or (AH.Art <> 'KEY') Then
      Begin
       _K_Close(AF);

       ERR_Error := KEYFILE_Error_NoKEYFile;
       CriticalError(AF.KEYFName);
      End;
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   PROCEDURE KEYDecode(Var Buf : Pointer; ASize : Word; AKey : Byte);
    (* ---------------------------------------------------------------- *)
    Var WH1 : Word;
        PH1 : ^Byte;
        BH1 : Byte;
    Begin
     PH1 := Buf;
     BH1 := AKey;
     For WH1 := 1 To ASize Do
      Begin
       PH1^ := PH1^ XOr BH1;
       Inc(PH1);
      End;
    End;

   PROCEDURE KEYCode(Var Buf : Pointer; ASize : Word; AKey : Byte);
    (* ---------------------------------------------------------------- *)
    Var WH1 : Word;
        PH1 : ^Byte;
        BH1 : Byte;
    Begin
     PH1 := Buf;
     BH1 := AKey;
     For WH1 := 1 To ASize Do
      Begin
       PH1^ := PH1^ XOr BH1;
       Inc(PH1);
      End;
    End;

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   { Keine. }

   (* 컴 Interface횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE _K_Assign(Var AF : TKEYFileStatus; AName : String);
    (* ---------------------------------------------------------------- *)
    Begin
     (* Infos eintragen: *)
     With AF Do
      Begin
       (* Zustand der Haupt-Datei: *)
       Assigned  := TRUE;               (* Ob schon was zugewiesen ist. *)
       Open      := FALSE;              (* Ob Haupt-Datei offen ist. *)
       KEYFName := AName;              (* Name der Hauptdatei. *)
       FillChar(KHeader, SizeOf(KHeader), 0);

       (* Allgemeine Infos: *)
       RecSize   := 0;                  (* Gr붳e eines BLOCKREADRECORDS. *)
      End;

     (* Physikalisch zuweisen: *)
     Assign(AF.F, AF.KEYFName);
    End;

   PROCEDURE _K_Reset(Var AF : TKEYFileStatus; ARecSize : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     (* Physikalischer Reset: *)
     {$I-}
     Reset(AF.F, 1);                    (* Intern: BlockReadSize = 1 Byte. *)
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);

     (* Reset eintragen: *)
     AF.Open := TRUE;                   (* Haupt-Datei offen. *)
     AF.RecSize := ARecSize;

     (* Daten in MAIN-Header einlesen, dabei gleichzeitig auf Datenanfang fahren: *)
     {$I-}
     BlockRead(AF.F, AF.KHeader, SizeOf(AF.KHeader));
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);

     (* Testen, Ggf. Ende: *)
     TestKEYHeader(AF.KHeader, AF);
    End;

   PROCEDURE _K_Close(Var AF : TKEYFileStatus);
    (* ---------------------------------------------------------------- *)
    Begin
     If AF.Open Then                    (* Nur, wenn OFFEN. *)
      Begin
       (* Physikalisches Close: *)
       {$I-}
       Close(AF.F);
       {$I+}
       ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);

       (* Reset eintragen: *)
       AF.Open := FALSE;                (* Haupt-Datei geschlossen. *)
      End;
    End;

   PROCEDURE _K_Read(Var AF : TKEYFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    Var PH1 : Pointer;
    Begin
     {$I-}
     BlockRead(AF.F, ABuf, 1);          (* 1 Byte einlesen. *)
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
     PH1 := @ABuf;
     KEYDecode(PH1, 1, AF.KHeader.Key);
    End;

   PROCEDURE _K_BlockRead(Var AF : TKEYFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     BlockRead(AF.F, ABuf^, AF.RecSize * ACount);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
     KEYDecode(ABuf, AF.RecSize * ACount, AF.KHeader.Key);
    End;

   PROCEDURE _K_Write(Var AF : TKEYFileStatus; Var ABuf : Byte);
    (* ---------------------------------------------------------------- *)
    Var PH1 : Pointer;
    Begin
     PH1 := @ABuf;
     KEYCode(PH1, 1, AF.KHeader.Key);
     {$I-}
     BlockWrite(AF.F, ABuf, 1);         (* 1 Byte einlesen. *)
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   PROCEDURE _K_BlockWrite(Var AF : TKEYFileStatus; Var ABuf : Pointer; ACount : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     KEYCode(ABuf, AF.RecSize * ACount, AF.KHeader.Key);
     {$I-}
     BlockWrite(AF.F, ABuf^, AF.RecSize * ACount);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   FUNCTION _K_FileSize(Var AF : TKEYFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     _K_FileSize := FileSize(AF.F) - SizeOf(TKEYHeader);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   FUNCTION _K_FilePos(Var AF : TKEYFileStatus) : LongInt;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     _K_FilePos := FilePos(AF.F) - SizeOf(TKEYHeader);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   FUNCTION _K_EOF(Var AF : TKEYFileStatus) : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     _K_EOF := Eof(AF.F);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   PROCEDURE _K_Seek(Var AF : TKEYFileStatus; AN : LongInt);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     Seek(AF.F, SizeOf(TKEYHeader) + AN);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AF.KEYFName);
    End;

   PROCEDURE MakeKEYFile(ASourceName, ADestName : String; AKey : Byte);
    (* ---------------------------------------------------------------- *)
    Var FromF, ToF          : File;
        NumRead, NumWritten : Word;
        PXH1                : Pointer;
        Buf                 : Array[1..2048] Of Char;
        AH                  : TKEYHeader;
    Begin
     (* Quelldatei 봣fnen: *)
     Assign(FromF, ASourceName);

     {$I-}
     Reset(FromF, 1);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ASourceName);

     (* ZielDatei 봣fnen: *)
     Assign(ToF, ADestName);

     {$I-}
     Rewrite(ToF, 1);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ADestName);

     (* Header erzeugen: *)
     With AH Do
      Begin
       Kennung := 'UK';
       Version := 1;
       Art     := 'KEY';
       Key     := AKey;
       FillChar(Dummy, SizeOf(Dummy), 0);
      End;

     (* Header schreiben: *)
     {$I-}
     BlockWrite(ToF, AH, SizeOf(AH));
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ADestName);

     Repeat
      {$I-}
      BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
      {$I+}
      ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ASourceName);

      (* Codieren: *)
      PXH1 := @Buf;
      KEYCode(PXH1, SizeOf(Buf), AKey);

      {$I-}
      BlockWrite(ToF, Buf, NumRead, NumWritten);
      {$I+}
      ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ADestName);

     Until (NumRead = 0) Or (NumWritten <> NumRead);

     {$I-}
     Close(FromF);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ASourceName);

     {$I-}
     Close(ToF);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(ADestName);
    End;

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE KEYFILEInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Anfangswerte besetzen: *)
     FillChar(K_F, SizeOf(K_F), 0);

     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(KEYFILECloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(KEYFILEGetErrorMessage);
    End;

   PROCEDURE KEYFILECloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   FUNCTION KEYFILEGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      KEYFILE_Error_NoKEYFile             : S := S + 'Datei ' + UpString(AS + C) + 'hat nicht das KEY-Format.';

      Else                                  S := '';
     End;

     KEYFILEGetErrorMessage := S;
    End;

  (* 컴 INITIALISIERUNGS훂EIL: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   BEGIN
    KEYFILEInitRoutines;
   END.

 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)