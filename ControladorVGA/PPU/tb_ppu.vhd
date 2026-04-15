LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_ppu IS
END tb_ppu;

ARCHITECTURE behavior OF tb_ppu IS

    -- Declarar a nossa PPU
    COMPONENT ppu
        PORT (
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            cpu_we      : IN  STD_LOGIC;
            cpu_sel     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            cpu_x       : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            cpu_y       : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            cpu_id      : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            VGA_R       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            VGA_G       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            VGA_B       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            VGA_HSYNC   : OUT STD_LOGIC;
            VGA_VSYNC   : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Sinais virtuais
    SIGNAL tb_clk       : STD_LOGIC := '0';
    SIGNAL tb_reset     : STD_LOGIC := '0';
    
    SIGNAL tb_cpu_we    : STD_LOGIC := '0';
    SIGNAL tb_cpu_sel   : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tb_cpu_x     : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_cpu_y     : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_cpu_id    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    
    SIGNAL tb_vga_r, tb_vga_g, tb_vga_b : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL tb_hsync, tb_vsync           : STD_LOGIC;

    -- Constante para o tempo do relógio (Ex: 25 MHz para VGA padrão)
    CONSTANT clk_period : time := 40 ns;

BEGIN

    -- Colocar a PPU na protoboard virtual
    UUT: ppu PORT MAP (
        clk       => tb_clk,
        reset     => tb_reset,
        cpu_we    => tb_cpu_we,
        cpu_sel   => tb_cpu_sel,
        cpu_x     => tb_cpu_x,
        cpu_y     => tb_cpu_y,
        cpu_id    => tb_cpu_id,
        VGA_R     => tb_vga_r,
        VGA_G     => tb_vga_g,
        VGA_B     => tb_vga_b,
        VGA_HSYNC => tb_hsync,
        VGA_VSYNC => tb_vsync
    );

    -- ==========================================
    -- GERADOR DE CLOCK INFINITO
    -- ==========================================
    clk_process : PROCESS
    BEGIN
        tb_clk <= '0';
        WAIT FOR clk_period/2;
        tb_clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- ==========================================
    -- ROTEIRO DO TESTE
    -- ==========================================
    stim_proc: PROCESS
    BEGIN
        -- 1. Dá um reset inicial para limpar a memória do gerador de vídeo
        tb_reset <= '1';
        WAIT FOR 100 ns;
        tb_reset <= '0';
        
        -- Aqui o circuito fica a rodar sozinho! 
        -- O gerador de relógio encarrega-se do resto.
        -- O VGA demora muito a desenhar um ecrã completo, por isso pode 
        -- deixar a simulação rodar por uns bons milissegundos (ms).
        
        WAIT;
    END PROCESS;

END behavior;