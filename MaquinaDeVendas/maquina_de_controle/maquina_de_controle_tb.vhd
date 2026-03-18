library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm_tb is
end entity;

architecture sim of fsm_tb is
    signal enter_s          : std_logic := '0';
    signal cancel_s         : std_logic := '0';
    signal enough_money_s   : std_logic := '0';
    signal timer_end_s      : std_logic := '0';
    signal clk_tb           : std_logic := '0';
	 signal reset_tb			 : std_logic := '0';
    
    signal product_enable_s     : std_logic;
    signal product_led_s        : std_logic;
    signal subtraction_enable_s : std_logic;
    signal timer_on_s           : std_logic;

    constant CLK_PERIOD : time := 20 ns;
begin
    uut: entity work.fsm
        port map (
            enter              => enter_s,
				reset					 => reset_tb,
            cancel             => cancel_s,
            enough_money       => enough_money_s,
            timer_end          => timer_end_s,
            clk                => clk_tb,

            product_enable     => product_enable_s,
            product_led        => product_led_s,
            subtraction_enable => subtraction_enable_s,
            timer_on           => timer_on_s
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;


    test_process: process
    begin
	 
	    -- Reset
		wait for 20 ns;
		reset_tb <= '1';
		wait for 20 ns;
        reset_tb <= '0';
        
        wait for 20 ns;
	 
        -- CENÁRIO 1: Compra bem-sucedida
        report "Cenario 1: Iniciando compra...";
        enter_s <= '1';
        wait for CLK_PERIOD;
        enter_s <= '0';
        -- Agora deve estar em ST_INSERE
        
        wait for CLK_PERIOD * 2;
        report "Inserindo dinheiro e confirmando...";
        enough_money_s <= '1';
        enter_s <= '1';
        wait for CLK_PERIOD;
        enter_s <= '0';
        -- Agora deve estar em ST_DISPENSA
        
        wait for CLK_PERIOD * 3;
        report "Fim do tempo de dispensa...";
        timer_end_s <= '1';
        wait for CLK_PERIOD;
        timer_end_s <= '0';
        -- Deve voltar para ST_ESCOLHE

        -- CENÁRIO 2: Cancelamento no meio da inserção
        report "Cenario 2: Selecionando e cancelando...";
        enter_s <= '1';
        wait for CLK_PERIOD;
        enter_s <= '0';
        
        wait for CLK_PERIOD;
        cancel_s <= '1'; -- Usuário desistiu
        wait for CLK_PERIOD;
        cancel_s <= '0';
        -- Agora deve estar em ST_CANCELA
        
        wait for CLK_PERIOD * 2;
        timer_end_s <= '1';
        wait for CLK_PERIOD;
        timer_end_s <= '0';

        -- CENÁRIO 3: Enter sem dinheiro suficiente
        report "Cenario 3: Enter em insere sem dinheiro";
        enter_s <= '1';
        wait for CLK_PERIOD;
        enter_s <= '0';

        -- Enter
        enough_money_s <= '0';
        enter_s <= '1';
        wait for CLK_PERIOD;
        enter_s <= '0';

        -- É pra estar em ST_INSERE
        wait for CLK_PERIOD;
        
        -- Reset
		wait for 20 ns;
		reset_tb <= '1';
		wait for 20 ns;
        reset_tb <= '0';
        
            
        report "Todos os testes finalizados!";
        wait; 
    end process;
end architecture;