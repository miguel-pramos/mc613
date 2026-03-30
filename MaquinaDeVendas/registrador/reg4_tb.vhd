library ieee;
use ieee.std_logic_1164.all;

entity reg4_tb is
end entity reg4_tb;

architecture sim of reg4_tb is
    signal clk_tb    : std_logic := '0';
    signal reset_tb  : std_logic := '0';
    signal enable_tb : std_logic := '0';
    signal D_tb      : std_logic_vector(3 downto 0) := (others => '0');
    signal Q_tb      : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 20 ns;
begin

    dut: entity work.reg4
        port map(
            clk    => clk_tb,
            reset  => reset_tb,
            enable => enable_tb,
            D      => D_tb,
            Q      => Q_tb
        );

    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_process: process
    begin
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';

        D_tb <= "1010";
        enable_tb <= '0';
        wait for CLK_PERIOD * 2;

        enable_tb <= '1';
        wait for CLK_PERIOD;
        
        D_tb <= "0101";
        wait for CLK_PERIOD;

        enable_tb <= '0';
        D_tb <= "1111";
        wait for CLK_PERIOD * 2;

        wait; 
    end process;
end architecture sim;