 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)
 (*  Programm : INIT MAKE                                                  *)
 (*             Zum Erzeugen von Init-Dateien mit Definitionen             *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : INIMAKE1.PAS                                               *)
 (*             Haupt-Unit.                                                *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 08.04.1995 Uwe Keim - Anfang.                              *)
 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)

 UNIT INIMAKE1;

  (*ÄÄ COMPILER-EINSTELLUNGEN: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)

  {$A-,B-,E+,F+,G+,I-,N+,O-,P-,Q-,R-,S-,T-,V-,X+}
  {$M 16384,0,655360}

  {$UNDEF  DEBUG}                       (* Debug-Infos AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ELSE}
  {$D-,L-,Y-}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- ™FFENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   (* ÄÄ Verschiedene Erkl„rungen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ----------------------------------------------------------- *)
   (*  Diese Unit ist das Komplement zu INIPARS1.PAS.             *)
   (*                                                             *)
   (*  Siehe Programm EXAM_003.PAS                                *)
   (*                                                             *)
   (*  Es wird nicht geprft, ob in einer Gruppe ein Eintrag      *)
   (*  mehrmals vorkommt.                                         *)
   (*  Das Konstrukt                                              *)
   (*                                                             *)
   (*   [Gruppe1]                                                 *)
   (*    Eintrag1 = A                                             *)
   (*    Eintrag1 = B                                             *)
   (*                                                             *)
   (*  beispielsweise wrde nicht als Fehler erkannt. Hier ist    *)
   (*  also Vorsicht geboten.                                     *)
   (* ----------------------------------------------------------- *)

   (* ÄÄ Verschiedene Konstanten, Typen und Variablen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ÄÄ Prototypen der Prozeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °° NORMALE PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE PutString(AGroup, AItem, AValue : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Fgt an die aktuelle Liste der Eintr„ge einen an.    *)
    (*  Eingabe  : AGROUP = Gruppe, zu der AITEM geh”rt,                *)
    (*             AITEM  = Eintrag in der Gruppe AGROUP.               *)
    (*             AVALUE = Zu schreibender Text.                       *)
    (*  Hinweise : - AGROUP kann in '[]' geschrieben werden oder nicht  *)
    (*               (Also z.B. '[OPTIONEN]' gleich wie 'OPTIONEN').    *)
    (*             - Groá-/Kleinschreibung wird nicht bercksichtigt.   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteINIFile(AFName : String);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt den Inhalt der aktuellen Liste der Eintr„ge *)
    (*             in eine Datei.                                       *)
    (*  Eingabe  : AFNAME = Vollst„ndiger (!) Dateiname der INI-Datei.  *)
    (*  Hinweise : - Die Datei wird dabei neu erzeugt. Eine bereits     *)
    (*               vorhandene Datei wird zuerst gel”scht.             *)
    (*             - Nach dem Schreiben, wird die aktuelle Liste der    *)
    (*               Eintr„ge gel”scht.                                 *)
    (* ---------------------------------------------------------------- *)

   (* °° SYSTEM-ROUTINEN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE MAKEINIInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles N”tige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE MAKEINICloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgem„á.                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MAKEINIGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.  *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                            *)
    (*             AS        = Eventueller zus„tzlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  Rckgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   USES Crt, Dos,
        UweERR01,
        UweUNI01;

   (* ÄÄ Verschiedene Konstanten, Typen und Variablen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

         (* Eigene Fehlercodes: 0000-0000: *)
         (* Siehe dazu auch Datei C:\UTILY\COMP\BP\UWEUNITS\ERRCODES.DOC. *)
   CONST MAKEINI_Error_XxXXXXxxx         = 0000;

         (* Liste mit Gruppen und Eintr„gen: *)
   TYPE  PStringList         = ^TStringList;
         TStringList         = Record
                                Group : String;
                                Item  : String;
                                Value : String;
                                Next  : PStringList;
                                Last  : PStringList;
                               End;

   CONST StringList          : PStringList = Nil;

   VAR   F                   : Text;

   (* ÄÄ Prototypen der ImplementationsÄProzeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °° NORMALE PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   FUNCTION SeekListEnd : PStringList; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : F„hrt an Ende der Liste.                             *)
    (*  Rckgabe : Zeiger auf letztes Element.                          *)
    (* ---------------------------------------------------------------- *)

   FUNCTION CreateNewListElement(AP : PStringList) : PStringList; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Erzeugt neues, leeres Listenelement.                 *)
    (*  Eingabe  : AP = Zeiger auf Position in Liste, hinter der das    *)
    (*                  Element erzeugt werden soll.                    *)
    (*  Rckgabe : Ggf. ge„nderter Zeiger auf das neu erstellte Element *)
    (*             (ge„ndert, wenn z.B. AP noch NIL war).               *)
    (* ---------------------------------------------------------------- *)

   FUNCTION SearchNextSameGroup(AGroup : String; AP : PStringList) : PStringList; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Sucht nach n„chstem Listenelement, das zu AGROUP     *)
    (*             geh”rt.                                              *)
    (*  Eingabe  : AGROUP = Gruppe, zu der n„chstes Element geh”ren     *)
    (*                      soll.                                       *)
    (*             AP     = Zeiger auf aktuelle Position in der Liste.  *)
    (*  Rckgabe : Zeiger auf n„chstes gefundenes Element.              *)
    (*             Wenn nichts gefunden, NIL.                           *)
    (* ---------------------------------------------------------------- *)

   FUNCTION UniformGroup(AGroup : String) : String; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Macht aus einem Gruppennamen einen Einheitlichen.    *)
    (*  Eingabe  : AGROUP = zu formatierender Gruppenname.              *)
    (*  Rckgabe : Formatierter Gruppenname.                            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteINIHeader; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Erstellt den Kommentar-Header einer INI-Datei und    *)
    (*             schreibt diesen an aktuelle Position in der Datei.   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteGroup(AGroup : String); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt in die aktuelle Position in der Datei eine  *)
    (*             neue Gruppe.                                         *)
    (*  Eingabe  : AGROUP = Zu schreibender Gruppenname.                *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteItem(AItem, AValue : String); Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt in die aktuelle Position in der Datei       *)
    (*             einen neuen Eintrag.                                 *)
    (*  Eingabe  : AITEM  = Zu schreibender Eintragname.                *)
    (*             AVALUE = Zu schreibender Wert.                       *)
    (* ---------------------------------------------------------------- *)

   FUNCTION DeleteActualElement(AP : PStringList) : PStringList; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : L”scht Listenelement.                                *)
    (*  Eingabe  : AP = Zeiger auf Position in Liste, an der Element    *)
    (*                  gel”scht werden soll.                           *)
    (*  Rckgabe : Zeiger auf das n„chste Element.                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ClearList; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : L”scht die Liste der Eintr„ge.                       *)
    (* ---------------------------------------------------------------- *)

   (* °° SYSTEM-ROUTINEN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   (* ÄÄ Rmpfe der ImplementationsÄProzeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° NORMALE PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   FUNCTION SeekListEnd : PStringList;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PStringList;
    Begin
     PH1 := StringList;
     If PH1 <> Nil Then While PH1^.Next <> Nil Do PH1 := PH1^.Next;
     SeekListEnd := PH1;
    End;

   FUNCTION CreateNewListElement(AP : PStringList) : PStringList;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PStringList;
    Begin
     (* Fall 1: Noch kein Element vorhanden: *)
     If AP = Nil Then
      Begin
       New(StringList);
       AP := StringList;
       AP^.Next := Nil;
       AP^.Last := Nil;
       CreateNewListElement := AP;
      End

     (* Fall 2: Am Ende einfgen: *)
     Else If AP^.Next = Nil Then
      Begin
       New(AP^.Next);
       AP^.Next^.Next := Nil;
       AP^.Next^.Last := AP;
       CreateNewListElement := AP^.Next;
      End

     (* Fall 3: In der Mitte einfgen: *)
     Else If AP^.Next <> Nil Then
      Begin
       PH1 := AP^.Next;
       New(AP^.Next);
       AP^.Next^.Last := AP;
       AP^.Next^.Next := PH1;
       PH1^.Last      := AP^.Next;
       CreateNewListElement := AP^.Next;
      End;
    End;

   FUNCTION SearchNextSameGroup(AGroup : String; AP : PStringList) : PStringList;
    (* ---------------------------------------------------------------- *)
    Var SH1, SH2 : String;
    Begin
     SearchNextSameGroup := Nil;

     (* Wenn keine Elemente mehr vorhanden: *)
     If (AP = Nil) Then Exit

     (* Wenn noch 1 Element vorhanden: *)
     Else If AP^.Next = Nil Then
      Begin
       SH1 := UniformGroup(AP^.Group);  (* Lese aktuellen Gruppennamen. *)
       SH2 := UniformGroup(AGroup);
       If SH1 = SH2 Then SearchNextSameGroup := AP;
      End

     (* Wenn noch Elemente vorhanden: *)
     Else
      Begin
       SH1 := UniformGroup(AGroup);      (* Lese aktuellen Gruppennamen. *)
       Repeat
        SH2 := UniformGroup(AP^.Group);
        If SH1 = SH2 Then
         Begin
          SearchNextSameGroup := AP;
          Break;
         End;
         AP := AP^.Next;
       Until AP = Nil;
      End;
    End;

   FUNCTION UniformGroup(AGroup : String) : String;
    (* ---------------------------------------------------------------- *)
    Begin
     If (AGroup[1] <> '[') And (AGroup[Length(AGroup)] <> ']') Then
      AGroup := '[' + AGroup + ']';
     UniformGroup := UpString(AGroup);
    End;

   PROCEDURE WriteINIHeader;
    (* ---------------------------------------------------------------- *)
    Var WH1, WH2, WH3, WH4 : Word;
        SH1, SH2, SH3      : String[4];
    Begin
     (* Aktuelles Datum ermitteln: *)
     GetDate(WH1, WH2, WH3, WH4);
     Str(WH1, SH1); While Length(SH1) < 2 Do SH1 := '0'+ SH1;
     Str(WH2, SH2); While Length(SH2) < 2 Do SH2 := '0'+ SH2;
     Str(WH3, SH3); While Length(SH3) < 2 Do SH3 := '0'+ SH3;

     {$I-}
     Write(F, '; INIT-Datei '+UpString(NameString(TextRec(F).Name)
              +ExtString(TextRec(F).Name))+''+#13#10+
              '; Erzeugt am '+SH3+'.'+SH2+'.'+SH1+''+#13#10+
              '; CopyRight (c) Uwe Keim.'+#13#10);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   PROCEDURE WriteGroup(AGroup : String);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     Write(F, #13#10+#32+UniformGroup(AGroup)+#13#10);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   PROCEDURE WriteItem(AItem, AValue : String);
    (* ---------------------------------------------------------------- *)
    Begin
     {$I-}
     Write(F, #32#32+AItem+' = '+AValue+#13#10);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));
    End;

   FUNCTION DeleteActualElement(AP : PStringList) : PStringList;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PStringList;
        PH2 : PStringList;
    Begin
     (* Fall 1: Erstes Element. *)
     If (AP = StringList) And (AP <> Nil) Then
      Begin
       PH1 := StringList^.Next;
       If PH1 <> Nil Then PH1^.Last := Nil;
       Dispose(StringList);
       StringList := PH1;
       DeleteActualElement := PH1;
      End

     (* Fall 2: Mittleres Element. *)
     Else If (AP^.Next <> Nil) And (AP <> Nil) Then
      Begin
       PH1 := AP^.Last;
       PH2 := AP^.Next;
       Dispose(AP);
       PH1^.Next := PH2;
       PH2^.Last := PH1;
       DeleteActualElement := PH2;
      End

     (* Fall 3: Letztes Element. *)
     Else If (AP^.Next = Nil) And (AP <> Nil) Then
      Begin
       If AP^.Last <> Nil Then AP^.Last^.Next := Nil;
       Dispose(AP);
       DeleteActualElement := Nil;
      End

     (* Fall 4: Kein Element. *)
     Else If AP = Nil Then
      Begin
       DeleteActualElement := Nil;
      End;
    End;

   PROCEDURE ClearList;
    (* ---------------------------------------------------------------- *)
    Begin
     While DeleteActualElement(StringList) <> Nil Do ;
    End;

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° SYSTEM-ROUTINEN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   (* ÄÄ InterfaceÄProzeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° NORMALE PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE PutString(AGroup, AItem, AValue : String);
    (* ---------------------------------------------------------------- *)
    Var PH1 : PStringList;
    Begin
     PH1 := CreateNewListElement(SeekListEnd);
     PH1^.Group := AGroup;
     PH1^.Item  := AItem;
     PH1^.Value := AValue;
    End;

   PROCEDURE WriteINIFile(AFName : String);
    (* ---------------------------------------------------------------- *)
    Var PH1 : PStringList;
        SH1 : String;
    Begin
     Assign(F, AFName);

     {$I-}
     Rewrite(F);
     {$I+}
     ERR_Error := IOResult; If ERR_Error <> 0 Then CriticalError(AFName);

     WriteINIHeader;

     (* So lange wiederholen, bis Liste vollst„ndig geleert: *)
     While StringList <> Nil Do
      Begin
       PH1 := StringList;               (* Auf Listenanfang. *)
       SH1 := PH1^.Group;               (* Gruppe lesen. *)
       WriteGroup(SH1);

       WriteItem(PH1^.Item, PH1^.Value);
       PH1 := DeleteActualElement(PH1);

       (* Alle Eintr„ge dieser Gruppe suchen, schreiben und l”schen: *)
       PH1 := SearchNextSameGroup(SH1, PH1);
       While PH1 <> Nil Do
        Begin
         WriteItem(PH1^.Item, PH1^.Value);
         PH1 := DeleteActualElement(PH1);

         PH1 := SearchNextSameGroup(SH1, PH1);
        End;
      End;

     {$I-}
     Close(F);
     {$I+}
     ERR_Error := IOResult;
     If ERR_Error <> 0 Then CriticalError(UpString(NameString(TextRec(F).Name)+ExtString(TextRec(F).Name)));

     (* Liste an Ende leeren: *)
     ClearList;
    End;

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° SYSTEM-ROUTINEN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE MAKEINIInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(MAKEINICloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(MAKEINIGetErrorMessage);
    End;

   PROCEDURE MAKEINICloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

   FUNCTION MAKEINIGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      MAKEINI_Error_XxXXXXxxx         : S := S + 'XXXXX ' + UpString(AS + C) + 'XxxX XXXx.';

      Else                              S := '';
     End;

     MAKEINIGetErrorMessage := S;
    End;

  (* ÄÄ INITIALISIERUNGSÄTEIL: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   BEGIN
    MAKEINIInitRoutines;
   END.

 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)
