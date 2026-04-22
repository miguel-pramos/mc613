library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
    port (
        -- Entradas
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(1 downto 0);

        -- Saídas
        VGA_R : out std_logic_vector(7 downto 0);
        VGA_G : out std_logic_vector(7 downto 0);
        VGA_B : out std_logic_vector(7 downto 0);

        VGA_BLANK_N : out std_logic;
        VGA_SYNC_N : out std_logic;
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        VGA_CLK : out std_logic
    );
end vga_controller;

architecture Behavioral of vga_controller is
    constant red : integer := 20;
    constant blue : integer := 125;
    constant green : integer := 125;

    type offset_array is array (0 to 3) of unsigned(9 downto 0);
    constant OFFSET_X : offset_array := (to_unsigned(0, 10), to_unsigned(16, 10),
                                        to_unsigned(0, 10), to_unsigned(16, 10));
    constant OFFSET_Y : offset_array := (to_unsigned(0, 10), to_unsigned(0, 10),
                                        to_unsigned(16, 10), to_unsigned(16, 10));

    signal v_sync : std_logic;

    signal reset_s : std_logic;
    signal bg_s : std_logic;
    signal pll_clk : std_logic;
    signal pll_locked : std_logic := '0';

    signal red_s : std_logic_vector(7 downto 0);
    signal blue_s : std_logic_vector(7 downto 0);
    signal green_s : std_logic_vector(7 downto 0);

    signal pixel_x, pixel_y : std_logic_vector(9 downto 0);

    signal video_active : std_logic;

    ------- Controle de sprites e PPU -------
    signal sprt_we, bg_we : std_logic := '0';
    signal oam_x, oam_y : std_logic_vector(9 downto 0);
    signal logo_x, logo_y : std_logic_vector(9 downto 0);
    signal sprite_sel : std_logic_vector (1 downto 0);
    signal oam_sprite_id : std_logic_vector (2 downto 0);

    signal bg_tile_fsm : std_logic;
    signal bg_tile_in : std_logic;
    signal bg_tile_id : std_logic;
    signal bg_write_addr : std_logic_vector(8 downto 0) := (others => '0');

    signal vsync_old : std_logic := '0';
    signal sprt_update_active : std_logic := '0';
    signal bg_update_active : std_logic := '0';

    -- cores
    signal bg_color_id : std_logic_vector(2 downto 0);
    signal sprite_color_id : std_logic_vector(2 downto 0) := "000";
    signal final_color_id : std_logic_vector(1 downto 0);

    -- Sinais que saem da Palette e entram no Mux
    signal pal_red_out : std_logic_vector(7 downto 0);
    signal pal_green_out : std_logic_vector(7 downto 0);
    signal pal_blue_out : std_logic_vector(7 downto 0);

begin
    -- Clock de pixel
    VGA_CLK <= pll_clk;

    reset_s <= not KEY(0);

    edge_detector_bg : entity work.borda_subida
        port map(
            clk => CLOCK_50,
            entrada => not KEY(1), -- Botões na DE1 são ativos em baixo (0)
            saida => bg_s
        );

    pll_u : entity work.pll
        port map(
            refclk => CLOCK_50,
            rst => reset_s,
            outclk_0 => pll_clk,
            locked => pll_locked
        );

    vga : entity work.vga
        port map(
            -- Saídas
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,

            VGA_BLANK_N => VGA_BLANK_N,
            VGA_SYNC_N => VGA_SYNC_N,
            VGA_HS => VGA_HS,
            VGA_VS => v_sync,
            VGA_CLK => VGA_CLK,

            pixel_x => pixel_x,
            pixel_y => pixel_y,
            video_active => video_active,

            -- Entradas
            pixel_clk => pll_clk,
            reset_s => reset_s,

            r_in => red_s,
            g_in => green_s,
            b_in => blue_s
        );

    ------------------- PPU ------------------

    oam : entity work.oam_memory
        port map(
            clk => pll_clk,
            we => sprt_we,
            pixel_x => pixel_x,
            pixel_y => pixel_y,

            in_x => oam_x,
            in_y => oam_y,

            sprite_sel => sprite_sel,
            in_id => sprite_sel,
            sprite_id_out => oam_sprite_id
        );

    tileset_sprt : entity work.sprite_memory
        port map(
            clk => pll_clk,
            sprite_id => oam_sprite_id,

            pixel_x => pixel_x,
            pixel_y => pixel_y,

            sprite_x => logo_x,
            sprite_y => logo_y,

            bitmap_out => sprite_color_id
        );


    bg_mem : entity work.memorybackground
        port map(
            clk => pll_clk,
            we => bg_we,
            write_addr => bg_write_addr,

            data_in => bg_tile_in,
            pixel_x => pixel_x,
            pixel_y => pixel_y,

            tile_id_out => bg_tile_id
        );

    tileset_bg : entity work.tileset_memory
        port map(

            tile_id => bg_tile_id,

            pixel_x => pixel_x,
            pixel_y => pixel_y,

            -- Saída: Id da cor
            color_id => bg_color_id
        );

    layer_selector : entity work.layer_selector
        port map(
            color_bg => bg_color_id,
            color_sprite => sprite_color_id,
            color_out => final_color_id
        );

    palette : entity work.palette_memory
        port map(
            id_color => final_color_id,
            red => pal_red_out,
            green => pal_green_out,
            blue => pal_blue_out
        );

    ppu_mux : entity work.mux_ppu
        port map(
            clk => pll_clk, -- Clock de pixel
            video_active => video_active,

            -- Entradas vindas da Palette
            red => pal_red_out,
            green => pal_green_out,
            blue => pal_blue_out,

            -- Saídas que vão para o controlador VGA
            vga_red => red_s,
            vga_green => green_s,
            vga_blue => blue_s
        );
    --------------------------------------

    mvmt : entity work.sprt_movement
        port map(
            clk_vga => pll_clk,
            v_sync => v_sync,
            reset => reset_s,
            pos_x => logo_x,
            pos_y => logo_y
        );

    fsm : entity work.fsm_interface
        port map(
            clk => CLOCK_50,
            reset => reset_s,
            key_signal => bg_s,
            bg_tile => bg_tile_fsm
        );

    -- atualização dos sprites
    process (pll_clk)
        variable delay_count : integer range 0 to 4 := 0;
        variable v_count : integer range 0 to 3 := 0;

    begin
        if rising_edge(pll_clk) then
            vsync_old <= v_sync; -- atualiza no fim do clock

            -- Borda de descida
            if vsync_old = '1' and v_sync = '0' then
                sprt_update_active <= '0';
                delay_count := 1;

                v_count := 0;

            elsif delay_count > 0 then
                if delay_count = 4 then
                    delay_count := 0;
                    sprt_update_active <= '1';
                else
                    delay_count := delay_count + 1;
                end if;
            end if;

            if sprt_update_active = '1' then
                sprt_we <= '1';
                sprite_sel <= std_logic_vector(to_unsigned(v_count, 2));

                oam_x <= std_logic_vector(unsigned(logo_x) + OFFSET_X(v_count));
                oam_y <= std_logic_vector(unsigned(logo_y) + OFFSET_Y(v_count));

                if v_count = 3 then
                    sprt_update_active <= '0';
                else
                    v_count := v_count + 1;
                end if;
            else
                sprt_we <= '0';
            end if;
        end if;

    end process;

    -- atualização do Background
    process (pll_clk)
        variable bg_count : integer range 0 to 511 := 0;
    begin
        if rising_edge(pll_clk) then
            if vsync_old = '1' and v_sync = '0' then
                bg_update_active <= '1';
                bg_count := 0;
            end if;

            if bg_update_active = '1' then
                bg_we <= '1';
                bg_write_addr <= std_logic_vector(to_unsigned(bg_count, 9));

                if (bg_count mod 2 = 0) xor (bg_count / 20 mod 2 = 0) then
                    bg_tile_in <= bg_tile_fsm;
                else
                    bg_tile_in <= not bg_tile_fsm;
                end if;

                if bg_count = 511 then
                    bg_update_active <= '0';
                else
                    bg_count := bg_count + 1;
                end if;
            else
                bg_we <= '0';
            end if;
        end if;
    end process;

    VGA_VS <= v_sync;

end Behavioral;