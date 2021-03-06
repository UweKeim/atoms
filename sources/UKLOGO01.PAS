 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)
 (*  Programm : UKLOGO01                                                   *)
 (*             L꼜st ein LOGO erscheinen.                                 *)
 (* ---------------------------------------------------------------------- *)
 (*     Datei : UKLOGO01.PAS                                               *)
 (*             Hauptprogramm.                                             *)
 (* ---------------------------------------------------------------------- *)
 (*   Version : 0.1                                                        *)
 (*     Autor : Uwe Keim                                                   *)
 (*     Start : 04. Oktober 1994                                           *)
 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)

 PROGRAM UKLOGO01;

  {$A-,B-,D-,E+,F+,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
  {$M 16384,0,655360}

  {$UNDEF  DEBUG}                       (* Debug-Infos AN/AUS. *)

  {$IFDEF DEBUG}
  {$D+,L+,Y+}                           (* Debug-Infos. *)
  {$ENDIF}

  (*컴 DEKLARATIONSTEIL: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*)

   USES Crt,

        UwePAL01,
        UweVGA01,
        UweUNI01;

   (* 컴 Verschiedene Erkl꼛ungen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* ----------------------------------------------------------- *)
   (* ----------------------------------------------------------- *)

   (* 컴 Verschiedene Konstanten: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* 컴 Verschiedene Typen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* 컴 Verschiedene Variablen: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� *)

   (* 컴 Prototypen der Prozeduren: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   (* -- Normale Prozeduren: ------------------------------------------- *)

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

   (* -- Die Systemprozeduren: ----------------------------------------- *)

   PROCEDURE Init;
    (* ---------------------------------------------------------------- *)
    Begin
     Init256N;
    End;

   PROCEDURE Main;
    (* ---------------------------------------------------------------- *)
    Const StartL   = 1;
          StartN   = 1;
          StdSpeed = 55;
    Var HPal  : TPalette;
        Cnt   : Word;
        WH1   : Word;
        Speed : Word;
        Code  : Integer;
    Begin
     (* Palette laden: *)
     LoadPalette('UKLOGO.PAL', 1);
     HPal := PALField[1];
     SetPalette(ZeroColors);

     (* Sprites laden: *)
     Cnt := LoadSprite('UKLOGO.SPR', StartL);

     (* Sprites verketten: *)
     For WH1 := StartL+Cnt-1 DownTo StartL Do
      NextSprite[WH1] := WH1 - 1;
     NextSprite[StartL] := Cnt;

     (* Geschwindigkeit: *)
     If ParamCount <> 0 Then
      Begin
       Val(ParamStr(1), Speed, Code);
       If Code = 0 Then SetCycleTime(Speed)
        Else SetCycleTime(StdSpeed);
      End
     Else SetCycleTime(StdSpeed);

     (* Hintergrund-Sterne: *)
     Randomize;
     For WH1 := 1 To 150 Do
      PutPixel(255, Random(320), Random(200), BackGroundPage);

     (* Einblenden: *)
     Animate;
     FadeToPalette(HPal, 40);

     (* Positionen: *)
     SpriteN[StartN] := StartL;
     SpriteX[StartN] := XMAX Div 2;
     SpriteY[StartN] := YMAX Div 2;

     (* Zeigen: *)
     For WH1 := 1 To Cnt Do
      Begin
       Dec(SpriteX[StartN], Round(0.0200 * WH1 * WH1));
       Dec(SpriteY[StartN], Round(0.0138 * WH1 * WH1));

       Animate;
      End;

     (* Warte auf Taste: *)
     While KeyPressed Do ReadKey;
     Repeat Until KeyPressed;

     (* Ausblenden: *)
     FadeToPalette(ZeroColors, 40);
    End;

   PROCEDURE Done;
    (* ---------------------------------------------------------------- *)
    Begin
     (* Fremde Units beenden: *)
     VGACloseRoutines;
    End;

  (* 컴 HAUPTPROGRAMM: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 *)

   BEGIN
    Init;
    Main;
    Done;
   END.

 (*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*)