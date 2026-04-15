library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sprt_movement_tb is
end sprt_movement_tb;

architecture sim of sprt_movement_tb is
    -- Sinais de interface
    signal clk_vga_tb : std_logic := '0';
    signal v_sync_tb  : std_logic := '1';
    signal reset_tb   : std_logic := '0';
    signal pos_x_tb   : std_logic_vector(9 downto 0);
    signal pos_y_tb   : std_logic_vector(9 downto 0);

    -- Constantes de tempo
    constant clk_period : time := 40 ns; -- ~25 MHz
    -- No VGA real, o V_SYNC ocorre a cada 16.6ms. 
    -- Para a simulação não demorar séculos, vamos reduzir esse tempo.
    constant v_sync_period : time := 1 us; 

begin

    -- Instância do componente (DUT)
    UUT: entity work.sprt_movement
        port map (
            clk_vga => clk_vga_tb,
            v_sync  => v_sync_tb,
            reset   => reset_tb,
            pos_x   => pos_x_tb,
            pos_y   => pos_y_tb
        );

    -- Gerador de Clock (25 MHz)
    clk_process : process
    begin
        clk_vga_tb <= '0';
        wait for clk_period/2;
        clk_vga_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Gerador de V_SYNC (Simulando o fim de cada frame)
    -- O módulo detecta a borda de descida (1 -> 0)
    vsync_process : process
    begin
        v_sync_tb <= '1';
        wait for v_sync_period * 0.9; 
        v_sync_tb <= '0'; -- Pulso de sincronismo (borda de descida ativa o movimento)
        wait for v_sync_period * 0.1;
    end process;

    -- Processo de Estímulos
    stim_proc: process
    begin
        -- Reset inicial
        reset_tb <= '1';
        wait for 100 ns;
        reset_tb <= '0';
        
        -- Deixamos a simulação rodar por tempo suficiente para ver o movimento.
        -- Como X_MAX é 608 e a posição inicial é 100, precisamos de 
        -- pelo menos 508 "frames" para ver a colisão na direita.
        wait for 1 ms; 

        -- Se você quiser testar uma colisão específica rapidamente, 
        -- pode forçar valores no sinal interno via script de simulação 
        -- ou apenas deixar rodar como um teste de estresse.

        assert false report "Fim da simulação (não é um erro)" severity note;
        wait;
    end process;

end sim;