library ieee;
use ieee.std_logic_1164.all;

entity addr_conversor is
    port (
        entrada : in std_logic_vector(9 downto 0);
        saida : out std_logic_vector(25 downto 0);
    );
end entity addr_conversor;

architecture rtl of addr_conversor is
    signal entrada_reg : std_logic := '0';
begin
    saida(25) <= entrada(9);
    saida(23 downto 21) <= entrada(8 downto 6);
    saida(1 downto 0) <= entrada(5 downto 4);
end architecture rtl;