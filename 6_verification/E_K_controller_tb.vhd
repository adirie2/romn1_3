----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2021 02:24:46 AM
-- Design Name: 
-- Module Name: E_K_controller_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity E_K_controller_tb is
--  Port ( );
end E_K_controller_tb;

architecture Behavioral of E_K_controller_tb is
signal e_start, e_done, clk : std_logic;
signal selInitial, enTK, enRound, enIS, enAC : std_logic;
constant clk_period : TIME := 20 ns;
signal InS_SC, InS_AC, InS_ART, InS_SR, InS_MC : std_logic_vector(127 downto 0);
signal InS_p : std_logic_vector(127 downto 0);
signal InS : std_logic_vector(127 downto 0) := (others => '0');
signal S_E, S, K, T : std_logic_vector(127 downto 0);
signal B : std_logic_vector(7 downto 0);
signal D : std_logic_vector(55 downto 0);
signal enDD : std_logic;
signal sboxin, sboxout, sboxcolin, sboxcolout : std_logic_vector(7 downto 0);
begin

clk_generate : process
    begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

TEST_SBOXROM : entity work.sbox
    port map(
            clk => clk,
            Addr => sboxin,
             Y => sboxout);

TEST_SBOXCOL : entity work.sbox_col
    port map(Addr => sboxcolin,
             Y => sboxcolout);

E_K_CONTROLLER_INSTANTIATION_TB : entity work.E_K_controller
    port map(clk => clk,
             e_start => e_start,
             e_done => e_done,
             selInitial => selInitial,
             enTK => enTK,
             enRound => enRound,
             enIS => enIS,
             enAC => enAC);
-- Testing Add Constants Component

--AC_INSTANTIATION : entity work.AddConstants
--    port map(clk => clk,
--             enRound => enAC,
--             selInitial => selInitial,
--             InS => InS,
--             InS_p => InS_p);
             
-- Testing entire E_K component 
E_K_FUNCTION_INSTANTIATION_TB : entity work.E_K
     generic map (TESTING => 1)
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
 LFSRD_FUNCTION_INSTANTIATION_TB : entity work.LFSRD
      port map(clk => clk,
               selDD => selInitial,
               enDD => enDD,
               D => D);
               
-- Since E_K function was instantiated with Testing = 1, we set Tweakey to a specific value which was shown
-- in the Skinny-128-384+ test vector in Romulus v1.3 description, we also assign S to this same specified value 
           
UUT : process
    begin
        S <= x"A3994B66AD85A3459F44E92B08F550CB";
        -- S <= (others => '0');
        K <= (others => '0');
        T <= (others => '0');
        B <= (others => '0');
        e_start <= '0';
        wait for clk_period;
        e_start <= '1';
        wait for clk_period;
        e_start <= '0';
        for i in 0 to 42 loop
            wait for clk_period;
        end loop;
        wait for clk_period;
        wait;
end process;

-- Verifying SBOX combinational logic as well as ROM
SBOXUT : process
    begin
    sboxin <= (others => '0');
    sboxcolin <= (others => '0');
    for i in 0 to 255 loop
        wait for clk_period/4;
        sboxin <= std_logic_vector(unsigned(sboxin) + 1);
        sboxcolin <= std_logic_vector(unsigned(sboxcolin) + 1);
    end loop;
    wait;
end process SBOXUT;

end Behavioral;
