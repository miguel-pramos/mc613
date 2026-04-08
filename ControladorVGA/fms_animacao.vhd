library ieee;
use ieee.std_logic_1164.all;
-- Entidade --
entity fsm_animation is
    port (
        clk         : in  std_logic;
        reset     : in  std_logic;
        tick_timer  : in  std_logic;
        pos_enable  : out std_logic
    );
end fsm_animation;


-- Arquitetura -- 
architecture mealy of fsm_animation is
    type state_type is (IDLE, UPDATE);
    signal state, next_state : state_type;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
	-- Alterna entre os dois estados -- 
    process(state, tick_timer)
    begin
        next_state <= state;
        pos_enable <= '0';

        case state is
            when IDLE =>
                if tick_timer = '1' then
                    next_state <= UPDATE;
                    pos_enable <= '1'; 
                end if;

            when UPDATE =>
                next_state <= IDLE;
        end case;
    end process;
end mealy;