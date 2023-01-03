library IEEE;
use IEEE.STD_LOGIC_1164.all;

package design_pkg is
    --! design parameters needed by the PreProcessor, PostProcessor, and LWC
    --!
    --! Tag size in bits
    constant TAG_SIZE        : integer := 128;
    --! Hash digest size in bits
    constant HASH_VALUE_SIZE : integer := 256;
    --! CryptoCore BDI data width in bits. Supported values: 32, 16, 8
    constant CCW             : integer := 32;
    --! CryptoCore key input width in bits
    constant CCSW            : integer := CCW;
    --!
    constant CCRW            : integer := 0;

--------------------------------------------------------------------------------
------------------------- DO NOT CHANGE ANYTHING BELOW -------------------------
--------------------------------------------------------------------------------
    
    --! design parameters specific to the CryptoCore; assigned in the package body below!
    --! place declarations of your constants here
    constant N       : NATURAL; --! Npub size
    constant DBLK_SIZE       : integer; --! Block size
    
    constant CCWdiv8         : integer; --! derived from parameters above, assigned in body.
    
    
    type state_t is (
        IDLE,
        LOAD_KEY,
        LOAD_NPUB,
        WAIT_AD,
        LOAD_AD,
        PAD_AD,
        PROC_AD,
        PROC_LAST_AD,
        PROC_AD_N,
        LOAD_DATA,
        PAD_DATA,
        PROC_DATA,
        PROC_DATA_N,
        PROC_LAST_DATA,
        OUTPUT_DATA,
        PROC_TAG,
        OUTPUT_TAG,
        VERIFY_TAG,
        TAG_ACK,
        FAILURE,
        SUCCESS
    );

    type encoding_t is record 
    HDR_AD : std_logic_vector(3 downto 0);
    HDR_MSG : std_logic_vector(3 downto 0);
    HDR_CT : std_logic_vector(3 downto 0);
    HDR_TAG : std_logic_vector(3 downto 0);
    HDR_KEY : std_logic_vector(3 downto 0);
    HDR_NPUB : std_logic_vector(3 downto 0);
    NUM_WORDS : integer;
    MAX_WORDS : integer;
    end record encoding_t;

    constant c_encoding_t : encoding_t;

    type control_t is record
         -- BDI Port Info
        bdi_valid   : std_logic;
        bdi_valid_bytes     : std_logic_vector(3 downto 0);
        bdi_size    : std_logic_vector(2 downto 0);
        bdi_eot     : std_logic;
        bdi_eoi     : std_logic;
        bdi_type    : std_logic_vector(3 downto 0);
        decrypt_in  : std_logic;
        -- Control of Keys
        key_valid   : std_logic;
        key_update  : std_logic;
        -- BDO Control
        bdo_ready   : std_logic;
        -- Tag Verification
        msg_auth_ready : std_logic;
        -- tag_verify : std_logic;
        -- TBC Control
        -- E_done : std_logic;
      

    end record control_t;

    type status_t is record 
        -- BDI Port Info
        bdi_ready   : std_logic;
        -- BDO Control
        bdo_valid   : std_logic;
        bdo_valid_bytes : std_logic_vector(3 downto 0);
        end_of_block    : std_logic;
        -- Control of Keys
        key_ready   : std_logic;
        -- Tag Verification
        msg_auth_valid  : std_logic;
        msg_auth : std_logic;
        -- Control
        -- E_start : std_logic;
        -- Enabling Signals
        enKey : std_logic;
        enAM : std_logic;
        enN : std_logic;
        enS : std_logic;
        enCi_T : std_logic;
        enTag : std_logic;
        enDD : std_logic;
        -- Select Signals
        selAM : std_logic_vector(1 downto 0);
        selSR : std_logic;
        selMR : std_logic;
        selD : std_logic;
        selT : std_logic;
        selS : std_logic;
        -- Load Signals
        ldCi_T : std_logic;
        -- Skinny Domain Encoding
        Bin : std_logic_vector(4 downto 0);
        -- Padding Helper Signals
        ctr_words : std_logic_vector(2 downto 0);
        data_bytes : std_logic_vector(3 downto 0); 
    end record status_t;

    type data_in_t is record
        bdi : std_logic_vector(31 downto 0);
        control : control_t;
    end record data_in_t;

    type data_out_t is record
        bdo : std_logic_vector(31 downto 0);
        status : status_t;
    end record data_out_t;

    type datapath_t is record
        E_done : std_logic;
        tag_verify : std_logic;
    end record datapath_t;

    type controller_t is record
        -- Enabling Signals
        enKey : std_logic;
        enAM : std_logic;
        enN : std_logic;
        enS : std_logic;
        enCi_T : std_logic;
        enTag : std_logic;
        enDD : std_logic;
        -- Select Signals
        selAM : std_logic_vector(1 downto 0);
        selSR : std_logic;
        selMR : std_logic;
        selD : std_logic;
        selT : std_logic;
        selS : std_logic;
        -- Load Signals
        ldCi_T : std_logic;
        -- Skinny Domain Encoding
        Bin : std_logic_vector(4 downto 0);
        -- Padding Helper Signals
        ctr_words : std_logic_vector(2 downto 0);
        data_bytes : std_logic_vector(3 downto 0); 
        -- Enable Skinny
        E_start : std_logic;
    end record controller_t;

    type registers_t is record
    gen_cnt : integer range 0 to 4;
    last_valid : integer range 0 to 4;
    end_of_ad : std_logic;
    ad_partial : std_logic;
    end_of_input : std_logic;
    message_partial : std_logic;
    data_bytes : std_logic_vector(3 downto 0);
    is_odd : std_logic;
    initial: std_logic;
    state : state_t;
    end record registers_t;


    function Pad (bdi: std_logic_vector(31 downto 0);
                  bdi_valid_bytes : std_logic_vector(3 downto 0);
                  ctr_words : std_logic_vector(2 downto 0))
                  return std_logic_vector;

end package;


package body design_pkg is

    --! design parameters specific to the CryptoCore
    constant N               : NATURAL := 128;  --! N size
    constant DBLK_SIZE       : integer := 128; --! Block size

    constant CCWdiv8         : integer := CCW / 8;

    
    constant c_encoding_t : encoding_t := (HDR_AD => "0001",
                                           HDR_MSG => "0100",
                                           HDR_CT => "0101",
                                           HDR_TAG => "1000",
                                           HDR_KEY => "1100",
                                           HDR_NPUB => "1101",
                                           NUM_WORDS => 3,
                                           MAX_WORDS => 4);


    function Pad (bdi : std_logic_vector(31 downto 0);
                  bdi_valid_bytes : std_logic_vector(3 downto 0);
                  ctr_words : std_logic_vector(2 downto 0)) 
                  return std_logic_vector is
        
        variable len_encoding : std_logic_vector(7 downto 0);
        variable bdi_encoding : std_logic_vector(31 downto 0);
        begin
            if (ctr_words = "000") then
                bdi_encoding(31 downto 8) := (others => '0');
                if (bdi_valid_bytes = "0000") then
                    len_encoding := x"00";
                elsif (bdi_valid_bytes = "1000") then
                    len_encoding := x"01";
                elsif (bdi_valid_bytes = "1100") then
                    len_encoding := x"02";
                elsif (bdi_valid_bytes = "1110") then
                    len_encoding := x"03"; 
                elsif (bdi_valid_bytes = "1111") then
                    len_encoding := x"04";
                end if;
            elsif (ctr_words = "001") then
                bdi_encoding(31 downto 8) := (others => '0');
                if (bdi_valid_bytes = "0000") then
                    len_encoding := x"04";
                elsif (bdi_valid_bytes = "1000") then
                    len_encoding := x"05";
                elsif (bdi_valid_bytes = "1100") then
                    len_encoding := x"06";
                elsif (bdi_valid_bytes = "1110") then
                    len_encoding := x"07";
                elsif (bdi_valid_bytes = "1111") then
                    len_encoding := x"08";
                end if;
            elsif (ctr_words = "010") then
                bdi_encoding(31 downto 8) := (others => '0');
                if (bdi_valid_bytes = "0000") then
                    len_encoding := x"08";
                elsif (bdi_valid_bytes = "1000") then
                    len_encoding := x"09";
                elsif (bdi_valid_bytes = "1100") then
                    len_encoding := x"0A";
                elsif (bdi_valid_bytes = "1110") then
                    len_encoding := x"0B";
                elsif (bdi_valid_bytes = "1111") then
                    len_encoding := x"0C";
                end if;
            elsif (ctr_words = "011") then
                if (bdi_valid_bytes = "0000") then
                    bdi_encoding(31 downto 8) := (others => '0');
                    len_encoding := x"0C";
                elsif (bdi_valid_bytes = "1000") then
                    bdi_encoding(31 downto 24) := bdi(31 downto 24);
                    bdi_encoding(23 downto 8) := (others => '0');  
                    len_encoding := x"0D";
                elsif (bdi_valid_bytes = "1100") then
                    bdi_encoding(31 downto 16) := bdi(31 downto 16);
                    bdi_encoding(15 downto 8) := (others => '0');
                    len_encoding := x"0E";
                elsif (bdi_valid_bytes = "1110") then
                    bdi_encoding(31 downto 8) := bdi(31 downto 8);
                    len_encoding := x"0F";
                elsif (bdi_valid_bytes = "1111") then
                    bdi_encoding(31 downto 8) := bdi(31 downto 8);
                    len_encoding := bdi(7 downto 0);
                end if;
            end if;
            bdi_encoding(7 downto 0) := len_encoding;
            return bdi_encoding;
            -- len_encoding <= x"0" & std_logic_vector(unsigned(l, 4));
            -- if (lenX = 16) then
            --     X_padded <= X;
            -- elsif (lenX = 0) then
            --     X_padded <= others => '0';
            -- elsif (lenX < 15) then
            --     X_padded(127 downto 128-(lenX-1)*8) <= X(127 downto 128-(lenX-1)*8);
            --     X_padded(127-(lenX-1)*8 downto 8) <= others => '0';
            --     X_padded(7 downto 0) <= len_encoding;
            -- elsif (l < 16) then
            --     X_padded <= X(127 downto 8) & len_encoding;
            -- else
        end function Pad;

end package body design_pkg;