----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2021 01:54:37 AM
-- Design Name: 
-- Module Name: sbox_col - Behavioral
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

entity sbox_col is
--  Port ( );
Port(Addr: in std_logic_vector(7 downto 0);
     Y : out std_logic_vector(7 downto 0));
end sbox_col;

architecture Behavioral of sbox_col is
type Sdata is array (0 to 4) of STD_LOGIC_VECTOR(7 downto 0);
signal Sout : Sdata;
begin
Sout(0) <= Addr;
GEN_SBOXCOL : for i in 1 to 4 generate
    -- Did the Transformation then the Permutation all in one step
    Sout(i) <= Sout(i-1)(2) & Sout(i-1)(1) & Sout(i-1)(7) & Sout(i-1)(6) & (Sout(i-1)(4) xor (Sout(i-1)(7) nor Sout(i-1)(6)))
               & (Sout(i-1)(0) xor (Sout(i-1)(3) nor Sout(i-1)(2))) & Sout(i-1)(3) & Sout(i-1)(5);
end generate GEN_SBOXCOL;
Y <= Sout(4)(7 downto 3) & Sout(4)(1) & Sout(4)(2) & Sout(4)(0);

end Behavioral;
