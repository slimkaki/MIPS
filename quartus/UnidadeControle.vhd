library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity UnidadeControle is
  generic ( 
        controlWidth : natural := 18
    );
  port (
    clk, rst          : in std_logic;
    opCodeFunct       : in std_logic_vector (11 downto 0);
    palavraControle   : out std_logic_vector(17 downto 0)
  );
end UnidadeControle; 

architecture arch of UnidadeControle is
	 -- Separando em OpCode e Funct para melhor tratamento
    alias opCode : std_logic_vector(5 downto 0) is opCodeFunct(11 downto 6);
    alias funct  : std_logic_vector(5 downto 0) is opCodeFunct(5 downto 0);
	
	 -- Separando a palavra controle para melhor tratamento
	 alias LUI           : std_logic is palavraControle(17);
    alias BNE           : std_logic is palavraControle(16);
    alias muxJR         : std_logic is palavraControle(15);
    alias muxR31        : std_logic is palavraControle(14);
    alias muxJUMP       : std_logic_vector is palavraControle(13 downto 12);
    alias muxRtRd       : std_logic is palavraControle(11);
    alias habEscritaReg : std_logic is palavraControle(10);
    alias muxRtImed     : std_logic_vector is palavraControle(9 downto 8);
    alias ULActrl       : std_logic_vector(2 downto 0) is palavraControle(7 downto 5);
    alias muxULAMem     : std_logic_vector(1 downto 0) is palavraControle(4 downto 3);
    alias BEQ           : std_logic is palavraControle(2);
    alias habLeituraMEM : std_logic is palavraControle(1);
    alias habEscritaMEM : std_logic is palavraControle(0);

    signal ULAop : std_logic_vector(1 downto 0);

begin
  -- Bit reservado para dizer se a saida da ULA sera o LUI
  LUI <= '1' when (opCode = lui_I (11 downto 6)) else '0';
	
  -- Bit reservado para instrucao BNE
  BNE <= '1' when (opCode = bne_I (11 downto 6)) else '0';
	
  -- Seletor do MUX JR para o caso da instrucao ser jr
  muxJR <= '1' when (opCode = jr_R (11 downto 6) and funct = jr_R (5 downto 0)) else '0';

  -- Selecao para o registrador 3 do banco de registradores ser 31
  -- para o caso de a instrucao ser jal
  muxR31 <= '1' when (opcode = jal_J (11 downto 6)) else '0';
  
  -- Seletor do MUX para os diferentes tipos de jump no fetch (jump incondicional, BNE, jal e jr)
  muxJUMP <= "11"  when (opCode = j_J(11 downto 6)) or 
                      (opCode = jal_J(11 downto 6)) else
				 "10" when (opCode = bne_I(11 downto 6)) else
				 "01" when (opCode = jr_R (11 downto 6) and funct = jr_R (5 downto 0)) else
				 "00";
  
  -- Seletor do MUX Rt/Rd para selecionar a entrada do registrador 3 no banco de registrador
  -- entre ser igual ao registrador 2 ou igual ao que estiver como terceiro endereco na instrucao
  -- Obs: a saida desse mux e entrada do mux R31
  muxRtRd <= '1' when (opCode = "000000") else '0';
  
  -- Permite escrita no banco de registradores
  habEscritaReg <= '1' when (opCode = "000000" and funct /= jr_R(5 downto 0)) or 
                            (opCode = addi_I(11 downto 6)) or
                            (opCode = addiu_I(11 downto 6)) or
                            (opCode = andi_I(11 downto 6)) or
                            (opCode = lbu_I(11 downto 6)) or
                            (opCode = lhu_I(11 downto 6)) or
                            (opCode = ll_I(11 downto 6)) or
                            (opCode = lui_I(11 downto 6)) or
                            (opCode = lw_I(11 downto 6)) or
                            (opCode = ori_I(11 downto 6)) or
									 (opCode = slt_R(11 downto 6)) or
                            (opCode = slti_I(11 downto 6)) or
                            (opCode = sltiu_I(11 downto 6)) or
									 (opcode = jal_J (11 downto 6)) or
									 (opCode = "000000" and funct /= "000000") else '0';
									 
  -- Escolhe a entrada B da ULA, entre o imediato e a segunda saida do banco de registradores
  muxRtImed <= "10" when (opCode = andi_I(11 downto 6)) or
								 (opCode = ori_I(11 downto 6)) else
					"01"  when (opCode = addi_I(11 downto 6)) or
                          (opCode = addiu_I(11 downto 6)) or
                          (opCode = lui_I(11 downto 6)) or
                          (opCode = slti_I(11 downto 6)) or
                          (opCode = sltiu_I(11 downto 6)) or
								  (opCode = sw_I(11 downto 6)) or
								  (opCode = lw_I(11 downto 6)) else "00";

  -- Escolhe o que deve ser escrito no banco de registradres, entre a saida da ULA, saida da memoria ram
  -- ou o vetor extendido do lui ou tambem o valor do jal
  muxULAMem <= "11" when (opcode = jal_J(11 downto 6)) else
               "10" when (opCode = lui_I(11 downto 6)) else
               "01" when (opCode = ll_I(11 downto 6)) or
                         (opCode = lbu_I(11 downto 6)) or
                         (opCode = lhu_I(11 downto 6)) or
                         (opCode = lw_I(11 downto 6)) else "00";
  -- Bit reservado para instrucao BNE
  BEQ <= '1' when (opCode = beq_I(11 downto 6)) else '0';
  
  -- Permite a escrita na memoria ram, tambem conhecida como memoria de dados
  habLeituraMEM <= '1' when (opCode = ll_I(11 downto 6)) or
                            (opCode = lbu_I(11 downto 6)) or
                            (opCode = lhu_I(11 downto 6)) or
                            (opCode = lw_I(11 downto 6)) else '0';
  -- Permite a leitura na memoria ram, tambem conhecida como memoria de dados
  habEscritaMEM <= '1' when (opCode = sb_I(11 downto 6)) or
                            (opCode = sc_I(11 downto 6)) or
                            (opCode = sh_I(11 downto 6)) or
                            (opCode = sw_I(11 downto 6)) else '0';
  
  -- Operacao a enviar para a unidade de controle da ULA
  ULAop <= "00"  when (opCode = lw_I(11 downto 6)) or (opCode = sw_I(11 downto 6)) else
           "01"  when (opCode = beq_I(11 downto 6)) or (opCode = bne_I(11 downto 6)) else
           "10";
			  
  -- Unidade de Controle da ULA
  -- Entra ULAop e sai a ULActrl, com a operacionalizacao do ULAop
  UC_ULA : entity work.UnidadeControleULA port map (ULAop => ULAop,
                                                    opCodeFunct => opCodeFunct,
                                                    ULActrl => ULActrl);


end architecture;