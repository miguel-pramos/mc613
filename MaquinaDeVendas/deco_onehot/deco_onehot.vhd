library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity deco_onehot is
	Port(
		--Entrada de 4 bits--
		prod	: in std_logic_vector(3 downto 0);
		
		price	: out std_logic_vector(10 downto 0)
	);
end entity deco_onehot;

architecture Behavioral of deco_onehot is
begin
	
	-- Seletor de preços --
	with prod select
			  price <= 
					std_logic_vector(to_unsigned(125, 11)) when x"0", -- Produto 0: R$ 1,25
					std_logic_vector(to_unsigned(300, 11)) when x"1", -- Produto 1: R$ 3,00
					std_logic_vector(to_unsigned(175, 11)) when x"2", -- Produto 2: R$ 1,75
					std_logic_vector(to_unsigned(450, 11)) when x"3", -- Produto 3: R$ 4,50
					std_logic_vector(to_unsigned(225, 11)) when x"4", -- Produto 4: R$ 2,25
					std_logic_vector(to_unsigned(350, 11)) when x"5", -- Produto 5: R$ 3,50
					std_logic_vector(to_unsigned(250, 11)) when x"6", -- Produto 6: R$ 2,50
					std_logic_vector(to_unsigned(425, 11)) when x"7", -- Produto 7: R$ 4,25
					std_logic_vector(to_unsigned(500, 11)) when x"8", -- Produto 8: R$ 5,00
					std_logic_vector(to_unsigned(325, 11)) when x"9", -- Produto 9: R$ 3,25
					std_logic_vector(to_unsigned(600, 11)) when x"A", -- Produto A: R$ 6,00
					std_logic_vector(to_unsigned(275, 11)) when x"B", -- Produto B: R$ 2,75
					std_logic_vector(to_unsigned(700, 11)) when x"C", -- Produto C: R$ 7,00
					std_logic_vector(to_unsigned(475, 11)) when x"D", -- Produto D: R$ 4,75
					std_logic_vector(to_unsigned(525, 11)) when x"E", -- Produto E: R$ 5,25
					std_logic_vector(to_unsigned(800, 11)) when x"F", -- Produto F: R$ 8,00
					(others => '0') when others;

end architecture Behavioral;