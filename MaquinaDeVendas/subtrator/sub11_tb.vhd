library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sub11_tb is
end entity sub11_tb;

architecture sim of sub11_tb is

    -- Sinais para conectar ao Device Under Test (DUT)
    signal t_valor_atual : std_logic_vector(10 downto 0) := (others => '0');
    signal t_valor_add   : std_logic_vector(10 downto 0) := (others => '0');
    signal t_valor_final : std_logic_vector(10 downto 0);

begin

    -- Instanciação do módulo subtrator
    dut: entity work.sub11
        port map(
            valor_atual => t_valor_atual,
            valor_add   => t_valor_add,
            valor_final => t_valor_final
        );

    stim_process: process
    begin
        -- Teste 1: Subtração normal (Saldo maior que o preço/adição)
        -- valor_atual = 500 (R$ 5,00), valor_add = 200 (R$ 2,00) -> Esperado: 300
        t_valor_atual <= std_logic_vector(to_signed(500, 11));
        t_valor_add   <= std_logic_vector(to_signed(200, 11));
        wait for 10 ns;

        -- Teste 2: Resultado zero (Pagamento exato)
        -- valor_atual = 350, valor_add = 350 -> Esperado: 0
        t_valor_atual <= std_logic_vector(to_signed(350, 11));
        t_valor_add   <= std_logic_vector(to_signed(350, 11));
        wait for 10 ns;

        -- Teste 3: Resultado negativo (Falta dinheiro)
        -- valor_atual = 150, valor_add = 300 -> Esperado: -150
        t_valor_atual <= std_logic_vector(to_signed(150, 11));
        t_valor_add   <= std_logic_vector(to_signed(300, 11));
        wait for 10 ns;
        
        -- Teste 4: Subtração com números negativos
        -- valor_atual = -50, valor_add = 100 -> Esperado: -150
        t_valor_atual <= std_logic_vector(to_signed(-50, 11));
        t_valor_add   <= std_logic_vector(to_signed(100, 11));
        wait for 10 ns;

        wait; -- Finaliza a simulação
    end process;

end architecture sim;