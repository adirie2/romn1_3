----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2/21/2021 01:51:23 AM
-- Design Name: 
-- Module Name: RomulusN_Controller - Behavioral
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

entity RomulusN_Controller is
Port(
    clk     : in std_logic;
    rst     : in std_logic;
    -- Control of Keys
    key_valid   : in std_logic;
    key_ready   : out std_logic;
    key_update  : in std_logic;
    -- BDI Port Info
    bdi_valid   : in std_logic;
    bdi_ready   : out std_logic;
    bdi_valid_bytes     : in std_logic_vector(3 downto 0);
    bdi_size    : in std_logic_vector(2 downto 0);
    bdi_eot     : in std_logic;
    bdi_eoi     : in std_logic;
    bdi_type    : in std_logic_vector(3 downto 0);
    decrypt_in  : in std_logic;
    -- BDO Control
    bdo_valid   : out std_logic;
    bdo_ready   : in std_logic;
    bdo_valid_bytes : out std_logic_vector(3 downto 0);
    end_of_block    : out std_logic;
    -- Tag Verification
    msg_auth_valid  : out std_logic;
    msg_auth_ready : in std_logic;
    tag_verify : in std_logic;
    -- Control
    E_start : out std_logic;
    E_done : in std_logic;
    -- Enabling Signals
    enKey : out std_logic;
    enAM : out std_logic;
    enN : out std_logic;
    enS : out std_logic;
    enCi_T : out std_logic;
    enTag : out std_logic;
    enDD : out std_logic;
    -- Select Signals
    selAM : out std_logic_vector(1 downto 0);
    selSR : out std_logic;
    selMR : out std_logic;
    selD : out std_logic;
    selT : out std_logic;
    selS : out std_logic;
    -- Load Signals
    ldCi_T : out std_logic
    );
end RomulusN_Controller;

architecture Behavioral of RomulusN_Controller is

-- Constants for Encoding
constant HDR_AD : std_logic_vector(3 downto 0) := "0001";
constant HDR_MSG : std_logic_vector(3 downto 0) := "0100";
constant HDR_CT : std_logic_vector(3 downto 0) := "0101";
constant HDR_TAG : std_logic_vector(3 downto 0) := "1000";
constant HDR_KEY : std_logic_vector(3 downto 0) := "1100";
constant HDR_NPUB : std_logic_vector(3 downto 0) := "1101";

-- Type Declaration for FSM

type FSM is (idle, load_key, wait_npub, load_npub, process_npub, wait_ad, load_ad, process_ad, load_data, process_data, output_tag,
     load_tag, verify_tag, AD_last, MD_1, MD_2);

-- Signals

signal decrypt_rst : std_logic;
signal decrypt_set : std_logic;
signal decrypt_reg : std_logic;

signal last_AD_reg : std_logic;
signal last_AD_rst : std_logic;
signal last_AD_set : std_logic;

signal half_AD_reg : std_logic;
signal half_AD_rst : std_logic;
signal half_AD_set : std_logic;

signal no_AD_reg : std_logic;
signal no_AD_rst : std_logic;
signal no_AD_set : std_logic;

signal last_M_reg : std_logic;
signal last_M_rst : std_logic;
signal last_M_set : std_logic;

signal half_M_reg : std_logic;
signal half_M_rst : std_logic;
signal half_M_set : std_logic;

signal no_M_reg : std_logic;
signal no_M_rst : std_logic;
signal no_M_set : std_logic;

-- Counter Signals
signal ctr_words_rst : std_logic;
signal ctr_words_inc : std_logic;

signal ctr_bytes_rst : std_logic;
signal ctr_bytes_inc : std_logic;

signal ctr_words : std_logic_vector(2 downto 0);
signal ctr_bytes : unsigned(3 downto 0);

signal AD_count : std_logic_vector(6 downto 0);
signal AD_count_inc : std_logic;

signal M_count : std_logic_vector(6 downto 0);
signal M_count_inc : std_logic;



-- State Machine
signal state : FSM;
signal state_next : FSM;



begin

bdo_valid_bytes <= bdi_valid_bytes when (bdi_type = HDR_MSG or bdi_type = HDR_CT) else -- PT or CT extraction
                   "1111";
end_of_block <= bdi_eot when (bdi_type = HDR_MSG or bdi_type = HDR_CT) else -- PT or CT extraction
                    '1'     when (ctr_words = "011") else
                    '0';

-- Clock Process

process(clk)
begin

    if rising_edge(clk) then
        if (rst = '1') then
            state <= idle;
            AD_count <= (others => '0');
            M_count <= (others => '0');
        else
            state <= next_state;

            if (ctr_words_rst = '1') then
                ctr_words <= (others => '0');
            elsif (ctr_words_inc = '1') then
                ctr_words <= std_logic_vector(unsigned(ctr_words) + 1);
            end if;
        
            if (ctr_bytes_rst = '1') then
                ctr_bytes <= (others => '0');
            elsif (ctr_bytes_inc = '1') then
                ctr_bytes <= unsigned(ctr_bytes) + unsigned(bdi_size);
            end if;

            if (decrypt_rst = '1') then 
                decrypt_reg <= '0';
            elsif (decrypt_set = '1') then
                decrypt_reg <= '1';
            end if;

            if (last_AD_rst = '1') then
                last_AD_reg <= '0';
            elsif (last_AD_set = '1') then
                last_AD_reg <= '1';
            end if;

            if (half_AD_rst = '1') then
                half_AD_reg <= '0';
            elsif (half_AD_set = '1') then
                half_AD_reg <= '1';
            end if;

            if (no_AD_rst = '1') then
                no_AD_reg <= '0';
            elsif (no_AD_set = '1') then
                no_AD_reg <= '1';
            end if;

            if (last_M_rst = '1') then
                last_M_reg <= '0';
            elsif (last_M_set = '1') then
                last_M_reg <= '1';
            end if;

            if (half_M_rst = '1') then
                half_M_reg <= '0';
            elsif (half_M_set = '1') then
                half_M_reg <= '1';
            end if;

            if (no_M_rst = '1') then
                no_M_reg <= '0';
            elsif (half_M_set = '1') then
                no_M_reg <= '1';
            end if;

            if (AD_count_inc = '1') then
                AD_count <= std_logic_vector(unsigned(AD_count) + 1);
            end if;
            
            if (M_count_inc = '1') then
                M_count <= std_logic_vector(unsigned(M_count) + 1);
            end if;
        end if;
    end if;

end process;


-- Controller Process

RomN_Controller : process(all)
begin
    next_state <= idle;
    key_ready <= '0';
    bdi_ready <= '0';
    bdo_valid <= '0';
    msg_auth_valid <= '0';
    E_start <= '0';
    ctr_bytes_rst <= '0';
    ctr_bytes_inc <= '0';
    ctr_words_rst <= '0';
    ctr_words_inc <= '0';

    enKey <= '0';
    enAM <= '0';
    enN <= '0';
    enS <= '0';
    enCi_T <= '0';
    enTag <= '0';
    enDD <= '0';

    last_AD_rst <= '0';
    last_AD_set <= '0';
    half_AD_rst <= '0';
    half_AD_set <= '0';
    no_AD_rst <= '0';
    no_AD_set <= '0';
    last_M_rst <= '0';
    last_M_set <= '0';
    half_M_rst <= '0';
    half_M_set <= '0';
    no_M_rst <= '0';
    no_M_set <= '0';
    
    selAM <= "00";
    selSR <= '0';
    selMR <= '0';
    selD <= '0';
    selT <= '0';
    selS <= '0';
    ldCi_T <= '0';
    


    case state is
        when idle =>
            ctr_words_rst <= '1';
            ctr_bytes_rst <= '1';
            decrypt_rst <= '1';
            last_AD_rst <= '1';
            half_AD_rst <= '1';
            no_AD_rst <= '1';
            last_M_rst <= '1';
            half_M_rst <= '1';
            no_M_rst <= '1';
            if key_valid='1' then
                if key_update = '1' then
                    next_state <= load_key;
                end if;
            end if;
        when load_key =>
            key_ready <= '1';
            ctr_words_inc <= '1';
            enKey <= '1';
            if ctr_words = "011" then
                ctr_words_rst <= '1';
                next_state <= wait_npub;
            else
                next_state <= load_key;
            end if;
        when wait_npub =>
            if (bdi_valid = '1') then
                next_state <= load_npub;
            else
                next_state <= wait_npub;
            end if;
        when load_npub =>
            bdi_ready <= '1';
            ctr_words_inc <= '1';
            enN <= '1';
            if decrypt_in = '1' then
                decrypt_set <= '1';
            else
                decrypt_rst <= '1';
            end if;
            if (bdi_eoi = '1') then -- No AD and No CT/PT
                no_AD_set <= '1';
                no_M_set <= '1';
            end if;
            if (ctr_words="011") then
                ctr_words_rst <= '1';
                next_state <= wait_ad;
            else
                next_state <= load_npub;
            end if;
        when wait_ad =>
            if(bdi_type /= HDR_AD) then -- no AD
                no_AD_set <= '1';
                next_state <= AD_last;
            else
                next_state <= load_ad;
            end if;
        when load_ad =>
            bdi_ready <= '1';
            ctr_words_inc <= '1';
            ctr_bytes_inc <= '1';
            enAM <= '1';
            if (bdi_eoi = '1') then -- No data
                no_M_set <= '1';
            end if;
            if (bdi_eot = '1') then 
                last_AD_set <= '1';
                if (bdi_size /= "100" and ctr_words /= "011") then
                    half_AD_set <= '1';
                end if;
            end if;
            if (bdi_eot = '1' or ctr_words = "011") then
           -- or ctr_words = "011") then
                -- ctr_words_rst <= '1';
                next_state <= AD_last;
            else
                next_state <= load_ad;
            end if;
        when AD_last =>
            enAM <= '1';
            if ( ctr_words \= "011" ) then -- not done processing words
                selAM <= "01"; -- Pad with zeros
                next_state <= AD_last; 
                ctr_words_inc <= '1'; -- increment count and go to next state
            else
                selAM <= "10"; -- for the last block we use encoding
                ctr_words_rst <= '1'; -- reset word count
                next_state <= process_ad; -- Now we process the incoming ad_block
            end if;
        when process_ad =>
            E_start <= '1';
            if ( E_done = '1' ) then
                E_start <= '0';
                ctr_bytes_rst <= '1'; 




end process;


end Behavioral;
