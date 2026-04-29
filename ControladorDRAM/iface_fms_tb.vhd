library ieee;
use ieee.std_logic_1164.all;

entity tb_iface_fsm is
end tb_iface_fsm;

architecture sim of tb_iface_fsm is
    -- Sinais para conectar na UUT (Unit Under Test)
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '0';
    signal switch_change : std_logic := '0';
    signal write_req     : std_logic := '0';
    signal ready         : std_logic := '1'; -- Começa pronto
    signal req           : std_logic;
    signal enable_op     : std_logic;

    -- Configuração do Clock (Ex: 100MHz -> 10ns de período)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanciação da FSM
    uut: entity work.iface_fsm
        port map (
            clk           => clk,
            rst           => rst,
            switch_change => switch_change,
            write_req     => write_req,
            ready         => ready,
            req           => req,
            enable_op     => enable_op
        );

    -- Geração do Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Processo de Estímulo
    stim_proc: process
    begin		
        -- 1. Reset do Sistema
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- --- TESTE 1: Operação de LEITURA ---
        -- Simula mudança de endereço (switch_change) para leitura (write_req=0)
        switch_change <= '1';
        write_req     <= '0';
        wait for CLK_PERIOD;
        switch_change <= '0'; -- Pulso de mudança termina

        -- Espera a FSM pedir REQ
        wait until req = '1';
        -- Simula o Controller ocupado (baixando ready após o pedido)
        wait for CLK_PERIOD;
        ready <= '0'; 
        
        -- Simula latência da DRAM (espera 50ns)
        wait for 50 ns;
        ready <= '1'; -- Dado pronto! (Data Valid)
        
        -- Espera a FSM voltar para READY
        wait for 20 ns;

        -- --- TESTE 2: Operação de ESCRITA ---
        switch_change <= '1';
        write_req     <= '1';
        wait for CLK_PERIOD;
        switch_change <= '0';
        write_req     <= '0';

        wait until req = '1';
        ready <= '0'; -- Controller começou a escrever
        
        wait for 30 ns;
        ready <= '1'; -- Escrita finalizada
        
        wait for 20 ns;

        -- --- TESTE 3: Tentativa de operação com Controller ocupado ---
        -- Se o controlador estiver em REFRESH (ready=0), a FSM não deve sair de S_READY
        ready <= '0'; 
        wait for 20 ns;
        switch_change <= '1';
        wait for 20 ns;
        
        -- Aqui você deve verificar no waveform que req continua '0'
        switch_change <= '0';
        
        wait for 20 ns;
        ready <= '1'; -- Liberou o controlador
        -- Agora ela deve reconhecer o switch_change se ele ainda estiver alto, 
        -- ou aguardar o próximo pulso.
        
        wait for 100 ns;
        assert false report "Fim da simulação" severity note;
        wait;
    end process;

end sim;