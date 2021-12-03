----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2021 09:54:12 PM
-- Design Name: 
-- Module Name: ShiftRows - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRows is
--  Port ( );
generic(N: INTEGER := 128);
port(InS : in STD_LOGIC_VECTOR(N-1 downto 0);
     InS_p : out STD_LOGIC_VECTOR(N-1 downto 0));
end ShiftRows;

architecture Behavioral of ShiftRows is

begin
    GEN_SHIFTERS: for i in 1 to 3 generate
        -- we only apply rotator on row 1, row 2, and row 3. not on row 0
    
        GEN_EACH_SHIFTER: entity work.nrotk 
            generic map(N => 32, -- Width is 32
                        K => 8*i) -- rotation by 8 * i or i bytes 
            port map(D => InS(127-32*i downto 128-32*(i+1)), -- Map each respect row with i
                     Q => InS_p(127-32*i downto 128-32*(i+1)));
  
    end generate GEN_SHIFTERS;
-- first row is not rotated at all    
InS_p(127 downto 96) <= InS(127 downto 96);

end Behavioral;
