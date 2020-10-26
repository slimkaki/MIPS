library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FluxoDados is
    generic(
        instructWidth : natural := 32
    );
    port(
        clk, rst    :  in std_logic;
        escritaC    :  in std_logic;
        operacaoULA : in std_logic_vector(2 downto 0);
        instrucao   : out std_logic_vector((instructWidth - 1) downto 0);
        opCode      : out std_logic_vector(5 downto 0)
    );
end entity;

architecture comportamento of FluxoDados is
    signal endA, endB, endC : std_logic_vector(4 downto 0);
    signal outA, outB : std_logic_vector((instructWidth - 1) downto 0);
    signal flagZ : std_logic;
    signal saidaULA : std_logic_vector((instructWidth - 1) downto 0);

    begin
        fetchInstruction : entity work.fetch generic map (dataWidth => instructWidth)
                                  port map(clk => clk,
                                           rst => rst,
                                           instrucao => instrucao);

        opCode <= instrucao(31 downto 26);
        endA   <= instrucao(25 downto 21);
        endB   <= instrucao(20 downto 16);
        endC   <= instrucao(15 downto 11);

        BancoReg : entity work.bancoRegistradores port map (clk => clk,
                                                            enderecoA => endA,
                                                            enderecoB => endB,
                                                            enderecoC => endC,
                                                            dadoEscritaC => saidaULA,
                                                            escreveC => escritaC,
                                                            saidaA => outA,
                                                            saidaB => outB);

        ULAmips : entity work.ULA port map (entradaA => outA,
                                            entradaB => outB,
                                            seletor => operacaoULA,
                                            saida => saidaULA,
                                            flagZero => flagZ);
                                            
end architecture;