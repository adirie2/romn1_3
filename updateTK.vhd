----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2021 03:24:45 PM
-- Design Name: 
-- Module Name: updateTK - Behavioral
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

entity updateTK is
--  Port ( );
port (TK : in STD_LOGIC_VECTOR(383 downto 0);
      reset, clk: in STD_LOGIC;
      TK_p : out STD_LOGIC_VECTOR(383 downto 0)
);
end updateTK;

architecture Behavioral of updateTK is
signal TK_temp : STD_LOGIC_VECTOR(383 downto 0);
signal tk2_lfsr, tk3_lfsr: STD_LOGIC_VECTOR(7 downto 0);
begin
TK_INTERMEDIATE :
 -- P(T)_i for TK_i and I is from 0 to 2
    -- {0,1,2,3,....,14,15} -> {9,15,8,13,10,14,12,11,0,1,2,3,4,5,6,7}
    for i in 0 to 2 generate
        -- ROWS 0 and 1 of Each TK Array get placed at ROWS 2 and 3 of TK Prime 
        TK_temp(319-128*i downto 256-128*i) <= TK(383-128*i downto 320-128*i);
        -- Rest of Rows 0 and 1 are just a permutation where each cell is swapped to different locations
        -- Cells 0 to 7 for each TK take this permutation
        TK_temp(383-128*i downto 320-128*i) <= 
        -- 9
            TK(311-128*i downto 320-128*i)
           & 
        -- 15
            TK(263-128*i downto 304-128*i)
           &
        -- 8
            TK(319-128*i downto 256-128*i)
           &
        -- 13
            TK(279-128*i downto 272-128*i)
           &
        -- 10
            TK(303-128*i downto 296-128*i)
           &
        -- 14
            TK(273-128*i downto 266-128*i)
           &
        -- 12
            TK(287-128*i downto 280-128*i)
           &
        -- 11
            TK(295-128*i downto 288-128*i)
        ;
    end generate TK_INTERMEDIATE;

TK_LFSR :
    for j in 0 to 15 generate
    
        -- TK2 Rows 0 and 1 updated with LFSR
        TK_p(255-8*j downto 256-8*(j+1)) <= TK_temp(254-8*j downto 256-8*(j+1)) & (TK_temp(255-8*j) xor TK_temp(253-8*j));
        
        -- TK3 Rows 0 and 1 updated with LFSR
        TK_p(127-8*j downto 128-8*(j+1)) <= (TK_temp(126-8*j) xor TK_temp(128-8*(j+1))) & TK_temp(127-8*j downto 129-8*(j+1));
    
    end generate TK_LFSR;





end Behavioral;
