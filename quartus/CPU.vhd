library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity CPU is
  generic (
    instructWidth : natural := 32;
    controlWidth  : natural := 10
  );
  port (
    clk, rst : in std_logic;
	 saida : out std_logic
  );
end CPU; 

architecture arch of CPU is
    signal palavraControle : std_logic_vector(10 downto 0);
    signal instrucao       : std_logic_vector((instructWidth-1) downto 0);
    signal opCodeFunct     : std_logic_vector(11 downto 0);

begin

    FD : entity work.FluxoDados generic map(instructWidth => instructWidth)
                                port map(clk => clk,
                                         rst => rst,
                                         escritaC => '1',
                                         palavraControle => palavraControle,
                                         instrucao => instrucao,
                                         opCodeFunct => opCodeFunct);

    UC : entity work.UnidadeControle generic map(controlWidth => controlWidth)
                                     port map(clk => clk,
                                              rst => rst,
                                              opCodeFunct => opCodeFunct,
                                              palavraControle => palavraControle);
	saida <= '1';

end architecture ;