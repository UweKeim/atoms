 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)
 (*  Programm : UWE ERROR V 0.1                                            *)
 (*             Routine zum Behandeln von Fehlern.                         *)
 (*             Nun ist nicht mehr in jeder Unit eine eigene Fehler-       *)
 (*             Routine n봳ig, sondern nur noch diese Unit einzubinden.    *)
 (*             Siehe auch HINWEISE, unten !                               *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UWEERR01.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 13. Februar 1995                                           *)
 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)

 UNIT UweERR01;

  {$A-,B-,E+,F+,G+,I-,N+,O-,P-,Q-,R-,S-,T-,V-,X+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ELSE}
  {$D-,L-,Y-}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- 섺FENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   (* 컴 Verschiedene Erkl꼛ungen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* ----------------------------------------------------------- *)
   (*  Um bei einem Fehler noch Dinge zu beenden, gibt es eine    *)
   (*  lineare Liste, in die man Prozeduren eintragen kann,       *)
   (*  die in einem solchen Fall aufgerufen werden.               *)
   (*  Siehe Prozedur "INSERTERRORPROC(..)", unten !              *)
   (*                                                             *)
   (*  Um ein Multi-Units-Programm richtig zu beenden, ruft man   *)
   (*  die Prozedur "CALLALLERRORPROCS" auf, die dann alle        *)
   (*  eingebundenen Prozeduren aufruft, OHNE Fehlermeldung       *)
   (*  auszugeben.                                                *)
   (*                                                             *)
   (*  Man kann hier in der Unit dann f걊 die betreffende Unit    *)
   (*  den Fehlercode ablegen und in der Funktion                 *)
   (*  "ERRGETERRORMESSAGE" seinen Text dazu einbinden.           *)
   (*  Oder man f갾t in die Liste "PERRMESSPROCS" seine eigene    *)
   (*  "GetErrorMessage"-Funktion ein, die dann ebenfalls         *)
   (*  durchsucht wird. diese Funktion mu� den gleichen Header    *)
   (*  wie "ERRGETERRORMESSAGE" haben (siehe dort).               *)
   (*                                                             *)
   (*  Wenn beim Abarbeiten der ErrorProc-Liste wieder ein Fehler *)
   (*  auftritt und Critical Error aufgerufen wird, kann es zu    *)
   (*  Rekursion kommen.                                          *)
   (*  Deshalb ist die Variable CALLCOUNT deklariert. Jedesmal    *)
   (*  beim Aufruf von "CriticalError()" wird der Z꼑ler erh봦t,  *)
   (*  wenn er > 1 ist, wird abrupt abgebrochen durch die         *)
   (*  Prozedur EMERGENCYSTOP.                                    *)
   (* ----------------------------------------------------------- *)

   (* 컴 Verschiedene Typen, Konstanten und Variablen: 컴컴컴컴컴컴컴컴� *)

   CONST (* Fehler-Codes: *)

         (* F걊 DOS: 0-0199 freilassen: *)
         ERR_Error_OK                    = 0000;
         ERR_Error_FileNotFound          = 0002;
         ERR_Error_PathNotFound          = 0003;
         ERR_Error_TooManyOpenFiles      = 0004;
         ERR_Error_FileAccessDenied      = 0005;
         ERR_Error_InvalidFileAccessMode = 0012;
         ERR_Error_InvalidDriveNumber    = 0015;
         ERR_Error_CannotRemoveCurDir    = 0016;
         ERR_Error_CannotRenAcrossDrives = 0017;
         ERR_Error_NoMoreFiles           = 0018;

         ERR_Error_DiskReadError         = 0100;
         ERR_Error_DiskWriteError        = 0101;
         ERR_Error_FileNotAssigned       = 0102;
         ERR_Error_FileNotOpen           = 0103;
         ERR_Error_FileNotOpenForInput   = 0104;
         ERR_Error_FileNotOpenForOutput  = 0105;
         ERR_Error_InvalidNumericFormat  = 0106;

         ERR_Error_DiskIsWriteProtected  = 0150;
         ERR_Error_UnknownUnit           = 0151;
         ERR_Error_DriveNotReady         = 0152;
         ERR_Error_UnknownCommand        = 0153;
         ERR_Error_CRCErrorInData        = 0154;
         ERR_Error_BadDriveReqStrucBlock = 0155;
         ERR_Error_DiskSeekError         = 0156;
         ERR_Error_UnknownMediaType      = 0157;
         ERR_Error_SectorNotFound        = 0158;
         ERR_Error_PrinterOutOfPaper     = 0159;
         ERR_Error_DeviceWriteFault      = 0160;
         ERR_Error_DeviceReadFault       = 0161;
         ERR_Error_HardwareFailure       = 0162;

         (* Zur 쉇ergabe an "InsertErrorProc(..): *)
   TYPE  TProc01             = Procedure;

         (* Zur 쉇ergabe an "InsertErrorMessFunc(..): *)
   TYPE  TFunc01             = Function(AS : String) : String;

         (* Globale Fehlervariable: *)
   CONST ERR_Error           : Integer = ERR_Error_OK;

   (* 컴 Prototypen der Prozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE InsertErrorProc(AProc : TProc01);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F갾t in die Fehler-Prozeduren Liste, die bein einem  *)
    (*             Fehler zur Beendigung der T꼝igkeiten aufgerufen     *)
    (*             wird, eine Prozedur ein.                             *)
    (*  Eingabe  : APROC = Prozedur, OHNE ! Parameter, die              *)
    (*                     aufgerufen werden soll.                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE InsertErrorMessageFunc(AMessFunc : TFunc01);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F갾t in die Fehler-Message Liste, die bein suchen    *)
    (*             nach einem Text zus꼝zlich zu "ErrGetErrorMessage"   *)
    (*             aufgerufen wird eine weitere zum durchsuchen ein.    *)
    (*             Siehe auch "Hinweise", oben.                         *)
    (*  Eingabe  : AMESSFUNC = Funktion, die den Text ermittelt.        *)
    (* ---------------------------------------------------------------- *)

   FUNCTION CallAllErrorMessageFuncs(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ruft alle Prozeduren in der Liste "ERRErrorMessFunc" *)
    (*             nacheinander auf. Wenn Nummer gefunden, wird Text    *)
    (*             zur갷kgegeben, sonst ''.                             *)
    (*  Eingabe  : AS = Text, der noch zus꼝zlich zum Fehlertext mit    *)
    (*                  ausgegeben werden kann, ist abh꼗gig vom Typ    *)
    (*                  des Fehlers (z.B. Dateiname bei Ladefehler).    *)
    (*  Hinweise : Vorher immer die Variable ERR_Error setzen !         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CallAllErrorProcs;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ruft alle Prozeduren in der Liste "ERRErrorProc"     *)
    (*             nacheinander auf.                                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CriticalError(AS : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Wird bei einem kritischen Fehler aufgerufen.         *)
    (*  Eingabe  : AS = Text, der noch zus꼝zlich zum Fehlertext mit    *)
    (*                  ausgegeben werden kann, ist abh꼗gig vom Typ    *)
    (*                  des Fehlers (z.B. Dateiname bei Ladefehler).    *)
    (*  Hinweise : Diese Prozedur kann von jedem Programm aus bei       *)
    (*             einem Fehler aufgerufen werden und beendet das       *)
    (*             Programm unverz갾lich !                              *)
    (*             Vorher immer die Variable ERR_Error setzen !         *)
    (* ---------------------------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE ERRInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles N봳ige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ERRCloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgem꾞.                         *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   USES Crt,
        UweUNI01;

   (* 컴 Verschiedene Typen, Konstanten und Variablen: 컴컴컴컴컴컴컴컴� *)

         (* Fehler-Prozeduren-Liste: *)
   TYPE  PERRErrorProc       = ^TERRErrorProc;
         TERRErrorProc       = Record
                                ErrorProc : TProc01;
                                Next      : PERRErrorProc;
                                Last      : PERRErrorProc;
                               End;

         (* Fehler-Message-Functionen-Liste: *)
   TYPE  PERRErrorMessFunc   = ^TERRErrorMessFunc;
         TERRErrorMessFunc   = Record
                                ErrorMessFunc : TFunc01;
                                Next          : PERRErrorMessFunc;
                                Last          : PERRErrorMessFunc;
                               End;

   CONST ERRErrorProc        : PERRErrorProc     = Nil;
         ERRErrorMessFunc    : PERRErrorMessFunc = Nil;

         (* Wie oft selbe Fehler-Routine aufgerufen: *)
   CONST CallCount           : Integer = 0;

   (* 컴 Prototypen der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   FUNCTION ERRGetErrorMessage(AS : String) : String; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_ERROR.  *)
    (*  Eingabe  : ERR_ERROR = Fehlernummer,                            *)
    (*             AS        = Eventueller zus꼝zlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  R갷kgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE EmergencyStop; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Bewirkt SOFORTIGEN Halt des Programms.               *)
    (*  Hinweise : Es wird in Modus CO80 geschalten.                    *)
    (* ---------------------------------------------------------------- *)

   (* 컴 R걅pfe der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   FUNCTION ERRGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* F걊 DOS: 0-1000 freilassen: *)
      ERR_Error_Ok                    : S := S + 'Es liegt kein Fehler vor, alles OK.';
      ERR_Error_FileNotFound          : S := S + 'Datei ' + UpString(NameString(AS) + ExtString(AS) + C) + 'nicht gefunden.';
      ERR_Error_PathNotFound          : S := S + 'Pfad ' + UpString(DirString(AS) + C) + 'nicht gefunden.';
      ERR_Error_TooManyOpenFiles      : S := S + 'Zu viele offene Dateien.';
      ERR_Error_FileAccessDenied      : S := S + 'Dateizugriff verweigert.';
      ERR_Error_InvalidFileAccessMode : S := S + 'Ung걄tiger Zugriffscode.';
      ERR_Error_InvalidDriveNumber    : S := S + 'Ung걄tiges Laufwerk.';
      ERR_Error_CannotRemoveCurDir    : S := S + 'Aktuelles Verzeichnis kann nicht gel봲cht werden.';
      ERR_Error_CannotRenAcrossDrives : S := S + 'Umbenennen 갶er Laufwerke hinweg nicht erlaubt.';
      ERR_Error_NoMoreFiles           : S := S + 'Keine weiteren Dateien.';

      ERR_Error_DiskReadError         : S := S + 'Fehler beim Lesen von Diskette/Festplatte.';
      ERR_Error_DiskWriteError        : S := S + 'Fehler beim Schreiben auf Diskette/Festplatte.';
      ERR_Error_FileNotAssigned       : S := S + 'Datei-Variable ist keiner Datei zugeordnet.';
      ERR_Error_FileNotOpen           : S := S + 'Datei ' + UpString(AS + C) + 'nicht ge봣fnet.';
      ERR_Error_FileNotOpenForInput   : S := S + 'Datei ' + UpString(AS + C) + 'wurde nicht f걊 Leseoperationen ge봣fnet.';
      ERR_Error_FileNotOpenForOutput  : S := S + 'Datei ' + UpString(AS + C) + 'wurde nicht f걊 Schreibeoperationen ge봣fnet.';
      ERR_Error_InvalidNumericFormat  : S := S + 'Ung걄tiges numerisches Format.';

      ERR_Error_DiskIsWriteProtected  : S := S + 'Diskette ist schreibgesch걎zt.';
      ERR_Error_UnknownUnit           : S := S + 'Peripherie ist nicht bekannt/nicht angeschlossen.';
      ERR_Error_DriveNotReady         : S := S + 'Laufwerk ist nicht bereit.';
      ERR_Error_UnknownCommand        : S := S + 'Ung걄tiger DOS-Funktionscode/Funktion nicht definiert.';
      ERR_Error_CRCErrorInData        : S := S + 'CRC-Fehler in Daten.';
      ERR_Error_BadDriveReqStrucBlock : S := S + 'Ung걄tiger Laufwerks-Parameterblock.';
      ERR_Error_DiskSeekError         : S := S + 'Seek-Fehler auf Laufwerk.';
      ERR_Error_UnknownMediaType      : S := S + 'Unbekanntes Sektorformat.';
      ERR_Error_SectorNotFound        : S := S + 'Sektor nicht gefunden.';
      ERR_Error_PrinterOutOfPaper     : S := S + 'Drucker hat kein Papier.';
      ERR_Error_DeviceWriteFault      : S := S + 'Fehler beim Schreiben auf Peripherieger꼝.';
      ERR_Error_DeviceReadFault       : S := S + 'Fehler beim Lesen von Peripherieger꼝.';
      ERR_Error_HardwareFailure       : S := S + 'Hardware-Fehler.';

      Else                              S := '';
     End;

     ERRGetErrorMessage := S;
    End;

   PROCEDURE EmergencyStop;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Videomodus 3h (Text): *)
     Asm
      mov   ax, CO80
      int   10h
     End;

     (* Text ausgeben: *)
     ClrScr;
     WriteLn('Fehler : Abnormaler Halt.');

     (* Programm anhalten: *)
     Halt($0101);
    End;

   (* 컴 Interface횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE InsertErrorProc(AProc: TProc01);
    (* ---------------------------------------------------------------- *)
    Var PH1 : PERRErrorProc;
    Begin
     PH1 := ERRErrorProc;               (* Wurzel. *)

     (* Wenn 1. Element in Liste: *)
     If PH1 = NIL Then
      Begin
       New(ERRErrorProc);
       PH1 := ERRErrorProc;
       PH1^.Last := NIL;
       PH1^.Next := NIL;
       PH1^.ErrorProc := AProc;
      End

     (* Wenn schon Elemente in Liste: *)
     Else
      Begin
       While PH1^.Next <> NIL Do PH1 := PH1^.Next;
       New(PH1^.Next);
       PH1^.Next^.Last := PH1;
       PH1 := PH1^.Next;
       PH1^.Next := NIL;
       PH1^.ErrorProc := AProc;
      End;
    End;

   PROCEDURE InsertErrorMessageFunc(AMessFunc : TFunc01);
    (* ---------------------------------------------------------------- *)
    Var PH1 : PERRErrorMessFunc;
    Begin
     PH1 := ERRErrorMessFunc;               (* Wurzel. *)

     (* Wenn 1. Element in Liste: *)
     If PH1 = NIL Then
      Begin
       New(ERRErrorMessFunc);
       PH1 := ERRErrorMessFunc;
       PH1^.Last := NIL;
       PH1^.Next := NIL;
       PH1^.ErrorMessFunc := AMessFunc;
      End

     (* Wenn schon Elemente in Liste: *)
     Else
      Begin
       While PH1^.Next <> NIL Do PH1 := PH1^.Next;
       New(PH1^.Next);
       PH1^.Next^.Last := PH1;
       PH1 := PH1^.Next;
       PH1^.Next := NIL;
       PH1^.ErrorMessFunc := AMessFunc;
      End;
    End;

   PROCEDURE CallAllErrorProcs;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PERRErrorProc;
    Begin
     PH1 := ERRErrorProc;               (* Wurzel. *)
     If @PH1 = Nil Then Exit;           (* Wenn nichts in Liste, Ende. *)

     (* Alle Listen-Eintr꼏e durch: *)
     While PH1 <> Nil Do
      Begin
       PH1^.ErrorProc;                  (* Rufe Fehler-Prozedur auf. *)
       PH1 := PH1^.Next;                (* N꼊hstes Listenelement. *)
      End;
    End;

   FUNCTION CallAllErrorMessageFuncs(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PERRErrorMessFunc;
        SH1 : String;
    Begin
     SH1 := '';
     PH1 := ERRErrorMessFunc;           (* Wurzel. *)
     If @PH1 = Nil Then Exit;           (* Wenn nichts in Liste, Ende. *)

     (* Alle Listen-Eintr꼏e durch: *)
     While PH1 <> Nil Do
      Begin
        SH1 := PH1^.ErrorMessFunc(AS);   (* Rufe Fehler-Prozedur auf. *)
       If SH1 <> '' Then Break;         (* Wenn gefunden, Ende. *)
       PH1 := PH1^.Next;                (* N꼊hstes Listenelement. *)
      End;

     CallAllErrorMessageFuncs := SH1;
    End;

   PROCEDURE CriticalError(AS : String);
    (* ---------------------------------------------------------------- *)
    Const AllowedOwnCalls = 1;
    Var   ErrString : String;
    Begin
     (* Wenn kein Fehler, Ende: *)
     If ERR_Error = 0 Then Exit;        (* Es liegt kein Fehler vor. *)

     (* Erh봦e Z꼑ler f걊 eigenen Aufruf: *)
     Inc(CallCount);
     If CallCount > AllowedOwnCalls Then EmergencyStop;

     (* Hole Fehlermeldung: *)
     ErrString := CallAllErrorMessageFuncs(AS);

     (* Wenn nichts gefunden, unbekannt: *)
     If ErrString = '' Then
      Begin
       Str(ERR_Error, ErrString);
       ErrString := 'Fehler Nr. ' + ErrString + ' : Unbekannter Fehler.';
      End;

     CallAllErrorProcs;                 (* Rufe ggf. externe Fehlerroutine auf. *)

     ClrScr;
     WriteLn(ErrString);                (* Fehlermeldung ausgeben. *)

     Halt(ERR_Error);                   (* Halte Programm mit Fehlernummer an. *)
    End;

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE ERRInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(ERRCloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(ERRGetErrorMessage);
    End;

   PROCEDURE ERRCloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Textmodus 3h (Standart): *)
     Asm
      mov   ax, 0003h
      int   10h
     End;
    End;

  (* 컴 INITIALISIERUNGS훂EIL: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   BEGIN
    ERRInitRoutines;
   END.

 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)