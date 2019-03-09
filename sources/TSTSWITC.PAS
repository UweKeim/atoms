PROGRAM TestSwitch;
 (* Testet, ob CHANGEPAGE wirklich die vorgegebene Zeit braucht: *)

 USES Crt,
      UweVGA01;

 CONST CRTAddress = $3D4;

 VAR TIME : Word;

   PROCEDURE ChangePage(P : Byte); Assembler;
    (* ---------------------------------------------------------------- *)
    Asm
{    cli

     mov   dx, CRTAddress		(* Index der CRT-CONTROLLER REGISTER. *)
     mov   al, 0Dh                      (* Index des START ADRESS LOW REGISTERS. *)
     out   dx, al                       (* Register fÅr Daten aktivieren. *)
     inc   dx                           (* Datenadresse der CRT-CONTROLLER REGISTER. *)

     mov   bl, P                        (* Seite (P) nach BL laden. *)
     mov   si, bx                       (* Seite nach SI. *)
     and   si, 3                        (* nur Bit 0 und 1 zÑhlt. *)
     shl   si, 1                        (* SI := SI * 2. *)
     add   si, OFFSET PAdr              (* Aus Tabelle die Offset-Seiten-Adresse lesen. *)
     lodsw                              (* Laden von DS:SI nach AX. *)

     out   dx, al			(* LB der neuen Startadr. setzen. *)
     dec   dx
     mov   al, 0Ch
     out   dx, al
     inc   dx
     mov   al, ah			(* HB der neuen Startadr. setzen. *)
     out   dx, al
     sti  }

      Cli

      (* Seitennummern in Variablen eintragen: *)
      mov   bx, Page
      neg   bx
      inc   bx
      mov   Page, bx                    (* PAGE := 1-PAGE. *)

      (* LOW-Byte der Startadresse setzen: *)
      mov   dx, CRTAddress              (* Index der CRT-CONTROLLER REGISTER. *)
      mov   al, 0Dh                     (* Index des START ADRESS LOW REGISTERS.*)
      mov   ah, cl                      (* LOW-Byte der Startadresse. *)
      out   dx, ax                      (* Register fÅr Daten aktivieren und senden. *)

      (* HIGH-Byte der Startadresse setzen: *)
      dec   al                          (* Index des START ADRESS HIGH REGISTERS.*)
      mov   ah, ch                      (* LOW-Byte der Startadresse. *)
      out   dx, ax                      (* Register fÅr Daten aktivieren und senden. *)

      Sti
    End;


 BEGIN
  Init256N;

  ChangePage(1);

  Asm
   mov ax, 3
   int 10h
  End;
 END.