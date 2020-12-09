library ieee;
use ieee.std_logic_1164.all;

entity extensorSinal_LUI is
    generic
    (
        larguraDadoEntrada : natural  :=    16;
        larguraDadoSaida   : natural  :=    32
    );
    port
    (
        -- Input ports
        estendeSinal_IN : in  std_logic_vector(larguraDadoEntrada-1 downto 0);
        -- Output ports
        estendeSinal_OUT: out std_logic_vector(larguraDadoSaida-1 downto 0)
    );
end entity;

architecture comportamento of extensorSinal_LUI is
begin
	 estendeSinal_OUT <= estendeSinal_IN & (larguraDadoSaida-1 downto larguraDadoEntrada => '0');
end architecture;
