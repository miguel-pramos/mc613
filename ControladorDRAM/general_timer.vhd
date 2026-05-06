library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity general_timer is
    port (
        clk : in std_logic;
        timer_on : in std_logic;
        max_ticks : in std_logic_vector(3 downto 0);
        timer_end : out std_logic
    );
end entity general_timer;

architecture behavioural of general_timer is
    signal ticks : integer range 0 to 15 := 0;
begin

    process (clk, timer_on, max_ticks)
    begin
        if timer_on = '0' then
            timer_end <= '0';
            ticks <= 0;
        elsif rising_edge(clk) then
            if ticks = unsigned(max_ticks) then
                timer_end <= '1';
            else
                timer_end <= '0';
                ticks <= ticks + 1;
            end if;
        end if;
    end process;

end behavioural;