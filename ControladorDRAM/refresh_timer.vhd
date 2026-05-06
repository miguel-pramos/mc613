library ieee;
use ieee.std_logic_1644.all;
use ieee.numeric_std.all;

entity refresh_timer is
    port (
        clk : in std_logic;
        timer_on : in std_logic;
        timer_end : out std_logic
    );
end entity refresh_timer;

architecture behavioural of refresh_timer is
    signal ticks : integer range 0 to 1116 := 0;
begin

    process (clk, timer_on)
    begin
        if timer_on = '0' then
            timer_end <= '0';
            ticks <= 0;
        elsif rising_edge(clk) then
            if ticks > 1040  then
                timer_end <= '1';
            else
                timer_end <= '0';
                ticks <= ticks + 1;
            end if;
        end if;
    end process;

end behavioural;