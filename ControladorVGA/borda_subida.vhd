library ieee;
use ieee.std_logic_1164.all;

entity borda_subida is
    port (
        clk : in std_logic;
        entrada : in std_logic;
        saida : out std_logic := '0'
    );
end entity borda_subida;

architecture rtl of borda_subida is
    signal entrada_reg : std_logic := '0';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            entrada_reg <= entrada;

            saida <= entrada and (not entrada_reg);
        end if;
    end process;
end architecture rtl;