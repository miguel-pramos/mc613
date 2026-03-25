library ieee;
use ieee.std_logic_1164.all;

entity tb_temporizador is
end entity tb_temporizador;

architecture sim of tb_temporizador is

    signal clk_tb  : std_logic := '0';
    signal t_on_tb : std_logic := '0';
    signal t_f_tb  : std_logic;

begin

    dut: entity work.temporizador
        port map (
            clk  => clk_tb,
            t_on => t_on_tb,
            t_f  => t_f_tb
        );

    clk_tb <= not clk_tb after 10 ns;

    stim: process
    begin

        t_on_tb <= '0';
        wait for 50 ns;

        t_on_tb <= '1';

        wait for 1 sec; 
        
        t_on_tb <= '0';
        wait for 50 ns;

        wait; 
    end process;

end architecture sim;