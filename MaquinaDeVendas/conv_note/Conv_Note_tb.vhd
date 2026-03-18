library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity Conv_Note_tb is
end Conv_Note_tb;

architecture Behavioral of Conv_Note_tb is

    component Conv_Note
        Port(
            SW    : in STD_LOGIC_VECTOR(9 downto 4);
            price : out STD_LOGIC_VECTOR(10 downto 0)
        );
    end component;
    
    signal  tb_SW    : STD_LOGIC_VECTOR(9 downto 4) := (others => '0');
    signal  tb_price : STD_LOGIC_VECTOR(10 downto 0);

begin

    uut: Conv_Note
        port map (
            SW    =>  tb_SW,
            price =>  tb_price
        );
    
    test_process: process
        variable line_out : line;
    begin
        write(line_out, string'("--- Iniciando Teste do Conversor de Notas ---"));
        writeline(output, line_out);
        writeline(output, line_out);
        
        -- Loop --
        for i in 0 to 63 loop
             tb_SW <= STD_LOGIC_VECTOR(to_unsigned(i, 6));
            wait for 10 ns;
            
            -- Imprime a Entrada em Binário --
            write(line_out, string'("Entrada SW(9..4) [Bin]: "));
            write(line_out,  tb_SW); 
            
            -- Imprime a Saída em Decimal --
            write(line_out, string'(" | Saida (Centavos): "));
            write(line_out, to_integer(unsigned( tb_price))); 
            
            writeline(output, line_out);
        end loop;
        
        writeline(output, line_out);
        write(line_out, string'("--- Teste Concluido ---"));
        writeline(output, line_out);
        wait;
    end process;

end Behavioral;