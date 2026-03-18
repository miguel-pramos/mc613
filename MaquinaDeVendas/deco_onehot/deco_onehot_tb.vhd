library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

entity deco_onehot_tb is
end deco_onehot_tb;

architecture Behavioral of deco_onehot_tb is

    component deco_onehot
        Port (
            prod  : in  std_logic_vector(3 downto 0);
            price : out std_logic_vector(10 downto 0)
        );
    end component;
	
	-- Signals para realizaç~ao dos testes --
    signal tb_prod  : std_logic_vector(3 downto 0) := (others => '0');
    signal tb_price : std_logic_vector(10 downto 0);

begin
uut: deco_onehot
        port map (
            prod  => tb_prod,
            price => tb_price
        );
    
    test_process: process
        variable line_out : line;
    begin
        write(line_out, string'("Testando deco_onehot da Vending Machine..."));
        writeline(output, line_out);
        
        -- Loop de 0 a 15
        for i in 0 to 15 loop
            tb_prod <= STD_LOGIC_VECTOR(to_unsigned(i, 4));
            wait for 10 ns;  -- Aguarda para o sinal estabilizar
            
				-- HEX --
            write(line_out, string'("Produto (Hex): "));
            hwrite(line_out, tb_prod);
            
				-- BIN --
            write(line_out, string'(" | Saida (Bin): "));
            write(line_out, tb_price);
            
            -- Decimal --
            write(line_out, string'(" | Saida (Decimal/Centavos): "));
            write(line_out, to_integer(unsigned(tb_price))); 
            
            writeline(output, line_out);
        end loop;
        
        write(line_out, string'("Teste concluido"));
        writeline(output, line_out);
        wait;
    end process;
end Behavioral;