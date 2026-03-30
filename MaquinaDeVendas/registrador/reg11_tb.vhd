library ieee;
use ieee.std_logic_1164.all;

entity reg11_tb is
end entity reg11_tb;

architecture sim of reg11_tb is
    -- Sinais
    signal clk_tb    : std_logic := '0';
    signal reset_tb  : std_logic := '0';
    signal enable_tb : std_logic := '0';
    signal D_tb      : std_logic_vector(10 downto 0) := (others => '0');
    signal Q_tb      : std_logic_vector(10 downto 0);

    -- Constante de tempo do Clock (50MHz)
    constant CLK_PERIOD : time := 20 ns;
begin

    -- Instanciação do DUT (Device Under Test)
    dut: entity work.reg11
        port map(
            clk    => clk_tb,
            reset  => reset_tb,
            enable => enable_tb,
            D      => D_tb,
            Q      => Q_tb
        );

    -- Geração do Clock
    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulos
    stim_process: process
    begin
        -- Teste 1: Reset inicial
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';

        -- Teste 2: Tenta escrever com enable DESLIGADO (Q deve se manter em 0)
        D_tb <= "10101010101";
        enable_tb <= '0';
        wait for CLK_PERIOD * 2;

        -- Teste 3: Tenta escrever com enable LIGADO (Q deve atualizar na borda)
        enable_tb <= '1';
        wait for CLK_PERIOD;
        
        -- Teste 4: Muda o dado com enable LIGADO
        D_tb <= "01010101010";
        wait for CLK_PERIOD;

        -- Teste 5: Desliga o enable e muda o dado (Q deve manter o valor antigo)
        enable_tb <= '0';
        D_tb <= "11111111111";
        wait for CLK_PERIOD * 2;

        -- Teste 6: Reset síncrono/assíncrono
        reset_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '0';

        wait; -- Finaliza simulação
    end process;
end architecture sim;