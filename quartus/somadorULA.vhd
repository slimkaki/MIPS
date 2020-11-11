library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;          -- Biblioteca IEEE para funções aritméticas

entity somadorULA is
    generic
    (
        larguraDados : natural := 32
    );
    port
    (
        entradaA, entradaB: in STD_LOGIC;
        vem_1: in std_logic;
        vai_1, saida:  out STD_LOGIC
    );
end entity;

architecture comportamento of somadorULA is
    signal temp, A, B, v : std_logic_vector(1 downto 0);
    begin
		  A(1) <= '0';
		  A(0) <= entradaA;
		  B(1) <= '0';
		  B(0) <= entradaB;
		  v(1) <= '0';
		  v(0) <= vem_1;
        temp  <= std_logic_vector(unsigned(A)+unsigned(B)+unsigned(v));
        vai_1 <= temp(1);
        saida <= temp(0);
end architecture;