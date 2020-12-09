library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevel is
  generic (larguraDados : natural := 32;
           controlWidth : natural := 16);
  port (
    clock : in std_logic;
    SW : in std_logic_vector(1 downto 0);
    KEY : in std_logic_vector(1 downto 0);
    LEDR : out std_logic_vector(7 downto 0);
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
  );
end TopLevel; 

architecture arch of TopLevel is
    signal data : std_logic_vector((larguraDados-1) downto 0);
    signal palavraControle : std_logic_vector((controlWidth-1) downto 0);
    signal mux_data_write : std_logic_vector(31 downto 0);
    signal habEscritaMEM, habLeituraMEM : std_logic;
    signal seg7Input0, seg7Input1, seg7Input2, seg7Input3, seg7Input4, seg7Input5 : std_logic_vector(3 downto 0);
    signal habilitaHEX : std_logic_vector(5 downto 0);
    signal meu_clock : std_logic;
	 signal saida_PC, saida, saidaMegaMux : std_logic_vector((larguraDados-1) downto 0);

begin
	 -- Chamando o processador como um todo
    processador : entity work.CPU generic map(instructWidth => larguraDados,
                                              controlWidth => controlWidth)
                                  port map (clk => meu_clock,
                                            rst => not KEY(1),
                                            saida_PC => saida_PC,
                                            saida => saida,
                                            saidaMegaMux => saidaMegaMux);
	
	 -- Transformando o sinal do botao em Clock
    edges : entity work.edgeDetector port map (clk => clock,
                                               entrada => not KEY(0),
                                               saida => meu_clock);
	 -- MUX para selecao da saida nos HEX
    MUX : entity work.muxGenerico4x2_32 port map(entrada0 => saida_PC,
                                              entrada1 => saida,          -- saida ula
                                              entrada2 => saidaMegaMux,
                                              entrada3 => saidaMegaMux,
                                              seletor_MUX => SW(1 downto 0),
                                              saida_MUX => data);

    -- Colocando os dados nos HEX
    showHEX0 : entity work.conversorHex7Segmentos port map (dadoHex => data(3 downto 0), saida7seg => HEX0);
    showHEX1 : entity work.conversorHex7Segmentos port map (dadoHex => data(7 downto 4), saida7seg => HEX1);
    showHEX2 : entity work.conversorHex7Segmentos port map (dadoHex => data(11 downto 8), saida7seg => HEX2);
    showHEX3 : entity work.conversorHex7Segmentos port map (dadoHex => data(15 downto 12), saida7seg => HEX3);
    showHEX4 : entity work.conversorHex7Segmentos port map (dadoHex => data(19 downto 16), saida7seg => HEX4);
    showHEX5 : entity work.conversorHex7Segmentos port map (dadoHex => data(23 downto 20), saida7seg => HEX5);
	 
	 -- Colocando os dados nos LEDs
    LEDR(7 downto 0) <= data(31 downto 24);
end architecture;