library ieee;
use ieee.std_logic_1164.all;

entity fsm_interface is
    port (
        clk         : in  std_logic;
        reset     : in  std_logic;
        key_signal  : in  std_logic;
        bg_tile     : out std_logic
    );
end fsm_interface;

architecture behavioural of fsm_interface is
    type state_type is (TILE_A, TILE_B);
    signal state, next_state : state_type;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= TILE_A;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, key_signal)
    begin
        next_state <= state;
        bg_tile <= '0';

        case state is
            when TILE_A =>
                bg_tile <= '0';
                if key_signal = '1' then
                    next_state <= TILE_B;
                end if;

            when TILE_B =>
                bg_tile <= '1';
                if key_signal = '1' then
                    next_state <= TILE_A;
                end if;
        end case;
    end process;

end behavioural;