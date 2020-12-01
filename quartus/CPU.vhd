library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity CPU is
  generic (
    instructWidth : natural := 32;
    controlWidth  : natural := 15
  );
  port (
   clk, rst : in std_logic;
	 instruc : out std_logic_vector((instructWidth-1) downto 0);
   palavraControl: out std_logic_vector((controlWidth-1) downto 0);
   saida_PC : out std_logic_vector((instructWidth-1) downto 0);
   saida, saidaMegaMux, inA, inB, inB_inv : out std_logic_vector(31 downto 0)
  );
end CPU; 

architecture arch of CPU is
    signal palavraControle : std_logic_vector(14 downto 0);
    signal instrucao       : std_logic_vector((instructWidth-1) downto 0);
    signal opCodeFunct     : std_logic_vector(11 downto 0);

begin

    FD : entity work.FluxoDados generic map(instructWidth => instructWidth)
                                port map(clk => clk,
                                         rst => rst,
                                         palavraControle => palavraControle,
                                         instrucao => instrucao,
                                         opCodeFunct => opCodeFunct,
                                         saida_PC => saida_PC,
                                         mSaidaULA => saida,
                                         saidaMegaMux => saidaMegaMux,
													  inA => inA,
													  inB => inB,
													  inB_inv => inB_inv);

    UC : entity work.UnidadeControle generic map(controlWidth => controlWidth)
                                     port map(clk => clk,
                                              rst => rst,
                                              opCodeFunct => opCodeFunct,
                                              palavraControle => palavraControle);
                                              
	instruc <= instrucao;
	palavraControl <= palavraControle;

end architecture ;