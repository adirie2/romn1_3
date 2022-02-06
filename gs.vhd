----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 12:04:06 AM
-- Design Name: 
-- Module Name: gs - Behavioral
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

entity gs is
  Port ( S: in STD_LOGIC_VECTOR(7 downto 0);
         G_S: out STD_LOGIC_VECTOR(7 downto 0));
end gs;

architecture Behavioral of gs is
begin
GEN_G: for i in 1 to 7 generate
    G_S(i-1) <= S(i);
end generate GEN_G;
G_S(7) <= S(0) xor S(7);
end Behavioral;
