library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fsm_dram_controller is
end tb_fsm_dram_controller;

architecture sim of tb_fsm_dram_controller is

    -- Configuração do Clock (143 MHz -> ~7 ns de período)
    constant CLK_PERIOD : time := 7 ns;

    -- Sinais de entrada para o DUT (Device Under Test)
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal wEn : std_logic := '0';
    signal req : std_logic := '0';
    signal general_timer_end : std_logic := '0';
    signal refresh_timer_end : std_logic := '0';

    -- Sinais de saída do DUT
    signal s_cas : std_logic;
    signal s_ras : std_logic;
    signal s_cs : std_logic;
    signal s_we : std_logic;
    signal ready : std_logic;
    signal timer_clocks : std_logic_vector(3 downto 0);
    signal general_timer_on : std_logic;

begin

    -- Instanciação do Módulo Sob Teste (DUT)
    dut : entity work.fsm_dram_controller
        port map(
            clk => clk,
            rst => rst,
            wEn => wEn,
            req => req,
            general_timer_end => general_timer_end,
            refresh_timer_end => refresh_timer_end,
            s_cas => s_cas,
            s_ras => s_ras,
            s_cs => s_cs,
            s_we => s_we,
            ready => ready,
            timer_clocks => timer_clocks,
            general_timer_on => general_timer_on
        );

    -- Geração do Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulos e Verificação
    stimulus_process : process
    begin
        -- ============================================================
        -- 1. FASE DE INICIALIZAÇÃO
        -- ============================================================
        report ">> Iniciando Simulacao: Reset do Sistema";
        rst <= '1';
        wait for 5 * CLK_PERIOD;
        rst <= '0';

        -- 1. Responde ao INIT_WAIT_TRP_INIT
        -- Espera a FSM terminar os 100us e ligar o timer pela primeira vez
        wait until general_timer_on = '1'; 
        wait for 3 * CLK_PERIOD;
        general_timer_end <= '1'; wait for CLK_PERIOD; general_timer_end <= '0';

        -- 2. Responde ao INIT_WAIT_TRC_1
        wait until general_timer_on = '0'; wait until general_timer_on = '1';
        wait for 9 * CLK_PERIOD;
        general_timer_end <= '1'; wait for CLK_PERIOD; general_timer_end <= '0';

        -- 3. Responde ao INIT_WAIT_TRC_2
        wait until general_timer_on = '0'; wait until general_timer_on = '1';
        wait for 9 * CLK_PERIOD;
        general_timer_end <= '1'; wait for CLK_PERIOD; general_timer_end <= '0';

        -- 4. Responde ao INIT_WAIT_TMRD
        wait until general_timer_on = '0'; wait until general_timer_on = '1';
        wait for 2 * CLK_PERIOD;
        general_timer_end <= '1'; wait for CLK_PERIOD; general_timer_end <= '0';

        -- Verifica se o sistema chegou no estado READY
        wait until ready = '1';
        report ">> Sistema Inicializado e READY!";

        -- ============================================================
        -- 2. FASE DE LEITURA
        -- ============================================================
        report ">> Teste: Requisicao de LEITURA";
        req <= '1';
        wEn <= '0';
        wait for CLK_PERIOD;
        req <= '0'; -- Derruba requisição (pulso)

        -- FSM foi para ACTIVATE -> WAIT_TRCD
        -- Simulamos o timer avisando que o tRCD passou
        wait for 4 * CLK_PERIOD;
        general_timer_end <= '1';
        wait for CLK_PERIOD;
        general_timer_end <= '0';

        -- FSM foi para READ_S -> WAIT_TCAS
        -- Simulamos o timer avisando que a Latência CAS passou
        wait for 4 * CLK_PERIOD;
        general_timer_end <= '1';
        wait for CLK_PERIOD;
        general_timer_end <= '0';

        -- FSM foi para PRECHARGE -> WAIT_TRP
        -- Simulamos o timer avisando que a linha foi fechada
        wait for 4 * CLK_PERIOD;
        general_timer_end <= '1';
        wait for CLK_PERIOD;
        general_timer_end <= '0';

        -- FSM deve voltar para READY
        wait until ready = '1';
        report ">> Leitura Concluida!";
        wait for 5 * CLK_PERIOD;

        -- ============================================================
        -- 3. FASE DE ESCRITA
        -- ============================================================
        report ">> Teste: Requisicao de ESCRITA";
        req <= '1';
        wEn <= '1';
        wait for CLK_PERIOD;
        req <= '0';

        -- WAIT_TRCD
        wait for 4 * CLK_PERIOD;
        general_timer_end <= '1';
        wait for CLK_PERIOD;
        general_timer_end <= '0';

        -- WRITE_S -> WAIT_TDPL (Tempo de estabilização do dado na escrita)
        wait for 3 * CLK_PERIOD;
        general_timer_end <= '1';
        wait for CLK_PERIOD;
        general_timer_end <= '0';

        -- PRECHARGE -> WAIT_TRP
        wait for 4 * CLK_PERIOD;
        general_timer_end <= '1';
        wait for CLK_PERIOD;
        general_timer_end <= '0';

        wait until ready = '1';
        report ">> Escrita Concluida!";
        wait for 5 * CLK_PERIOD;

        -- ============================================================
        -- FIM DA SIMULAÇÃO
        -- ============================================================
        report ">> Todos os testes executados com sucesso.";
        assert false report "SIMULACAO FINALIZADA" severity note;
        wait;
    end process;

end sim;