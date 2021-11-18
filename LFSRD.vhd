----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2021 01:14:58 AM
-- Design Name: 
-- Module Name: LFSRD - Behavioral
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

entity LFSRD is
--  Port ( );
port( reset, selInitial, clk, enDD : in STD_LOGIC;
      D : out STD_LOGIC_VECTOR(55 downto 0));
       
end LFSRD;

architecture Behavioral of LFSRD is
signal z_next, z_initial, z, z_in : STD_LOGIC_VECTOR(55 downto 0);
begin
z_initial <= ( 48 => '1',
               others => '0');
               
z_next <= z(54 downto 7) & (z(6) xor z(55)) & z(5 downto 4) & (z(3) xor z(55)) & z(2) & (z(1) xor z(55)) & z(0) & (z(55)); 

z_in <= z_initial when selInitial = '1' else z_next;

-- Process for LFSR_D
LFSR_D : process(clk)
            begin
                if rising_edge(clk) then
                    if rst = '1' then
                        z <= (others => '0');
                    elsif enDD = '1' then
                        z <= z_in;
                    end if;
                end if;
         end process LFSR_D;
-- Output signals cannot be on right hand side of signal assignment hence why we have a signal z created
D <= z;
         
end Behavioral;
