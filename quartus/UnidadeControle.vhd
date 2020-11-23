library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity UnidadeControle is
  generic ( 
        controlWidth : natural := 11
    );
  port (
    clk, rst          : in std_logic;
    opCodeFunct       : in std_logic_vector (11 downto 0);
    palavraControle   : out std_logic_vector(10 downto 0)
  );
end UnidadeControle; 

architecture arch of UnidadeControle is
    alias opCode : std_logic_vector(5 downto 0) is opCodeFunct(11 downto 6);
    alias funct  : std_logic_vector(5 downto 0) is opCodeFunct(5 downto 0);

    alias muxJUMP       : std_logic is palavraControle(10);
    alias muxRtRd       : std_logic is palavraControle(9);
    alias habEscritaReg : std_logic is palavraControle(8);
    alias muxRtImed     : std_logic is palavraControle(7);
    alias ULActrl       : std_logic_vector(2 downto 0) is palavraControle(6 downto 4);
    alias muxULAMem     : std_logic is palavraControle(3);
    alias BEQ           : std_logic is palavraControle(2);
    alias habLeituraMEM : std_logic is palavraControle(1);
    alias habEscritaMEM : std_logic is palavraControle(0);

    signal ULAop : std_logic_vector(1 downto 0);

begin

  muxJUMP <= '1' WHEN (opCode = j_J(11 downto 6)) or 
                      (opCode = jal_J(11 downto 6)) or 
                      (opCodeFunct = jr_R) ELSE '0';

  muxRtRd <= '1' WHEN (opCode = "000000") ELSE '0';
              
  habEscritaReg <= '1' WHEN (opCode = "000000") or 
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
                            (opCode = sltiu_I(11 downto 6)) ELSE '0';

  muxRtImed <= '1' WHEN (opCode = addi_I(11 downto 6)) or
                        (opCode = addiu_I(11 downto 6)) or
                        (opCode = andi_I(11 downto 0)) or
                        (opCode = lui_I(11 downto 6)) or
                        (opCode = ori_I(11 downto 6)) or
                        (opCode = slti_I(11 downto 6)) or
                        (opCode = sltiu_I(11 downto 6)) ELSE '0';


  muxULAMem <= '1' WHEN (opCode = ll_I(11 downto 6)) or
                        (opCode = lbu_I(11 downto 6)) or
                        (opCode = lhu_I(11 downto 6)) or
                        (opCode = lw_I(11 downto 6)) ELSE '0';

  BEQ <= '1' WHEN (opCode = beq_I(11 downto 6)) or
                  (opCode = bne_I(11 downto 6)) ELSE '0';  -- ????

  habLeituraMEM <= '1' WHEN (opCode = ll_I(11 downto 6)) or
                            (opCode = lbu_I(11 downto 6)) or
                            (opCode = lhu_I(11 downto 6)) or
                            (opCode = lw_I(11 downto 6)) ELSE '0';

  habEscritaMEM <= '1' WHEN (opCode = sb_I(11 downto 6)) or
                            (opCode = sc_I(11 downto 6)) or
                            (opCode = sh_I(11 downto 6)) or
                            (opCode = sw_I(11 downto 6)) ELSE '0';
  
  ULAop <= "00"  WHEN (opCode = lw_I(11 downto 6)) or (opCode = sw_I(11 downto 6)) ELSE
           "01"  WHEN (opCode = beq_I(11 downto 6)) ELSE
           "10";
  
  UC_ULA : entity work.UnidadeControleULA port map (ULAop => ULAop,
                                                    funct => funct,
                                                    ULActrl => ULActrl);


end architecture;