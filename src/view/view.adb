-------------------------------------------------------------------------------
--                                                                           --
--                     Copyright (C) 2014-, AdaHeads K/S                     --
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

package body View is
   use GNATCOLL.JSON;

   function Description (Message : in String) return JSON_Value is
      JSON : constant JSON_Value := Create_Object;
   begin
      JSON.Set_Field ("description", Message);

      return JSON;
   end Description;

   function Description (Event : in Ada.Exceptions.Exception_Occurrence)
                         return GNATCOLL.JSON.JSON_Value is
      JSON : constant JSON_Value := Create_Object;
   begin
      JSON.Set_Field ("description", Ada.Exceptions.Exception_Message (Event));

      return JSON;
   end Description;

end View;
