library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dram_iface is
end tb_dram_iface;

architecture sim of tb_dram_iface is

    constant CLK_PERIOD : time := 7 ns;

    -- Entradas
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal SW       : std_logic_vector(9 downto 0) := (others => '0');
    signal KEY      : std_logic_vector(3 downto 0) := (others => '1'); -- KEYs são ativos em 0
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal ready    : std_logic := '0';

    -- Saídas
    signal HEX0     : std_logic_vector(6 downto 0);
    signal HEX1     : std_logic_vector(6 downto 0);
    signal HEX4     : std_logic_vector(6 downto 0);
    signal HEX5     : std_logic_vector(6 downto 0);
    signal address  : std_logic_vector(25 downto 0);
    signal data_out : std_logic_vector(7 downto 0);
    signal req      : std_logic;
    signal wEn      : std_logic;

begin

    dut : entity work.dram_iface
        port map (
            clk      => clk,
            rst      => rst,
            SW       => SW,
            KEY      => KEY,
            HEX0     => HEX0,
            HEX1     => HEX1,
            HEX4     => HEX4,
            HEX5     => HEX5,
            address  => address,
            data_in  => data_in,
            data_out => data_out,
            req      => req,
            wEn      => wEn,
            ready    => ready
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stimulus_process : process
    begin
        -- Reset
        rst <= '1';
        wait for 5 * CLK_PERIOD;
        rst <= '0';
        
        -- Memória pronta para receber comandos
        ready <= '1';
        wait for 5 * CLK_PERIOD;

        -- ==========================================
        -- Teste 1: Mudança de Switch (Leitura Automática)
        -- ==========================================
        report "Teste: Mudanca de SW (Deve disparar Leitura)";
        -- Altera endereço (SW 9 a 4). SW(9)=1
        SW(9) <= '1'; 
        
        -- A interface deve detectar a mudança e levantar 'req' com 'wEn=0'
        wait until req = '1';
        ready <= '0'; -- Simula a memória processando (ocupada)
        wait for 10 * CLK_PERIOD;
        ready <= '1'; -- Memória terminou a leitura
        
        wait for 5 * CLK_PERIOD;

        -- ==========================================
        -- Teste 2: Pressionamento do Botão (Escrita)
        -- ==========================================
        report "Teste: Botao KEY[3] pressionado (Deve disparar Escrita)";
        -- Configura dado de entrada (SW 3 a 0)
        SW(3 downto 0) <= "1010"; 
        
        -- Pressiona o botão (ativo em baixo)
        KEY(3) <= '0'; 
        wait for 3 * CLK_PERIOD;
        KEY(3) <= '1'; -- Solta o botão
        
        -- A interface deve detectar a borda e levantar 'req' com 'wEn=1'
        wait until req = '1';
        ready <= '0'; -- Simula a memória ocupada com a escrita
        wait for 10 * CLK_PERIOD;
        ready <= '1'; -- Memória terminou a escrita
        
        wait for 5 * CLK_PERIOD;
        
        -- ==========================================
        -- Teste 3: Leitura de verificação imediata após escrita
        -- ==========================================
        -- Conforme sua FSM de interface, após uma escrita, ela deve fazer uma leitura automaticamente.
        -- O sinal 'req' deve subir de novo logo após o 'ready' ter voltado para 1.
        if req = '0' then
            wait until req = '1';
        end if;
        report "Teste: Leitura automatica pos-escrita disparada.";
        
        ready <= '0';
        data_in <= x"0A"; -- Retorna um dado fictício lido da memória
        wait for 10 * CLK_PERIOD;
        ready <= '1';

        wait for 10 * CLK_PERIOD;
        assert false report "SIMULACAO FINALIZADA" severity note;
        wait;
    end process;

end sim;