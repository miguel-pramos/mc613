library ieee;
use ieee.std_logic_1164.all;

entity fsm_control_tb is
end fsm_control_tb;

architecture sim of fsm_control_tb is
    -- Sinais de Relógio e Reset
    signal clk          : std_logic := '0';
    signal reset      : std_logic := '0';
    
    -- Sinais de Estímulo
    signal tick_timer   : std_logic := '0';
    signal key_signal   : std_logic := '0';
    
    -- Sinais de Saída das FSMs
    signal pos_enable   : std_logic;
    signal bg_tile      : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz (Clock padrão da DE1-SoC)

begin

    -- 1. Instância da FSM de Animação (Mealy)
    uut_anim: entity work.fsm_animation
        port map (
            clk        => clk,
            reset    => reset,
            tick_timer => tick_timer,
            pos_enable => pos_enable
        );

    -- 2. Instância da FSM de Interface (Moore)
    uut_inter: entity work.fsm_interface
        port map (
            clk        => clk,
            reset    => reset,
            key_signal => key_signal,
            bg_tile    => bg_tile
        );

    -- Gerador de Clock
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Processo de Estímulos
    stim_proc: process
    begin
        -- Estado Inicial (Reset)
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- --- Teste da FSM de Animação (Mealy) ---
        -- Simula o temporizador disparando um pulso
        wait until falling_edge(clk);
        tick_timer <= '1'; 
        wait for CLK_PERIOD;
        tick_timer <= '0';
        
        wait for 40 ns;

        -- --- Teste da FSM de Interface (Moore) ---
        -- Simula o usuário apertando o botão KEY0
        -- (Lembrando que key_signal deve ser um pulso vindo de um detector de borda)
        wait until falling_edge(clk);
        key_signal <= '1';
        wait for CLK_PERIOD;
        key_signal <= '0';
        
        wait for 40 ns;

        -- Aperta o botão novamente para voltar ao padrão original
        key_signal <= '1';
        wait for CLK_PERIOD;
        key_signal <= '0';

        wait for 10 ns;
        assert false report "Fim da simulação" severity note;
        wait;
    end process;

end sim;