-- Biblioteca
library ieee;
use ieee.std_logic_1164.all;

-- Entidade 
entity sub11 is
	port(
		valor_atual		: in std_logic_vector(10 downto 0);
		valor_add		: in std_logic_vector(10 downto 0);
		valor_final		: out std_logic_vector(10 downto 0)
	);
end sub11;

-- Arquitetura
architecture behavioral of subtractor11 is
begin  
	valor_final <= std_logic_vector( signed(valor_atual) - signed(valor_add) );
end behavioral;
