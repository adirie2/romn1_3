----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2021 03:26:26 PM
-- Design Name: 
-- Module Name: nshiftk - Behavioral
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

entity nrotk is
generic( N: INTEGER:= 128;
         K: NATURAL;
         ROT: NATURAL:= 1
        );
port (signal D: in STD_LOGIC_VECTOR(N-1 downto 0);
      signal Q: out STD_LOGIC_VECTOR(N-1 downto 0)
       );
end nrotk;

architecture Behavioral of nrotk is

begin

    GEN_RIGHT: if ROT = 1 generate
    Q <= D(K-1 downto 0) & D(N-1 downto K);
    end generate GEN_RIGHT;
    
    GEN_LEFT: if ROT /= 1 generate
    Q <= D(N-K downto 0) & D(N downto N-K+1);
    end generate GEN_LEFT;

end Behavioral;
