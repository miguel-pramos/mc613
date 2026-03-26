library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temporizador_tb is
end entity temporizador_tb;

architecture tb of temporizador_tb is

	-- sinais de estímulo/observação
	signal clk_s       : std_logic := '0';
	signal timer_on_s  : std_logic := '0';
	signal timer_end_s : std_logic;

	constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

begin

	-- DUT
	dut: entity work.timer
		port map (
			timer_on  => timer_on_s,
			clk       => clk_s,
			timer_end => timer_end_s
		);

	-- geração de clock
	clk_process : process
	begin
		while true loop
			clk_s <= '0';
			wait for CLK_PERIOD/2;
			clk_s <= '1';
			wait for CLK_PERIOD/2;
		end loop;
		wait;
	end process;

	stim_proc : process
	begin
		-- início com timer desligado
		timer_on_s <= '0';
		wait for 200 ns;

		-- liga o timer
		timer_on_s <= '1';

		wait for 1 sec + 100 ms;

		-- desliga o timer
		timer_on_s <= '0';
		wait for 200 ns;
        
		wait;
	end process;

end architecture tb;

