library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity bitShift is
  generic (dataWidth : natural := 32; shiftSize : natural := 2);
  port (
    clock : in std_logic;
    entrada : in std_logic_vector((dataWidth - 1) downto 0);
    saida : out std_logic_vector((dataWidth - 1) downto 0)
  );
end bitShift; 

architecture arch of bitShift is

signal shift1 : std_logic_vector((dataWidth - 1) downto 0);

begin
    process(clock) is
    begin
        saida <= std_logic_vector(shift_left(unsigned(entrada), shiftSize));
    end process;
end architecture;