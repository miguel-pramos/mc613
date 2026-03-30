library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin11_to_bcd4_tb is
end entity bin11_to_bcd4_tb;

architecture sim of bin11_to_bcd4_tb is
    signal t_bin : std_logic_vector(10 downto 0) := (others => '0');
    signal t_bcd : std_logic_vector(15 downto 0);
begin

    -- Instanciação do módulo
    dut: entity work.bin11_to_bcd4
        port map(
            bin => t_bin,
            bcd => t_bcd
        );

    -- Processo de estímulos para validar a conversão
    stim_process: process
    begin
        -- Teste 1: Valor Zero
        -- Bin: 0 -> BCD Esperado: x"0000"
        t_bin <= std_logic_vector(to_unsigned(0, 11));
        wait for 10 ns;

        -- Teste 2: Valor 9 (Último digito único decimal)
        -- Bin: 9 -> BCD Esperado: x"0009"
        t_bin <= std_logic_vector(to_unsigned(9, 11));
        wait for 10 ns;

        -- Teste 3: Valor 15 (Para ver se passa para a dezena)
        -- Bin: 15 -> BCD Esperado: x"0015"
        t_bin <= std_logic_vector(to_unsigned(15, 11));
        wait for 10 ns;

        -- Teste 4: Valor 125 (Pre��o de R$ 1,25 do produto x"0")
        -- Bin: 125 -> BCD Esperado: x"0125"
        t_bin <= std_logic_vector(to_unsigned(125, 11));
        wait for 10 ns;

        -- Teste 5: Valor 999 
        -- Bin: 999 -> BCD Esperado: x"0999"
        t_bin <= std_logic_vector(to_unsigned(999, 11));
        wait for 10 ns;

        -- Teste 6: Valor Máximo esperado pelas notas (ex: R$ 14,99 = 1499 centavos)
        -- Bin: 1499 -> BCD Esperado: x"1499"
        t_bin <= std_logic_vector(to_unsigned(1499, 11));
        wait for 10 ns;
        
        -- Teste 7: Valor limite do barramento (2047)
        -- Bin: 2047 -> BCD Esperado: x"2047"
        t_bin <= std_logic_vector(to_unsigned(2047, 11));
        wait for 10 ns;

        wait; -- Fim da simulação
    end process;
end architecture sim;