library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller_tb is
end vga_controller_tb;

architecture sim of vga_controller_tb is

    -- Sinais para conectar ao componente
    signal clk_50_tb     : std_logic := '0';
    signal key_tb        : std_logic_vector(1 downto 0) := "11"; -- KEY(0) é o reset
    signal vga_r_tb      : std_logic_vector(7 downto 0);
    signal vga_g_tb      : std_logic_vector(7 downto 0);
    signal vga_b_tb      : std_logic_vector(7 downto 0);
    signal vga_blank_n_tb: std_logic;
    signal vga_sync_n_tb : std_logic;
    signal vga_hs_tb     : std_logic;
    signal vga_vs_tb     : std_logic;
    signal vga_clk_tb    : std_logic;

    -- Período do clock de 50MHz (20 ns)
    constant clk_period : time := 20 ns;

begin

    -- Instância do Componente Top Level
    uut: entity work.vga_controller
        port map (
            CLOCK_50    => clk_50_tb,
            KEY         => key_tb,
            VGA_R       => vga_r_tb,
            VGA_G       => vga_g_tb,
            VGA_B       => vga_b_tb,
            VGA_BLANK_N => vga_blank_n_tb,
            VGA_SYNC_N  => vga_sync_n_tb,
            VGA_HS      => vga_hs_tb,
            VGA_VS      => vga_vs_tb,
            VGA_CLK     => vga_clk_tb
        );

    -- Geração do Clock de 50 MHz
    clk_process : process
    begin
        clk_50_tb <= '0';
        wait for clk_period/2;
        clk_50_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de Estímulo
    stim_proc: process
    begin		
        -- 1. Pulso de Reset (No seu código, reset_s <= not KEY(0))
        -- Então KEY(0) = '0' ativa o reset.
        key_tb(0) <= '0'; 
        wait for 100 ns;
        key_tb(0) <= '1'; -- Libera o reset
        
        -- 2. Aguarda a simulação correr
        -- Como sinais VGA são lentos (60Hz), em simulação observamos 
        -- apenas alguns microssegundos para ver as mudanças no HS/VS.
        wait for 20 ms; 

        -- Fim da simulação
        assert false report "Simulação finalizada" severity note;
        wait;
    end process;

end sim;