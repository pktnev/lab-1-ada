with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   num_thread : constant Integer := 4;
   pragma Assert (num_thread > 0);

   type Can_Stop_Arr is array (1..num_thread) of Boolean;
   Can_Stop : Can_Stop_Arr := (others => False);
   pragma Atomic (Can_Stop);

   task type Stoper is
      entry Start_Stoper (Timer : Duration; id : Integer);
   end Stoper;

   task type My_threads is
      entry Start (Step : Long_Long_Integer; id : Integer);
   end My_threads;

   task body Stoper is
      Timer : Duration := 0.0;
      id : Integer := 0;
   begin
      accept Start_Stoper (Timer : in Duration; id : in Integer) do
         Stoper.Timer := Timer;
         Stoper.id := id;
      end Start_Stoper;
      Put_Line("Stoper " & id'Img & " started with Timer: " & Timer'Img);
      delay Timer;
      Can_Stop(id) := True;
      Put_Line("Stoper " & id'Img & " finished.");
   end Stoper;

   task body My_threads is
      Step : Long_Long_Integer := 0;
      Sum : Long_Long_Integer := 0;
      Count : Long_Long_Integer := 0;
      id : Integer := 0;
   begin
      accept Start (Step : Long_Long_Integer; id : Integer) do
         My_threads.Step := Step;
         My_threads.id := id;
      end Start;

      Put_Line("Thread " & id'Img & " started with Step: " & Step'Img);

      loop
         Sum := Sum + Count * Step;
         Count := Count + 1;
         exit when Can_Stop(id);
      end loop;

      Put_Line(id'Img & " " & Sum'Img & " " & Count'Img);
      Put_Line("Thread " & id'Img & " finished.");
   end My_threads;

   Timers_array : array (1..num_thread) of Standard.Duration := (10.0, 5.0, 7.0, 7.0);
   Threads_array : array (1..num_thread) of My_threads;
   Stoper_array : array (1..num_thread) of Stoper;

begin
   for i in Threads_array'Range loop
      Put_Line("Starting thread " & i'Img);
      Threads_array(i).Start(2, i);
      Stoper_array(i).Start_Stoper(Timers_array(i), i);
   end loop;
   delay 15.0;
   Put_Line("All threads and stoppers should have finished.");
end Main;
