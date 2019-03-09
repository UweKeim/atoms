 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)
 (*  Programm : ATOMS SETUP                                                *)
 (*             Stand-Alone Setup Programm fr Spiel Atoms.                *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : SETUP.PAS                                                  *)
 (*             Hauptdatei.                                                *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 09.04.1995 Uwe Keim - Anfang.                              *)
 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)

 PROGRAM SETUP;

  (*ÄÄ COMPILER-EINSTELLUNGEN: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)

  {$A-,B-,E+,F+,G+,I-,N+,O-,P-,Q-,R-,S-,T-,V-,X+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ELSE}
  {$D-,L-,Y-}                           (* Debug-Infos. *)
  {$ENDIF}

  (*ÄÄ DEKLARATIONSTEIL: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)

   USES Crt,                            (* BP-Units. *)

        Objects, Views, Dialogs,        (* TV-Units. *)
        App, Drivers,

        INIMake1,                       (* INI-Handling. *)
        INIPars1,

        UweERR01,                       (* Eigene Units. *)
        UweUNI01;

   (* ÄÄ Verschiedene Erkl„rungen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* ----------------------------------------------------------- *)
   (*  Setup-Programm, das gleichzeitig auch als Gerst fr       *)
   (*  Allgemeines Setup-Programm dient.                          *)
   (*                                                             *)
   (*  Es soll sp„ter mal ein Editor entstehen, der es m”glich    *)
   (*  macht, ein Programm zum konfigurieren einer INI-Datei      *)
   (*  automatisch (!) zu erzeugen.                               *)
   (*                                                             *)
   (*                                                             *)
   (*                                                             *)
   (*                                                             *)
   (*                                                             *)
   (*                                                             *)
   (*                                                             *)
   (* ----------------------------------------------------------- *)

   (* ÄÄ Verschiedene Typen, Konstanten und Variablen: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °° NORMALES: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

         (* Eigene Fehlercodes: 0000-0000: *)
         (* Siehe dazu auch Datei C:\UTILY\COMP\BP\UWEUNITS\ERRCODES.DOC. *)
   CONST STP_Error_XxXXX                 = 0000;

   TYPE  PInteger            = ^Integer;

         (* Optionen, die in Datei geschrieben werden: *)
   VAR   Optionen             : Record
                                SoundBlaster  : Record
                                                 DMA  : String;
                                                 IRQ  : String;
                                                 PORT : String;
                                                 TYP  : String;
                                                End;
                                Musik         : String;
                                Sound_Effekte : String;
                                HighScore     : String;
                               End;

   (* °° TURBO-VISION OBJEKTE: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

         (* Haupt-Objekt: *)
   TYPE  PSetUpApp           = ^TSetUpApp;
         TSetUpApp           = Object(TApplication)
                                Constructor Init;
                                Procedure   Run; Virtual;
                                Destructor  Done; Virtual;
                                Procedure   InitStatusLine; Virtual;
                               End;

   TYPE  TProc               = Procedure;

         (* Eigene List-Box fr PLISTENTRY: *)
   TYPE  PMyListBox          = ^TMyListBox;
         TMyListBox          = Object(TListBox)
                                Function  GetText(Item : Integer; MaxLen : Integer) : String; Virtual;
                                Procedure GetCall(Item : Integer; Var ACall : TProc); Virtual;
                                Function  GetEnd (Item : Integer) : Boolean;          Virtual;
                                Function  GetPalette : PPalette; Virtual;
                               End;

   CONST CMyListBox          = #01#03#22#02#06;


         (* 1 Eintrag in Kollektion von Men-Eintr„gen: *)
   TYPE  PListEntry          = ^TListEntry;
         TListEntry          = Object(TObject)
                                Entry : PString;(* Text, der im Men erscheint. *)
                                Call  : TProc;  (* Wenn <>NIL, wird die hier        *)
                                                (* angegebene Prozedur aufgerufen,  *)
                                                (* wenn dieser Punkt gew„hlt wurde. *)
                                EndAfterCall : Boolean;
                                                (* Ob nach CALL, Objekt beendet wird. *)
                                Constructor Init(AEntry : String; ACall : TProc; AEnd : Boolean);
                                Destructor  Done; Virtual;
                               End;

         (* Dialog der List-Box zur Verfgung stellt und die *)
         (* Nummer des gew„hlten Menpunktes (0..n) in der   *)
         (* globalen Variablen RETVALUE zurckgibt:          *)
   TYPE  PMyDialog           = ^TMyDialog;
         TMyDialog           = Object(TDialog)
                                Constructor Init(ATitle : String; AEntries : PCollection);
                                Procedure   HandleEvent(Var Event : TEvent); Virtual;
                               End;

   VAR   SetUpApp            : TSetUpApp;

         (* Wird von beendeter Dialogbox gesetzt: *)
   VAR   RetValue            : Integer; (* Nr. des gew„hlten Eintrags (0..n). *)

   (* ÄÄ Prototypen der Prozeduren: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °° MENš-PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE Box_Main;                Forward;
   PROCEDURE  Box_SoundBlaster;       Forward;
   PROCEDURE   Box_SoundBlaster_Typ;  Forward;
   PROCEDURE   Box_SoundBlaster_DMA;  Forward;
   PROCEDURE   Box_SoundBlaster_IRQ;  Forward;
   PROCEDURE   Box_SoundBlaster_PORT; Forward;
   PROCEDURE  Box_Musik;              Forward;
   PROCEDURE  Box_Sound;              Forward;
   PROCEDURE  Box_HighScore;          Forward;
   PROCEDURE  Box_Show_Config;        Forward;
   PROCEDURE  Box_Save;               Forward;

   (* °° NORMALE PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE NormalTexts; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt in Menleiste direkt einen Text.            *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetLongestLength(AP : PCollection) : Integer; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt die L„nge des l„ngsten Strings in einer    *)
    (*             Kollektion.                                          *)
    (*  Eingabe  : AP = Zu testende Kollektion,                         *)
    (*  Rckgabe : L„nge, wenn nichts drin, "0".                        *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MakeSelectDialog(ATitle : String; AEntries : PCollection) : Integer; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Erzeugt einen Dialog mit einer Listbox und stellt    *)
    (*             Diesen auf dem Bildschirm dar.                       *)
    (*  Eingabe  : ATITLE   = šberschrift des Dialogs,                  *)
    (*             AENTRIES = Zeiger auf Namen der einzelnen Eintr„ge.  *)
    (*  Rckgabe : Nummer (0..n) des gew„hlten Menpunktes.             *)
    (* ---------------------------------------------------------------- *)

   (* °° SYSTEM-ROUTINEN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   FUNCTION STPGetErrorMessage(AS : String) : String; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_ERROR.  *)
    (*  Eingabe  : ERR_ERROR = Fehlernummer,                            *)
    (*             AS        = Eventueller zus„tzlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  Rckgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Init; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert das Programm.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Main; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Hauptteil des Programms, ruft alles auf.             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE Done; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet das Programm.                                *)
    (* ---------------------------------------------------------------- *)

   (* ÄÄ Prozedurrmpfe: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° TURBO-VISION OBJEKTE: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   FUNCTION TMyListBox.GetText(Item : Integer; MaxLen : Integer) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt den Text eines Eintrages in Listbox.       *)
    (*  Eingabe  : ITEM   = Position in Liste.                          *)
    (*             MAXLEN = Maximale Anzahl Zeichen.                    *)
    (*  Rckgabe : Gelesener Text.                                      *)
    (* ---------------------------------------------------------------- *)
    Begin
     If List <> NIL Then GetText := PListEntry(List^.At(Item))^.Entry^
     Else GetText := '';
    End;

   PROCEDURE TMyListBox.GetCall(Item : Integer; Var ACall : TProc);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt CALL-Zeiger eines Eintrages in Listbox.    *)
    (*  Eingabe  : ITEM   = Position in Liste.                          *)
    (*  Rckgabe : Zeiger auf Procedure oder NIL.                       *)
    (* ---------------------------------------------------------------- *)
    Begin
     If List <> NIL Then ACall := PListEntry(List^.At(Item))^.Call
     Else ACall := Nil;
    End;

   FUNCTION TMyListBox.GetEnd(Item : Integer) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt den Status von ENDAFTERCALL.               *)
    (*  Eingabe  : ITEM   = Position in Liste.                          *)
    (*  Rckgabe : Ob ja oder nein.                                     *)
    (* ---------------------------------------------------------------- *)
    Begin
     If List <> NIL Then GetEnd := PListEntry(List^.At(Item))^.EndAfterCall
     Else GetEnd := FALSE;
    End;

   FUNCTION TMyListBox.GetPalette : PPalette;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert Farbwert.                                    *)
    (*  Rckgabe : String mit den Nummern in der aktuellen Farb-Palette *)
    (*             des Programms.                                       *)
    (* ---------------------------------------------------------------- *)
    Const P : String[Length(CMyListBox)] = CMyListBox;
    Begin
     GetPalette := @P;
    End;

   CONSTRUCTOR TSetUpApp.Init;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert das Haupt-Objekt.                      *)
    (* ---------------------------------------------------------------- *)
    Begin
     Inherited Init;
    End;

   PROCEDURE TSetUpApp.Run;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Haupt-Prozedur des Programms, ruft alles auf.        *)
    (* ---------------------------------------------------------------- *)
    Begin
     NormalTexts;
     Box_Main;
    End;

   DESTRUCTOR TSetUpApp.Done;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles.                                       *)
    (* ---------------------------------------------------------------- *)
    Begin
     Inherited Done;
    End;

   PROCEDURE TSetUpApp.InitStatusLine;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Neue Statuszeile.                                    *)
    (* ---------------------------------------------------------------- *)
    Var R : TRect;
    Begin
     GetExtent(R);
     R.A.Y := R.B.Y - 1;
     New(StatusLine, Init(R, Nil));
    End;

   CONSTRUCTOR TMyDialog.Init(ATitle : String; AEntries : PCollection);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Erstellt und zeigt Men-Dialogbox.                   *)
    (* ---------------------------------------------------------------- *)
    Var R         : TRect;
        Control   : PView;
        Width     : Integer;
    Begin
     Width := GetLongestLength(AEntries);
     If Width < Length(ATitle)+6 Then Width := Length(ATitle)+6;

     R.Assign(01, 01, Width+5, AEntries^.Count+3);
     Inherited Init(R, ATitle);
     Flags   := 0;                      (* Alle wfXXXX auf 0. *)
     Options := Options Or ofCentered Or ofPostProcess Or ofPreProcess;
     R.Assign(01, 01, Width+3, AEntries^.Count+1);
     Control := New(PMyListBox, Init(R, 1, Nil));
     Insert(Control);
     PMyListBox(Control)^.NewList(AEntries);
    End;

   PROCEDURE TMyDialog.HandleEvent(Var Event : TEvent);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Abarbeiten von Ereignissen.                          *)
    (* ---------------------------------------------------------------- *)
    Var RH1 : Record
               P  : PMyListBox;
               Nr : Integer;
              End;
        PH1 : TProc;
        PH2 : Pointer;
    Begin
     If Event.What = evBroadcast Then
      If Event.Command = cmListItemSelected Then
       Begin
        PH2 := Event.InfoPtr;
        PMyListBox(PH2)^.GetData(RH1);
        PMyListBox(PH2)^.GetCall(RH1.Nr, PH1);
        RetValue := RH1.Nr;

        If @PH1 <> Nil Then PH1;                        (* Rufe Objekt auf. *)

        If (@PH1 = Nil) And
           (PMyListBox(PH2)^.GetEnd(RH1.Nr)) Then
         Begin
          Event.What := evKeyDown;
          Event.KeyCode := kbESC;
          Event.InfoPtr := nil;
          PutEvent(Event);
          Event.What := evNothing;
         End;

        DrawView;
        ClearEvent(Event);
       End;
     Inherited HandleEvent(Event);
    End;

   CONSTRUCTOR TListEntry.Init(AEntry : String; ACall : TProc; AEnd : Boolean);
    (* ---------------------------------------------------------------- *)
    Var PH1 : Pointer;
    Begin
     Entry        := NewStr(AEntry);
     Call         := ACall;
     EndAfterCall := AEnd;
    End;

   DESTRUCTOR TListEntry.Done;
    (* ---------------------------------------------------------------- *)
    Begin
     DisposeStr(Entry);
    End;

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° MENš- PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE Box_Main;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Soundblaster Einstellungen', Box_SoundBlaster, TRUE)));
       Insert(New(PListEntry, Init('Musik Einstellungen', Box_Musik, TRUE)));
       Insert(New(PListEntry, Init('Sound-Effekte Einstellungen', Box_Sound, TRUE)));
       Insert(New(PListEntry, Init('Highscore Einstellungen', Box_HighScore, TRUE)));
       Insert(New(PListEntry, Init('Einstellungen zeigen', Box_Show_Config, FALSE)));
       Insert(New(PListEntry, Init('Einstellungen speichern', Box_Save, FALSE)));
       Insert(New(PListEntry, Init('Setup beenden', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Haupt-Men', PH1);
    End;

   PROCEDURE Box_SoundBlaster;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Soundblaster Typ', Box_SoundBlaster_Typ, TRUE)));
       Insert(New(PListEntry, Init('Soundblaster DMA-Kanal', Box_SoundBlaster_DMA, TRUE)));
       Insert(New(PListEntry, Init('Soundblaster IRQ-Nummer', Box_SoundBlaster_IRQ, TRUE)));
       Insert(New(PListEntry, Init('Soundblaster Port-Adresse', Box_SoundBlaster_PORT, TRUE)));
       Insert(New(PListEntry, Init('Zurck', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Soundblaster Einstellungen', PH1);
    End;

   PROCEDURE Box_SoundBlaster_Typ;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Soundblaster Mono', Nil, TRUE)));
       Insert(New(PListEntry, Init('Soundblaster Pro', Nil, TRUE)));
       Insert(New(PListEntry, Init('Soundblaster 16', Nil, TRUE)));
       Insert(New(PListEntry, Init('Keine Soundblaster-Karte', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Soundblaster Karten-Typ', PH1);

     Case IH1 Of
      0 : Optionen.SoundBlaster.TYP := 'SB';
      1 : Optionen.SoundBlaster.TYP := 'SB_PRO';
      2 : Optionen.SoundBlaster.TYP := 'SB_16';
      3 : Optionen.SoundBlaster.TYP := 'NONE';
     End;
    End;

   PROCEDURE Box_SoundBlaster_DMA;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Kanal 0', Nil, TRUE)));
       Insert(New(PListEntry, Init('Kanal 1', Nil, TRUE)));
       Insert(New(PListEntry, Init('Kanal 2', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Soundblaster DMA-Kanal', PH1);

     Case IH1 Of
      0 : Optionen.SoundBlaster.DMA := '0';
      1 : Optionen.SoundBlaster.DMA := '1';
      2 : Optionen.SoundBlaster.DMA := '2';
     End;
    End;

   PROCEDURE Box_SoundBlaster_IRQ;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('IRQ 2', Nil, TRUE)));
       Insert(New(PListEntry, Init('IRQ 3', Nil, TRUE)));
       Insert(New(PListEntry, Init('IRQ 5', Nil, TRUE)));
       Insert(New(PListEntry, Init('IRQ 7', Nil, TRUE)));
       Insert(New(PListEntry, Init('IRQ 10', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Soundblaster IRQ-Nummer', PH1);

     Case IH1 Of
      0 : Optionen.SoundBlaster.IRQ := '2';
      1 : Optionen.SoundBlaster.IRQ := '3';
      2 : Optionen.SoundBlaster.IRQ := '5';
      3 : Optionen.SoundBlaster.IRQ := '7';
      4 : Optionen.SoundBlaster.IRQ := '10';
     End;
    End;

   PROCEDURE Box_SoundBlaster_PORT;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Port $210', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $220', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $230', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $240', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $250', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $260', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $270', Nil, TRUE)));
       Insert(New(PListEntry, Init('Port $280', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Soundblaster PORT-Adresse', PH1);

     Case IH1 Of
      0 : Optionen.SoundBlaster.PORT := '$210';
      1 : Optionen.SoundBlaster.PORT := '$220';
      2 : Optionen.SoundBlaster.PORT := '$230';
      3 : Optionen.SoundBlaster.PORT := '$240';
      4 : Optionen.SoundBlaster.PORT := '$250';
      5 : Optionen.SoundBlaster.PORT := '$260';
      6 : Optionen.SoundBlaster.PORT := '$270';
      7 : Optionen.SoundBlaster.PORT := '$280';
     End;
    End;

   PROCEDURE Box_Musik;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Musik an', Nil, TRUE)));
       Insert(New(PListEntry, Init('Musik aus', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Musik Einstellungen', PH1);

     Case IH1 Of
      0 : Optionen.Musik := 'AN';
      1 : Optionen.Musik := 'AUS';
     End;
    End;

   PROCEDURE Box_Sound;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Sound-Effekte an', Nil, TRUE)));
       Insert(New(PListEntry, Init('Sound-Effekte aus', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('Sound Einstellungen', PH1);

     Case IH1 Of
      0 : Optionen.Sound_Effekte := 'AN';
      1 : Optionen.Sound_Effekte := 'AUS';
     End;
    End;

   PROCEDURE Box_HighScore;
    (* ---------------------------------------------------------------- *)
    Var PH1 : PCollection;
        IH1 : Integer;
    Begin
     PH1 := New(PCollection, Init(10, 5));
     With PH1^ Do
      Begin
       Insert(New(PListEntry, Init('Highscore-Speicherung zulassen', Nil, TRUE)));
       Insert(New(PListEntry, Init('Highscore-Speicherung sperren', Nil, TRUE)));
      End;

     IH1 := MakeSelectDialog('HighScore Einstellungen', PH1);

     Case IH1 Of
      0 : Optionen.HighScore := 'AN';
      1 : Optionen.HighScore := 'AUS';
     End;
    End;

   PROCEDURE  Box_Show_Config;
    (* ---------------------------------------------------------------- *)
    Var Dialog  : PDialog;
        Control : PView;
        R       : TRect;
    Begin
     R.Assign(01, 01, 37, 16);
     Dialog := New(PDialog, Init(R, 'Aktuelle Einstellungen'));

     With Dialog^ Do
      Begin
       Flags   := 0;                    (* Alle wfXXXX auf 0. *)
       Options := Options Or ofCentered;
       Inc(R.A.X, 2); Inc(R.A.Y); Dec(R.B.X, 2); R.B.Y := R.A.Y + 9;
       With Optionen Do
        Begin
         Control := New(PStaticText,
                     Init(R, 'Soundblaster-Typ      : '+SoundBlaster.Typ+#13+
                             'SB-DMA Kanal          : '+SoundBlaster.DMA+#13+
                             'SB-IRQ Nummer         : '+SoundBlaster.IRQ+#13+
                             'SB-Port Adresse       : '+SoundBlaster.Port+#13+
                             #13+
                             'Musik                 : '+Musik+#13+
                             'Sound-Effekte         : '+Sound_Effekte+#13+
                             #13+
                             'HighScore Speicherung : '+HighScore));
         Insert(Control);
        End;
       (* Knopf: *)

       R.A.X := 13; R.A.Y := R.B.Y + 1; R.B.Y := R.A.Y + 2; R.B.X := R.A.X + 10;
       Control := New(PButton, Init(R, 'O~K~', cmOK, bfDefault));
       Insert(Control);

       SelectNext(False);
      End;
     DeskTop^.ExecView(Dialog);
     Dispose(Dialog, Done);
    End;

   PROCEDURE Box_Save;
    (* ---------------------------------------------------------------- *)
    Begin
     PutString('[SoundBlaster]' , 'TYP', Optionen.SoundBlaster.TYP);
     PutString('[SoundBlaster]' , 'DMA', Optionen.SoundBlaster.DMA);
     PutString('[SoundBlaster]' , 'IRQ', Optionen.SoundBlaster.IRQ);
     PutString('[SoundBlaster]' , 'PORT', Optionen.SoundBlaster.PORT);
     PutString('[Musik]'        , 'Musik', Optionen.Musik);
     PutString('[Sound-Effekte]', 'Sound', Optionen.Sound_Effekte);
     PutString('[HighScore]'    , 'Schreibe_HighScore', Optionen.HighScore);

     WriteINIFile('ATOMS.INI');
    End;

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° NORMALE PROZEDUREN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   PROCEDURE NormalTexts;
    (* ---------------------------------------------------------------- *)
    Const MenuText   = 'ATOMS - Setup  (c) 1995 Uwe Keim';
    Begin
     (* Farb-Einstellung: *)
     TextColor(0);
     TextBackGround(7);

     (* Men-Text zentriert schreiben: *)
     GotoXY((80 - Length(MenuText)) Div 2 + 1,1);
     Write(MenuText);
    End;

   FUNCTION GetLongestLength(AP : PCollection) : Integer;
    (* ---------------------------------------------------------------- *)
    Var IH1, IH2 : Integer;
        SH1      : String;
    Begin
     IH1 := 0;

     If AP^.Count > 0 Then
      For IH2 := 0 To AP^.Count-1 Do
       Begin
        SH1 := PListEntry(AP^.At(IH2))^.Entry^;
        If Length(SH1) > IH1 Then IH1 := Length(SH1);
       End;

     GetLongestLength := IH1;
    End;

   FUNCTION MakeSelectDialog(ATitle : String; AEntries : PCollection) : Integer;
    (* ---------------------------------------------------------------- *)
    Begin
     SetUpApp.ExecuteDialog(New(PMyDialog, Init(ATitle, AEntries)), Nil);
     MakeSelectDialog := RetValue;
    End;

   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °° SYSTEM-ROUTINEN: °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)
   (* °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° *)

   FUNCTION STPGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      STP_Error_XxXXX                 : S := S + '.';

      Else                              S := '';
     End;

     STPGetErrorMessage := S;
    End;

   PROCEDURE Init;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(Done);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(STPGetErrorMessage);

     (* Variablen default vorbelegen: *)
     With Optionen Do
      Begin
       SoundBlaster.DMA  := '1';
       SoundBlaster.IRQ  := '7';
       SoundBlaster.TYP  := 'NONE';
       SoundBlaster.PORT := '$220';
       Musik             := 'AUS';
       Sound_Effekte     := 'AUS';
       HighScore         := 'AN';
      End;
    End;

   PROCEDURE Main;
    (* ---------------------------------------------------------------- *)
    Begin
     SetUpApp.Init;
     SetUpApp.Run;
     SetUpApp.Done;
    End;

   PROCEDURE Done;
    (* ---------------------------------------------------------------- *)
    Begin
    End;

  (* ÄÄ HAUPTPROGRAMM: ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ *)

   BEGIN
    Init;
    Main;
    Done;
   END.

 (*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*)