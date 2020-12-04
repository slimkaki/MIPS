library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity CPU is
  generic (
    instructWidth : natural := 32;
    controlWidth  : natural := 16
  );
  port (
   clk, rst : in std_logic;
   saida_PC, saida, saidaMegaMux : out std_logic_vector((instructWidth-1) downto 0)
  );
end CPU; 

architecture arch of CPU is
    signal palavraControle : std_logic_vector(15 downto 0);
    signal opCodeFunct     : std_logic_vector(11 downto 0);

begin
	 -- Chamando o Fluxo de Dados
    FD : entity work.FluxoDados generic map(instructWidth => instructWidth)
                                port map(clk => clk,
                                         rst => rst,
                                         palavraControle => palavraControle,
                                         opCodeFunct => opCodeFunct,
                                         saida_PC => saida_PC,
                                         mSaidaULA => saida,
                                         saidaMegaMux => saidaMegaMux);
	 -- Chamando a Unidade de Controle
    UC : entity work.UnidadeControle generic map(controlWidth => controlWidth)
                                     port map(clk => clk,
                                              rst => rst,
                                              opCodeFunct => opCodeFunct,
                                              palavraControle => palavraControle);
end architecture ;