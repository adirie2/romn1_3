----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 07:29:54 PM
-- Design Name: 
-- Module Name: MixColumns - Behavioral
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

entity MixColumns is
--  Port ( );
port(InS: in STD_LOGIC_VECTOR(127 downto 0);
     InS_p: out STD_LOGIC_VECTOR(127 downto 0));
end MixColumns;

architecture Behavioral of MixColumns is

begin
GEN_MIX_COLS: for i in 0 to 3 generate

    -- ROW 0
    InS_p(127-8*i downto 128-8*(i+1)) <= InS(127-8*i downto 128-8*(i+1))
                                     xor InS(63-8*i downto 64-8*(i+1))
                                     xor InS(31-8*i downto 32-8*(i+1));
    -- ROW 1                              
    InS_p(95-8*i downto 96-8*(i+1)) <= InS(127-8*i downto 128-8*(i+1));
    
    -- ROW 2
    InS_p(63-8*i downto 64-8*(i+1)) <= InS(95-8*i downto 96-8*(i+1)) xor InS(63-8*i downto 64-8*(i+1));
    
    -- ROW 3
    InS_p(31-8*i downto 32-8*(i+1)) <= InS(127-8*i downto 128-8*(i+1)) xor InS(63-8*i downto 64-8*(i+1));
    

end generate GEN_MIX_COLS;

end Behavioral;
