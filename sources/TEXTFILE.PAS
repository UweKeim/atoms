UNIT TextFile;

 (* FileSize, Seek und FilePos auch fÅr TextFiles. *)
 (* CT 10/92, S.230 und CT 12/92, S.12.            *)

  {$A-,B-,D+,E+,F+,G+,I-,L+,N+,O+,P-,Q-,R-,S-,T-,V-,X+,Y+}
  {$M 16384,0,655360}

  {$undef  DEBUG}                       (* Debug-Infos AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

INTERFACE

USES Dos;

FUNCTION TextFilePos(Var Handle : Text) : LongInt;
FUNCTION TextFileSize(Var Handle : Text) : LongInt;
PROCEDURE TextSeek(Var Handle : Text; Pos : LongInt);

IMPLEMENTATION

FUNCTION TextFilePos(Var Handle : Text) : LongInt;
 Var Regs : Registers;
 Begin
  With Regs Do
   Begin
    AH := $42;
    AL := $01;
    BX := TextRec(Handle).Handle;
    CX := $00;
    DX := $00;
    MSDOS(Regs);

    If Flags And fCarry = fCarry Then
     Begin
      InOutRes := AX;
      TextFilePos := 0;
     End
   Else
    Begin
     TextFilePos := DX * 65536 + AX - TextRec(Handle).BufEnd
                    + TextRec(Handle).BufPos;
    End;
   End;
 End;

FUNCTION TextFileSize(Var Handle : Text) : LongInt;
 Var Regs    : Registers;
     TempPtr : LongInt;
 Begin
  Case TextRec(Handle).Mode Of
   fmInput  : Begin
               TempPtr      := TextFilePos(Handle);
               TextFileSize := 0;

               With Regs Do
                Begin
                 AH := $42;
                 AL := $02;
                 BX := TextRec(Handle).Handle;
                 CX := $00;
                 DX := $00;
                 MSDOS(Regs);

                 If Flags And fCarry = fCarry Then InOutRes := AX
                 Else TextFileSize := DX * 65536 + AX;
                 TextSeek(Handle, TempPtr);
                End;
              End;
   fmOutPut : Begin
               TextFileSize := TextFilePos(Handle);
              End;
   Else       Begin
               TextFileSize := 0;
               InOutRes     := 1;
              End;
  End;
 End;

PROCEDURE TextSeek(Var Handle : Text; Pos : LongInt);
 Type DWord = Array[0..1] Of Word;
 Var Regs : Registers;
 Begin
  If TextFilePos(Handle) <> Pos Then
   Begin
    If TextRec(Handle).Mode = fmOutPut Then Flush(Handle);

    With Regs Do
     Begin
      TextRec(Handle).BufPos := 0;
      TextRec(Handle).BufEnd := 0;
      AH := $42;
      AL := $00;
      BX := TextRec(Handle).Handle;
      CX := DWord(Pos)[1];
      DX := DWord(Pos)[0];
      MSDOS(Regs);
      If Flags And fCarry = fCarry Then InOutRes := AX
     End;
   End;
 End;

End.