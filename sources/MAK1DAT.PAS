 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)
 (*  Programm : MAK1DAT                                                    *)
 (*             Erstellt f걊 ATOMIX eine Datei mit allen kleinen Dateien.  *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : MAK1DAT.PAS                                                *)
 (*             Hauptdatei.                                                *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 05. September 1994                                         *)
 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)

 PROGRAM MAK1DAT;

  {$A-,B-,D+,E+,F+,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
  {$M 16384,0, 16384}

  {$DEFINE KEYFILE}                     (* Codiere Datei AN/AUS. *)
  {$UNDEF  DEBUG}

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (*컴 DEKLARATIONSTEIL: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*)

   USES Crt, Dos,

        {$IFDEF KEYFILE}
        KEYFile1,
        {$ENDIF}

        ONEFile1;

   (* 컴 Verschiedene Erkl꼛ungen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* ----------------------------------------------------------- *)
   (* ----------------------------------------------------------- *)

   (* 컴 Verschiedene Konstanten: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   CONST FilesCnt = 9;
         Files    : Array[1..FilesCnt] Of String = ('ATOMIX.FNT',
                                                    'ATOMIX.LEV',
                                                    'ATOMIX.PAL',
                                                    'ATOMIX.HIG',
                                                    'ATOMI1.PCX',
                                                    'ATOMI2.PCX',
                                                    'ATOMI3.PCX',
                                                    'ATOMI4.PCX',
                                                    'ATOMIX.SPR');
         {$IFDEF KEYFILE}
         KEYSchluessel = 231;

         MAINFile : String = 'ATOMIX.TMP';
         KEYFile  : String = 'ATOMIX.DAT';
         {$ELSE}
         MAINFile : String = 'ATOMIX.DAT';
         {$ENDIF}

   (* 컴 Verschiedene Typen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* 컴 Verschiedene Variablen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   VAR FileLength : Array[1..FilesCnt] Of LongInt;
       MAINLength : LongInt;

   (* 컴 Prototypen der Prozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE GetLength; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt die L꼗gen der einzelnen Unter-Dateien.    *)
    (*  R갷kgabe : das Feld "FILELENGTH[..]" wird gef걄lt.              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CalcMainLength; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die L꼗ge einer Datei.                       *)
    (*  R갷kgabe : MAINLENGTH wird gesetzt.                             *)
    (* ---------------------------------------------------------------- *)

   FUNCTION CalcSUBStart(ANr : Word) : LongInt; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert die Startposition einer Unter-Datei.         *)
    (*  Eingabe  : ANR = Nummer der Datei in FILES[..].                 *)
    (*  R갷kgabe : Die Startposition.                                   *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteMAINHeader; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt den Haupt-Header auf Disk.                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteMAINFollowers; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt die MAIN-Follow-Bl봠ke auf Disk.            *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WriteSUBHeaders; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schreibt die Unter-Header auf Disk.                  *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE EraseMAINHeader; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : L봲cht den Haupt-Header von Disk.                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE EraseMAINFollowers; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : L봲cht die MAIN-Follow-Bl봠ke von Disk.              *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE EraseSUBHeaders; Forward;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : L봲cht die Unter-Header von Disk.                    *)
    (* ---------------------------------------------------------------- *)

   (* -- Die Systemprozeduren: ----------------------------------------- *)

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

   (* 컴 Prozedurr걅pfe: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

   PROCEDURE GetLength;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
        F   : File;
    Begin
     For IH1 := 1 To FilesCnt Do
      Begin
       Assign(F, Files[IH1]);
       Reset(F, 1);
       FileLength[IH1] := FileSize(F);
       Close(F);
      End;
    End;

   PROCEDURE CalcMainLength;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     MAINLength := SizeOf(TMAINHeader);

     For IH1 := 1 To FilesCnt Do
      MAINLength := MAINLength + FileLength[IH1] +
                    SizeOf(TMAINFollow) + SizeOf(TMAINHeader);
    End;

   FUNCTION CalcSUBStart(ANr : Word) : LongInt;
    (* ---------------------------------------------------------------- *)
    Var LH1 : LongInt;
        IH1 : Integer;
    Begin
     (* L꼗ge := MAINHeader-Gr붳e + FilesCnt * MAIN-Follow-Gr붳e +  *)
     (*          (ANR-1) * SUB-Header-Gr붳e + FileLength[1..ANr-1]. *)

     LH1 := SizeOf(TMAINHeader) + FilesCnt * SizeOf(TMAINFollow) +
            + (ANr - 1) * SizeOf(TSUBHeader);

     (* Jetzt noch L꼗gen der vorherigen Dateien dazu: *)
     If ANr > 1 Then
      For IH1 := 1 To ANr-1 Do
       LH1 := LH1 + FileLength[IH1];

     (* Wert zur갷k: *)
     CalcSUBStart := LH1;
    End;

   PROCEDURE WriteMAINHeader;
    (* ---------------------------------------------------------------- *)
    Var CH1 : Array[1..12] Of Char;
        F   : File;
        HH1 : TMAINHeader;
    Begin
     (* Name auf definierte 12 Zeichen L꼗ge bringen, Rest mit "0" auff걄len. *)
     FillChar(CH1, SizeOf(CH1), 0);
     Move(MAINFile[1], CH1, SizeOf(CH1));

     (* Header f걄len: *)
     With HH1 Do
      Begin
       Kennung := 'UK';
       Version := 1;
       Art     := 'DAT';
       CalcMainLength; Laenge  := MAINLength;
       Move(CH1, FName, SizeOf(CH1));
       AnzSUB  := FilesCnt;
       FillChar(Dummy, SizeOf(Dummy), 0);
      End;

     (* Header schreiben: *)
     Assign(F, 'MAINHead.001');
     Rewrite(F, 1);
     BlockWrite(F, HH1, SizeOf(HH1));
     Close(F);
    End;

   PROCEDURE WriteMAINFollowers;
    (* ---------------------------------------------------------------- *)
    Var CH1 : Array[1..12] Of Char;
        F   : File;
        HH1 : TMAINFollow;
        IH1 : Integer;
        SH1 : String;
    Begin
     (* Alle Unter-Dateien: *)
     For IH1 := 1 To FilesCnt Do
      Begin
       (* Name auf definierte 12 Zeichen L꼗ge bringen, Rest mit "0" auff걄len. *)
       FillChar(CH1, SizeOf(CH1), 0);
       Move(Files[IH1][1], CH1, SizeOf(CH1));

       (* Header f걄len: *)
       With HH1 Do
        Begin
         Nr := IH1;
         Move(CH1, FName, SizeOf(CH1));
         Start := CalcSUBStart(IH1);
         If IH1 = FilesCnt Then Last := TRUE Else Last := FALSE;
         FillChar(Dummy, SizeOf(Dummy), 0);
        End;

       (* Header schreiben: *)

       Str(IH1, SH1); While Length(SH1) < 3 Do SH1 := '0' + SH1;

       Assign(F, 'MAINFoll.' + SH1);
       Rewrite(F, 1);
       BlockWrite(F, HH1, SizeOf(HH1));
       Close(F);
      End;
    End;

   PROCEDURE WriteSUBHeaders;
    (* ---------------------------------------------------------------- *)
    Var CH1 : Array[1..12] Of Char;
        F   : File;
        HH1 : TSUBHeader;
        IH1 : Integer;
        SH1 : String;
    Begin
     (* Alle Unter-Dateien: *)
     For IH1 := 1 To FilesCnt Do
      Begin
       (* Name auf definierte 12 Zeichen L꼗ge bringen, Rest mit "0" auff걄len. *)
       FillChar(CH1, SizeOf(CH1), 0);
       Move(Files[IH1][1], CH1, SizeOf(CH1));

       (* Header f걄len: *)
       With HH1 Do
        Begin
         Kennung := 'UK';
         Version := 1;
         Art     := 'SUB';
         Laenge  := FileLength[IH1];
         Move(CH1, FName, SizeOf(CH1));
         FillChar(Dummy, SizeOf(Dummy), 0);
        End;

       (* Header schreiben: *)

       Str(IH1, SH1); While Length(SH1) < 3 Do SH1 := '0' + SH1;

       Assign(F, 'SUBHead.' + SH1);
       Rewrite(F, 1);
       BlockWrite(F, HH1, SizeOf(HH1));
       Close(F);
      End;
    End;

   PROCEDURE EraseMAINHeader;
    (* ---------------------------------------------------------------- *)
    Var F   : File;
    Begin
     (* Header l봲chen: *)
     Assign(F, 'MAINHead.001');
     Erase(F);
    End;

   PROCEDURE EraseMAINFollowers;
    (* ---------------------------------------------------------------- *)
    Var F   : File;
        IH1 : Integer;
        SH1 : String;
    Begin
     (* Alle Unter-Dateien: *)
     For IH1 := 1 To FilesCnt Do
      Begin
       (* Header l봲chen: *)

       Str(IH1, SH1); While Length(SH1) < 3 Do SH1 := '0' + SH1;

       Assign(F, 'MAINFoll.' + SH1);
       Erase(F);
      End;
    End;

   PROCEDURE EraseSUBHeaders;
    (* ---------------------------------------------------------------- *)
    Var F   : File;
        IH1 : Integer;
        SH1 : String;
    Begin
     (* Alle Unter-Dateien: *)
     For IH1 := 1 To FilesCnt Do
      Begin
       Str(IH1, SH1); While Length(SH1) < 3 Do SH1 := '0' + SH1;

       Assign(F, 'SUBHead.' + SH1);
       Erase(F);
      End;
    End;

   PROCEDURE Init;
    (* ---------------------------------------------------------------- *)
    Begin
     ClrScr;
     WriteLn('Erstelle MAIN-HEADER, MAIN-FOLLOW-BLOCKS und SUB-HEADER:');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     WriteLn;

     GetLength;
     WriteMAINHeader;
     WriteMAINFollowers;
     WriteSUBHeaders;
    End;

   PROCEDURE Main;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
        SH1 : String;
    Begin
     WriteLn('Erstelle ', MAINFile, ' ...');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~');
     WriteLn;
     WriteLn;

     (* GGf. alte Haupt-Datei l봲chen: *)
     WriteLn('L봲che alte Datei ', MAINFile, ':');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     SwapVectors;
     Exec(GetEnv('COMSPEC'), '/C DEL ' + MAINFile);
     SwapVectors;
     WriteLn;

     (* MAIN-Header-Kopieren: *)
     WriteLn('Kopiere MAIN-HEADER:');
     WriteLn('~~~~~~~~~~~~~~~~~~~~');
     SwapVectors;
     Exec(GetEnv('COMSPEC'), '/C COPY /B MAINHEAD.001 ' + MAINFile);
     SwapVectors;
     WriteLn;

     (* Restliche MAIN-Follower kopieren: *)
     WriteLn('Kopiere MAIN-FOLLOW-BLOCKS:');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     For IH1 := 1 To FilesCnt Do
      Begin
       Str(IH1, SH1); While Length(SH1) < 3 Do SH1 := '0' + SH1;

       SwapVectors;
       Exec(GetEnv('COMSPEC'), '/C COPY /B ' + MAINFile + '+ MAINFOLL.' + SH1 + ' ' + MAINFile);
       SwapVectors;
      End;
     WriteLn;

     (* Restliche Unter-Header und Unter-Dateien kopieren: *)
     WriteLn('Kopiere SUB-HEADER und SUB-DATEIEN:');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     For IH1 := 1 To FilesCnt Do
      Begin
       Str(IH1, SH1); While Length(SH1) < 3 Do SH1 := '0' + SH1;

       (* Unter-Header kopieren: *)
       SwapVectors;
       Exec(GetEnv('COMSPEC'), '/C COPY /B ' + MAINFile + '+ SUBHead.' + SH1 +  ' ' + MAINFile);
       SwapVectors;

       (* Unter-Dateien kopieren: *)
       SwapVectors;
       Exec(GetEnv('COMSPEC'), '/C COPY /B ' + MAINFile + '+' + Files[IH1] + ' ' + MAINFile);
       SwapVectors;
      End;
     WriteLn;

     (* Datei codieren: *)
     {$IFDEF KEYFILE}
     WriteLn('Codiere Datei ', MAINFile , ' in ', KEYFile,' ...');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     WriteLn;
     MakeKEYFile(MAINFile, KEYFile, KEYSchluessel);

     (* Uncodierte wieder l봲chen: *)
     WriteLn('L봲che uncodierte Datei ', MAINFile, ':');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     SwapVectors;
     Exec(GetEnv('COMSPEC'), '/C DEL ' + MAINFile);
     SwapVectors;
     WriteLn;

     {$ENDIF}
    End;

   PROCEDURE Done;
    (* ---------------------------------------------------------------- *)
    Begin
     WriteLn('L봲che MAIN-HEADER, MAIN-FOLLOW-BLOCKS und SUB-HEADER:');
     WriteLn('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     WriteLn;

     EraseMAINHeader;
     EraseMAINFollowers;
     EraseSUBHeaders;

     WriteLn('Beendet.');
     WriteLn('~~~~~~~~');
     WriteLn;
     WriteLn;
    End;

  (* 컴 HAUPTPROGRAMM: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   BEGIN
    Init;
    Main;
    Done;
   END.

 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)