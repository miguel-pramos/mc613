library ieee;
use ieee.std_logic_1164.all;

entity mux_ppu_tb is
end mux_ppu_tb;

architecture sim of mux_ppu_tb is
    -- Sinais para conectar ao componente
    signal clk_tb          : std_logic := '0';
    signal red_tb          : std_logic_vector(7 downto 0) := (others => '0');
    signal green_tb        : std_logic_vector(7 downto 0) := (others => '0');
    signal blue_tb         : std_logic_vector(7 downto 0) := (others => '0');
    signal video_active_tb : std_logic := '0';
    signal vga_red_tb      : std_logic_vector(7 downto 0);
    signal vga_green_tb    : std_logic_vector(7 downto 0);
    signal vga_blue_tb     : std_logic_vector(7 downto 0);

    -- Constante de clock (25 MHz aproximadamente para VGA)
    constant clk_period : time := 40 ns;

begin
    -- Instância do componente (DUT - Device Under Test)
    UUT: entity work.mux_ppu
        port map (
            clk          => clk_tb,
            red          => red_tb,
            green        => green_tb,
            blue         => blue_tb,
            video_active => video_active_tb,
            vga_red      => vga_red_tb,
            vga_green    => vga_green_tb,
            vga_blue     => vga_blue_tb
        );

    -- Gerador de clock
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        -- Estado inicial: Fora da área ativa (Blanking)
        video_active_tb <= '0';
        red_tb   <= x"FF"; -- Branco (se estivesse ativo)
        green_tb <= x"FF";
        blue_tb  <= x"FF";
        wait for clk_period * 2;

        -- Teste 1: Ativando o vídeo (Deve mostrar a cor no próximo ciclo)
        video_active_tb <= '1';
        wait for clk_period * 2;

        -- Teste 2: Mudando a cor com vídeo ativo
        red_tb   <= x"AA"; -- Uma cor qualquer
        green_tb <= x"00";
        blue_tb  <= x"55";
        wait for clk_period * 2;

        -- Teste 3: Entrando em blanking (Saídas devem zerar)
        video_active_tb <= '0';
        wait for clk_period * 2;

        -- Finaliza a simulação
        wait;
    end process;
end sim;