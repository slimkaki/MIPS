library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA_32 is
    generic(
        instructWidth : natural := 32
    );
    port(
        clk, rst        :  in std_logic;
        ULActrl :  in std_logic_vector(2 downto 0);
		  entradaA, entradaB : in std_logic_vector((instructWidth-1) downto 0);
        flagZ     :  out std_logic;
        mSaidaULA : out std_logic_vector((instructWidth-1) downto 0)
    );
end entity;

architecture comportamento of ULA_32 is
constant zero : std_logic_vector(31 downto 0) := (others => '0');
constant um : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
signal entradaB_ULA_inv : std_logic_vector((instructWidth-1) downto 0);
signal vai_1_all, saidaULA : std_logic_vector((instructWidth-1) downto 0);
signal saidaULA_final, saida_lui, saida_ext, result_slt : std_logic_vector(31 downto 0);
signal overflow_slt : std_logic;

begin

		  -- inverte a entrada B da ULA e soma 1 para os casos em que
		  -- ULActrl seleciona a inversao de B
        inverte_B : entity work.somador generic map(larguraDados => instructWidth)
                                       port map(entradaA => (not entradaB),
                                                entradaB => um,
                                                saida => entradaB_ULA_inv);

		  -- ULA bit a bit
        ULA_bit0   : entity work.ULA port map (entradaA => entradaA(0),
                                               entradaB => entradaB(0),
                                               seletor => ULActrl,
                                               vem_1 => '0',
											   vai_1 => vai_1_all(0),
                                               saida => saidaULA(0),
                                               entradaB_inv => entradaB_ULA_inv(0));

        ULA_bit1   : entity work.ULA port map (entradaA => entradaA(1),
                                                entradaB => entradaB(1),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(0),
                                                vai_1 => vai_1_all(1),
                                                saida => saidaULA(1),
                                                entradaB_inv => entradaB_ULA_inv(1));

        ULA_bit2   : entity work.ULA port map (entradaA => entradaA(2),
                                                entradaB => entradaB(2),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(1),
                                                vai_1 => vai_1_all(2),
                                                saida => saidaULA(2),
                                                entradaB_inv => entradaB_ULA_inv(2));
                                                
        ULA_bit3   : entity work.ULA port map (entradaA => entradaA(3),
                                                entradaB => entradaB(3),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(2),
                                                vai_1 => vai_1_all(3),
                                                saida => saidaULA(3),
                                                entradaB_inv => entradaB_ULA_inv(3));

        ULA_bit4   : entity work.ULA port map (entradaA => entradaA(4),
                                                entradaB => entradaB(4),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(3),
                                                vai_1 => vai_1_all(4),
                                                saida => saidaULA(4),
                                                entradaB_inv => entradaB_ULA_inv(4));

        ULA_bit5   : entity work.ULA port map (entradaA => entradaA(5),
                                                entradaB => entradaB(5),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(4),
                                                vai_1 => vai_1_all(5),
                                                saida => saidaULA(5),
                                                entradaB_inv => entradaB_ULA_inv(5));

        ULA_bit6   : entity work.ULA port map (entradaA => entradaA(6),
                                                entradaB => entradaB(6),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(5),
                                                vai_1 => vai_1_all(6),
                                                saida => saidaULA(6),
                                                entradaB_inv => entradaB_ULA_inv(6));

        ULA_bit7   : entity work.ULA port map (entradaA => entradaA(7),
                                                entradaB => entradaB(7),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(6),
                                                vai_1 => vai_1_all(7),
                                                saida => saidaULA(7),
                                                entradaB_inv => entradaB_ULA_inv(7));

        ULA_bit8   : entity work.ULA port map (entradaA => entradaA(8),
                                                entradaB => entradaB(8),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(7),
                                                vai_1 => vai_1_all(8),
                                                saida => saidaULA(8),
                                                entradaB_inv => entradaB_ULA_inv(8));

        ULA_bit9   : entity work.ULA port map (entradaA => entradaA(9),
                                                entradaB => entradaB(9),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(8),
                                                vai_1 => vai_1_all(9),
                                                saida => saidaULA(9),
                                                entradaB_inv => entradaB_ULA_inv(9));

        ULA_bit10   : entity work.ULA port map (entradaA => entradaA(10),
                                                entradaB => entradaB(10),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(9),
                                                vai_1 => vai_1_all(10),
                                                saida => saidaULA(10),
                                                entradaB_inv => entradaB_ULA_inv(10));

        ULA_bit11   : entity work.ULA port map (entradaA => entradaA(11),
                                                entradaB => entradaB(11),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(10),
                                                vai_1 => vai_1_all(11),
                                                saida => saidaULA(11),
                                                entradaB_inv => entradaB_ULA_inv(11));

        ULA_bit12   : entity work.ULA port map (entradaA => entradaA(12),
                                                entradaB => entradaB(12),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(11),
                                                vai_1 => vai_1_all(12),
                                                saida => saidaULA(12),
                                                entradaB_inv => entradaB_ULA_inv(12));

        ULA_bit13   : entity work.ULA port map (entradaA => entradaA(13),
                                                entradaB => entradaB(13),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(12),
                                                vai_1 => vai_1_all(13),
                                                saida => saidaULA(13),
                                                entradaB_inv => entradaB_ULA_inv(13));

        ULA_bit14   : entity work.ULA port map (entradaA => entradaA(14),
                                                entradaB => entradaB(14),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(13),
                                                vai_1 => vai_1_all(14),
                                                saida => saidaULA(14),
                                                entradaB_inv => entradaB_ULA_inv(14));
                                                
        ULA_bit15   : entity work.ULA port map (entradaA => entradaA(15),
                                                entradaB => entradaB(15),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(14),
                                                vai_1 => vai_1_all(15),
                                                saida => saidaULA(15),
                                                entradaB_inv => entradaB_ULA_inv(15));
                                                
        ULA_bit16   : entity work.ULA port map (entradaA => entradaA(16),
                                                entradaB => entradaB(16),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(15),
                                                vai_1 => vai_1_all(16),
                                                saida => saidaULA(16),
                                                entradaB_inv => entradaB_ULA_inv(16));
                                                
        ULA_bit17   : entity work.ULA port map (entradaA => entradaA(17),
                                                entradaB => entradaB(17),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(16),
                                                vai_1 => vai_1_all(17),
                                                saida => saidaULA(17),
                                                entradaB_inv => entradaB_ULA_inv(17));

        ULA_bit18   : entity work.ULA port map (entradaA => entradaA(18),
                                                entradaB => entradaB(18),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(17),
                                                vai_1 => vai_1_all(18),
                                                saida => saidaULA(18),
                                                entradaB_inv => entradaB_ULA_inv(18));

        ULA_bit19   : entity work.ULA port map (entradaA => entradaA(19),
                                                entradaB => entradaB(19),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(18),
                                                vai_1 => vai_1_all(19),
                                                saida => saidaULA(19),
                                                entradaB_inv => entradaB_ULA_inv(19));

        ULA_bit20   : entity work.ULA port map (entradaA => entradaA(20),
                                                entradaB => entradaB(20),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(19),
                                                vai_1 => vai_1_all(20),
                                                saida => saidaULA(20),
                                                entradaB_inv => entradaB_ULA_inv(20));

        ULA_bit21   : entity work.ULA port map (entradaA => entradaA(21),
                                                entradaB => entradaB(21),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(20),
                                                vai_1 => vai_1_all(21),
                                                saida => saidaULA(21),
                                                entradaB_inv => entradaB_ULA_inv(21));

        ULA_bit22   : entity work.ULA port map (entradaA => entradaA(22),
                                                entradaB => entradaB(22),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(21),
                                                vai_1 => vai_1_all(22),
                                                saida => saidaULA(22),
                                                entradaB_inv => entradaB_ULA_inv(22));
                                                
        ULA_bit23   : entity work.ULA port map (entradaA => entradaA(23),
                                                entradaB => entradaB(23),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(22),
                                                vai_1 => vai_1_all(23),
                                                saida => saidaULA(23),
                                                entradaB_inv => entradaB_ULA_inv(23));

        ULA_bit24   : entity work.ULA port map (entradaA => entradaA(24),
                                                entradaB => entradaB(24),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(23),
                                                vai_1 => vai_1_all(24),
                                                saida => saidaULA(24),
                                                entradaB_inv => entradaB_ULA_inv(24));
                                                
        ULA_bit25   : entity work.ULA port map (entradaA => entradaA(25),
                                                entradaB => entradaB(25),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(24),
                                                vai_1 => vai_1_all(25),
                                                saida => saidaULA(25),
                                                entradaB_inv => entradaB_ULA_inv(25));
                                                
        ULA_bit26   : entity work.ULA port map (entradaA => entradaA(26),
                                                entradaB => entradaB(26),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(25),
                                                vai_1 => vai_1_all(26),
                                                saida => saidaULA(26),
                                                entradaB_inv => entradaB_ULA_inv(26));
                                                
        ULA_bit27   : entity work.ULA port map (entradaA => entradaA(27),
                                                entradaB => entradaB(27),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(26),
                                                vai_1 => vai_1_all(27),
                                                saida => saidaULA(27),
                                                entradaB_inv => entradaB_ULA_inv(27));

        ULA_bit28   : entity work.ULA port map (entradaA => entradaA(28),
                                                entradaB => entradaB(28),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(27),
                                                vai_1 => vai_1_all(28),
                                                saida => saidaULA(28),
                                                entradaB_inv => entradaB_ULA_inv(28));

        ULA_bit29   : entity work.ULA port map (entradaA => entradaA(29),
                                                entradaB => entradaB(29),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(28),
                                                vai_1 => vai_1_all(29),
                                                saida => saidaULA(29),
                                                entradaB_inv => entradaB_ULA_inv(29));

        ULA_bit30   : entity work.ULA port map (entradaA => entradaA(30),
                                                entradaB => entradaB(30),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(29),
                                                vai_1 => vai_1_all(30),
                                                saida => saidaULA(30),
                                                entradaB_inv => entradaB_ULA_inv(30));

        ULA_bit31   : entity work.ULA port map (entradaA => entradaA(31),
                                                entradaB => entradaB(31),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(30),
                                                vai_1 => vai_1_all(31),
                                                saida => saidaULA(31),
                                                entradaB_inv => entradaB_ULA_inv(31));
																
		-- Flag Zero da saida da ULA								
        flagZ <= '1' when unsigned(saidaULA) = unsigned(zero) else '0';
         
        -- saida de overflow da ULA
		overflow_slt <= vai_1_all(30) xor vai_1_all(31);
		  
		-- Sinal usado para o caso da instrucao selecionar SLT
		-- concatena 31 zeros com o xor da saida da ULA e o overflow
		result_slt <= "0000000000000000000000000000000" & (saidaULA(31) xor overflow_slt);
	

		 -- Salvando a saida da ULA como output do fluxo de dados
		 mSaidaULA <= result_slt when ULActrl = "111" else
                    saidaULA;
end;