-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2013-, AdaHeads K/S                     --
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

with AWS.Status;

package Model.User.List is
   use Model;

   Package_Name : constant String := "Model.User.List";

   type Instance is tagged private;

   Not_Found : exception;

   function Get_Singleton return Instance;
   --  Returns the internal singleton object for the server.
   --  An easy ad-hoc way of

   function Get (Object   : in Instance;
                 Identity : in User.Identities) return User.Instance;
   --  Retrieves a user object based on the identity.

--     function Get (Object  : in Instance;
--                   User_ID : in User.Identifications) return User.Instance;

   function User_Of (Object  : in Instance;
                     Request : AWS.Status.Data) return User.Instance;
   --  Determine the user from a session in a request.

   function To_JSON (Object : in Instance) return JSON_Value;
   --  Gives back the JSON representation of the list.

private
   type Instance is tagged
      record
         User_Map      : User_Maps      := User.User_Storage.Empty_Map;
         ID_Lookup_Map : ID_Lookup_Maps := User.Lookup_Storage.Empty_Map;
      end record;

   procedure Reload_Map (Object   :    out Instance;
                         Filename : in     String);
   --  Reloads the internal map of users from the configuration.
   --  Callable by child SIGHUP handlers.
end Model.User.List;