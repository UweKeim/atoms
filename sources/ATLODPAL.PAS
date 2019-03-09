   FUNCTION LoadPCXPicToRAM(AName : String; Var Laenge : LongInt) : Pointer;
    (* ---------------------------------------------------------------- *)
    Var F   : File;
        PH1 : Pointer;
    Begin
     If Not (AFirst In [0..PCXMAX]) Then
      Begin
       VGA_Error := VGA_Error_Error_InvalidArgumentValues;
       Exit;
      End;

     Assign(F, AName);

     (* Datei ôffnen: *)
     {$I-}
     Reset(F, 1);                       (* RecordlÑnge = 1 Byte. *)
     {$I+}
     VGA_Error := IOResult; If VGA_Error <> 0 Then CriticalError(AName);

     (* DateilÑnge bestimmen: *)
     {$I-}
     Laenge := FileSize(F);
     {$I+}
     VGA_Error := IOResult; If VGA_Error <> 0 Then CriticalError(AName);

     (* Grî·er als 65528 Bytes (= 64 KByte-$08), dann Ende: *)
     If Laenge > 65528 Then
      Begin
       VGA_Error := VGA_Error_FileSizeTooBig;
       CriticalError(AName);
      End;

     (* Speicher fÅr Datei belegen: *)
     GetMem(PH1, Laenge);

     (* Daten einlesen: *)
     {$I-}
     BlockRead(F, PH1^, Laenge);
     {$I+}
     VGA_Error := IOResult; If VGA_Error <> 0 Then CriticalError(AName);

     (* RÅckgabe: *)
     LoadPCXPicToRAM := PH1;
     VGA_Error := VGA_Error_Ok;
    End;

   FUNCTION ShowPCXPicFromRAM(APtr : Pointer; ALaenge : LongInt; APage : Byte; AUsePal, ASetPal : Boolean) : Pointer;
    (* ---------------------------------------------------------------- *)
    Const BlockReadSize   = 526;        (* Nicht verÑndern !!!! *)

    Type TPCXHeader       = Record
                             Hersteller    : Byte;
                             Version       : Byte;
                             CodierArt     : Byte;
                             BitProPixel   : Byte;
                             Bildgroesse   : Array[1..4] Of Word;
                             HorizAufl     : Word;
                             VertiAufl     : Word;
                             Farbskala     : Array[1..48] Of Byte;
                             Reserviert    : Byte;
                             Farbebenen    : Byte;
                             BytesProZeile : Word;
                             FarbeOdGrau   : Word;
                             Fueller       : Array[1..58] Of Byte;
                            End;

    Var PCXHeader       : TPCXHeader;
        PCXFarbSkala256 : TPalette;

        CountDataBlocks : Integer;      (* Anzahl an Pixeldaten zu "BLOCKREADSIZE"-Blîcken. *)
        BlocksRead      : Integer;      (* Schon gelesene Blocks. *)
        ByteInLastBlock : Integer;      (* Wieviele Byte im letzten Block gebraucht werden. *)
        ByteReadInBlock : Integer;      (* Aktuelle Anzahl gelesener Byte in diesem Block. *)

        PFile           : Pointer;
        PFileByte       : ^Byte;
        PDatenIn4er     : Pointer;      (* Hier ist das Bild gespeichert, nach   *)
                                        (* Ebenen geordnet, also E0-Daten, E1... *)
        PBlockDaten     : Pointer;      (* Zeiger auf 1 geladenen Block. *)
        PEbenen         : Array[0..3] Of ^Byte;
        AktEbene        : Byte;

        IH1             : Integer;
        PB1             : ^Byte;
        BH1             : Byte;
        WH1, WH2, WH3   : Word;
        SH1             : String[79];
        BreakTrue       : Boolean;

        OK              : Boolean;
        Zaehler         : Integer;

    Begin
     ShowPCXPicFromRAM := Nil;

     (* Anzahl der Blocks lesen: *)
     CountDataBlocks := (ALAENGE  - SizeOf(PCXFarbSkala256))
                         Div BlockReadSize;

     If (ALaenge - SizeOf(PCXFarbSkala256)) Mod BlockReadSize > 0 Then Inc(CountDataBlocks);
     ByteInLastBlock  := (ALaenge - SizeOf(PCXFarbSkala256))
                         Mod BlockReadSize -1;

     (* Header lesen: *)
     PB1 := @PCXHeader;
     Move(APtr^, PB1^, SizeOf(PCXHeader));

     (* Lade Farbskala: *)
     If AUsePal And (PCXHeader.Version >= 5) Then
      Begin
       LongInt(APtr) := LongInt(APtr) + ALaenge - 768;
       PB1 := @PCXFarbSkala256;
       Move(APtr^, PB1^, 768);
       LongInt(APtr) := LongInt(APtr) - ALaenge + 768;

       If ASetPal Then SetPalette(PCXFarbSkala256);
       ShowPCXPicFromRAM := @PCXFarbSkala256;
      End;

     (* DatensÑtze lesen: *)
     BlocksRead := 0;
     AktEbene   := 0;
     ByteReadInBlock := 0;

     GetMem(PDatenIn4er, 320*200);      (* Speicher fÅr 1 Bild reservieren. *)
     LongInt(PEbenen[0]) := LongInt(PDatenIn4er) + 0 * ((320 * 200) Div 4);
     LongInt(PEbenen[1]) := LongInt(PDatenIn4er) + 1 * ((320 * 200) Div 4);
     LongInt(PEbenen[2]) := LongInt(PDatenIn4er) + 2 * ((320 * 200) Div 4);
     LongInt(PEbenen[3]) := LongInt(PDatenIn4er) + 3 * ((320 * 200) Div 4);

     GetMem(PBlockDaten, BlockReadSize);

     BreakTrue := False;
     OK := False;
     Zaehler := 1;

     While (BlocksRead <= CountDataBlocks) Do
      Begin
       (* Zeiger zum einlesen: *)
       Move(APtr^, PBlockDaten^, BlockReadSize);
       Inc(LongInt(APtr), BlockReadSize);

       ByteReadInBlock := 0;
       Inc(BlocksRead);
       PB1 := PBlockDaten;

       (* Ein Satz entpacken und gleich in die richtigen Ebenen verteilen: *)
       If BlocksRead = 1 Then           (* Header Åberspringen. *)
        Begin
         Inc(PB1, 128);
         Inc(ByteReadInBlock, 128);
        End;

       While LongInt(PB1) < LongInt(PBlockDaten)+BlockReadSize Do
        Begin
         If (Not OK) And (PB1^ >= 192) Then
          Begin
           Zaehler := PB1^ - 192;
           OK := False;
          End;
         If (Not OK) And (PB1^ < 192) Then
          Begin
           Zaehler := 1;
           OK := True;
          End;

         If (OK) Then
          Begin
           For IH1 := 1 To Zaehler Do
            Begin
             PEbenen[AktEbene]^ := PB1^;
             Inc(PEbenen[AktEbene]);
             Inc(AktEbene); If AktEbene > 3 Then AktEbene := 0;
            End;
           Inc(PB1);
           Inc(ByteReadInBlock);
           OK := False;
          End
         Else
          Begin
           OK := True;
           Inc(PB1);
           Inc(ByteReadInBlock);
          End;

         If (BlocksRead >= CountDataBlocks) And
            (ByteReadInBlock >= ByteInLastBlock) Then
             Begin
              BreakTrue := True;
              Break;
             End;
        End;

       If BreakTrue Then Break;

     End;

     FreeMem(PBlockDaten, BlockReadSize);

     (* PBLOCKDATEN^ Ebenenweise auf Schirm bringen: *)
     WH1 := Seg(PDatenIn4er^);
     WH2 := Ofs(PDatenIn4er^);
     WH3 := PAdr[APage];
     AktEbene := 1;

     Asm
      push  ds
      mov   ax, ScreenSeg
      mov   es, ax                      (* ES = ZielSegment. *)

      mov   ax, WH1
      mov   ds, ax                      (* DS = QuellSegment. *)

      mov   ax, WH2
      mov   si, ax                      (* SI = QuellOffset. *)

      (* Ebenen ausgeben: *)
      mov   cx, 4                       (* Alle Ebenen durch. *)

     @EineEbene:
      push  cx

      mov   ax, WH3
      mov   bx, ax                      (* BX = ZielOffset. *)

      mov   ah, AktEbene
      mov   al, 2                       (* AL = Index Map Mask Register. *)
      mov   dx, 3C4h
      out   dx, ax                      (* Ebene wÑhlen. *)

      mov   cx, ScreenSize / 2          (* BYTES -> WORDS. *)

      (* Alle Daten von 1 Ebene ausgeben: *)

      (* CX = Anzahl Bytes,                       *)
      (* ES = Bildschirm-Segment,                 *)
      (* BX = Bildschirm-Offset,                  *)
      (* DS = Spritedaten-Segment,                *)
      (* SI = Spritedaten-Offset.                 *)

      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
      dec   bx

     @AllePunkteEinerEbene:
      lodsw                             (* 1 Byte holen. *)
      mov   es:[bx+si], ax              (* öbertragen. *)
      loop  @AllePunkteEinerEbene       (* NÑchstes Byte. *)

      pop   cx

      mov   al, AktEbene                (* NÑchste Ebene. *)
      shl   al, 1
      mov   AktEbene, al

      loop  @EineEbene

      pop   ds
     End;

     FreeMem(PDatenIn4er, 320*200);     (* Speicher fÅr 1 Bild freigeben. *)

     VGA_Error := VGA_Error_OK;
    End;

    Const BlockReadSize   = 526;        (* Nicht verÑndern !!!! *)

    Type TPCXHeader       = Record
                             Hersteller    : Byte;
                             Version       : Byte;
                             CodierArt     : Byte;
                             BitProPixel   : Byte;
                             Bildgroesse   : Array[1..4] Of Word;
                             HorizAufl     : Word;
                             VertiAufl     : Word;
                             Farbskala     : Array[1..48] Of Byte;
                             Reserviert    : Byte;
                             Farbebenen    : Byte;
                             BytesProZeile : Word;
                             FarbeOdGrau   : Word;
                             Fueller       : Array[1..58] Of Byte;
                            End;

    Var PCXHeader       : TPCXHeader;
        PCXFarbSkala256 : TPalette;

        CountDataBlocks : Integer;      (* Anzahl an Pixeldaten zu "BLOCKREADSIZE"-Blîcken. *)
        BlocksRead      : Integer;      (* Schon gelesene Blocks. *)
        ByteInLastBlock : Integer;      (* Wieviele Byte im letzten Block gebraucht werden. *)
        ByteReadInBlock : Integer;      (* Aktuelle Anzahl gelesener Byte in diesem Block. *)

        PFile           : Pointer;
        PFileByte       : ^Byte;
        PDatenIn4er     : Pointer;      (* Hier ist das Bild gespeichert, nach   *)
                                        (* Ebenen geordnet, also E0-Daten, E1... *)
        PBlockDaten     : Pointer;      (* Zeiger auf 1 geladenen Block. *)
        PEbenen         : Array[0..3] Of ^Byte;
        AktEbene        : Byte;

        IH1             : Integer;
        PB1             : ^Byte;
        BH1             : Byte;
        WH1, WH2, WH3   : Word;
        SH1             : String[79];
        BreakTrue       : Boolean;

        OK              : Boolean;
        Zaehler         : Integer;

    Begin
     ShowPCXPicFromRAM := Nil;

     (* Anzahl der Blocks lesen: *)
     CountDataBlocks := (ALAENGE  - SizeOf(PCXFarbSkala256))
                         Div BlockReadSize;

     If (ALaenge - SizeOf(PCXFarbSkala256)) Mod BlockReadSize > 0 Then Inc(CountDataBlocks);
     ByteInLastBlock  := (ALaenge - SizeOf(PCXFarbSkala256))
                         Mod BlockReadSize -1;

     (* Header lesen: *)
     PB1 := @PCXHeader;
     Move(APtr^, PB1^, SizeOf(PCXHeader));

     (* Lade Farbskala: *)
     If AUsePal And (PCXHeader.Version >= 5) Then
      Begin
       LongInt(APtr) := LongInt(APtr) + ALaenge - 768;
       PB1 := @PCXFarbSkala256;
       Move(APtr^, PB1^, 768);
       LongInt(APtr) := LongInt(APtr) - ALaenge + 768;

       If ASetPal Then SetPalette(PCXFarbSkala256);
       ShowPCXPicFromRAM := @PCXFarbSkala256;
      End;

     (* DatensÑtze lesen: *)
     BlocksRead := 0;
     AktEbene   := 0;
     ByteReadInBlock := 0;

     GetMem(PDatenIn4er, 320*200);      (* Speicher fÅr 1 Bild reservieren. *)
     LongInt(PEbenen[0]) := LongInt(PDatenIn4er) + 0 * ((320 * 200) Div 4);
     LongInt(PEbenen[1]) := LongInt(PDatenIn4er) + 1 * ((320 * 200) Div 4);
     LongInt(PEbenen[2]) := LongInt(PDatenIn4er) + 2 * ((320 * 200) Div 4);
     LongInt(PEbenen[3]) := LongInt(PDatenIn4er) + 3 * ((320 * 200) Div 4);

     GetMem(PBlockDaten, BlockReadSize);

     BreakTrue := False;
     OK := False;
     Zaehler := 1;

     While (BlocksRead <= CountDataBlocks) Do
      Begin
       (* Zeiger zum einlesen: *)
       Move(APtr^, PBlockDaten^, BlockReadSize);
       Inc(LongInt(APtr), BlockReadSize);

       ByteReadInBlock := 0;
       Inc(BlocksRead);
       PB1 := PBlockDaten;

       (* Ein Satz entpacken und gleich in die richtigen Ebenen verteilen: *)
       If BlocksRead = 1 Then           (* Header Åberspringen. *)
        Begin
         Inc(PB1, 128);
         Inc(ByteReadInBlock, 128);
        End;

       While LongInt(PB1) < LongInt(PBlockDaten)+BlockReadSize Do
        Begin
         If (Not OK) And (PB1^ >= 192) Then
          Begin
           Zaehler := PB1^ - 192;
           OK := False;
          End;
         If (Not OK) And (PB1^ < 192) Then
          Begin
           Zaehler := 1;
           OK := True;
          End;

         If (OK) Then
          Begin
           For IH1 := 1 To Zaehler Do
            Begin
             PEbenen[AktEbene]^ := PB1^;
             Inc(PEbenen[AktEbene]);
             Inc(AktEbene); If AktEbene > 3 Then AktEbene := 0;
            End;
           Inc(PB1);
           Inc(ByteReadInBlock);
           OK := False;
          End
         Else
          Begin
           OK := True;
           Inc(PB1);
           Inc(ByteReadInBlock);
          End;

         If (BlocksRead >= CountDataBlocks) And
            (ByteReadInBlock >= ByteInLastBlock) Then
             Begin
              BreakTrue := True;
              Break;
             End;
        End;

       If BreakTrue Then Break;

     End;

     FreeMem(PBlockDaten, BlockReadSize);

     (* PBLOCKDATEN^ Ebenenweise auf Schirm bringen: *)
     WH1 := Seg(PDatenIn4er^);
     WH2 := Ofs(PDatenIn4er^);
     WH3 := PAdr[APage];
     AktEbene := 1;

     Asm
      push  ds
      mov   ax, ScreenSeg
      mov   es, ax                      (* ES = ZielSegment. *)

      mov   ax, WH1
      mov   ds, ax                      (* DS = QuellSegment. *)

      mov   ax, WH2
      mov   si, ax                      (* SI = QuellOffset. *)

      (* Ebenen ausgeben: *)
      mov   cx, 4                       (* Alle Ebenen durch. *)

     @EineEbene:
      push  cx

      mov   ax, WH3
      mov   bx, ax                      (* BX = ZielOffset. *)

      mov   ah, AktEbene
      mov   al, 2                       (* AL = Index Map Mask Register. *)
      mov   dx, 3C4h
      out   dx, ax                      (* Ebene wÑhlen. *)

      mov   cx, ScreenSize / 2          (* BYTES -> WORDS. *)

      (* Alle Daten von 1 Ebene ausgeben: *)

      (* CX = Anzahl Bytes,                       *)
      (* ES = Bildschirm-Segment,                 *)
      (* BX = Bildschirm-Offset,                  *)
      (* DS = Spritedaten-Segment,                *)
      (* SI = Spritedaten-Offset.                 *)

      stc                               (* BX so verringern, da· es zusammen *)
      sbb   bx, si                      (* mit SI zugleich als Zielindex     *)
                                        (* verwendet werden kann.            *)
      dec   bx

     @AllePunkteEinerEbene:
      lodsw                             (* 1 Byte holen. *)
      mov   es:[bx+si], ax              (* öbertragen. *)
      loop  @AllePunkteEinerEbene       (* NÑchstes Byte. *)

      pop   cx

      mov   al, AktEbene                (* NÑchste Ebene. *)
      shl   al, 1
      mov   AktEbene, al

      loop  @EineEbene

      pop   ds
     End;

     FreeMem(PDatenIn4er, 320*200);     (* Speicher fÅr 1 Bild freigeben. *)

     VGA_Error := VGA_Error_OK;
