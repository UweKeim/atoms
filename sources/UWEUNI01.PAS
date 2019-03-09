 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)
 (*  Programm : UWEUNI01                                                   *)
 (*             Allgemeine (UNIversal) Routinen.                           *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UWEUNI01.PAS                                               *)
 (*             Die Unit.                                                  *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*   History : 31.08.1994 Uwe Keim - Anfang.                              *)
 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)

 UNIT UWEUNI01;

  {$A-,B-,D-,E+,F+,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
  {$M 16384,0,655360}

  {$UNDEF  DEBUG}                       (* Debug-Infos AN/AUS. *)
  {$DEFINE ERROR_HANDLING}              (* Fehler-Handling AN/AUS.    *)
  {$DEFINE GETMEM_CHECK}                (* GetMem-Aufrufe ÅberprÅfen. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (* -- ôFFENTLICHER TEIL: ---------------------------------------------- *)
  INTERFACE

   USES Dos

        {$IFDEF ERROR_HANDLING}
        , UweERR01
        {$ENDIF}

        ;

   (* ƒƒ Verschiedene ErklÑrungen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ----------------------------------------------------------- *)
   (*  EnthÑlt Funktionen aus "MEMORY.PAS" um an Segment-Anfang   *)
   (*  Speicher zu reservieren (Offset garantiert 0).             *)
   (* ----------------------------------------------------------- *)

   (* ƒƒ Verschiedene Typen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   TYPE  TProc   = String[20];         (* Prozessorname. *)

         PtrRec = Record
                   Ofs, Seg : Word;
                  End;

   (* ƒƒ Verschiedene Konstanten: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST (* Fehler-Codes: *)

         (* Eigene Fehlercodes: 0500-0549: *)
         UNI_Error_AccessKeyBController  = 0500;
         UNI_Error_NotEnoughMem          = 0501;

   (* ƒƒ Verschiedene Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   VAR OldDelay  : Byte;                (* Start-Tastaturrate. *)
       OldSpeed  : Byte;                (* Start-Tastaturrate. *)
       Regs      : Registers;           (* Die Register. *)

       (* BIOS-Variablen: *)
       CharHeight : Word    Absolute $0000:$0485;(* BIOS: Zeichenhîhe. *)
       FontPtr    : Pointer Absolute $0000:$010C;(* INT 43h-Vektor. *)

   (* ƒƒ Prototypen der Prozeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   PROCEDURE UNIInitRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Initialisiert alles Nîtige.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE UNICloseRoutines;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Beendet alles ordnungsgemÑ·.                         *)
    (* ---------------------------------------------------------------- *)

   {$IFDEF ERROR_HANDLING}
   FUNCTION UNIGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den Text zum aktuellen Fehler in ERR_Error.  *)
    (*  Eingabe  : ERR_Error = Fehlernummer,                            *)
    (*             AS        = Eventueller zusÑtzlicher Text (Z.B.      *)
    (*                         Dateiname bei Fehler 'Nicht gefunden').  *)
    (*  RÅckgabe : Fehlertext.                                          *)
    (* ---------------------------------------------------------------- *)
   {$ENDIF}

   FUNCTION DirString(S : PathStr) : DirStr;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den DIR-Anteil eines Strings.                *)
    (*  Eingabe  : S = Kompletter String.                               *)
    (*  RÅckgabe : Der Dir-Anteil.                                      *)
    (* ---------------------------------------------------------------- *)

   FUNCTION NameString(S : PathStr) : NameStr;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den NAMNES-Anteil eines Strings.             *)
    (*  Eingabe  : S = Kompletter String.                               *)
    (*  RÅckgabe : Der Name-Anteil.                                     *)
    (* ---------------------------------------------------------------- *)

   FUNCTION ExtString(S : PathStr) : ExtStr;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Liefert den ERWEITERUNGS-Anteil eines Strings.       *)
    (*  Eingabe  : S = Kompletter String.                               *)
    (*  RÅckgabe : Der Erweiterungs-Anteil.                             *)
    (* ---------------------------------------------------------------- *)

   FUNCTION UpString(S : String) : String;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Wandelt alle Kleinbuchstaben in Gro·buchstaben.      *)
    (*  Eingabe  : S = Der zu wandelnde String.                         *)
    (*  RÅckgabe : Der gewandelte String.                               *)
    (* ---------------------------------------------------------------- *)

   FUNCTION FileExists(FileName : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Testet, ob eine Datei vorhanden ist.                 *)
    (*  Eingabe  : FILENAME = Dateiname.                                *)
    (*  RÅckgabe : TRUE, wenn vorhanden, sonst FALSE.                   *)
    (*  Hinweis  : Falls die Datei offen ist, wird sie geschlossen.     *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetTypmRate(ADelay, ASpeed : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Setzt die Typmatic-Rate der Tastatur.                 *)
    (* Eingabe  : ADELAY = Verzîgerung, bis Wiederholung einsetzt,      *)
    (*            ASPEED = Wiederholungsrate.                           *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE GetTypmRate(Var ADelay : Byte; Var ASpeed : Byte);
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Liest die Typmatic-Rate der Tastatur.                 *)
    (* RÅckgabe : ADELAY = Verzîgerung, bis Wiederholung einsetzt,      *)
    (*            ASPEED = Wiederholungsrate.                           *)
    (* ---------------------------------------------------------------- *)

   FUNCTION AT : Boolean;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Testen, ob mindestens ein AT ( >= 80286 ).            *)
    (* RÅckgabe : TRUE, wenn mindestens ein AT, sonst FALSE.            *)
    (* ---------------------------------------------------------------- *)

   FUNCTION Is386 : Boolean;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Testen, ob mind. ein 80386 Prozessor vorhanden ist.   *)
    (* RÅckgabe : TRUE, falls ja, sonst FALSE;                          *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetProzessor : TProc;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Ermittelt den Prozessor im Rechner.                   *)
    (* RÅckgabe : Name des Prozessors (siehe "PROCS").                  *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetCoProzessor : TProc;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Ermittelt den Co-Prozessor im Rechner.                *)
    (* RÅckgabe : Name des Co-Prozessors (siehe "COPROCS").             *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE SetBorderColor(AColor : Byte);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : FÑrbt den Bildschirmrand.                            *)
    (*  Eingabe  : ACOLOR = Die zu setzende Farbe.                      *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CursorAn;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schaltet den Text-Cursor an.                         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE CursorAus;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Schaltet den Text-Cursor aus.                        *)
    (* ---------------------------------------------------------------- *)

   FUNCTION MemAllocSeg(ASize: Word) : Pointer;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Reserviert einen an einer Segment-Grenze beginnenden *)
    (*             Speicherbereich, der garantiert an Offset 0 beginnt. *)
    (*  Eingabe  : ASIZE = Grî·e des zu belegenden Speichers, maximal   *)
    (*                     64k - $08.                                   *)
    (*  RÅckgabe : Zeiger auf Speicherbereich, wenn nicht mehr genÅgend *)
    (*             Speicher zur VerfÅgung, NIL.                         *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE WaitVRetrace;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Wartet auf den Beginn der vertikalen Retrace-Periode. *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ScreenOff;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schaltet den Bildschirm aus.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE ScreenOn;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Schaltet den Bildschirm ein.                          *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE _GetMem(Var P : Pointer; Size : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Belegt einen Bereich bestimmter Grî·e auf dem Heap.  *)
    (*  Eingabe  : SIZE = Grî·e des Bereichs in Bytes (max. 65528).     *)
    (*  RÅckgabe : P    = Zeiger auf den reservierten Speicherbereich.  *)
    (*  Hinweis  : - Genau gleich wie GETMEM(), nur mit PrÅfung, ob     *)
    (*               noch genug RAM frei.                               *)
    (*             - Wenn nicht mehr genug Speicher zur VerfÅgung       *)
    (*               steht, wird CRITICALERROR() aufgerufen.            *)
    (*             - Der so reservierte Speicher kann normal mittels    *)
    (*               FREEMEM() freigegeben werden.                      *)
    (* ---------------------------------------------------------------- *)

   FUNCTION Min(A, B : LongInt) : LongInt;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt kleinere zweier Zahlen.                    *)
    (*  Eingabe  : A, B = Die zu testenden Zahlen.                      *)
    (*  RÅckgabe : Die kleiner Zahl.                                    *)
    (* ---------------------------------------------------------------- *)

   FUNCTION Max(A, B : LongInt) : LongInt;
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : Ermittelt grî·ere zweier Zahlen.                     *)
    (*  Eingabe  : A, B = Die zu testenden Zahlen.                      *)
    (*  RÅckgabe : Die grî·ere Zahl.                                    *)
    (* ---------------------------------------------------------------- *)

   PROCEDURE FillWord(Var X; Count : Word; Value : Word);
    (* ---------------------------------------------------------------- *)
    (*  Aufgabe  : FÅllt Speicherbereich mit WORDS.                     *)
    (*  Eingabe  : X     = Zu fÅllender Speicherbereich.                *)
    (*             COUNT = Anzahl WORDs.                                *)
    (*             VALUE = WORD-Wert.                                   *)
    (* ---------------------------------------------------------------- *)

  (* -- PRIVATER TEIL: -------------------------------------------------- *)
  IMPLEMENTATION

   USES Crt;

   {$L ProzPa.Obj}                      (* Testprozeduren fÅr Prozessoren. *)

   (* ƒƒ Verschiedene Konstanten: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   CONST Procs   : Array[0..8] Of TProc =
                    ( 'INTEL 8088',             (* Code 0. *)
                      'INTEL 8086',             (* Code 1. *)
                      'NEC V20',                (* Code 2. *)
                      'NEC V30',                (* Code 3. *)
                      'INTEL 80188',            (* Code 4. *)
                      'INTEL 80186',            (* Code 5. *)
                      'INTEL 80286',            (* Code 6. *)
                      'INTEL 80386',            (* Code 7. *)
                      'INTEL 80486' );          (* Code 8. *)

         CoProcs : Array[0..3] Of TProc =
                    ( 'Kein Co-Prozessor',      (* Code 0. *)
                      '8087',                   (* Code 1. *)
                      '80287',                  (* Code 2. *)
                      '80387/80487' );          (* Code 3. *)

   (* ƒƒ Verschiedene Variablen: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ƒƒ Prototypen der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   FUNCTION GetProz : Integer; External;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Ermittelt den Prozessor im Rechner.                   *)
    (* RÅckgabe : Nummer zwischen 0 und 8, die den Prozessor            *)
    (*            spezifiziert (siehe "PROCS").                         *)
    (* ---------------------------------------------------------------- *)

   FUNCTION GetCo : Integer; External;
    (* ---------------------------------------------------------------- *)
    (* Aufgabe  : Ermittelt den Co-Prozessor im Rechner.                *)
    (* RÅckgabe : Nummer zwischen 0 und 3, die den Co-Prozessor         *)
    (*            spezifiziert (siehe "COPROCS").                       *)
    (* ---------------------------------------------------------------- *)

   (* ƒƒ RÅmpfe der ImplementationsƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   (* ƒƒ InterfaceƒProzeduren: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   PROCEDURE UNIInitRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     NoSound;

     (* Alte Tastaturrate auslesen: *)
     GetTypmRate(OldDelay, OldSpeed);

     {$IFDEF ERROR_HANDLING}

     (* Eigene Close-Prozedur einbinden: *)
     InsertErrorProc(UNICloseRoutines);

     (* Eigene Messages einbinden: *)
     InsertErrorMessageFunc(UNIGetErrorMessage);

     {$ENDIF}
    End;

   PROCEDURE UNICloseRoutines;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Alte Tastaturrate setzen: *)
     SetTypmRate(OldDelay, OldSpeed);
    End;

   {$IFDEF ERROR_HANDLING}
   FUNCTION UNIGetErrorMessage(AS : String) : String;
    (* ---------------------------------------------------------------- *)
    Var S : String;
        C : String;
    Begin
     If AS <> '' Then C := ' ' Else C := '';

     Str(ERR_Error, S);
     S := 'Fehler Nr. ' + S + ' : ';

     Case ERR_Error Of
      (* Eigene Fehlercodes: *)
      UNI_Error_AccessKeyBController  : S := S + 'Fehler beim Zugriff auf Tastaturkontroller.';
      UNI_Error_NotEnoughMem          : S := S + 'Nicht genug Speicher (unter 640k) zur VerfÅgung.';

      Else                              S := '';
     End;

     UNIGetErrorMessage := S;
    End;
   {$ENDIF}

   FUNCTION DirString(S : PathStr) : DirStr;
    (* ---------------------------------------------------------------- *)
    Var D : DirStr;
        N : NameStr;
        E : ExtStr;
    Begin
     FSplit(S, D, N, E);
     DirString := D;
    End;

   FUNCTION NameString(S : PathStr) : NameStr;
    (* ---------------------------------------------------------------- *)
    Var D : DirStr;
        N : NameStr;
        E : ExtStr;
    Begin
     FSplit(S, D, N, E);
     NameString := N;
    End;

   FUNCTION ExtString(S : PathStr) : ExtStr;
    (* ---------------------------------------------------------------- *)
    Var D : DirStr;
        N : NameStr;
        E : ExtStr;
    Begin
     FSplit(S, D, N, E);
     ExtString := E;
    End;

   FUNCTION UpString(S : String) : String;
    (* ---------------------------------------------------------------- *)
    Var W : Word;
    Begin
     For W := 1 To Length(S) Do S[W] := UpCase(S[W]);

     UpString := S;
    End;

   FUNCTION FileExists(FileName : String) : Boolean;
    (* ---------------------------------------------------------------- *)
    Var F : File;
    Begin
     {$I-}
     Assign(F, FileName);
     Reset(F);
     Close(F);
     {$I+}
     FileExists := (IOResult = 0) And (FileName <> '');
    End;

   PROCEDURE SetTypmRate(ADelay, ASpeed : Byte);
    (* ---------------------------------------------------------------- *)
    Begin
     If AT Then                         (* BIOS-Funktion erst ab AT. *)
      Begin
       (* öber BIOS ansprechen: *)
       Asm
        mov   ax, 0305h
        mov   bh, ADelay
        mov   bl, ASpeed
        int   16h
       End;
      End;

     {$IFDEF ERROR_HANDLING}
     ERR_Error := ERR_Error_OK;
     {$ENDIF}
    End;

   PROCEDURE GetTypmRate(Var ADelay : Byte; Var ASpeed : Byte);
    (* ---------------------------------------------------------------- *)
    Var Delay, Speed : Integer;
    Begin
     Delay := 1;                        (* Standart bei AT: 500 ms. *)
     Speed := 12;                       (* Standart bei AT: 10 Zeichen/Sek. *)

     (* RÅckgabe: *)
     ADelay := Delay;
     ASpeed := Speed;
    End;

   FUNCTION AT : Boolean;
    (* ---------------------------------------------------------------- *)
    Begin
     AT := Mem[$F000:$FFFE] = $FC;      (* Kennung fÅr >= AT. *)
    End;

   FUNCTION Is386 : Boolean;
    (* ---------------------------------------------------------------- *)
    Var IH1 : Integer;
    Begin
     IH1 := GetProz;                    (* Ermittle ProzessorNUMMER. *)
     Is386 := IH1 In [7,8];             (* Wert zurÅckgeben. *)
    End;

   FUNCTION GetProzessor : TProc;
    (* ---------------------------------------------------------------- *)
    Begin
     GetProzessor := Procs[GetProz];
    End;

   FUNCTION GetCoProzessor : TProc;
    (* ---------------------------------------------------------------- *)
    Begin
     GetCoProzessor := CoProcs[GetCo];
    End;

   PROCEDURE SetBorderColor(AColor : Byte); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   ax, 1001h
     mov   bh, AColor
     int   10h
    End;

   PROCEDURE CursorAn;
    (* ---------------------------------------------------------------- *)
    Begin
     Port[$3D4] := $A;
     Port[$3D5] := Port[$3D5] And $DF;
    End;

   PROCEDURE CursorAus;
    (* ---------------------------------------------------------------- *)
    Begin
     Port[$3D4] := $A;
     Port[$3D5] := Port[$3D5] Or $20;
    End;

   FUNCTION MemAllocSeg(ASize: Word) : Pointer;
    (* ---------------------------------------------------------------- *)
    Var P, T : Pointer;

    Function LowMemory : Boolean; Assembler;
     (* --------------------------------------------------------------- *)
     Asm
      MOV	AX, HeapEnd.Word[2]
      SUB	AX, HeapPtr.Word[2]
      SUB	AX, 256                 (* LowMemSize. *)
      SBB	AX, AX
      NEG	AX
     End;

    Function MemAlloc(ASize: Word) : Pointer;
     (* --------------------------------------------------------------- *)
     Var P : Pointer;
     Begin
      _GetMem(P, ASize);
{     If (P <> NIL) And LowMemory Then
       Begin
        FreeMem(P, ASize);
        P := NIL;
       End;
}     MemAlloc := P;
     End;

    (* ---------------------------------------------------------------- *)
    Begin
     ASize := (ASize + 7) And $FFF8;
     P := MemAlloc(ASize + 8);
     If P <> NIL Then
      Begin
       If PtrRec(P).Ofs = 0 Then
        Begin
         PtrRec(T).Ofs := ASize And 15;
         PtrRec(T).Seg := PtrRec(P).Seg + ASize Shr 4;
        End
       Else
        Begin
         T := P;
         PtrRec(P).Ofs := 0;
         Inc(PtrRec(P).Seg);
        End;
       FreeMem(T, 8);
      End;
     MemAllocSeg := P;
    End;

   PROCEDURE WaitVRetrace; Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     mov   dx, 03DAh

    @WaitNotVSyncLoop:                  (* Falls noch aktiv, warte bis Ende. *)
     in    al, dx
     and   al, 8
     jnz   @WaitNotVSyncLoop

    @WaitVSyncLoop:                     (* Warte bis Beginn. *)
     in    al, dx
     and   al, 8
     jz    @WaitVSyncLoop
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

   PROCEDURE _GetMem(Var P : Pointer; Size : Word);
    (* ---------------------------------------------------------------- *)
    Begin
     {$IFDEF GETMEM_CHECK}

     If MaxAvail < Size Then
      Begin
       {$IFDEF ERROR_HANDLING}
       ERR_Error := UNI_Error_NotEnoughMem; CriticalError('');
       {$ENDIF}
      End
     Else
      Begin
       GetMem(P, Size);
      End;

     {$ELSE}

     GetMem(P, Size);

     {$ENDIF}
    End;

   FUNCTION Min(A, B : LongInt) : LongInt;
    (* ---------------------------------------------------------------- *)
    Begin
     If A > B Then Min := B
     Else          Min := A;
    End;

   FUNCTION Max(A, B : LongInt) : LongInt;
    (* ---------------------------------------------------------------- *)
    Begin
     If A < B Then Max := B
     Else          Max := A;
    End;

   PROCEDURE FillWord(Var X; Count : Word; Value : Word); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
     les   di, X                        (* Ziel-Adresse. *)
     mov   cx, Count                    (* Anzahl Words. *)
     mov   ax, Value                    (* Zu schreibender Wert. *)
     cld                                (* Adressen erhîhen. *)
     rep   stosw                        (* CX Words von AX nach ES:DI. *)
    End;

  (* ƒƒ INITIALISIERUNGSƒTEIL: ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ *)

   BEGIN
    (* Initialisierung, nur wenn KEINE Overlay-Unit: *)

    {$IFOPT O-}
    UNIInitRoutines;
    {$ENDIF}
   END.

 (*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*)