LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ppu IS
    PORT (
        clk         : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        
        -- Entradas vindas do CPU (para escrever no OAM)
        cpu_we      : IN  STD_LOGIC;
        cpu_sel     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        cpu_x       : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        cpu_y       : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        cpu_id      : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        
        -- Saídas para o Monitor VGA (Assumindo 4 bits por cor)
        VGA_R       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_G       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_B       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_HSYNC   : OUT STD_LOGIC;
        VGA_VSYNC   : OUT STD_LOGIC
    );
END ppu;

ARCHITECTURE structural OF ppu IS

    SIGNAL pixel_x    : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL pixel_y    : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL video_on   : STD_LOGIC;
    
    SIGNAL sprite_id  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL sprite_x   : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL sprite_y   : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    SIGNAL cor_sprite : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL cor_fundo  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL cor_final  : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- ==========================================
    -- DECLARAÇÃO DOS COMPONENTES
    -- ==========================================
    
    COMPONENT video_timing_generator
        PORT (
            clk      : IN  STD_LOGIC;
            reset    : IN  STD_LOGIC;
            hsync    : OUT STD_LOGIC;
            vsync    : OUT STD_LOGIC;
            video_on : OUT STD_LOGIC;
            pixel_x  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            pixel_y  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT oam_memory
        PORT (
            clk           : IN  STD_LOGIC;
            we            : IN  STD_LOGIC;
            sprite_sel    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            in_x          : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            in_y          : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            in_id         : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            pixel_x       : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            pixel_y       : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            sprite_id_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            sprite_x_out  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            sprite_y_out  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sprite_memory
        PORT (
            sprite_id  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            pixel_x    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            pixel_y    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            sprite_x   : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            sprite_y   : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            bitmap_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    -- Assumindo que o Layer Selector e a Palette existam no seu projeto
    COMPONENT layer_selector
        PORT (
            bg_color     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            sprite_color : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            final_color  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT tileset_memory
        PORT (
            tile_id  : IN  STD_LOGIC;
            pixel_x  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            pixel_y  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            color_id : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    -- ==========================================
    -- INSTANCIAÇÃO E LIGAÇÃO
    -- ==========================================

    -- 1. O Gerador de Vídeo (O coração do ecrã)
    inst_video: video_timing_generator PORT MAP (
        clk      => clk,
        reset    => reset,
        hsync    => VGA_HSYNC,
        vsync    => VGA_VSYNC,
        video_on => video_on,
        pixel_x  => pixel_x,
        pixel_y  => pixel_y
    );

    -- 2. OAM (O Diretor dos Sprites)
    inst_oam: oam_memory PORT MAP (
        clk           => clk,
        we            => cpu_we,
        sprite_sel    => cpu_sel,
        in_x          => cpu_x,
        in_y          => cpu_y,
        in_id         => cpu_id,
        pixel_x       => pixel_x,
        pixel_y       => pixel_y,
        sprite_id_out => sprite_id,
        sprite_x_out  => sprite_x,
        sprite_y_out  => sprite_y
    );

    -- 3. Sprite Memory (A Biblioteca de Imagens)
    inst_sprite_mem: sprite_memory PORT MAP (
        sprite_id  => sprite_id,
        pixel_x    => pixel_x,
        pixel_y    => pixel_y,
        sprite_x   => sprite_x,
        sprite_y   => sprite_y,
        bitmap_out => cor_sprite
    );

    -- 4. Background (Tileset)
    inst_tileset: tileset_memory PORT MAP (
        tile_id  => '0',          -- Por enquanto deixamos fixo no Tile 0 (ou você pode ligar no seu Tilemap)
        pixel_x  => fio_pixel_x,  -- Recebe o X do Gerador de Vídeo
        pixel_y  => fio_pixel_y,  -- Recebe o Y do Gerador de Vídeo
        color_id => fio_cor_fundo -- Manda a cor do fundo para o Layer Selector!
    );

    -- 5. Layer Selector (Decide quem fica por cima)
    inst_layer: layer_selector PORT MAP (
        bg_color     => cor_fundo,
        sprite_color => cor_sprite,
        final_color  => cor_final
    );

    -- 6. Paleta Simples (Passa de 3 bits para as cores do VGA)
    -- Se tiver um ficheiro palette.vhd, instancie-o aqui. 
    -- Como teste, vamos apenas encaminhar os bits:
    PROCESS(cor_final, video_on)
    BEGIN
        IF video_on = '0' THEN
            VGA_R <= "0000"; VGA_G <= "0000"; VGA_B <= "0000";
        ELSE
            -- Se for a cor 1 (ex: Vermelho)
            IF cor_final = "001" THEN
                VGA_R <= "1111"; VGA_G <= "0000"; VGA_B <= "0000";
            -- Se for a cor 3 (ex: Branco)
            ELSIF cor_final = "011" THEN
                VGA_R <= "1111"; VGA_G <= "1111"; VGA_B <= "1111";
            ELSE
                VGA_R <= "0000"; VGA_G <= "0000"; VGA_B <= "0000";
            END IF;
        END IF;
    END PROCESS;

END structural;