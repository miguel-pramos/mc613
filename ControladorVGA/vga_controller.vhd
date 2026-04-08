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
        VGA_SYNC_N  : out std_logic; 
        VGA_HS      : out std_logic; 
        VGA_VS      : out std_logic; 
        VGA_CLK 	  : out std_logic
    );
end vga_controller;

architecture Behavioral of vga_controller is
    constant red : integer := 20;
    constant blue : integer := 125; 
    constant green : integer := 125; 
    
    signal reset_s : std_logic := '0';
    signal pll_clk : std_logic;
    signal pll_locked : std_logic := '0';

    signal red_s : std_logic_vector(7 downto 0);
    signal blue_s : std_logic_vector(7 downto 0);
    signal green_s : std_logic_vector(7 downto 0);

    signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
    signal video_active : std_logic;
    
begin
    -- Clock de pixel
    VGA_CLK <= pll_clk;

    -- Reset
    -- borda_subida_reset : entity work.borda_subida 
    --     port map (
    --         clk         =>      CLOCK_50,
    --         entrada     =>      not KEY(0),
    --         saida       =>      reset_s
    --     );
	 
    reset_s <= not KEY(0);

    pll_u : entity work.pll
        port map (
            refclk      =>      CLOCK_50,
            rst         =>      reset_s,
            outclk_0    =>      pll_clk,
            locked      =>      pll_locked
        );

    vga : entity work.vga
        port map (
            -- Saídas
            VGA_R           =>      VGA_R,
            VGA_G           =>      VGA_G,
            VGA_B           =>      VGA_B,

            VGA_BLANK_N     =>      VGA_BLANK_N,
            VGA_SYNC_N      =>      VGA_SYNC_N, 
            VGA_HS          =>      VGA_HS, 
            VGA_VS          =>      VGA_VS,
            VGA_CLK 	    	 =>      VGA_CLK,
            
            pixel_x         =>      pixel_x,
            pixel_y         =>      pixel_y,
            video_active    =>      video_active,

            -- Entradas
            pixel_clk       =>      pll_clk,
            reset_s         =>      reset_s,

            r_in            =>      red_s,
            g_in            =>      green_s,
            b_in            =>      blue_s
        );

			process(pixel_x, video_active)
			begin
				 if video_active = '1' then
					  if unsigned(pixel_x) < 213 then
							red_s   <= (others => '1'); -- Vermelho puro
							green_s <= (others => '0');
							blue_s  <= (others => '0');
					  elsif unsigned(pixel_x) < 427 then
							red_s   <= (others => '0');
							green_s <= (others => '1'); -- Verde puro
							blue_s  <= (others => '0');
					  else
							red_s   <= (others => '0');
							green_s <= (others => '0'); -- Verde puro
							blue_s  <= (others => '1');
					  end if;
				 else
					  red_s   <= (others => '0');
					  green_s <= (others => '0');
					  blue_s  <= (others => '0');
				 end if;
end process;


end Behavioral;