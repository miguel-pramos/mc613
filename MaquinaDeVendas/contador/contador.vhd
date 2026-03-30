library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- adicionei essa biblioteca pra poder fazer conta de matematica

entity temporizador is
    port (
        clk  : in std_logic; -- coloquei o clock como primeiro pino pra ficar mais organizado
        t_on : in std_logic;
        t_f  : out std_logic
    );
end entity temporizador;

architecture rtl of temporizador is
    -- usei esse registrador interno com 26 bits pra guardar a contagem ate 50 milhoes (50 MHz)
    signal contagem: unsigned (25 downto 0) := (others => '0');

begin

    t_f <= '1' when contagem = 50000000 else '0'; 

    process (clk)
    begin
        if rising_edge(clk) then
            if t_on = '1' then 
                if contagem = 50000000 then 
                    contagem <= (others => '0');
                else
                    contagem <= contagem + 1;
                end if;
            else 
                contagem <= (others => '0');
            end if;
        end if;
    end process;
  
end architecture rtl;