----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2021 10:55:29 PM
-- Design Name: 
-- Module Name: sbox - Behavioral
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
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sbox is
--  Port ( );

Port(Addr: in std_logic_vector(7 downto 0);
     Y : out std_logic_vector(7 downto 0));
end sbox;

architecture Behavioral of sbox is
type rom_memory is array (0 to 255) of std_logic_vector(7 downto 0);
signal int_addr: INTEGER RANGE 0 to 255;
constant sbox_rom : rom_memory := (
-- Row 1
x"65" ,x"4c" ,x"6a" ,x"42" ,x"4b" ,x"63" ,x"43" ,x"6b" ,x"55" ,x"75" ,x"5a" ,x"7a" ,x"53" ,x"73" ,x"5b" ,x"7b" ,
-- Row 2
x"35" ,x"8c" ,x"3a" ,x"81" ,x"89" ,x"33" ,x"80" ,x"3b" ,x"95" ,x"25" ,x"98" ,x"2a" ,x"90" ,x"23" ,x"99" ,x"2b" ,
-- Row 3
x"e5" ,x"cc" ,x"e8" ,x"c1" ,x"c9" ,x"e0" ,x"c0" ,x"e9" ,x"d5" ,x"f5" ,x"d8" ,x"f8" ,x"d0" ,x"f0" ,x"d9" ,x"f9" ,
-- Row 4
x"a5" ,x"1c" ,x"a8" ,x"12" ,x"1b" ,x"a0" ,x"13" ,x"a9" ,x"05" ,x"b5" ,x"0a" ,x"b8" ,x"03" ,x"b0" ,x"0b" ,x"b9" ,
-- Row 5
x"32" ,x"88" ,x"3c" ,x"85" ,x"8d" ,x"34" ,x"84" ,x"3d" ,x"91" ,x"22" ,x"9c" ,x"2c" ,x"94" ,x"24" ,x"9d" ,x"2d" ,
-- Row 6
x"62" ,x"4a" ,x"6c" ,x"45" ,x"4d" ,x"64" ,x"44" ,x"6d" ,x"52" ,x"72" ,x"5c" ,x"7c" ,x"54" ,x"74" ,x"5d" ,x"7d" ,
-- Row 7
x"a1" ,x"1a" ,x"ac" ,x"15" ,x"1d" ,x"a4" ,x"14" ,x"ad" ,x"02" ,x"b1" ,x"0c" ,x"bc" ,x"04" ,x"b4" ,x"0d" ,x"bd" ,
-- Row 8
x"e1" ,x"c8" ,x"ec" ,x"c5" ,x"cd" ,x"e4" ,x"c4" ,x"ed" ,x"d1" ,x"f1" ,x"dc" ,x"fc" ,x"d4" ,x"f4" ,x"dd" ,x"fd" ,
-- Row 9
x"36" ,x"8e" ,x"38" ,x"82" ,x"8b" ,x"30" ,x"83" ,x"39" ,x"96" ,x"26" ,x"9a" ,x"28" ,x"93" ,x"20" ,x"9b" ,x"29" ,
-- Row 10
x"66" ,x"4e" ,x"68" ,x"41" ,x"49" ,x"60" ,x"40" ,x"69" ,x"56" ,x"76" ,x"58" ,x"78" ,x"50" ,x"70" ,x"59" ,x"79" ,
-- Row 11
x"a6" ,x"1e" ,x"aa" ,x"11" ,x"19" ,x"a3" ,x"10" ,x"ab" ,x"06" ,x"b6" ,x"08" ,x"ba" ,x"00" ,x"b3" ,x"09" ,x"bb" ,
-- Row 12
x"e6" ,x"ce" ,x"ea" ,x"c2" ,x"cb" ,x"e3" ,x"c3" ,x"eb" ,x"d6" ,x"f6" ,x"da" ,x"fa" ,x"d3" ,x"f3" ,x"db" ,x"fb" ,
-- Row 13
x"31" ,x"8a" ,x"3e" ,x"86" ,x"8f" ,x"37" ,x"87" ,x"3f" ,x"92" ,x"21" ,x"9e" ,x"2e" ,x"97" ,x"27" ,x"9f" ,x"2f" ,
-- Row 14
x"61" ,x"48" ,x"6e" ,x"46" ,x"4f" ,x"67" ,x"47" ,x"6f" ,x"51" ,x"71" ,x"5e" ,x"7e" ,x"57" ,x"77" ,x"5f" ,x"7f" ,
-- Row 15
x"a2" ,x"18" ,x"ae" ,x"16" ,x"1f" ,x"a7" ,x"17" ,x"af" ,x"01" ,x"b2" ,x"0e" ,x"be" ,x"07" ,x"b7" ,x"0f" ,x"bf" ,
-- Row 16
x"e2" ,x"ca" ,x"ee" ,x"c6" ,x"cf" ,x"e7" ,x"c7" ,x"ef" ,x"d2" ,x"f2" ,x"de" ,x"fe" ,x"d7" ,x"f7" ,x"df" ,x"ff");
begin

int_addr <= to_integer(unsigned(Addr));
Y <= sbox_rom(int_addr); 

end Behavioral;
