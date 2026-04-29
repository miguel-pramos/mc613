library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ppu_tb is
end ppu_tb;

architecture behavior of ppu_tb is

    -- =====================================================
    -- SINAIS GLOBAIS E DE CONTROLE
    -- =====================================================
    signal clk          : std_logic := '0';
    signal video_active : std_logic := '0';
    signal pixel_x      : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y      : std_logic_vector(9 downto 0) := (others => '0');

    -- =====================================================
    -- SINAIS DE ESCRITA (CPU / FSM)
    -- =====================================================
    -- OAM (Sprites)
    signal sprt_we      : std_logic := '0';
    signal oam_x        : std_logic_vector(9 downto 0) := (others => '0');
    signal oam_y        : std_logic_vector(9 downto 0) := (others => '0');
    signal sprite_sel   : std_logic_vector(1 downto 0) := "00";
    signal logo_x       : std_logic_vector(9 downto 0) := (others => '0');
    signal logo_y       : std_logic_vector(9 downto 0) := (others => '0');
    
    -- Background
    signal bg_we        : std_logic := '0';
    signal bg_write_addr: std_logic_vector(8 downto 0) := (others => '0');
    signal bg_tile_in   : std_logic := '0';

    -- =====================================================
    -- SINAIS INTERNOS DA PPU (Interligações)
    -- =====================================================
    signal oam_sprite_id   : std_logic_vector(2 downto 0);
    signal bg_tile_id      : std_logic;
    
    signal sprite_color_id : std_logic_vector(2 downto 0);
    signal bg_color_id     : std_logic_vector(2 downto 0);
    signal final_color_id  : std_logic_vector(1 downto 0);
    
    signal pal_red         : std_logic_vector(7 downto 0);
    signal pal_green       : std_logic_vector(7 downto 0);
    signal pal_blue        : std_logic_vector(7 downto 0);

    -- =====================================================
    -- SAÍDAS FINAIS (Vão para o Monitor)
    -- =====================================================
    signal vga_r : std_logic_vector(7 downto 0);
    signal vga_g : std_logic_vector(7 downto 0);
    signal vga_b : std_logic_vector(7 downto 0);

    -- Clock de 25 MHz (Periodo de 40ns)
    constant CLK_PERIOD : time := 40 ns;

begin

    -- 1. Gerador de Clock de Pixel
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- =====================================================
    -- INSTANCIAÇÃO DIRETA DOS COMPONENTES DA PPU
    -- =====================================================

    uut_oam : entity work.oam_memory
        port map(
            clk           => clk,
            we            => sprt_we,
            pixel_x       => pixel_x,
            pixel_y       => pixel_y,
            in_x          => oam_x,
            in_y          => oam_y,
            sprite_sel    => sprite_sel,
            in_id         => sprite_sel, -- Reutilizando o sel como ID para simplificar
            sprite_id_out => oam_sprite_id
        );

    uut_sprite_mem : entity work.sprite_memory
        port map(
            clk        => clk,
            sprite_id  => oam_sprite_id,
            pixel_x    => pixel_x,
            pixel_y    => pixel_y,
            sprite_x   => logo_x,
            sprite_y   => logo_y,
            bitmap_out => sprite_color_id
        );

    uut_bg_mem : entity work.memorybackground
        port map(
            clk         => clk,
            we          => bg_we,
            write_addr  => bg_write_addr,
            data_in     => bg_tile_in,
            pixel_x     => pixel_x,
            pixel_y     => pixel_y,
            tile_id_out => bg_tile_id
        );

    uut_tileset_bg : entity work.tileset_memory
        port map(
            tile_id  => bg_tile_id,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            color_id => bg_color_id
        );

    uut_layer_selector : entity work.layer_selector
        port map(
            color_bg     => bg_color_id,
            color_sprite => sprite_color_id,
            color_out    => final_color_id
        );

    uut_palette : entity work.palette_memory
        port map(
            id_color => final_color_id,
            red      => pal_red,
            green    => pal_green,
            blue     => pal_blue
        );

    uut_mux_ppu : entity work.mux_ppu
        port map(
            clk          => clk,
            video_active => video_active,
            red          => pal_red,
            green        => pal_green,
            blue         => pal_blue,
            vga_red      => vga_r,
            vga_green    => vga_g,
            vga_blue     => vga_b
        );

    -- =====================================================
    -- PROCESSO DE ESTÍMULOS (A "CPU" e a Varredura do Monitor)
    -- =====================================================
    stim_proc: process
    begin
        report "--- INICIANDO TESTE ISOLADO DA PPU ---";
        
        -- Passo 1: Preencher a OAM com um Sprite
        -- Vamos colocar o Sprite Pedaço 1 na coordenada (10, 10)
        report "[FASE 1] Gravando Sprite 0 na OAM...";
        wait for CLK_PERIOD;
        sprt_we    <= '1';
        sprite_sel <= "00";
        oam_x      <= std_logic_vector(to_unsigned(10, 10));
        oam_y      <= std_logic_vector(to_unsigned(10, 10));
        logo_x     <= std_logic_vector(to_unsigned(10, 10));
        logo_y     <= std_logic_vector(to_unsigned(10, 10));
        wait for CLK_PERIOD;
        sprt_we    <= '0';

        -- Passo 2: Preencher o Background (Tile 0 na origem)
        report "[FASE 1] Gravando Background no endereco 0...";
        bg_we         <= '1';
        bg_write_addr <= "000000000";
        bg_tile_in    <= '1';
        wait for CLK_PERIOD;
        bg_we         <= '0';

        -- Passo 3: Iniciar "Varredura" Virtual do Monitor
        -- Vamos varrer uma pequena janela da tela: X de 5 a 15, Y apenas na linha 10
        report "[FASE 2] Simulando varredura do feixe de eletrões (Scanner VGA)...";
        video_active <= '1';
        
        -- Trava na linha Y = 10 (onde o topo do sprite foi desenhado)
        pixel_y <= std_logic_vector(to_unsigned(10, 10));

        for x in 5 to 15 loop
            pixel_x <= std_logic_vector(to_unsigned(x, 10));
            wait for CLK_PERIOD;
            
            -- Os dados têm um pipeline de atraso (geralmente 1 clock da OAM + 1 clock da Sprite_Mem)
            -- Vamos aguardar 2 clocks para o dado "cair" na saída, para fins de debug no console:
            -- (No ModelSim você verá instantaneamente no Waveform)
        end loop;

        -- Simula o Blanking (fora da tela)
        report "[FASE 3] Testando Blanking (Fora da área de vídeo)...";
        video_active <= '0';
        wait for 5 * CLK_PERIOD;

        report "--- TESTE CONCLUIDO. Analise as dependencias de cores no Waveform ---" severity failure;
        wait;
    end process;

end behavior;