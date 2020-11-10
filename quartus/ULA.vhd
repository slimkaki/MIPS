library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULA is
    generic
    (
        larguraDados : natural := 32
    );
    port
    (
      entradaA, entradaB, vem_1  :  in STD_LOGIC;--_VECTOR((larguraDados-1) downto 0);

      seletor    :  in STD_LOGIC_VECTOR(3 downto 0);
      saida, flagZero, vai_1      :  out STD_LOGIC--_VECTOR((larguraDados-1) downto 0);
    );
end entity;

architecture comportamento of ULA is

    alias inverteA   :  std_logic is seletor(3);  
    alias inverteB   :  std_logic is seletor(2);  
    alias selMuxzao  :  std_logic_vector is seletor(1 downto 0);
    
    signal outputMuxzao : std_logic;--_vector((larguraDados-1) downto 0);
    signal saidaA : std_logic;--_vector((larguraDados-1) downto 0);
    signal saidaB : std_logic;--_vector((larguraDados-1) downto 0);

    signal overflow, saidaSomador : std_logic;

    begin

      muxInva : entity work.muxAllLogic2x1 port map (entradaA_MUX => entradaA,
                                                     entradaB_MUX => (not entradaA),
                                                     seletor_MUX => inverteA,
                                                     saida_MUX => saidaA);

      muxInvb : entity work.muxAllLogic2x1 port map (entradaA_MUX => entradaB,
                                                     entradaB_MUX => (not entradaB),
                                                     seletor_MUX => inverteB,
                                                     saida_MUX => saidaB);

      soma  : entity work.somadorULA port map(entradaA => saidaA,
                                              entradaB => saidaB,
                                              vem_1 => vem_1,
                                              vai_1 => vai_1,
                                              saida => saidaSomador);
      
                                              -- vem 1 = inverteB
                                              -- vai 1 = ultimo bit 1 e 1 sobra 1
      overflow <= (vai_1 xor vem_1);

      Muxao : entity work.muxGenerico4x2 port map(entrada0 => (saidaA and saidaB),
                                                  entrada1 => (saidaA or  saidaB),
                                                  entrada2 => saidaSomador,
                                                  entrada3 => overflow,
                                                  seletor_MUX => selMuxzao,
                                                  saida_MUX => outputMuxzao);

      flagZero <= outputMuxzao nor outputMuxzao;
      saida <= outputMuxzao;

end architecture;