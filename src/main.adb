with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   num_thread : constant Integer := 3;
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
      Timer : Duration := 0.0; -- Initialize Timer to avoid potential delay issues
      id : Integer := 0; -- Initialize id to avoid potential uninitialized use
   begin
      accept Start_Stoper (Timer : in Duration; id : in Integer) do
         Stoper.Timer := Timer;
         Stoper.id := id;
      end Start_Stoper;
      delay Timer;
      Can_Stop(id) := True;
   end Stoper;

   task body My_threads is
      Step : Long_Long_Integer := 0; -- Initialize Step to avoid potential uninitialized use
      Sum : Long_Long_Integer := 0;
      Count : Long_Long_Integer := 0;
      id : Integer := 0; -- Initialize id to avoid potential uninitialized use
   begin
      accept Start (Step : Long_Long_Integer; id : Integer) do
         My_threads.Step := Step;
         My_threads.id := id;
      end Start;

      loop
         Sum := Sum + Count * Step;
         Count := Count + 1;
         exit when Can_Stop(id);
      end loop;
      Put_Line(id'Img & " " & Sum'Img & " " & Count'Img);
   end My_threads;

   Timers_array : array (1..num_thread) of Standard.Duration := (10.0, 5.0, 7.0);
   Threads_array : array (1..num_thread) of My_threads;
   Stoper_array : array (1..num_thread) of Stoper;

begin
   for i in Threads_array'Range loop
      Threads_array(i).Start(2, i);
      Stoper_array(i).Start_Stoper(Timers_array(i), i);
   end loop;
end Main;
