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
        