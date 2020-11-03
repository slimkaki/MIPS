library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity muxRT is
    generic(
        instructWidth : natural := 32
    );
    port(
        entradaA      :  in std_logic_vector(instructWidth-1 downto 0);
        entradaB      :  in std_logic_vector(instructWidth-1 downto 0);
        saida        :  out std_logic_vector(instructWidth-1 downto 0)
    );
end entity;

architecture comportamento of muxRT is

    begin
        MUX  : entity work.muxGenerico2x1 generic map (larguraDados => instructWidth)
                                                port map (entradaA_MUX => proxInst,
                                                entradaB_MUX =>  saidaSigExt,
                                                seletor_MUX => sinalLocal,
                                                saida_MUX => sinalLocal);