----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2021 12:29:56 AM
-- Design Name: 
-- Module Name: CipherCore_Datapath_TB - Behavioral
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

entity CipherCore_Datapath_TB is
--  Port ( );
end CipherCore_Datapath_TB;

architecture Behavioral of CipherCore_Datapath_TB is


type input_array is array (0 to 3) of std_logic_vector(31 downto 0);

type test_array is array (0 to 1) of input_array;



signal KeyValue, NonceValue : std_logic_vector(127 downto 0);

constant ADarray : test_array := ((x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F"),
                                  (x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F"));

constant Marray : test_array := ((x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F"),
                                 (x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F"));
                                 
constant KeyArray : input_array := (x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F");    
                   
constant NonceArray : input_array := (x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F");                       


constant clk_period : TIME := 20 ns;

signal len8 : std_logic_vector(7 downto 0);

signal totalCount, messageCount, ADCount : std_logic_vector(4 downto 0);

signal totalCountmod, messageCountmod, ADCountmod : std_logic;

signal clk, selS, selSR, selD, selT, selMR, enKey, enAM, enN, enS, enDD, enCi_t, enTag, ldCi_T, E_start, E_done, tag_verify : std_logic;

signal selAM : std_logic_vector(1 downto 0);

signal key, bdi, bdo : std_logic_vector(31 downto 0);

signal Bin : std_logic_vector(4 downto 0);

signal D : std_logic_vector(55 downto 0);

begin

--port (clk : in STD_LOGIC;
--      -- INPUTS FROM CRYPTO CORE
--      key : in STD_LOGIC_VECTOR(CCSW-1 downto 0);
--      bdi: in STD_LOGIC_VECTOR(CCW-1 downto 0);
--      bdi_valid_bytes, bdi_pad_loc : in STD_LOGIC_VECTOR(CCWdiv8-1 downto 0);
--      -- INPUTS FROM CONTROLLER
--      E_start : in STD_LOGIC;
--      selDD, selS, selSR, selD, selT, selAM, selMR : in STD_LOGIC;
--      enKey, enAM, enN, enS, enDD, enCi_T, enTag : in STD_LOGIC;
--      Bin : in STD_LOGIC_VECTOR(4 downto 0);
--      ldCi_T : in STD_LOGIC;
--      -- OUTPUTS INTO CONTROLLER
--      E_done : out STD_LOGIC;
--      -- OUTPUTS INTO CRYPTOCORE
--      bdo : out STD_LOGIC_VECTOR(CCW-1 downto 0)
--        );


KeyValue <= x"000102030405060708090A0B0C0D0E0F";
NonceValue <= x"000102030405060708090A0B0C0D0E0F";

-- Assign the last bit since that will just tell us the mod of 2

totalCountmod <= totalCount(0);
messageCountmod <= messageCount(0);
ADCountmod <= ADcount(0);

-- Process for generating the clock signal

DPATH_TB_INSTANTIATION : entity work.datapath
    port map( clk => clk,
              key => key,
              bdi => bdi,
              --bdi_valid_bytes => (others => '1'),
              len8 => (others => '1'),
              E_start => E_start,
              selS => selS,
              selSR => selSR,
              selD => selD,
              selT => selT,
              selAM => selAM,
              selMR => selMR,
              enKey => enKey,
              enAM => enAM,
              enN => enN,
              enS => enS,
              enDD => enDD,
              enCi_T => enCi_T,
              enTag => enTag,
              Bin => Bin,
              ldCi_T => ldCi_T,
              E_done => E_done,
              bdo => bdo,
              tag_verify => tag_verify);



clk_generate : process
    begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- Device Under Test Process

DUT : process
        begin
            Bin <= '0' & x"8";
            totalCount <= (others => '0');
            messageCount <= (others => '0');
            ADCount <= (others => '0');
            enKey <= '0';
            enAM <= '0';
            enN <= '0';
            enDD <= '0';
            enCi_T <= '0';
            enTag <= '0';
            ldCi_T <= '0';
            E_start <= '0';
            selD <= '0';
            selS <= '0';
            selSR <= '0';
            selD <= '0';
            selT <= '0';
            selAM <= "00";
            selMR <= '0';
            -- Loading Key
            for a in 0 to 3 loop
                enKey <= '1';
                key <= KeyArray(a);
                wait for clk_period;
            end loop;
            enKey <= '0';
            -- Loading Nonce
            for b in 0 to 3 loop
                enN <= '1';
                bdi <= NonceArray(b);
                wait for clk_period;
            end loop;
            enN <= '0';
            
            -- Load Initial LFSR Value
            selD <= '1';
            enDD <= '1';
            wait for clk_period;
            selD <= '0';
            enDD <= '0';
            
            -- Load and Process Associated Data Blocks
            for c in 0 to ADarray'length-1 loop
                
                
                
                selSR <= '0';
                selMR <= '0';
                selS <= '0';
                enS <= '0';
                selT <= '0';
                -- Load Associated Data Block corresponding to the one in the array
                selAM <= "00";
                for a in 0 to 3 loop
                    enAM <= '1';
                    bdi <= ADarray(c)(a);
                    wait for clk_period;
                end loop;
                selAM <= "00";
                enAM <= '0';
                wait for clk_period;
                -- Configure Rho Function to be used for this AD Block
                if ADCountmod = '0' then
                    
                    if ADcount = "00000" then
                        selSR <= '1';
                        selMR <= '0';
                        selS <= '1';
                        enS <= '1';
                        wait for clk_period;
                    else
                        selSR <= '0';
                        selMR <= '0';
                        selS <= '1';
                        enS <= '1';
                        wait for clk_period;
                    end if;
                    
                    -- wait for clk_period;
                    enS <= '0';
                    selS <= '0';
                -- Configure Skinny-128-384+ to be used for this AD Block
                else
                    selT <= '0';
                    E_start <= '1';
                    wait for clk_period;
                    E_start <= '0';
                    wait for clk_period;
                    for d in 0 to 41 loop
                        wait for clk_period;
                    end loop;
                    selS <= '0';
                    enS <= '1';
                    wait for clk_period;
                    enS <= '0';
                end if;
                
                wait for clk_period;
                
                -- Increment Counter
                ADCount <= std_logic_vector(unsigned(ADCount) + 1);
                -- Increment LFSR
                enDD <= '1';
                wait for clk_period;
                enDD <= '0';
      
            end loop;
            
            -- One more Rho Call and TBC call before loading and processing data blocks
            
            -- Rho Call
            selMR <= '1';
            selS <= '1';
            enS <= '1';
            selSR <= '0';
            wait for clk_period;
            enS <= '0';
            selMR <= '0';
            
            -- EK Call
            selT <= '1';
            E_start <= '1';
            Bin <= "11000";
            wait for clk_period;
            E_start <= '0';
            wait for clk_period;
            for d in 0 to 41 loop
                wait for clk_period;
            end loop;
            selS <= '0';
            enS <= '1';
            wait for clk_period;
            enS <= '0';
            
            -- Load Initial LFSR Value (Reset prior to loading and processing Message Blocks
            selD <= '1';
            enDD <= '1';
            wait for clk_period;
            selD <= '0';
            enDD <= '0';
            
             -- Load and Process Message Data Blocks
            for c in 0 to Marray'length-1 loop
                
                Bin <= "00100";
                ldCi_T <= '0';
                selSR <= '0';
                selMR <= '0';
                selS <= '0';
                enS <= '0';
                selT <= '0';
                -- Load Message Data Block corresponding to the one in the array
                selAM <= "00";
                for a in 0 to 3 loop
                    enAM <= '1';
                    bdi <= Marray(c)(a);
                    wait for clk_period;
                end loop;
                selAM <= "00";
                enAM <= '0';
                -- Configure Rho Function to be used for this Meessage Block
                if messageCountmod = '0' then
                 
                    selSR <= '0';
                    selMR <= '0';
                    selS <= '1';
                    enS <= '1';                    
                    wait for clk_period;
                    enS <= '0';
                -- Configure Skinny-128-384+ to be used for this Message Block
                else
                    selT <= '0';
                    E_start <= '1';
                    wait for clk_period;
                    E_start <= '0';
                    wait for clk_period;
                    for d in 0 to 41 loop
                        wait for clk_period;
                    end loop;
                    selS <= '0';
                    enS <= '1';
                    ldCi_T <= '1';
                    wait for clk_period;
                    enS <= '0';
                end if;
                
                wait for clk_period;
                
                -- Increment Counter
                messageCount <= std_logic_vector(unsigned(messageCount) + 1);
                -- Increment LFSR
                enDD <= '1';
                wait for clk_period;
                enDD <= '0';
      
            end loop;
            
            -- One more Rho Call and TBC call before loading and processing data blocks
            
            -- Rho Call
            selMR <= '1';
            selS <= '1';
            enS <= '1';
            selSR <= '0';
            wait for clk_period;
            enS <= '0';
            selMR <= '0';
            
            -- EK Call
            selT <= '1';
            Bin <= "10100";
            E_start <= '1';
            wait for clk_period;
            E_start <= '0';
            wait for clk_period;
            for d in 0 to 41 loop
                wait for clk_period;
            end loop;
            selS <= '0';
            enS <= '1';
            wait for clk_period;
            enS <= '0';
            selT <= '0';
            
            
            
            
wait;          
end process DUT;

end Behavioral;
