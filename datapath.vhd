----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2021 06:11:10 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
generic(CCSW : INTEGER := 32;
        CCW : INTEGER := 32;
        CCWdiv8 : INTEGER := 4;
        N : INTEGER := 128);
port (clk : in STD_LOGIC;
      -- INPUTS FROM CRYPTO CORE
      key : in STD_LOGIC_VECTOR(CCSW-1 downto 0);
      bdi: in STD_LOGIC_VECTOR(CCW-1 downto 0);
      bdi_valid_bytes, bdi_pad_loc : in STD_LOGIC_VECTOR(CCWdiv8-1 downto 0);
      -- INPUTS FROM CONTROLLER
      E_start : in STD_LOGIC;
      selInitial, selS, selSR, selD, selT : in STD_LOGIC;
      enKey, enAM, enN, enS, enDD, enCi_T, enTag : in STD_LOGIC;
      Bin : in STD_LOGIC_VECTOR(4 downto 0);
      ldCi_T : in STD_LOGIC;
      -- OUTPUTS INTO CONTROLLER
      E_done : out STD_LOGIC;
      -- OUTPUTS INTO CRYPTOCORE
      bdo : out STD_LOGIC_VECTOR(CCW-1 downto 0)
        );
        
--  Port ( );
end datapath;

architecture Behavioral of datapath is
signal S_E, S, NN, K, Ci_T, S_R, A_M, Ci_T_in, S_Rin, T_in, S_in, Tag: std_logic_vector(N-1 downto 0);
signal D : std_logic_vector(55 downto 0);
signal B : std_logic_vector(7 downto 0);
--signal Q_i : unsigned(55 downto 0);
begin
-- Romulus N first 3 bits of vector B are zero
B <= "000" & Bin;
-- bdo 
bdo <= Ci_T(N-1 downto 96);
-- Muxes
S_Rin <= S when selSR = '1' else (others => '0');
T_in <= NN when selT = '1' else A_M;
S_in <= S_R when selS = '1' else S_E;

-- SIPO Register for Key K
SIPO_K : process(clk)
            begin
                if rising_edge(clk) then 
                    if enKey = '1' then 
                        K <= key &  K(N-1 downto CCSW);
                    end if;
                end if;
            
            end process SIPO_K;
            
            
-- SIPO Register for Associated Data and Message

SIPO_AM : process(clk)
            begin
                if rising_edge(clk) then
                    if enAM = '1' then
                        A_M <= bdi & A_M(N-1 downto CCW);
                    end if;
                end if;
          end process SIPO_AM;

-- SIPO Register for Nonce
SIPO_NONCE : process(clk)
                begin
                    if rising_edge(clk) then
                        if enN = '1' then
                            NN <= bdi & NN(N-1 downto CCW);
                        end if;
                    end if;
             end process SIPO_NONCE;
             
-- SIPO Register for Tag (used for msg authentication for decryption)
SIPO_TAG : process(clk)
                begin
                    if rising_edge(clk) then
                        if enTag = '1' then
                            Tag <= bdi & Tag(N-1 downto CCW);
                        end if;
                    end if;
           end process SIPO_TAG;

-- Register for S
REGISTER_S : process(clk)
                begin
                    if rising_edge(clk) then
                        if enS = '1' then
                            S <= S_in;
                        end if;
                    end if;
             end process REGISTER_S;

-- PISO Register for CipherText and Tag output
PISO_Ci_T : process(clk)
                begin
                    if rising_edge(clk) then
                        if ldCi_T = '1' then
                            Ci_T <= Ci_T_in;    
                        elsif enTag = '1' then
                            Ci_T <= Ci_T(N-33 downto 0) & x"00000000";
                        end if;
                    end if;
                            
            end process PISO_Ci_T;
            
-- Counter for keeping track of Loop  -- Guess that it actually uses LFSR D as the counter for encoding, but we need a trivial counter
-- for interfacing with the controller and adding comparators
--COUNTER_i : process(clk)
--                begin
--                    if rising_edge(clk) then
--                        if ldi = '1' then 
--                            Q_i <= (others => '0');
--                        elsif eni = '1' then
--                            Q_i <= Q_i + 1;
--                        end if;
--                    end if;
--            end process COUNTER_i;

-- Comparator as well as modulo by two function










-- Component Instantiation for RHO function

INSTANTIATE_RHO : entity work.rho
    port map (M => A_M,
              S => S_Rin,
              C => Ci_T_in,
              S_p => S_R);

-- Component Instantiation for E_K function

INSTANTIATE_E_K_WRAPPER : entity work.EK_Skinnyromn
    port map(clk => clk,
             E_start => E_start,
             K => K,
             T => T_in,
             B => B,
             D => D,
             S_E => S_E,
             E_done => E_done,
             S => S_Rin);

-- Component Instantiation for LFSRD  counter

INSTANTIATE_LFSRD : entity work.LFSRD
    port map(clk => clk,
             selInitial => selInitial,
             enDD => enDD,
             D => D);

end Behavioral;
