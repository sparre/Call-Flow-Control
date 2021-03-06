-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2012-, AdaHeads K/S                     --
--                                                                           --
--  This is free software;  you can redistribute it and/or modify it         --
--  under terms of the  GNU General Public License  as published by the      --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Interrupts.Names;
with Ada.Strings.Fixed;
with Ada.Exceptions;

with System_Messages;

package body SIGHUP is

   type Handler_Count is range 0 .. 20;
   subtype Handler_Indices is Handler_Count range 1 .. Handler_Count'Last;
   type Handler_States is array (Handler_Indices) of Boolean;

   protected Queue is
      procedure HUP;
      --  Activate all SIGHUP handlers.

      pragma Attach_Handler (HUP, Ada.Interrupts.Names.SIGHUP);
      --  Attaches HUP to SIGHUP signals.

      procedure Register
        (Handler_Index : out Handler_Indices);
      --  Register a handler.

      procedure Stop;
      --  Stop all registered SIGHUP handlers.

      entry Wait (Handler_Indices)
        (Stop : out Boolean);
      --  All Watcher tasks hang here as long as HUP hasn't been called.
   private
      Handle     : Handler_States := (others => False);
      Registered : Handler_Count := 0;
      Stopping   : Boolean := False;
   end Queue;

   -------------
   --  Queue  --
   -------------

   protected body Queue is

      -----------
      --  HUP  --
      -----------

      procedure HUP
      is
      begin
         for Index in 1 .. Registered loop
            Handle (Index) := True;
         end loop;
      end HUP;

      ----------------
      --  Register  --
      ----------------

      procedure Register
        (Handler_Index : out Handler_Indices)
      is
      begin
         if Registered < Handler_Indices'Last then
            Registered := Registered + 1;
            Handler_Index := Registered;
         else
            raise Constraint_Error;
         end if;
      end Register;

      ------------
      --  Stop  --
      ------------

      procedure Stop
      is
      begin
         Stopping := True;
         for Index in 1 .. Registered loop
            Handle (Index) := True;
         end loop;
      end Stop;

      ------------
      --  Wait  --
      ------------

      entry Wait (for Handler in Handler_Indices) (Stop : out Boolean)
      when Handle (Handler)
      is
      begin
         Handle (Handler) := False;
         Stop := Stopping;
      end Wait;
   end Queue;

   task type Watcher
     (Index : Handler_Indices;
      Call  : Callback);
   --  A SIGHUP watcher. Call is called when a SIGHUP signal is caught.

   type Watcher_Reference is access Watcher;

   ---------------
   --  Watcher  --
   ---------------

   task body Watcher is
      use Ada.Strings.Fixed;
      use System_Messages;

      Context : constant String := Package_Name & ".Watcher";

      Stop : Boolean := False;
   begin
      System_Messages.Information (Message => "Attached handler.",
                                   Context => Context);
      loop
         begin
            Queue.Wait (Index) (Stop);
            exit when Stop;
            Call.all;
         exception
            when E : others =>
               System_Messages.Critical
                 (Message => Trim
                    (Handler_Indices'Image (Index), Ada.Strings.Both) &
                    "Unhandled exception: " &
                    Ada.Exceptions.Exception_Information (E),
                  Context => Context);

         end;
      end loop;

      System_Messages.Information (Message => "Detached handler.",
                                   Context => Context);
   end Watcher;

   ----------------
   --  Register  --
   ----------------

   procedure Register
     (Handler : in Callback)
   is
      use Ada.Strings.Fixed;
      use System_Messages;

      Context : constant String := Package_Name & ".Watcher";

      Index       : Handler_Indices := 1;
      New_Watcher : Watcher_Reference;
      pragma Unreferenced (New_Watcher);
   begin
      Queue.Register (Handler_Index => Index);
      New_Watcher := new Watcher (Index => Index,
                                  Call  => Handler);
   exception
      when Constraint_Error =>
         System_Messages.Critical
           (Message => Trim (Handler_Indices'Image (Index), Ada.Strings.Both),
            Context => Context);
   end Register;

   ------------
   --  Stop  --
   ------------

   procedure Stop is
   begin
      Queue.Stop;
   end Stop;

end SIGHUP;
