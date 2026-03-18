-- Biblioteca 
library ieee;
use ieee.std_logic_1164.all;

-- Entidade 
entity mod11_tb is
end entity;

-- Arquitetura
architecture sim of mod11_tb is
    signal t_valor:     std_logic_vector(10 downto 0);
    signal t_modulo:    std_logic_vector(10 downto 0);
begin  
    
    dut: entity work.mod11
        port map(
            valor => t_valor,
            modulo => t_modulo
        );
    stim: process
    begin
        -- Valor positivo 
        t_valor <= std_logic_vector(to_signed(10,11));
        wait for 2 ns;
        -- Zero
        t_valor <= std_logic_vector(to_signed(0, 11));
        wait for 2 ns;
        -- Valor negativo
        t_valor <= std_logic_vector(to_signed(-10, 11));
        wait for 2 ns;

        wait; -- Mantém simulação rodando 
    end process;
end architecture;

