----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 09:22:19 PM
-- Design Name: 
-- Module Name: CryptoCore - Behavioral
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

entity CryptoCore is
--  Port ( );
generic(CCSW : INTEGER := 32;
        CCW : INTEGER := 32;
        CCWdiv8 : INTEGER := 4);
port(
     clk, rst : in STD_LOGIC;
     -- INPUTS FROM PRE PROCESSOR
     key : in STD_LOGIC_VECTOR(CCSW-1 downto 0);
     key_valid, bdi_valid, bdi_eot, bdi_eoi, decrypt_in, key_update : in STD_LOGIC;
     bdi : in STD_LOGIC_VECTOR(CCW-1 downto 0);
     bdi_type : in STD_LOGIC_VECTOR(3 downto 0);
     bdi_valid_bytes, bdi_pad_loc : in STD_LOGIC_VECTOR(CCWdiv8-1 downto 0);
     bdi_size : in STD_LOGIC_VECTOR(CCWdiv8 downto 0);
     -- OUTPUTS TO PRE PROCESSOR
     key_ready, bdi_ready : out STD_LOGIC;
     -- OUTPUTS TO POST PROCESSOR
     bdo : out STD_LOGIC_VECTOR(CCW-1 downto 0);
     bdo_type : out STD_LOGIC_VECTOR(3 downto 0);
     bdo_valid_bytes : out STD_LOGIC_VECTOR(CCWdiv8-1 downto 0);
     bdo_valid, end_of_block, msg_auth, msg_auth_valid : out STD_LOGIC;
     -- INPUTS FROM POST PROCESSOR
     bdo_ready, msg_auth_ready : in STD_LOGIC
     );
end CryptoCore;

architecture Behavioral of CryptoCore is
-- Intermediate Signals for Interface Division between Datapath and Controller
signal Bin : std_logic_vector(4 downto 0);
signal E_start : std_logic;
signal selS, selSR, selD, selT, selMR : std_logic;
signal selAM : std_logic_vector(1 downto 0);
signal enKey, enAM, enN, enS, enDD, enCi_T, enTag : std_logic;
signal ldCi_T : std_logic;
signal E_done : std_logic;
signal tag_verify : std_logic;
signal len8 : std_logic_vector(7 downto 0);
-- Intermediate Signals to avoid signal assignment of output appearing on right hand side of signal assignment
signal bdo_i : std_logic_vector(CCW-1 downto 0);
signal bdo_type_i : std_logic_vector(3 downto 0);
signal bdo_valid_bytes_i : std_logic_vector(CCWdiv8-1 downto 0);
signal bdo_valid_i, end_of_block_i, msg_auth_i, msg_auth_valid_i , bdi_ready_i: std_logic;
begin
bdo <= bdo_i;
bdo_type <= bdo_type_i;
bdo_valid_bytes <= bdo_valid_bytes_i;
bdo_valid <= bdo_valid_i;
end_of_block <= end_of_block_i;
msg_auth <= msg_auth_i;
msg_auth_valid <= msg_auth_valid_i;
bdi_ready <= bdi_ready_i;
-- Instantiate Datapath

--clk : in STD_LOGIC;
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

INSTANTIATE_DATAPATH: entity work.datapath
    port map (
              clk => clk,
              key => key,
              bdi => bdi,
              -- bdi_pad_loc => bdi_pad_loc,
              len8 => len8,
              bdo => bdo,
              Bin => Bin,
              ldCi_T => ldCi_T,
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
              E_done => E_done,
              tag_verify => tag_verify);
              

INSTANTIATE_CONTROLLER: entity work.controller
    port map (
              clk => clk,
              rst => rst,
              bdi_type => bdi_type,
              msg_auth_ready => msg_auth_ready,
              decrypt_in => decrypt_in,
              bdi_eoi => bdi_eoi,
              bdi_eot => bdi_eot,
              bdo_ready => bdo_ready,
              key_update => key_update,
              key_valid => key_valid,
              key_ready => key_ready,
              bdi_valid => bdi_valid,
              end_of_block => end_of_block,
              bdo_valid => bdo_valid,
              msg_auth => msg_auth,
              msg_auth_valid => msg_auth_valid,
              bdi_ready => bdi_ready,
              bdo_type => bdo_type,
              bdo_valid_bytes => bdo_valid_bytes,
              Bin => Bin,
              E_start => E_start,
              ldCi_T => ldCi_T,
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
              tag_verify => tag_verify,
              E_done => E_done,
              len8 => len8);

end Behavioral;
