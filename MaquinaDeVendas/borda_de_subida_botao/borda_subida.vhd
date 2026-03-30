library ieee;
use ieee.std_logic_1164.all;

entity borda_subida is
    port (
        clk : in std_logic;
        entrada : in std_logic;
        saida : out std_logic
    );
end entity borda_subida;

architecture rtl of borda_subida is
    signal entrada_reg : std_logic;
    signal respondido : std_logic;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            entrada_reg <= entrada;

            -- Se entrada voltou a 0, reseta a flag
            if entrada = '0' then
                respondido <= '0';
            end if;

            -- Detecta borda de subida e ainda não respondeu
            if entrada = '1' and entrada_reg = '0' and respondido = '0' then
                saida <= '1';
                respondido <= '1';
            else
                saida <= '0';
            end if;
        end if;
    end process;
end architecture rtl;