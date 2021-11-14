----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2021 12:47:06 AM
-- Design Name: 
-- Module Name: AddRoundTweakey - Behavioral
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

entity AddRoundTweakey is
--  Port ( );
port(InS: in STD_LOGIC_VECTOR(127 downto 0);
     TK : in STD_LOGIC_VECTOR(383 downto 0);
     InS_p : out STD_LOGIC_VECTOR(127 downto 0)
    );
end AddRoundTweakey;

architecture Behavioral of AddRoundTweakey is

begin
GEN_ARTK : for i in 0 to 1 generate
    InS_p(127-32*i downto 128-32*(i+1)) <= InS(127-32*i downto 128-32*(i+1))
                                           xor TK(383-32*i downto 384-32*(i+1))
                                           xor TK(255-32*i downto 256-32*(i+1))
                                           xor TK(127-32*i downto 128-32*(i+1));
end generate GEN_ARTK;
InS_p(63 downto 0) <= InS(63 downto 0);
end Behavioral;
