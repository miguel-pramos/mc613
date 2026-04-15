library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_tb is
end vga_tb;

architecture sim of vga_tb is

    -- Sinais para conectar ao componente
    signal clk          : std_logic := '0';
    signal rst_n        : std_logic := '0';
    signal r_in, g_in, b_in : std_logic_vector(7 downto 0) := (others => '0');
     
    signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
    signal video_active     : std_logic;
    
    signal vga_r, vga_g, vga_b : std_logic_vector(7 downto 0);
    signal vga_hs, vga_vs      : std_logic;
    signal vga_blank_n         : std_logic;
    signal vga_sync_n          : std_logic;
    signal vga_clk             : std_logic;

    -- Constante de clock: 25.175 MHz é aprox 39.72 ns
    constant CLK_PERIOD : time := 39.72 ns;

begin

    -- Instância do seu controlador
    uut: entity work.vga
        port map (
            pixel_clk    => clk,
            reset_n      => rst_n,
            r_in         => r_in,
            g_in         => g_in,
            b_in         => b_in,
            pixel_x      => pixel_x,
            pixel_y      => pixel_y,
            video_active => video_active,
            VGA_R        => vga_r,
            VGA_G        => vga_g,
            VGA_B        => vga_b,
            VGA_HS       => vga_hs,
            VGA_VS       => vga_vs,
            VGA_BLANK_N  => vga_blank_n,
            VGA_SYNC_N   => vga_sync_n,
            VGA_CLK      => vga_clk
        );

    -- Geração do Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        
        rst_n <= '0'; 
        wait for 100 ns;
        rst_n <= '1';
        
        -- Cores fixas para teste (Branco)
        r_in <= x"FF";
        g_in <= x"FF";
        b_in <= x"FF";

        -- Aguarda tempo suficiente para ver algumas linhas (H_TOTAL * CLK_PERIOD)
        -- Para ver um frame inteiro (640x480), levaria ~16.6ms
        wait for 40 ms; 

        report "Simulação finalizada";
        wait;
    end process;

end sim;