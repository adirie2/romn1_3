----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 09:52:00 PM
-- Design Name: 
-- Module Name: E_K - Behavioral
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

entity E_K is
--  Port ( );
generic(N: INTEGER := 128;
        TESTING : NATURAL := 0);
port(clk, enAC, enIS, enTK, selInitial : in STD_LOGIC;
     S, K, T : in STD_LOGIC_VECTOR(N-1 downto 0);
     B : in STD_LOGIC_VECTOR(7 downto 0);
     D : in STD_LOGIC_VECTOR(55 downto 0);
     S_E : out STD_LOGIC_VECTOR(N-1 downto 0));
     
end E_K;

architecture Behavioral of E_K is
signal InS, InS_next, InS_SC, InS_AC, InS_ART, InS_SR, InS_MC: std_logic_vector(N-1 downto 0);
signal TK, TK_p, TK_next: std_logic_vector(383 downto 0);
begin

-- Muxes for Input to Registers

InS_next <= S when selInitial = '1' else InS_MC;
TK_NEXT_GEN_REAL : if TESTING /= 1 GENERATE
TK_next <= D & B & x"0000000000000000" & T & K when selInitial = '1' else TK_p;
end GENERATE TK_NEXT_GEN_REAL;

TK_NEXT_GEN_TESTING : if TESTING = 1 GENERATE
TK_next <= x"df889548cfc7ea52d296339301797449ab588a34a47f1ab2dfe9c8293fbea9a5ab1afac2611012cd8cef952618c3ebe8" when selInitial = '1' else TK_p;
-- TK_next <= (others => '0') when selInitial = '1' else TK_p;
end GENERATE TK_NEXT_GEN_TESTING;

-- Process Register for Internal State
InS_REG : process(clk)
            begin
                if rising_edge(clk) then
                    if enIS = '1' then
                        InS <= InS_next;
                    end if;
                end if;
            end process InS_REG;
            
-- Process Register for Tweakey 
TK_REG : process(clk)
            begin
                if rising_edge(clk) then
                    if enTK = '1' then
                        TK <= TK_next;
                    end if;
                end if;
         end process;
         
-- Instantiate updateTK function

INSTANTIATE_UPDATE_TK : entity work.updateTK 
    port map (TK => TK,
              TK_p => TK_p,
              clk => clk);
              
-- Connect Internal State to all Round Functions by Instantiation of Components

-- SubCells Instantiation

--INSTANTIATE_SUBCELLS_ROM : entity work.SubCellsRom
--    port map (clk => clk,
--              InS => InS,
--              InS_p => InS_SC);
              
 INSTANTIATE_SUBCELLS_COL : entity work.SubCells  
    port map (InS => InS,
              InS_p => InS_SC);
              
-- AddConstants Instantiation
INSTANTIATE_ADDCONSTANTS : entity work.AddConstants
    port map (InS => InS_SC,
              InS_p => InS_AC,
              enAC => enAC,
              selInitial => selInitial,
              clk => clk);

-- AddRoundTweakey Instantiation
INSTANTIATE_ADDROUNDTWEAKEY : entity work.AddRoundTweakey
    port map (InS => InS_AC,
              InS_p => InS_ART,
              TK => TK);
              
-- ShiftRows Instantiation
INSTANTIATE_SHIFTROWS : entity work.ShiftRows
    port map (InS => InS_ART,
              InS_p => InS_SR);
-- MixColumns Instantiation
INSTANTIATE_MIXCOLUMNS : entity work.MixColumns
    port map (InS => InS_SR,
              InS_p => InS_MC);

S_E <= InS;
end Behavioral;
