library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller_tb is
end vga_controller_tb;

architecture behavior of vga_controller_tb is

    -- Sinais para conectar ao componente sob teste (UUT)
    signal clk_50      : std_logic := '0';
    signal keys        : std_logic_vector(1 downto 0) := "11";
    
    signal vga_r       : std_logic_vector(7 downto 0);
    signal vga_g       : std_logic_vector(7 downto 0);
    signal vga_b       : std_logic_vector(7 downto 0);
    signal vga_blank_n : std_logic;
    signal vga_sync_n  : std_logic;
    signal vga_hs      : std_logic;
    signal vga_vs      : std_logic;
    signal vga_clk     : std_logic;

    -- Contadores para o monitor de vídeo
    signal frame_count : integer := 0;
    
    -- Constante de tempo do Clock (50 MHz)
    constant CLK_PERIOD : time := 20 ns; 

begin

    -- Instanciação do Controlador VGA
    uut: entity work.vga_controller
        port map (
            CLOCK_50    => clk_50,
            KEY         => keys,
            VGA_R       => vga_r,
            VGA_G       => vga_g,
            VGA_B       => vga_b,
            VGA_BLANK_N => vga_blank_n,
            VGA_SYNC_N  => vga_sync_n,
            VGA_HS      => vga_hs,
            VGA_VS      => vga_vs,
            VGA_CLK     => vga_clk
        );

    -- 1. Gerador de Clock de 50MHz
    clk_process : process
    begin
        clk_50 <= '0';
        wait for CLK_PERIOD/2;
        clk_50 <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 2. Processo Principal de Estímulos
    stim_proc: process
    begin
        report "========================================================";
        report " INICIANDO SUPER TESTBENCH - CONTROLADOR VGA & PPU      ";
        report "========================================================";
        
        -- TESTE 1: Reset do Sistema
        report "[TESTE 1] Iniciando Reset...";
        keys(0) <= '0'; -- Ativa reset (KEY(0) é invertido no código)
        wait for 100 ns;
        keys(0) <= '1';
        report "[TESTE 1] Reset Concluido. Aguardando estabilizacao do PLL (vga_clk)...";
        
        -- Espera o clock do VGA dar os primeiros pulsos
        wait until rising_edge(vga_clk);
        wait for 10 us;

        -- TESTE 2: FSM de Sprites (Atualizacao no V_SYNC)
        report "[TESTE 2] Aguardando o primeiro Fim de Frame (Borda de descida do V_SYNC)...";
        wait until falling_edge(vga_vs);
        report " >>> V_SYNC DETECTADO! A FSM de Sprites (0 a 3) e FSM de BG (0 a 511) devem iniciar AGORA.";
        report " >>> DICA WAVEFORM: Olhe os sinais 'sprt_we', 'bg_we' e 'bg_write_addr' neste instante de tempo.";
        
        wait for 1 ms; -- Visualiza um pedaço do blanking e ativação de vídeo
        
        -- TESTE 3: FSM de Background (Interface FSM)
        report "[TESTE 3] Testando FSM de Background (Botao KEY(1))...";
        keys(1) <= '0'; -- Pressiona o botão
        wait for 40 ns; -- Segura por 2 ciclos de clock
        keys(1) <= '1'; -- Solta o botão
        report " >>> Botao de Background pressionado. O sinal 'bg_tile_fsm' deve ter alternado.";
        
        -- TESTE 4: Movimentacao e Simulacao Longa
        report "[TESTE 4] Simulando varios frames para checar movimentacao dos Sprites (Bounce)...";
        
        -- Vamos esperar 3 frames completos para o objeto se mover algumas vezes
        for i in 1 to 3 loop
            wait until falling_edge(vga_vs);
            report " >>> Frame " & integer'image(i) & " concluido. Logo_x e Logo_y foram atualizados.";
        end loop;

        report "========================================================";
        report " SIMULACAO CONCLUIDA COM SUCESSO.                       ";
        report "========================================================";
        assert false report "Fim programado do Testbench." severity failure; -- Para a simulação
    end process;


    -- =======================================================================
    -- MONITORES DE PROTOCOLO E PPU (Verificam regras automaticamente)
    -- =======================================================================

    -- Monitor A: Regra de Ouro do VGA (Cores = 0 durante o Blanking)
    -- Se a PPU vazar cor fora da área ativa, o monitor real não funciona!
    vga_protocol_monitor: process(vga_clk)
    begin
        if rising_edge(vga_clk) then
            if vga_blank_n = '0' then
                -- Durante o blanking (HSYNC/VSYNC/Porches), RGB TEM que ser zero.
                if (vga_r /= "00000000") or (vga_g /= "00000000") or (vga_b /= "00000000") then
                    report "ERRO DE PROTOCOLO: A PPU esta vazando cores durante o Blanking!" severity error;
                end if;
            end if;
        end if;
    end process;

    -- Monitor B: Rastreador de Pixels Estranhos (Verdes/Lixo de Memória)
    -- Lembra dos pixels verdes? Esse bloco avisa se eles aparecerem na tela.
    ppu_color_monitor: process(vga_clk)
    begin
        if rising_edge(vga_clk) then
            -- Só avalia durante o vídeo ativo
            if vga_blank_n = '1' then
                -- Condição de Alerta: Verde no máximo e Vermelho zerado
                -- (Ajuste isso para a cor fantasma exata que você estava vendo)
                if (vga_g = "11111111") and (vga_r = "00000000") then
                    report "AVISO PPU: Pixel Fantasma Verde detectado na saida da Palette!" severity warning;
                end if;
            end if;
        end if;
    end process;

end behavior;