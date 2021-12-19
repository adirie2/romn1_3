----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2021 05:25:00 PM
-- Design Name: 
-- Module Name: EK_Skinnyromn - Behavioral
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

entity EK_Skinnyromn is
--  Port ( );

port (clk, E_start : in STD_LOGIC;
      S, T, K : in STD_LOGIC_VECTOR(127 downto 0);
      D : in STD_LOGIC_VECTOR(55 downto 0);
      S_E : out STD_LOGIC_VECTOR(127 downto 0);
      E_done : out STD_LOGIC;
      B : in STD_LOGIC_VECTOR(7 downto 0));
end EK_Skinnyromn;

architecture Behavioral of EK_Skinnyromn is
signal selInitial, enTK, enRound, enIS, enAC, e_done_i : std_logic;


begin

e_done <= e_done_i;

E_K_FUNCTION : entity work.E_K
     generic map (TESTING => 0)
     port map(clk => clk,
              enIS => enIS,
              enAC => enAC,
              enTK => enTK,
              selInitial => selInitial,
              S => S,
              K => K,
              T => T,
              B => B,
              D => D,
              S_E => S_E);
              
E_K_CONTROLLER : entity work.E_K_controller
    port map(clk => clk,
             e_start => e_start,
             e_done => e_done_i,
             selInitial => selInitial,
             enTK => enTK,
             enRound => enRound,
             enIS => enIS,
             enAC => enAC);

end Behavioral;
