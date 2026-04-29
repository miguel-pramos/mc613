library ieee;
use ieee.std_logic_1164.all;

entity iface_fsm is
    port(
        clk           : in  std_logic;
        rst           : in  std_logic;
        switch_change : in  std_logic; 
        write_req     : in  std_logic; 
        ready         : in  std_logic; 
        req           : out std_logic; 
        enable_op     : out std_logic  
    );
end iface_fsm;

architecture behavioral of iface_fsm is
    type state_type is (S_READY, S_REQ_READ, S_REQ_WRITE, S_WAIT_READ, S_WAIT_WRITE);
    signal state, next_state : state_type;
begin

    -- Processo Sequencial
    process(clk, rst)
    begin
        if rst = '1' then
            state <= S_READY;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Processo Combinacional 
    process(state, write_req, switch_change, ready)
    begin
        -- Valores padrão 
        next_state <= state;
        req        <= '0';
        enable_op  <= '0';

        case state is
            when S_READY =>
                -- Prioridade: Se o endereço mudou e não é escrita, vai para Read.
                -- Importante: Só sai de READY se o controlador estiver pronto (ready = '1')
                if ready = '1' then
                    if switch_change = '1' then
                        if write_req = '1' then
                            next_state <= S_REQ_WRITE;
                        else
                            next_state <= S_REQ_READ;
                        end if;
                    end if;
                end if;

            when S_REQ_READ =>
                req <= '1';
                enable_op <= '0';
                next_state <= S_WAIT_READ;

            when S_REQ_WRITE =>
                req <= '1';
                enable_op <= '1';
                next_state <= S_WAIT_WRITE;

            when S_WAIT_READ =>
                req <= '1'; 
                enable_op <= '0';
                if ready = '1' then
                    next_state <= S_READY;
                else
                    next_state <= S_WAIT_READ;
                end if;

            when S_WAIT_WRITE =>
                req <= '1';
                enable_op <= '1';
                if ready = '1' then
                    next_state <= S_READY;
                else
                    next_state <= S_WAIT_WRITE;
                end if;

            when others =>
                next_state <= S_READY;
        end case;
    end process;

end behavioral;