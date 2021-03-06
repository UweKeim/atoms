 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)
 (*  Programm : INIT PARSE                                                 *)
 (*             Zum Lesen von Definitionen aus einer Init-Datei.           *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : INIPARS1.PAS                                               *)
 (*             Haupt-Unit.                                                *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 07.04.1995 Uwe Keim - Anfang.                              *)
 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)

 UNIT INIPARS1;

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
   (*  INI-Dateien d걊fen nicht mit ONEFILE oder KEYFILE          *)
   (*  gepackt/verschl걌selt sein !                               *)
   (*                                                             *)
   (*  Aufbau einer INI-Datei:                                    *)
   (*  ~~~~~~~~~~~~~~~~~~~~~~~                                    *)
   (*   Eine Zeile, die mit ";" beginnt ist eine Kommentarzeile.  *)
   (*   Gro�-/Kleinschrift wird nicht unterschieden.              *)
   (*   Eine Zuweisung ("X = Y") darf auf der rechten Seite des   *)
   (*   "=" nur 1 Wort haben. Dieses Wort darf nur 갶er 1 Zeile   *)
   (*   gehen und keine Blanks oder Tabs beinhalten.              *)
   (*                                                             *)
   (*   Zul꼜sige Zuweisungen (Beispiele):                        *)
   (*                                                             *)
   (*    "X = Y,X,Z_ABC",                                         *)
   (*    "Y = c:\data\",                                          *)
   (*    "X = �".                                                 *)
   (*                                                             *)
   (*   Unzul꼜sige Zuweisungen (Beispiele):                      *)
   (*                                                             *)
   (*    "X = Y + 3"          (Leerzeichen " " nicht zul꼜sig),   *)
   (*    "Y = c,        d"    (Tabulator (#9) nicht zul꼜sig),    *)
   (*    "Y = 0;1;2;3;        (Strichpunkt ";" nicht zul꼜sig,    *)
   (*                          da reserviert f걊 Kommentar).      *)
   (*                                                             *)
   (*   Beispiel einer INI-Datei:                                 *)
   (*                                                             *)
   (*    "; INI-Datei f걊 das Spiel ATOMIX.EXE                    *)
   (*     ; Erstellt am 07.04.1995 Uwe Keim.                      *)
   (*                                                             *)
   (*     [SoundBlaster]                                          *)
   (*                                                             *)
   (*     DMA  = 1                                                *)
   (*     PORT = 220                                              *)
   (*     IRQ  = 7                                                *)
   (*     TYPE = SB_PRO"                                          *)
   (* ----------------------------------------------------------- *)

   (* 컴 Verschiedene Konstanten, Typen und Variablen: 컴컴컴컴컴컴컴컴� *)

   (* 컴 Prototypen der Prozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)

   FUNCTION GetString(AGroup, AItem : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Wert in einer INI-Datei.                 *)
    (*  Eingabe  : AGROUP = Gruppe, zu der AITEM geh봱t,                *)
    (*             AITEM  = Eintrag in der Gruppe AGROUP.               *)
    (*  R갷kgabe : '' (Leerstring), wenn nicht gefunden, sonst den      *)
    (*             Eintrag hinter AITEM.                                *)
    (*  Hinweise : - AGROUP kann in '[]' geschrieben werden oder nicht  *)
    (*               (Also z.B. ist '[OPTIONEN]' gleich wie 'OPTIONEN'. *)
    (*             - Gro�-/Kleinschreibung wird nicht ber갷ksichtigt.   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ExistsGroup(AGroup : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Gruppe vorhanden ist.                     *)
    (*  Eingabe  : AGROUP = Gruppe, nach der gesucht werden soll.       *)
    (*  R갷kgabe : TRUE  = Ja, Gruppe existiert,                        *)
    (*             FALSE = Nein, Gruppe existiert nicht.                *)
    (*  Hinweise : - AGROUP kann in '[]' geschrieben werden oder nicht  *)
    (*               (Also z.B. ist '[OPTIONEN]' gleich wie 'OPTIONEN'. *)
    (*             - Gro�-/Kleinschreibung wird nicht ber갷ksichtigt.   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ExistsItem(AGroup, AItem : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Eintrag in Gruppe vorhanden ist.          *)
    (*  Eingabe  : AGROUP = Gruppe, nach der gesucht werden soll        *)
    (*             AITEM  = Eintrag, in AGROUP, der zu suchen ist.      *)
    (*  R갷kgabe : TRUE  = Ja, Gruppe existiert,                        *)
    (*             FALSE = Nein, Gruppe existiert nicht.                *)
    (*  Hinweise : - AGROUP kann in '[]' geschrieben werden oder nicht  *)
    (*               (Also z.B. '[OPTIONEN]' gleich wie 'OPTIONEN').    *)
    (*             - Gro�-/Kleinschreibung wird nicht ber갷ksichtigt.   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE OpenINIFile(AFName : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : 셟fnet INI-Datei zum lesen.                          *)
    (*  Eingabe  : AFNAME = Vollst꼗diger (!) Dateiname der INI-Datei.  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CloseINIFile;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schlie�t INI-Datei.                                  *)
    (* ---------------------------------------------------------------- *)

   (* 같 SYSTEM-ROUTINEN: 같같같같같같같같같같같같같같같같같같같같같같� *)

   PROCEDURE PARSINIInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles N봳ige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE PARSINICloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgem꾞.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION PARSINIGetErrorMessage(AS : String) : String;
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
       TextFile,
       UweERR01,
       UweUNI01;

   (* 컴 Verschiedene Konstanten, Typen und Variablen: 컴컴컴컴컴컴컴컴� *)

         (* Fehlermeldungen: *)
   CONST PARSINI_Error_GroupNotFound     = 0750;
         PARSINI_Error_ItemNotFound      = 0751;

         (* Benutzte Zeichen: *)
   CONST Comment             = ';';
         Space               = #32;
         Tab                 = #09;
         Equal               = '=';
         Return              = #13;
         LineFeed            = #10;
         GroupStart          = '[';

   VAR   F                   : Text;

   (* 컴 Prototypen der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴 *)

   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)

   FUNCTION IsEof : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Dateiende erreicht.                       *)
    (*  R갷kgabe : TRUE  = Ja, Ende erreicht,                           *)
    (*             FALSE = Nein, nicht am Ende.                         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GoOneBack; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F꼑rt aktuellen Dateizeiger um 1 Position zur갷k.    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GoOneForward; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F꼑rt aktuellen Dateizeiger um 1 Position vorw꼛ts.  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ReadChar : Char; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liest Zeichen an der aktuellen Position, verschiebt  *)
    (*             den Dateizeiger.                                     *)
    (*  R갷kgabe : Gelesenes Zeichen.                                   *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ReadCharStay : Char; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liest Zeichen an der aktuellen Position, verschiebt  *)
    (*             den Dateizeiger NICHT.                               *)
    (*  R갷kgabe : Gelesenes Zeichen.                                   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SkipBlanks; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : 쉇erspringt Blanks (TAB, SPACE) ab der aktuellen     *)
    (*             Dateiposition.                                       *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE NewLine; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Setzt Dateizeiger auf Beginn der n꼊hsten Zeile.     *)
    (* ---------------------------------------------------------------- *)

   FUNCTION SkipCommentLine : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : 쉇erspringt eine Kommentarzeile.                     *)
    (*  R갷kgabe : TRUE  = Die Zeile war Kommentarzeile,                *)
    (*             FALSE = Die Zeile war keine Kommentarzeile.          *)
    (*  Hinweise : Es wird davon ausgegangen, da� der Dateizeiger am    *)
    (*             ANFANG einer Zeile steht.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SkipBlankLines; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : 쉇erspringt eine leere Zeile ab der aktuellen        *)
    (*             Dateiposition, die entweder ganz leer ist oder die   *)
    (*             nur SPACE, TAB enth꼕t.                              *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ReadOneWord : String; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Lie�t ein Wort ab aktueller Dateiposition ein.       *)
    (*  R갷kgabe : '', wenn kein Wort gefunden,                         *)
    (*             sonst gelesenes Wort.                                *)
    (*  Hinweise : Ein WORT ist jede Zeichenfolge die nicht die Zeichen *)
    (*             SPACE, TAB, '=' enth꼕t.                             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SkipOverNextEqual; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F꼑rt den Dateizeiger an die Position nach dem       *)
    (*             n꼊hsten '='.                                        *)
    (* ---------------------------------------------------------------- *)

   FUNCTION IsNewGroup : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob Dateizeiger am Anfang einer neuen Gruppe  *)
    (*             steht.                                               *)
    (*  R갷kgabe : TRUE  = Ja, Zeiger steht an neuer Gruppe,            *)
    (*             FALSE = Nein, nicht an neuer Gruppe.                 *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SkipTilValidValue; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F꼑rt den Dateizeiger von der aktuellen Position     *)
    (*             갶er alle Kommentare, Leerzeilen, etc. bis zum       *)
    (*             n꼊hsten Zeichen, das Bedeutung hat.                 *)
    (* ---------------------------------------------------------------- *)

   FUNCTION SeekGroup(AGroup : String) : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F꼑rt Dateizeiger an Anfang einer Gruppe.            *)
    (*  Eingabe  : AGROUP = Gruppe, die angefahren werden soll.         *)
    (*  R갷kgabe : TRUE   = Gefunden,                                   *)
    (*             FALSE  = Nicht gefunden.                             *)
    (* ---------------------------------------------------------------- *)

   FUNCTION SeekItem(AItem : String) : Boolean; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F꼑rt Dateizeiger von der aktuellen Position ab an   *)
    (*             die Position nach dem gesuchten Eintrag.             *)
    (*  Eingabe  : AITEM = Eintrag, der angefahren werden soll.         *)
    (*  R갷kgabe : TRUE  = Gefunden,                                    *)
    (*             FALSE = Nicht gefunden.                              *)
    (*  Hinweise : Es wird nur bis zum Beginn der n꼊hsten Gruppe       *)
    (*             gesucht.                                             *)
    (* ---------------------------------------------------------------- *)

   (* 컴 R걅pfe der Implementations횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   FUNCTION IsEOF : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     IsEOF := EOF(F);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   PROCEDURE GoOneBack;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     If TextFilePos(F) <> 0 Then TextSeek(F, TextFilePos(F)-1);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   PROCEDURE GoOneForward;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     If Not IsEOF Then TextSeek(F, TextFilePos(F)+1);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   FUNCTION ReadChar : Char;
    (* ---------------------------------------------------------------- *)
    Var CH1 : Char;
    Begin
     {$I-}
     Read(F, CH1);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
     ReadChar := CH1;
    End;

   FUNCTION ReadCharStay : Char;
    (* ---------------------------------------------------------------- *)
    Begin
     ReadCharStay := ReadChar;
     GoOneBack;
    End;

   PROCEDURE SkipBlanks;
    (* ---------------------------------------------------------------- *)
    Begin
     While ReadCharStay In [Space, Tab] Do GoOneForward;
    End;

   PROCEDURE NewLine;
    (* ---------------------------------------------------------------- *)
    Begin
     While (ReadChar <> LineFeed) Do If IsEOF Then Exit;
    End;

   FUNCTION SkipCommentLine : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     If IsEOF Then Exit;
     SkipBlanks;
     While ReadCharStay = Comment Do NewLine;
    End;

   PROCEDURE SkipBlankLines;
    (* ---------------------------------------------------------------- *)
    Begin
     If IsEOF Then Exit;
     While ReadCharStay In [Return, LineFeed, Space, Tab] Do GoOneForward;
    End;

   FUNCTION ReadOneWord : String;
    (* ---------------------------------------------------------------- *)
    Var SH1 : String;
    Begin
     SkipBlanks;
     SH1 := '';
     While (Not (ReadCharStay In [Space, Tab, Equal, Return])) Do
      Begin
       SH1 := SH1 + ReadChar;

       If IsEOF Then Break;
      End;
     ReadOneWord := SH1;
    End;

   PROCEDURE SkipOverNextEqual;
    (* ---------------------------------------------------------------- *)
    Begin
     SkipBlanks;
     While ReadChar <> Equal Do;
     SkipBlanks;
    End;

   FUNCTION IsNewGroup : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     If ReadCharStay = GroupStart Then IsNewGroup := TRUE
     Else                              IsNewGroup := FALSE;
     If IsEOF Then IsNewGroup := FALSE;
    End;

   PROCEDURE SkipTilValidValue;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Nur, wenn kein Brauchbares: *)
     While ReadCharStay In [Space, Tab, LineFeed, Return, Comment] Do
      Begin
       SkipBlanks;
       SkipCommentLine;
       SkipBlankLines;

       SkipBlanks;
       SkipBlankLines;
       SkipCommentLine;

       SkipCommentLine;
       SkipBlanks;
       SkipBlankLines;

       SkipCommentLine;
       SkipBlankLines;
       SkipBlanks;

       SkipBlankLines;
       SkipBlanks;
       SkipCommentLine;

       SkipBlankLines;
       SkipCommentLine;
       SkipBlanks;
      End;
    End;

   FUNCTION SeekGroup(AGroup : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    Var SH1 : String;
    Begin
     SH1 := '';
     (* Gruppen-Text bearbeiten: *)
     AGroup := UpString(AGroup);
     If (AGroup[1] <> '[') And (AGroup[Length(AGroup)] <> ']') Then
      AGroup := '[' + AGroup + ']';

     SeekGroup := FALSE;
     {$I-}
     TextSeek(F, 0);                        (* An Dateianfang. *)
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));

     While Not IsEOF Do
      Begin
       SkipTilValidValue;

       SH1 := UpString(ReadOneWord);
       If SH1 = AGroup Then
        Begin
         NewLine;
         SeekGroup := TRUE;
         Break;
        End
       Else If SH1 = '' Then Break;

       NewLine;
      End;
    End;

   FUNCTION SeekItem(AItem : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    Var SH1 : String;
    Begin
     SH1 := '';
     AItem := UpString(AItem);

     SeekItem := FALSE;

     (* Suche Eintrag: *)
     While Not IsEOF Do
      Begin
       SkipTilValidValue;
       If IsNewGroup Then Break;        (* Wenn Dateizeiger an neuer Gruppe *)
                                        (* steht, Ende.                     *)

       SH1 := UpString(ReadOneWord);
       If SH1 = AItem Then
        Begin
         SkipBlanks;
         SkipOverNextEqual;
         SkipBlanks;

         SeekItem := TRUE;
         Break;
        End
       Else If SH1 = '' Then
        Begin
         Break;
        End;

       NewLine;
      End;
    End;

   (* 컴 Interface횾rozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 NORMALE PROZEDUREN: 같같같같같같같같같같같같같같같같같같같같같 *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   FUNCTION GetString(AGroup, AItem : String) : String;
    (* ---------------------------------------------------------------- *)
    Begin
     GetString := '';
     If SeekGroup(AGroup) Then
      Begin
       If SeekItem(AItem) Then GetString := ReadOneWord
       Else
        Begin
         ERR_Error := PARSINI_Error_ItemNotFound;
         CriticalError(UpString(AItem)+' in Gruppe '+UpString(AGroup));
        End;
      End
     Else
      Begin
       ERR_Error := PARSINI_Error_GroupNotFound;
       CriticalError(AGroup);
      End;
    End;

   FUNCTION ExistsGroup(AGroup : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     If SeekGroup(AGroup) Then ExistsGroup := TRUE
     Else                      ExistsGroup := FALSE;
    End;

   FUNCTION ExistsItem(AGroup, AItem : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     ExistsItem := FALSE;
     If SeekGroup(AGroup) Then
      If SeekItem(AItem) Then
       If ReadOneWord <> '' Then ExistsItem := TRUE;
    End;

   PROCEDURE OpenINIFile(AFName : String);
    (* ---------------------------------------------------------------- *)
    Begin
     Assign(F, AFName);

     {$I-}
     Reset(F);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);
    End;

   PROCEDURE CloseINIFile;
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     Close(F);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같 SYSTEM-ROUTINEN: 같같같같같같같같같같같같같같같같같같같같같같� *)
   (* 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� *)

   PROCEDURE PARSINIInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(PARSINICloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(PARSINIGetErrorMessage);
    End;

   PROCEDURE PARSINICloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   FUNCTION PARSINIGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      PARSINI_Error_GroupNotFound     : S := S + 'Gruppe ' + UpString(AS + C) + 'in INI-Datei nicht gefunden.';
      PARSINI_Error_ItemNotFound      : S := S + 'Eintrag ' + AS + C + 'in INI-Datei nicht gefunden.';

      Else                              S := '';
     End;

     PARSINIGetErrorMessage := S;
    End;

  (* 컴 INITIALISIERUNGS훂EIL: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   BEGIN
    PARSINIInitRoutines;
   END.

 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)