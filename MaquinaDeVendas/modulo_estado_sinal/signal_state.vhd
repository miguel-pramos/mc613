-- Biblioteca 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade
entity signal_state is
	port(
		valor			: in std_logic_vector(10 down to 0);
		valor_suf	: out std_logic; 
		tem_troco	: out std_logic
	);
end signal_state;

-- Arquitetura
architecture Behavioral of signal_state is
	signal s_valor : signed(10 downto 0);
begin
	s_valor <= signed(valor);
	-- verifica se tem troco 
	tem_troco <= '1' when ( s_valor < 0) else '0';
	-- Verifica se alcançou o valor suficiente
	valor_suf <= '1' when (valor <= 0) else '0';
	end Behavioral;
	
	