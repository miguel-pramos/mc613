library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_dram_controller is
    port (
        -- Entradas --
        clk : in std_logic;
        rst;
        in std_logic;
        write_enable : in std_logic;
        req : in std_logic;
        general_timer_end : in std_logic;
        refresh_timer_end : in std_logic;

        -- Saidas --
        s_cas : out std_logic;
        s_ras : out std_logic;
        s_cs : out std_logic;
        s_we : out std_logic;
        ready : out std_logic;

        timer_clocks : out std_logic_vector(3 downto 0);
        general_timer_on : out std_logic;

    );
end fsm_dram_controller;

architecture Behavioural of fsm_dram_controller is
    type state_type is (INIT, -- QUEBRAR EM MAIS ESTADOS!!! 
        READY, ACTIVATE, READ_S, WRITE_S, PRECHARGE,
        REFRESH, WAIT_TRCD, WAIT_TCAS, WAIT_TDPL, WAIT_TRP, WAIT_TRC);
    signal state, next_state : state_type;

begin
    process (clk, rst)
    begin
        if rst = '1' then
            state <= INIT;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process (state, write_enable, req, timer_end, refresh_timer_end)
    begin
        case state is
            when READY =>
                if refresh_timer_end = '1' then
                    next_state <= REFRESH;
                elsif req = '1' then
                    next_state <= ACTIVATE;
                else
                    next_state <= READY;
                end if

                general_timer_on <= '0';
                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when ACTIVATE =>
                next_state <= WAIT_TRCD;

                general_timer_on <= '0';
                s_ras <= '0';
                s_cas <= '1';
                s_we <= '1';

            when READ_S =>
                next_state <= WAIT_TCAS;

                general_timer_on <= '0';
                s_ras <= '1';
                s_cas <= '0';
                s_we <= '1';

            when WRITE_S =>
                next_state <= WAIT_TDPL;

                general_timer_on <= '0';
                s_ras <= '1';
                s_cas <= '0';
                s_we <= '0';

            when PRECHARGE =>
                next_state <= WAIT_TRP;

                general_timer_on <= '0';
                s_ras <= '0';
                s_cas <= '1';
                s_we <= '0';

            when REFRESH =>
                next_state <= WAIT_TRC;

                general_timer_on <= '0';
                s_ras <= '0';
                s_cas <= '0';
                s_we <= '1';

            when WAIT_TRCD =>
                if general_timer_end = '1' then
                    if write_enable = '1' then
                        next_state <= WRITE_S;
                    else
                        next_state <= READ_S;
                    end if
                else
                    next_state <= WAIT_TRCD;
                end if

                timer_clocks <= std_logic_vector(to_unsigned(3, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TCAS =>
                if general_timer_end = '1' then
                    next_state <= PRECHARGE;
                else
                    next_state <= WAIT_TCAS;
                end if

                timer_clocks <= std_logic_vector(to_unsigned(3, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TDLP =>
                if general_timer_end = '1' then
                    next_state <= PRECHARGE;
                else
                    next_state <= WAIT_TDLP;
                end if

                timer_clocks <= std_logic_vector(to_unsigned(2, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TRP =>
                if general_timer_end = '1' then
                    next_state <= READY;
                else
                    next_state <= WAIT_TRP;
                end if

                timer_clocks <= std_logic_vector(to_unsigned(3, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TRC =>
                if general_timer_end = '1' then
                    next_state <= READY;
                else
                    next_state <= WAIT_TRC;
                end if

                timer_clocks <= std_logic_vector(to_unsigned(9, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when others =>
                next_state <= INIT;

        end case;
    end process;

    s_cs <= '1';
    ready <= '1' when state = READY else
             '0';
end Behavioural;