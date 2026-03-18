library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Conv_Note is
	Port(
		-- Entrada de Switches da placa --
		SW		: in STD_LOGIC_VECTOR(9 downto 4);
		
		--Saidas --
		price	: out STD_LOGIC_VECTOR(10 downto 0)
	);
	end Conv_Note;
	
architecture Behavioral of Conv_Note is
begin

	-- Seletor de Notas --
    with SW select
        price <= 
            std_logic_vector(to_unsigned(5, 11))   when "000001", --  SW(4) : R$ 0,05
            std_logic_vector(to_unsigned(10, 11))  when "000010", --  SW(5) : R$ 0,10
            std_logic_vector(to_unsigned(25, 11))  when "000100", --  SW(6) : R$ 0,25
            std_logic_vector(to_unsigned(50, 11))  when "001000", --  SW(7) : R$ 0,50
            std_logic_vector(to_unsigned(100, 11)) when "010000", --  SW(8) : R$ 1,00
            std_logic_vector(to_unsigned(200, 11)) when "100000", --  SW(9) : R$ 2,00
            (others => '0')                        when others;   -- Caso de erro : R$ 0,00
				
end architecture Behavioral;
						