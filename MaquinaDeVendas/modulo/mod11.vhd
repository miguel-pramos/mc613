--Biblioteca
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade
entity mod11 is
	port(
		valor		: in std_logic_vector(10 downto 0);
		modulo	: out std_logic_vector(10 downto 0)
	);
end mod11;

-- Arquitetura
architecture Behavioral of mod11 is
begin
	modulo <= std_logic_vector(-signed(valor)) when (signed(valor) < 0) else valor;
end Behavioral;
	