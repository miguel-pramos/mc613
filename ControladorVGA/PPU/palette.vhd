LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rom IS
  PORT (
    addr     : IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- Endereço (índice da cor)
    data_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) -- Saída da cor RGB de 8 bits (ex: RRRGGGBB)
  );
END rom;

ARCHITECTURE behavioral OF rom IS
  -- Criação do tipo do array: 256 posições, cada uma guardando 8 bits
  TYPE rom_array IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
  
  -- Declaração e inicialização da memória com as cores desejadas
  SIGNAL storage: rom_array := (]
  
    1 => "00000000", -- Índice 1: Preto (RGB 000-000-00)
    2 => "11111111", -- Índice 2: Branco (RGB 111-111-11)
    3 => "11100000", -- Índice 3: Vermelho (RGB 111-000-00)
    4 => "00011100", -- Índice 4: Verde (RGB 000-111-00)
    5 => "00000011", -- Índice 5: Azul (RGB 000-000-11)

    -- Preenche todas as posições não declaradas (de 4 a 255) com preto
    OTHERS => "00000000" 
  );

BEGIN
  -- Leitura assíncrona: o valor sai imediatamente após o endereço mudar
  data_out <= storage(TO_INTEGER(UNSIGNED(addr)));
END behavioral;