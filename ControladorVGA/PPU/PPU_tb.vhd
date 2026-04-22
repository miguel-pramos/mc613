library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ppu is
end tb_ppu;

architecture sim of tb_ppu is

    -- Sinais de interface com a PPU
    signal clk_tb        : std_logic := '0';
    signal reset_tb      : std_logic := '0';
    
    -- Interface CPU
    signal cpu_we_tb     : std_logic := '0';
    signal cpu_sel_tb    : std_logic_vector(1 downto 0) := "00";
    signal cpu_x_tb      : std_logic_vector(9 downto 0) := (others => '0');
    signal cpu_y_tb      : std_logic_vector(9 downto 0) := (others => '0');
    signal cpu_id_tb     : std_logic_vector(1 downto 0) := "00";
    
    -- Saídas VGA
    signal vga_r_tb      : std_logic_vector(3 downto 0);
    signal vga_g_tb      : std_logic_vector(3 downto 0);
    signal vga_b_tb      : std_logic_vector(3 downto 0);
    signal vga_hsync_tb  : std_logic;
    signal vga_vsync_tb  : std_logic;

    -- Constante de clock (25 MHz -> 40ns)
    constant clk_period : time := 40 ns;

begin

    -- Instância da PPU (Device Under Test)
    UUT: entity work.ppu
        port map (
            clk        => clk_tb,
            reset      => reset_tb,
            cpu_we     => cpu_we_tb,
            cpu_sel    => cpu_sel_tb,
            cpu_x      => cpu_x_tb,
            cpu_y      => cpu_y_tb,
            cpu_id     => cpu_id_tb,
            VGA_R      => vga_r_tb,
            VGA_G      => vga_g_tb,
            VGA_B      => vga_b_tb,
            VGA_HSYNC  => vga_hsync_tb,
            VGA_VSYNC  => vga_vsync_tb
        );

    -- Gerador de Clock
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de Estímulos
    stim_proc: process
    begin
        -- 1. Reset do Sistema
        reset_tb <= '1';
        wait for 100 ns;
        reset_tb <= '0';
        wait for clk_period * 5;

        -- 2. Simulação da CPU configurando sprites na OAM
        -- Posicionando Sprite 0 em (100, 100) com ID 0
        cpu_we_tb  <= '1';
        cpu_sel_tb <= "00";
        cpu_x_tb   <= std_logic_vector(to_unsigned(100, 10));
        cpu_y_tb   <= std_logic_vector(to_unsigned(100, 10));
        cpu_id_tb  <= "00";
        wait for clk_period;

        -- Posicionando Sprite 1 em (200, 150) com ID 1
        cpu_sel_tb <= "01";
        cpu_x_tb   <= std_logic_vector(to_unsigned(200, 10));
        cpu_y_tb   <= std_logic_vector(to_unsigned(150, 10));
        cpu_id_tb  <= "01";
        wait for clk_period;

        -- Desativa escrita da CPU
        cpu_we_tb <= '0';

        -- 3. Observação da varredura VGA
        -- Deixamos rodar por um tempo considerável para ver o HSYNC pulsar
        -- e a PPU processar os pixels.
        wait for 1 ms; 

        -- Fim da simulação
        assert false report "Simulação completa" severity note;
        wait;
    end process;

end sim;