library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_dram_controller is
    port (
        -- Entradas --
        clk : in std_logic;
        rst : in std_logic;
        wEn : in std_logic;
        req : in std_logic;
        general_timer_end : in std_logic;
        refresh_timer_end : in std_logic;

        -- Saidas --
        s_cas : out std_logic;
        s_ras : out std_logic;
        s_cs : out std_logic;
        s_we : out std_logic;
        ready : out std_logic;
        latch_data : out std_logic;

        timer_clocks : out std_logic_vector(3 downto 0);
        general_timer_on : out std_logic;
        s_addr_sel : out std_logic 
    
    );
end fsm_dram_controller;

architecture Behavioural of fsm_dram_controller is
    type state_type is (
        -- Estados de Inicialização
        INIT_WAIT_100US, INIT_PRECHARGE, INIT_WAIT_TRP_INIT,
        INIT_REFRESH_1, INIT_WAIT_TRC_1,
        INIT_REFRESH_2, INIT_WAIT_TRC_2,
        INIT_LOAD_MODE, INIT_WAIT_TMRD,
        -- Estados de Operação Normal
        READY_S, ACTIVATE, READ_S, WRITE_S, PRECHARGE,
        REFRESH, WAIT_TRCD, WAIT_TCAS, WAIT_TDPL, WAIT_TRP, WAIT_TRC
    );

    signal state, next_state : state_type;
    signal init_counter : integer range 0 to 14300 := 0;
begin
    process (clk, rst)
    begin
        if rst = '1' then
            state <= INIT_WAIT_100US;
            init_counter <= 0;
        elsif rising_edge(clk) then
            state <= next_state;

            -- Lógica do contador de 100us
            if state = INIT_WAIT_100US then
                if init_counter < 14300 then
                    init_counter <= init_counter + 1;
                end if;
            else
                init_counter <= 0;
            end if;
        end if;
    end process;

    process (state, wEn, req, general_timer_end, refresh_timer_end, init_counter)
    begin
        next_state <= state;
        general_timer_on <= '0';
        timer_clocks <= (others => '0');
        s_ras <= '1';
        s_cas <= '1';
        s_we <= '1';
        s_addr_sel <= '0';
        latch_data <= '0';
        case state is
                -- ==========================================
                -- SEQUÊNCIA DE INICIALIZAÇÃO
                -- ==========================================
            when INIT_WAIT_100US =>
                -- Aguarda 14300 ciclos de clock (100us a 50MHz)
                if init_counter >= 14300 then
                    next_state <= INIT_PRECHARGE;
                end if;

            when INIT_PRECHARGE =>
                next_state <= INIT_WAIT_TRP_INIT;
                s_ras <= '0';
                s_cas <= '1';
                s_we <= '0'; -- Cmd: PRECHARGE ALL

            when INIT_WAIT_TRP_INIT =>
                if general_timer_end = '1' then
                    next_state <= INIT_REFRESH_1;
                end if;
                general_timer_on <= '1';
                timer_clocks <= std_logic_vector(to_unsigned(3, 4));

            when INIT_REFRESH_1 =>
                next_state <= INIT_WAIT_TRC_1;
                s_ras <= '0';
                s_cas <= '0';
                s_we <= '1'; -- Cmd: AUTO REFRESH

            when INIT_WAIT_TRC_1 =>
                if general_timer_end = '1' then
                    next_state <= INIT_REFRESH_2;
                end if;
                general_timer_on <= '1';
                timer_clocks <= std_logic_vector(to_unsigned(9, 4));

            when INIT_REFRESH_2 =>
                next_state <= INIT_WAIT_TRC_2;
                s_ras <= '0';
                s_cas <= '0';
                s_we <= '1'; -- Cmd: AUTO REFRESH

            when INIT_WAIT_TRC_2 =>
                if general_timer_end = '1' then
                    next_state <= INIT_LOAD_MODE;
                end if;
                general_timer_on <= '1';
                timer_clocks <= std_logic_vector(to_unsigned(9, 4));

            when INIT_LOAD_MODE =>
                next_state <= INIT_WAIT_TMRD;
                s_ras <= '0';
                s_cas <= '0';
                s_we <= '0'; -- Cmd: LOAD MODE REGISTER

            when INIT_WAIT_TMRD =>
                if general_timer_end = '1' then
                    next_state <= READY_S;
                end if;
                general_timer_on <= '1';
                timer_clocks <= std_logic_vector(to_unsigned(2, 4));

                -- MODO NORMAL DE OPERAÇÃO
            when READY_S =>
                if refresh_timer_end = '1' then
                    next_state <= REFRESH;
                elsif req = '1' then
                    next_state <= ACTIVATE;
                else
                    next_state <= READY_S;
                end if;

                general_timer_on <= '0';
                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when ACTIVATE =>
                next_state <= WAIT_TRCD;
                
                s_addr_sel <= '0'; 
                general_timer_on <= '0';
                s_ras <= '0';
                s_cas <= '1';
                s_we <= '1';

            when READ_S =>
                next_state <= WAIT_TCAS;
                
                latch_data <= '1';
                s_addr_sel <= '1';
                general_timer_on <= '0';
                s_ras <= '1';
                s_cas <= '0';
                s_we <= '1';

            when WRITE_S =>
                next_state <= WAIT_TDPL;

                s_addr_sel <= '1';
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
                    if wEn = '1' then
                        next_state <= WRITE_S;
                    else
                        next_state <= READ_S;
                    end if;
                else
                    next_state <= WAIT_TRCD;
                end if;

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
                end if;

                timer_clocks <= std_logic_vector(to_unsigned(3, 4));
                general_timer_on <= '1';
                
                s_addr_sel <= '1';
                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TDPL =>
                if general_timer_end = '1' then
                    next_state <= PRECHARGE;
                else
                    next_state <= WAIT_TDPL;
                end if;

                timer_clocks <= std_logic_vector(to_unsigned(2, 4));
                general_timer_on <= '1';
                
                s_addr_sel <= '1';
                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TRP =>
                if general_timer_end = '1' then
                    next_state <= READY_S;
                else
                    next_state <= WAIT_TRP;
                end if;

                timer_clocks <= std_logic_vector(to_unsigned(3, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when WAIT_TRC =>
                if general_timer_end = '1' then
                    next_state <= READY_S;
                else
                    next_state <= WAIT_TRC;
                end if;

                timer_clocks <= std_logic_vector(to_unsigned(9, 4));
                general_timer_on <= '1';

                s_ras <= '1';
                s_cas <= '1';
                s_we <= '1';

            when others =>
                next_state <= INIT_WAIT_100US;

        end case;
    end process;

    s_cs <= '0';
    ready <= '1' when state = READY_S else
             '0';

end Behavioural;