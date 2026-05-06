library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dram_submodule is
end tb_dram_submodule;

architecture sim of tb_dram_submodule is

    -- Clock de 143 MHz (~7 ns)
    constant CLK_PERIOD : time := 7 ns;

    -- Sinais de entrada do DUT
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal wEn          : std_logic := '0';
    signal req          : std_logic := '0';

    -- Sinais de saída do DUT
    signal o_cas        : std_logic;
    signal o_ras        : std_logic;
    signal o_cs         : std_logic;
    signal o_we         : std_logic;
    signal ready        : std_logic;

begin

    -- Instanciação do módulo sob teste (DUT)
    dut : entity work.dram_submodule
        port map (
            clk          => clk,
            rst          => rst,
            wEn          => wEn,
            req          => req,
            o_cas        => o_cas,
            o_ras        => o_ras,
            o_cs         => o_cs,
            o_we         => o_we,
            ready        => ready
        );

    -- Geração de Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulo
    stimulus_process : process
    begin
        -- Reset inicial
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';

        -- Aguarda o fim da inicialização (os 100us simulados + precharge/refresh/LMR)
        report ">> Aguardando inicializacao (aprox 100us)...";
        wait until ready = '1';
        report ">> Inicializacao concluida. Sistema em estado READY.";
        wait for 5 * CLK_PERIOD;

        -- ==========================================
        -- Teste de Escrita
        -- ==========================================
        report ">> Iniciando operacao de ESCRITA...";
        wEn <= '1';
        req <= '1';
        
        wait for CLK_PERIOD;
        req <= '0'; -- Pulso de requisição (dura apenas 1 clock)

        -- Aguarda o controlador passar por todos os Waits e voltar para o Ready
        wait until ready = '1';
        report ">> Escrita concluida e linha fechada (Precharge).";
        wait for 5 * CLK_PERIOD;

        -- ==========================================
        -- Teste de Leitura
        -- ==========================================
        report ">> Iniciando operacao de LEITURA...";
        wEn <= '0';
        req <= '1';
        
        wait for CLK_PERIOD;
        req <= '0';

        -- Aguarda o controlador terminar a leitura
        wait until ready = '1';
        report ">> Leitura concluida.";
        wait for 5 * CLK_PERIOD;

        -- ==========================================
        -- Fim do Teste
        -- ==========================================
        assert false report "SIMULACAO FINALIZADA COM SUCESSO" severity note;
        wait;
    end process;

end sim;