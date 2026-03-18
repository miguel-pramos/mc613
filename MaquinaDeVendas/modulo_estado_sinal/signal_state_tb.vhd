-- Biblioteca 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade 
entity signal_state_tb is
--
end entity;


-- Arquitetura 
architecture sim of signal_state_tb is 
    signal t_valor :    std_logic_vector(10 downto 0);
    signal t_valor_suf: std_logic;
    signal t_tem_troco: std_logic;
begin
  
    dut: entity work.signal_state
        port map(
            valor       => t_valor,
            valor_suf   => t_valor_suf,
            tem_troco   => t_tem_troco
        );

    stim: process
    begin
        -- Saldo positivo
        t_valor <= std_logic_vector(to_signed(500, 11));
        wait for 2 ns;

        -- Saldo zerado
        t_valor <= std_logic_vector(to_signed(0,11));
        wait for 2 ns;

        -- Saldo negativo
        t_valor <= std_logic_vector(to_signed(-100, 11));
        wait for 2 ns;

        wait;
    end process;
end architecture;


