PROGRAM TestDelay;
 (* Testet, ob EASYANIMATE wirklich die vorgegebene Zeit braucht: *)

 USES Crt,
      UweVGA01;

 VAR TIME : Word;

 BEGIN

  ClrScr;
  Write('Zeit in Milli-Sekunden: ');
  ReadLn(Word(TIME));

  Init256N;

  SetCycleTime(Word(TIME));

  EasyAnimate;

  Asm
   mov ax, 3
   int 10h
  End;
 END.