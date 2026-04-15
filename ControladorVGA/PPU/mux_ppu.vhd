library ieee;
use ieee.std_logic_1164.all;

-- Entidade
entity mux_ppu is
	port(
		-- Entradas --
		clk: in std_logic;
		red : in std_logic_vector(7 downto 0);
		green: in std_logic_vector(7 downto 0);
		blue: in std_logic_vector(7 downto 0);
		video_active: in std_logic;
		-- Saidas
		vga_red: out std_logic_vector(7 downto 0);
		vga_green: out std_logic_vector(7 downto 0);
		vga_blue: out std_logic_vector(7 downto 0)
	);
end mux_ppu;

architecture behavioral of mux_ppu is
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			if video_active = '1' then
				vga_red <= red;
				vga_blue <= blue;
				vga_green <= green;
			else
				vga_red <= (others => '0');
				vga_blue <= (others => '0');
				vga_green <= (others => '0');
			end if;
		end if;
	end process;
end behavioral;

	
