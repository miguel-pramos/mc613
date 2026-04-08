library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_machine_tb is
end entity;

architecture tb of vending_machine_tb is

    -- Sinais de estímulo / observação (Nomes e tamanhos sincronizados com o Top-Level)
    signal CLOCK_50_s : std_logic := '0';
    signal KEY_s      : std_logic_vector(3 downto 0) := (others => '1'); -- Active-Low (1 = solto)
    signal SW_s       : std_logic_vector(9 downto 0) := (others => '0');

    signal HEX0_s     : std_logic_vector(6 downto 0);
    signal HEX1_s     : std_logic_vector(6 downto 0);
    signal HEX2_s     : std_logic_vector(6 downto 0);
    signal HEX3_s     : std_logic_vector(6 downto 0);
    signal HEX5_s     : std_logic_vector(6 downto 0);
    signal LEDR_s     : std_logic_vector(7 downto 0); -- Corrigido para 8 bits

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

begin

    -- Instancia UUT (Unit Under Test)
    uut: entity work.vending_machine
        port map (
            CLOCK_50 => CLOCK_50_s,
            KEY      => KEY_s,
            SW       => SW_s,
            HEX0     => HEX0_s,
            HEX1     => HEX1_s,
            HEX2     => HEX2_s,
            HEX3     => HEX3_s,
            HEX5     => HEX5_s,
            LEDR     => LEDR_s
        );

    -- Geração de clock de 50MHz
    clk_process : process
    begin
        CLOCK_50_s <= '0';
        wait for CLK_PERIOD/2;
        CLOCK_50_s <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Estímulos de teste
    stim_proc : process
    begin
        -- RESET INICIAL (Usando KEY(3) conforme definido no Top-Level)
        SW_s  <= (others => '0');
        KEY_s <= (others => '1'); -- Todos soltos
        wait for 100 ns;
        
        KEY_s(3) <= '0'; -- Pressiona Reset (KEY 3)
        wait for 2 * CLK_PERIOD;
        KEY_s(3) <= '1'; -- Solta Reset
        wait for 100 ns;

        -----------------------------------------------------------------
        -- CENÁRIO 1: Compra de Produto 0 (Exemplo: 50 centavos)
        -----------------------------------------------------------------
        -- 1. Seleciona ID do produto nos Switches 3..0
        SW_s(3 downto 0) <= "0000"; 
        wait for 5 * CLK_PERIOD;

        -- 2. Pressiona ENTER (KEY 0) para confirmar produto
        KEY_s(0) <= '0'; -- Ativo em '0'
        wait for 2 * CLK_PERIOD;
        KEY_s(0) <= '1';
        wait for 10 * CLK_PERIOD;

        -- 3. Insere Nota (Exemplo: Ativa Switch 4)
        SW_s(4) <= '1'; 
        wait for 5 * CLK_PERIOD;

        -- 4. Pressiona ENTER (KEY 0) para registrar o crédito
        KEY_s(0) <= '0';
        wait for 2 * CLK_PERIOD;
        KEY_s(0) <= '1';
        SW_s(4) <= '0'; -- Desativa switch após registrar
        wait for 20 * CLK_PERIOD;

        -----------------------------------------------------------------
        -- CENÁRIO 2: Cancelamento de Operação
        -----------------------------------------------------------------
        -- 1. Seleciona outro produto
        SW_s(3 downto 0) <= "0001";
        wait for 5 * CLK_PERIOD;

        -- 2. Confirma produto (ENTER)
        KEY_s(0) <= '0';
        wait for 2 * CLK_PERIOD;
        KEY_s(0) <= '1';
        wait for 5 * CLK_PERIOD;

        -- 3. Pressiona CANCELAR (KEY 1)
        KEY_s(1) <= '0'; 
        wait for 2 * CLK_PERIOD;
        KEY_s(1) <= '1';
        
        -- Aguarda o tempo do Temporizador de 1 segundo (Simulação rápida)
        wait for 100 * CLK_PERIOD;

        -----------------------------------------------------------------
        -- Fim da simulação
        -----------------------------------------------------------------
        report "Fim da simulacao com sucesso!";
        wait;
    end process;

end architecture;