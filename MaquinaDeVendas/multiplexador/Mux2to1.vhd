-- Bibliotecas
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_numeric_std.all;

-- Entidade
entity Mux2to1 is
	port(
		valor,modulo: in std_logic_vector(10 down to 0);  
		S				: in std_logic; 
		X				: out std_logic_vector(10 down to 0));
	end Mux2to1;
	
-- Arquitetura
architecture Behavioral of Mux2to1 is
begin
	X <= valor when (S = '0') else modulo;
	end Behavioral;