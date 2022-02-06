----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2021 11:36:59 PM
-- Design Name: 
-- Module Name: rho - Behavioral
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

entity rho is
--  Port ( );
port (M : in STD_LOGIC_VECTOR(127 downto 0);
      S : in STD_LOGIC_VECTOR(127 downto 0);
      C : out STD_LOGIC_VECTOR(127 downto 0);
      S_P : out STD_LOGIC_VECTOR(127 downto 0));
end rho;

architecture Behavioral of rho is
signal G_S : STD_LOGIC_VECTOR(127 downto 0);
begin
S_P <= S xor M;
C <= G_S xor M;
GEN_GS: for i in 0 to 15 generate
    GS_GEN : entity work.gs 
        port map(S => S(127-8*i downto 128-8*(i+1)),
                 G_S => G_S(127-8*i downto 128-8*(i+1)));
end generate GEN_GS;

end Behavioral;
