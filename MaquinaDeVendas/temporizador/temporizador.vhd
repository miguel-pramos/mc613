library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
	Port(
		--Entrada de 4 bits--
		timer_on    : in std_logic;
        clk         : in std_logic;
		timer_end	: out std_logic
	);
end entity timer;


begin behavioural of timer is
    signal ticks : integer range 0 to 50_000_000; -- 1 segundo depois de 50_000_000 contagens de clock a 50MHz

process(clk)
begin
    if timer_on = '0' then
        timer_end <= '0';
        ticks <= '0';
    elsif rising_edge(clk) then 
        if ticks = 50_000_000 then 
            timer_end <= '1';
        else
            timer_end <= '0';
            ticks <= ticks + 1; 
        end if;
    end if;
end process;

end behavioural;