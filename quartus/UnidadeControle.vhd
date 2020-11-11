library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity UnidadeControle is
  generic ( 
        controlWidth : natural := 11
    );
  port (
    clk, rst          : in std_logic;
    opCodeFunct       : in std_logic_vector (11 downto 0);
    palavraControle   : out std_logic_vector(11 downto 0)
  );
end UnidadeControle; 

architecture arch of UnidadeControle is
    alias opCode : std_logic_vector(5 downto 0) is opCodeFunct(11 downto 6);
    alias funct  : std_logic_vector(5 downto 0) is opCodeFunct(5 downto 0);

    alias muxJUMP       : std_logic is palavraControle(11);
    alias muxRtRd       : std_logic is palavraControle(10);
    alias habEscritaReg : std_logic is palavraControle(9);
    alias muxRtImed     : std_logic is palavraControle(8);
    alias ULActrl       : std_logic_vector(3 downto 0) is palavraControle(7 downto 4);
    alias muxULAMem     : std_logic is palavraControle(3);
    alias BEQ           : std_logic is palavraControle(2);
    alias habLeituraMEM : std_logic is palavraControle(1);
    alias habEscritaMEM : std_logic is palavraControle(0);

begin

  muxRtRd <= '1';



end architecture;