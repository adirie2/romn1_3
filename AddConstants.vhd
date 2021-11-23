----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 12:04:06 AM
-- Design Name: 
-- Module Name: AddConstants - Behavioral
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

entity AddConstants is
--  Port ( );
port (InS : IN STD_LOGIC_VECTOR(127 downto 0);
      InS_p : OUT STD_LOGIC_VECTOR(127 downto 0);
      clk, enRound, selInitial : IN STD_LOGIC);
end AddConstants;

architecture Behavioral of AddConstants is
signal c0, c1, c2 : STD_LOGIC_VECTOR(7 downto 0);
signal rc, rc_p, rc_next : STD_LOGIC_VECTOR(5 downto 0);
begin

-- Values Necessary for LFSR
 rc_p <= rc(4) & rc(3) & rc(2) & rc(0) & (rc(5) xor rc(4) xor '1');
 c0 <= "0000" & rc(3) & rc(2) & rc(1) & rc(0);
 c1 <= "000000" & rc(3) & rc(2) & rc(1) & rc(0);
 c2 <= "000000" & x"02";
 rc_next <= (others => '0') when selInitial='1' else rc_p;
 
-- LFSR for AddConstants
rc_reg : process(clk)
            begin
            if rising_edge(clk) then
                if enRound = '1' then
                    rc <= rc_next;
                end if;
            end if;
            end process rc_reg;
-- Modify corresponding Message Cells of Internal State
InS_p(127 downto 120) <= c0 xor InS(127 downto 120);
InS_p(95 downto 88) <= c1 xor InS(95 downto 88);
InS_p(63 downto 56) <= c2 xor InS(63 downto 56);

-- All other Cells of Internal State Stay the Same
InS_p(119 downto 96) <= InS(119 downto 96);
InS_p(87 downto 64) <= InS(87 downto 64);
InS_p(55 downto 0) <= InS(55 downto 0);

end Behavioral;
