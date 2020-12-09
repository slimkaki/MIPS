library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity UnidadeControleULA is
  port (
    ULAop  : in  std_logic_vector(1 downto 0);
    opCodeFunct : in std_logic_vector(11 downto 0);
    ULActrl: out std_logic_vector(2 downto 0)
  );
end UnidadeControleULA; 

architecture arch of UnidadeControleULA is
    alias opcode : std_logic_vector is opCodeFunct(11 downto 6);
    alias funct  : std_logic_vector is opCodeFunct(5 downto 0);
begin
    -- Operacoes a serem realizadas
	 -- Primeiro bit reservado para inversao do B
	 -- Segundo e terceiro bit funcionam em conjunto para selecionar a saida da ULA
	 -- saidas da ULA:
	 --       - 00: AND
	 --       - 01: OR
	 --       - 10: SOMA/SUBTRACAO
	 --       - 11: SLT
	 
    ULActrl <=   "010" WHEN (opcode = add_R(11 downto 6) and funct = add_R(5 downto 0) and (ULAop = "10")) or 
                            (opcode = addu_R(11 downto 6) and funct = addu_R(5 downto 0) and (ULAop = "10")) or
                            (opcode = addi_I(11 downto 6) and (ULAop = "10")) or (ULAop = "00") ELSE
                 "110" WHEN (opcode = sub_R(11 downto 6) and funct = sub_R(5 downto 0) and (ULAop = "10")) or
                            (opcode = subu_R(11 downto 6) and funct = subu_R(5 downto 0) and (ULAop = "10")) or
                            (opcode = beq_I(11 downto 6) and (ULAop = "10")) or (opcode = bne_I(11 downto 6) and (ULAop = "10")) or (ULAop = "01") ELSE
                 "111" WHEN (opcode = slt_r(11 downto 6) and funct = slt_R(5 downto 0) and (ULAop = "10")) or
                            (opcode = sltu_R(11 downto 6) and funct = sltu_R(5 downto 0) and (ULAop = "10")) or 
									 (opcode = slti_I(11 downto 6) and (ULAop = "10")) ELSE
                 "000" WHEN (opcode = and_R(11 downto 6) and funct = and_R(5 downto 0) and (ULAop = "10")) or
                            (opcode = andi_I(11 downto 6) and (ULAop = "10")) ELSE
                 "001" WHEN (opcode = or_R(11 downto 6) and funct = or_R(5 downto 0) and (ULAop = "10")) or
                            (opcode = ori_I(11 downto 6) and (ULAop = "10"));

end architecture;