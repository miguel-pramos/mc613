-- Biblioteca
library ieee;
use ieee.std_logic_1164.all;

-- Entidade
entity Mux2to1_tb is
end entity;

-- Arquitetura
architecture sim of Mux2to1_tb is 
    signal t_valor, t_modulo, t_X   : std_logic_vector(10 downto 0);
    signal t_S      : std_logic;
begin
    dut: entity work.Mux2to1
        port_map(
            valor   => t_valor,
            modulo  => t_modulo;
            S       => t_S;
            X       => t_X;
        );
    stim: process
    begin
        -- Valores fixos para as entradas 
        t_valor <= std_logic_vector(to_signed(500, 11));
        t_modulo <= std_logic_vector(to_signed(100, 11));
        
        -- Seleciona 'valor'
        t_S <= '0';
        wait for 10 ns;

        -- Muda valor com S em 0
        t_valor <= std_logic_vector(to_signed(150,11));
        wait for 10 ns;

        -- Seleciona 'modulo'
        t_S <= '1';
        wait for 10 ns;

        -- Muda valor com S em 1
        t_valor ,= std_logic_vector(to_signed(900, 11));
        wait for 10 ns;

        wait;
    end process;
end architecture

        