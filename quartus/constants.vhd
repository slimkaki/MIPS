library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package constants is
    constant OPCODE_FUNCT_WIDTH  : natural :=  12;

    subtype opCode_funct     is std_logic_vector(OPCODE_FUNCT_WIDTH-1 downto 0);

    -- opcode/Funct
    --    constant = {nomeInstrucao}_{tipoInstrucao}      
    --  opCode = (11 downto 6) ; funct = (5 downto 0)
    constant add_R   :  opCode_funct := "000000" & "100000";
    constant addi_I  :  opCode_funct := "001000" & "000000";
    constant addiu_I :  opCode_funct := "001001" & "000000";
    constant addu_R  :  opCode_funct := "000000" & "100001";
    constant and_R   :  opCode_funct := "000000" & "100100";
    constant andi_I  :  opCode_funct := "001100" & "000000";
    constant beq_I   :  opCode_funct := "000100" & "000000";
    constant bne_I   :  opCode_funct := "000101" & "000000";
    constant j_J     :  opCode_funct := "000010" & "000000";
    constant jal_J   :  opCode_funct := "000011" & "000000";
    constant jr_R    :  opCode_funct := "000000" & "001000";
    constant lbu_I   :  opCode_funct := "100100" & "000000";
    constant lhu_I   :  opCode_funct := "100101" & "000000";
    constant ll_I    :  opCode_funct := "110000" & "000000";
    constant lui_I   :  opCode_funct := "001111" & "000000";
    constant lw_I    :  opCode_funct := "100011" & "000000";
    constant nor_R   :  opCode_funct := "000000" & "100111";
    constant or_R    :  opCode_funct := "000000" & "100101";
    constant ori_I   :  opCode_funct := "001101" & "000000";
    constant slt_R   :  opCode_funct := "000000" & "101010";
    constant slti_I  :  opCode_funct := "001010" & "000000";
    constant sltiu_I :  opCode_funct := "001011" & "000000";
    constant sltu_R  :  opCode_funct := "000000" & "101011";
    constant sll_R   :  opCode_funct := "000000" & "000000";
    constant srl_R   :  opCode_funct := "000000" & "000010";
    constant sb_I    :  opCode_funct := "101000" & "000000";
    constant sc_I    :  opCode_funct := "111000" & "000000";
    constant sh_I    :  opCode_funct := "101001" & "000000";
    constant sw_I    :  opCode_funct := "101011" & "000000";
    constant sub_R   :  opCode_funct := "000000" & "100010";
    constant subu_R  :  opCode_funct := "000000" & "100011";

end package constants;