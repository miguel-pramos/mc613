--Biblioteca
library ieee;
use ieee.std_logic_1164.all;

-- Entidade
entity mod11 is
	port(
		valor		: in std_logic_vector(10 downto 0);
		modulo	: out std_logic_vector(10 downto 0);
	);
end mod11;

-- Arquitetura
architecture Behavioral of mod is
begin
	modulo <= std_logic_vector(-signed(valor)) when (signed(entrada) < 0) else valor
end Behavioral;
	