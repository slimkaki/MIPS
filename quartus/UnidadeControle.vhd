library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity UnidadeControle is
  generic ( 
        controlWidth : natural := 15
    );
  port (
    clk, rst          : in std_logic;
    opCodeFunct       : in std_logic_vector (11 downto 0);
    palavraControle   : out std_logic_vector(14 downto 0)
  );
end UnidadeControle; 

architecture arch of UnidadeControle is
    alias opCode : std_logic_vector(5 downto 0) is opCodeFunct(11 downto 6);
    alias funct  : std_logic_vector(5 downto 0) is opCodeFunct(5 downto 0);

    alias BNE           : std_logic is palavraControle(14);
    alias muxJR         : std_logic is palavraControle(13);
    alias muxR31        : std_logic is palavraControle(12);
    alias muxJUMP       : std_logic is palavraControle(11);
    alias muxRtRd       : std_logic is palavraControle(10);
    alias habEscritaReg : std_logic is palavraControle(9);
    alias muxRtImed     : std_logic is palavraControle(8);
    alias ULActrl       : std_logic_vector(2 downto 0) is palavraControle(7 downto 5);
    alias muxULAMem     : std_logic_vector(1 downto 0) is palavraControle(4 downto 3);
    alias BEQ           : std_logic is palavraControle(2);
    alias habLeituraMEM : std_logic is palavraControle(1);
    alias habEscritaMEM : std_logic is palavraControle(0);

    signal ULAop : std_logic_vector(1 downto 0);

begin

  BNE <= '1' when (opCode = bne_I (11 downto 6)) else '0';

  muxJR <= '1' when (opCode = jr_R (11 downto 6) and funct = jr_R (5 downto 0)) else '0';

  muxR31 <= '1' when (opcode = jal_J (11 downto 6)) else '0';

  muxJUMP <= '1' when (opCode = j_J(11 downto 6)) or 
                      (opCode = jal_J(11 downto 6)) else '0';

  muxRtRd <= '1' when (opCode = "000000") else '0';
              
  habEscritaReg <= '1' when (opCode = "000000" and funct /= jr_R(5 downto 0)) or 
                            (opCode = addi_I(11 downto 6)) or
                            (opCode = addiu_I(11 downto 6)) or
                            (opCode = andi_I(11 downto 0)) or
                            (opCode = lbu_I(11 downto 6)) or
                            (opCode = lhu_I(11 downto 6)) or
                            (opCode = ll_I(11 downto 6)) or
                            (opCode = lui_I(11 downto 6)) or
                            (opCode = lw_I(11 downto 6)) or
                            (opCode = ori_I(11 downto 6)) or
                            (opCode = slti_I(11 downto 6)) or
                            (opCode = sltiu_I(11 downto 6)) else '0';

  muxRtImed <= '1' when (opCode = addi_I(11 downto 6)) or
                        (opCode = addiu_I(11 downto 6)) or
                        (opCode = andi_I(11 downto 0)) or
                        (opCode = lui_I(11 downto 6)) or
                        (opCode = ori_I(11 downto 6)) or
                        (opCode = slti_I(11 downto 6)) or
                        (opCode = sltiu_I(11 downto 6)) else '0';


  muxULAMem <= "11" when (opcode = jal_J(11 downto 6)) else
               "10" when (opCode = lui_I(11 downto 6)) else
               "01" when (opCode = ll_I(11 downto 6)) or
                         (opCode = lbu_I(11 downto 6)) or
                         (opCode = lhu_I(11 downto 6)) or
                         (opCode = lw_I(11 downto 6)) else "00";

  BEQ <= '1' when (opCode = beq_I(11 downto 6)) or
                  (opCode = bne_I(11 downto 6)) else '0';

  habLeituraMEM <= '1' when (opCode = ll_I(11 downto 6)) or
                            (opCode = lbu_I(11 downto 6)) or
                            (opCode = lhu_I(11 downto 6)) or
                            (opCode = lw_I(11 downto 6)) else '0';

  habEscritaMEM <= '1' when (opCode = sb_I(11 downto 6)) or
                            (opCode = sc_I(11 downto 6)) or
                            (opCode = sh_I(11 downto 6)) or
                            (opCode = sw_I(11 downto 6)) else '0';
  
  ULAop <= "00"  when (opCode = lw_I(11 downto 6)) or (opCode = sw_I(11 downto 6)) else
           "01"  when (opCode = beq_I(11 downto 6)) or (opCode = bne_I(11 downto 6)) else
           "10";
  
  UC_ULA : entity work.UnidadeControleULA port map (ULAop => ULAop,
                                                    opCodeFunct => opCodeFunct,
                                                    ULActrl => ULActrl);


end architecture;