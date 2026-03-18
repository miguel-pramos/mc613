-- Biblioteca
library ieee;
use ieee.std_logic_1164.all;

-- Entidade
entity reg11 is
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		enable	: in std_logic;
		D			: in std_logic_vector(10 downto 0);
		Q			: out std_logic_vector(10 downto 0)
	);
end entity reg11;

-- Arquitetura
architecture rtl of reg11 is
	signal Q_reg : std_logic_vector(10 downto 0);
begin
	process(clk, reset)
	begin
		if reset = '1' then
			Q_reg <= (others => '0');
		elsif clk'event and clk = '1' then
			if enable = '1' then
				Q_reg <= D;
			end if;
		end if;
	end process;
	
	Q <= Q_reg;
end architecture rtl;