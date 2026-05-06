library ieee;
use ieee.std_logic_1164.all;

entity addr_change_detector is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        addr_sw      : in  std_logic_vector(5 downto 0); 
        change_pulse : out std_logic                     
    );
end addr_change_detector;

architecture Behavioral of addr_change_detector is
    signal r_last_addr : std_logic_vector(5 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            r_last_addr  <= (others => '0');
            change_pulse <= '0';
        elsif rising_edge(clk) then
            change_pulse <= '0';
            
            if addr_sw /= r_last_addr then
                change_pulse <= '1';       
                r_last_addr  <= addr_sw;  
            end if;
        end if;
    end process;
end Behavioral;