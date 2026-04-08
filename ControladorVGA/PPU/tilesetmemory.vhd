LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tilesetmemory IS
  PORT (
    id_tile    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Entrada: Qual tile queremos ler
    bitmap_out : OUT STD_LOGIC_VECTOR (127 DOWNTO 0)  -- Saída: O tile inteiro (4x4 = 16 pixels * 8 bits = 128 bits)
  );
END tilesetmemory;

ARCHITECTURE behavioral OF tilesetmemory IS
BEGIN
  -- Cada tile inteiro usa uma unica cor.
  -- O proprio id_tile e reutilizado como indice de cor em todos os 16 pixels.
  bitmap_out <=
    id_tile & id_tile & id_tile & id_tile &
    id_tile & id_tile & id_tile & id_tile &
    id_tile & id_tile & id_tile & id_tile &
    id_tile & id_tile & id_tile & id_tile;
END behavioral;
