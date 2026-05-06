library ieee;
use ieee.std_logic_1164.all;

entity borda_subida_tb is
end entity borda_subida_tb;

architecture tb of borda_subida_tb is
    component borda_subida is
        port (
            clk   : in  std_logic;
            entrada : in  std_logic;
            saida : out std_logic
        );
    end component borda_subida;
    
    signal clk   : std_logic := '0';
    signal entrada : std_logic := '0';
    signal saida : std_logic;
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    uut: borda_subida port map (
        clk => clk,
        entrada => entrada,
        saida => saida
    );
    
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;
    
    stim_process: process
    begin
        -- Teste 1: Borda de subida deve gerar saida = '1'
        entrada <= '1';
        wait for CLK_PERIOD;
        -- saida deve ser '1' neste clock
        
        -- Teste 2: Entrada continua em '1', saida deve ser '0'
        wait for CLK_PERIOD;
        -- saida deve ser '0' (ja respondeu)
        
        wait for CLK_PERIOD;
        -- saida deve ser '0' (continua respondido)
        
        -- Teste 3: Volta entrada para '0', reseta flag
        entrada <= '0';
        wait for CLK_PERIOD;
        
        -- Teste 4: Nova borda de subida deve gerar saida = '1' novamente
        entrada <= '1';
        wait for CLK_PERIOD;
        -- saida deve ser '1' novamente
        
        wait for CLK_PERIOD;
        entrada <= '0';
        wait for CLK_PERIOD;
		  
		  entrada <= '1';
		  wait for CLK_PERIOD;
        
        wait;
    end process stim_process;
    
end architecture tb;