library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FluxoDados is
    generic(
        instructWidth : natural := 32
    );
    port(
        clk, rst        :  in std_logic;
        escritaC        :  in std_logic;
        palavraControle :  in std_logic_vector(10 downto 0);
        instrucao       :  out std_logic_vector((instructWidth - 1) downto 0);
        opCodeFunct   :  out std_logic_vector(11 downto 0)
    );
end entity;

architecture comportamento of FluxoDados is
    signal endA, endB, endC : std_logic_vector(4 downto 0);
    signal outA, outB : std_logic_vector((instructWidth - 1) downto 0);
    signal flagZ : std_logic;
    signal saidaULA : std_logic_vector((instructWidth - 1) downto 0);
    signal extendInstruc : std_logic(15 downto 0);
    signal saidaSigExt : std_logic_vector((instructWidth - 1) downto 0);
    signal andBEQZero : std_logic;
    signal saida_MUXimed : std_logic_vector((instructWidth-1) downto 0);
    signal saidaRAM : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXimed : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXulaRAM : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXRd : std_logic_vector((instructWidth-1) downto 0);

    alias muxRtRd        :  std_logic is palavraControle(10);  
    alias habEscritaReg  :  std_logic is palavraControle(9);  
    alias muxRtImed      :  std_logic is palavraControle(8);  
    alias operacaoULA    :  std_logic_vector(3 downto 0) is palavraControle(7 downto 4);
    alias muxULAmem      :  std_logic is palavraControle(3);  
    alias BEQ            :  std_logic is palavraControle(2);  
    alias habLeituraMEM  :  std_logic is palavraControle(1);  
    alias habEscritaMEM  :  std_logic is palavraControle(0);    

    begin
        fetchInstruction : entity work.fetch generic map (dataWidth => instructWidth)
                                             port map(clk => clk,
                                                      rst => rst,
                                                      extendedInst => saidaSigExt,
                                                      andBEQZero => andBEQZero,
                                                      instrucao => instrucao);

        opCodeFunct(11 downto 6) <= instrucao(31 downto 26);
        opCodeFunct(5 downto 0)  <= instrucao(5 downto 0);
        endA                     <= instrucao(25 downto 21);
        endB                     <= instrucao(20 downto 16);
        endC                     <= instrucao(15 downto 11);
        extendInstruc            <= instrucao(15 downto 0);

        BancoReg : entity work.bancoRegistradores port map (clk => clk,
                                                            enderecoA => endA,
                                                            enderecoB => endB,
                                                            enderecoC => endC,
                                                            dadoEscritaC => saida_MUXulaRAM,
                                                            escreveC => escritaC,
                                                            saidaA => outA,
                                                            saidaB => outB);

        ULAmips : entity work.ULA port map (entradaA => outA,
                                            entradaB => saida_MUXimed,
                                            seletor => operacaoULA,
                                            saida => saidaULA,
                                            flagZero => flagZ);

                                        

        sigExt : entity work.extensorSinal generic map (larguraDadoEntrada => 16, 
                                                        larguraDadoSaida   => instructWidth)
                                           port map (estendeSinal_IN  => extendInstruc,
                                                     estendeSinal_OUT => saidaSigExt);

        muxRtRd  : entity work.muxGenerico2x1 port map (entradaA_MUX  => endB,
                                                        entradaB_MUX  => endC,
                                                        seletor_MUX   => muxRtRd,
                                                        saida_MUX     => saida_MUXRd);

        muxRTimed  : entity work.muxGenerico2x1 port map (entradaA_MUX  => outB,
                                                          entradaB_MUX  => saidaSigExt,
                                                          seletor_MUX   => muxRtImed,
                                                          saida_MUX     => saida_MUXimed);


        LogicAND : entity work.LogicAnd port map(flagZ  => flagZ,
                                                 BEQ    => BEQ,
                                                 andOUT => andBEQZero);

        memRAM   : entity work.RAM port map(addr     => saidaULA,
                                            wr       => habEscritaMEM, 
                                            re       => habLeituraMEM,
                                            clk      => clk,
                                            dado_in  => outB,
                                            dado_out => saidaRAM);
        
        muxULAram  : entity work.muxGenerico2x1 port map (entradaA_MUX  => saidaULA,
                                                          entradaB_MUX  => saidaRAM,
                                                          seletor_MUX   => muxULAmem,
                                                          saida_MUX     => saida_MUXulaRAM);
        
                                            
                                            
end architecture;