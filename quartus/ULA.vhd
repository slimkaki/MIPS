library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULA is
    port
    (
      entradaA, entradaB  :  in STD_LOGIC;
      seletor    :  in STD_LOGIC_VECTOR(2 downto 0);
      vem_1 : in std_logic;
      vai_1 : out std_logic;
      saida :  out STD_LOGIC;
      entradaB_inv : in std_logic
    );
end entity;

architecture comportamento of ULA is

    -- alias inverteA   :  std_logic is seletor(3);  
    alias inverteB   :  std_logic is seletor(2);  
    alias selMuxzao  :  std_logic_vector is seletor(1 downto 0);
    
    signal outputMuxzao : std_logic;
    signal saidaB : std_logic;

    signal saidaSomador : std_logic;


    begin


      muxInvb : entity work.muxAllLogic2x1 port map (entradaA_MUX => entradaB,
                                                     entradaB_MUX => entradaB_inv,
                                                     seletor_MUX => inverteB,
                                                     saida_MUX => saidaB);

                            

      soma  : entity work.somadorULA port map(entradaA => entradaA,
                                              entradaB => saidaB,
                                              vem_1 => vem_1,
                                              vai_1 => vai_1,
                                              saida => saidaSomador);		
		

      Muxao : entity work.muxGenerico4x2 port map(entrada0 => (entradaA and saidaB),
                                                  entrada1 => (entradaA or  saidaB),
                                                  entrada2 => saidaSomador,
                                                  entrada3 => saidaSomador,
                                                  seletor_MUX => selMuxzao,
                                                  saida_MUX => outputMuxzao);

      saida <= outputMuxzao;

end architecture;