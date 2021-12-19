----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2021 01:37:59 AM
-- Design Name: 
-- Module Name: E_K_controller - Behavioral
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity E_K_controller is
--  Port ( );
port(clk : in std_logic;
     -- Signals Incoming from another controller
    E_start : in std_logic;
    -- Signals going to E_K function for controlling Rounds
    selInitial, enTK, enRound, enIS, enAC : out std_logic;
    -- Signals going to another controller
    E_done : out std_logic);
end E_K_controller;

architecture Behavioral of E_K_controller is
type e_states is (E_idle, E_before, E_compute, E_finish);
signal state_reg, state_next : e_states;
signal cnt_s, cnt_s_next : integer range 0 to 41;
begin

E_STATE : process(clk)
    begin
        if rising_edge(clk) then
            state_reg <= state_next;
            cnt_s <= cnt_s_next;
        end if;
    end process E_STATE;

E_NEXT_STATE : process(cnt_s, state_reg, E_start)
    begin
        -- default
        selInitial <= '0';
        enTK <= '0';
        enRound <= '0';
        enAC <= '0';
        E_done <= '0';
        enIS <= '0';
        case state_reg is
            
            when E_idle =>
                if E_start = '1' then
                    enAC <= '1';
                    selInitial <= '1';
                    enTK <= '1';
                    enRound <= '1';
                    enIS <= '1';
                    state_next <= E_before;
                else
                    state_next <= E_idle;
                end if;
                
            when E_before =>
                enAC <= '1';
                state_next <= E_compute;
            
            when E_compute =>
                if cnt_s = 0 then
                   cnt_s_next <= cnt_s + 1;
                   state_next <= E_compute;
                   enAC <= '1'; 
                elsif cnt_s = 41 then
                    state_next <= E_finish;
                else
                    enRound <= '1';
                    enAC <= '1';
                    enTK <= '1';
                    enIS <= '1';
                    cnt_s_next <= cnt_s + 1;
                    state_next <= E_compute;
                end if;
                
            when E_finish =>
                E_done <= '1';
                cnt_s_next <= 0;
                state_next <= E_idle;
        end case;
    end process E_NEXT_STATE;

end Behavioral;
