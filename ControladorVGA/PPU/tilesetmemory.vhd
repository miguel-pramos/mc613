LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tilesetmemory IS
  PORT (
    id_tile    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Entrada: Qual tile queremos ler
    bitmap_out : OUT STD_LOGIC_VECTOR (127 DOWNTO 0)  -- Saída: O tile INTEIRO (4x4 = 16 pixels * 8 bits = 128 bits)
  );
END tilesetmemory;

ARCHITECTURE behavioral OF tilesetmemory IS
  -- Criando um tipo de memória onde cada "linha" tem 128 bits de largura
  TYPE rom_array IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR (127 DOWNTO 0);
  
  
  SIGNAL storage: rom_array := (
    -- TILE 0: Cor sólida Preta (ID da cor na paleta = x"00")
    -- Todos os 16 pixels têm o valor 00.
    0 => x"000000000000000000000000000000000",
    
    1 => x"000000000000000000000000000000000",

    2 => x"000000000000000000000000000000000", 

    3 => x"000000000000000000000000000000000",

    -- Preenche os outros tiles com zeros (preto)
    OTHERS => (OTHERS => '1')
  );

BEGIN
  -- O circuito entrega o bitmap completo instantaneamente baseado no ID
  bitmap_out <= storage(TO_INTEGER(UNSIGNED(id_tile)));
END behavioral;