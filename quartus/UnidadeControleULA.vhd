library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity UnidadeControleULA is
  port (
    ULAop  : in  std_logic_vector(1 downto 0);
    funct  : in  std_logic_vector(5 downto 0);
    ULActrl: out std_logic_vector(2 downto 0)
  );
end UnidadeControleULA; 

architecture arch of UnidadeControleULA is
    signal Functcrtl : std_logic_vector(2 downto 0);
begin
    Functcrtl <= "010" WHEN (funct = add_R(5 downto 0))or(funct = addu_R(5 downto 0)) ELSE
                 "110" WHEN (funct = sub_R(5 downto 0))or(funct = subu_R(5 downto 0)) ELSE
                 "111" WHEN (funct = slt_R(5 downto 0))or(funct = sltu_R(5 downto 0)) ELSE
                 "000" WHEN (funct = and_R(5 downto 0)) ELSE
                 "001" WHEN (funct = or_R(5 downto 0));

    ULActrl <= Functcrtl WHEN (ULAop = "10") ELSE 
                   "110" WHEN (ULAop = "01") ELSE 
                   "010";

end architecture;