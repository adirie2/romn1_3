----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2021 11:14:31 PM
-- Design Name: 
-- Module Name: SubCells - Behavioral
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

entity SubCells is
  Port (
         InS: in STD_LOGIC_VECTOR(127 downto 0);
         InS_p : out STD_LOGIC_VECTOR(127 downto 0) );
end SubCells;
architecture Behavioral of SubCells is

begin
GEN_SBOX : for i in 0 to 15 generate

    SBOX_GEN : entity work.sbox_col
    port map(
            Addr => InS(127-8*i downto 128-8*(i+1)),
             Y => InS_p(127-8*i downto 128-8*(i+1)));

end generate GEN_SBOX;

end Behavioral;
