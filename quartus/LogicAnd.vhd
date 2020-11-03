library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity LogicAnd is
  port (
    flagZ  : in  std_logic;
    BEQ    : in  std_logic;
    andOUT : out std_logic
  ) ;
end LogicAnd ; 

architecture arch of LogicAnd is

begin
    andOUT <= flagZ and BEQ;

end architecture ;