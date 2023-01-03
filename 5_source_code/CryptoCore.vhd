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

use work.design_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CryptoCore is
--  Port ( );
port(
     clk, rst : in STD_LOGIC;
     -- INPUTS FROM PRE PROCESSOR
     key : in STD_LOGIC_VECTOR(CCSW-1 downto 0);
     key_valid, bdi_valid, bdi_eot, bdi_eoi, decrypt_in, hash_in, key_update : in STD_LOGIC;
     bdi : in STD_LOGIC_VECTOR(CCW-1 downto 0);
     bdi_type : in STD_LOGIC_VECTOR(3 downto 0);
     bdi_valid_bytes, bdi_pad_loc : in STD_LOGIC_VECTOR(CCWdiv8-1 downto 0);
     bdi_size : in STD_LOGIC_VECTOR(2 downto 0);
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
-- signal control : control_t;
signal status : status_t;

signal in_bus : data_in_t;
signal out_bus : data_out_t;

signal E_start : std_logic;
signal E_done : std_logic;
signal tag_verify : std_logic;
signal bdo_i : std_logic_vector(31 downto 0);

begin

bdi_ready <= out_bus.status.bdi_ready;
bdo_valid <= out_bus.status.bdo_valid;
bdo_valid_bytes <= out_bus.status.bdo_valid_bytes;
end_of_block <= out_bus.status.end_of_block;
key_ready <= out_bus.status.key_ready;
msg_auth_valid <= out_bus.status.msg_auth_valid;
msg_auth <= out_bus.status.msg_auth_valid;
bdo <= bdo_i;



in_bus <= (bdi => bdi,
           control => (bdi_valid => bdi_valid,
            bdi_valid_bytes => bdi_valid_bytes,
            bdi_size => bdi_size,
            bdi_eot => bdi_eot,
            bdi_eoi => bdi_eoi,
            bdi_type => bdi_type,
            decrypt_in => decrypt_in,
            key_valid => key_valid,
            key_update => key_update,
            bdo_ready => bdo_ready,
            msg_auth_ready => msg_auth_ready));


INSTANTIATE_DATAPATH: entity work.RomNDatapath
    port map (clk => clk,
              key => key,
              bdi => bdi,
              status => out_bus.status,
              E_start => E_start,
              tag_verify => tag_verify,
              E_done => E_done,
              bdo => bdo_i);
              

INSTANTIATE_CONTROLLER: entity work.RomNController
    port map (clk => clk,
              rst => rst,
              in_bus => in_bus,
              out_bus => out_bus,
              E_start => E_start,
              E_done => E_done,
              tag_verify => tag_verify);

end Behavioral;
