LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tilesetmemory IS
  PORT (
    id_tile    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Entrada: Qual tile queremos ler
    red        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Saída: vermelho
    green      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Saída: verde
    blue       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)    -- Saída: azul
  );
END tilesetmemory;

ARCHITECTURE behavioral OF tilesetmemory IS
  -- Criando um tipo de memória onde cada "linha" tem 128 bits de largura
  TYPE rom_array IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
  
  
  SIGNAL red_intens: rom_array := (
    0 => "00000000", -- cor 0: transparente (RGB 000-000-000)

    1 => "00000000", -- cor 1: preto (RGB 000-000-000)
    
    2 => "11111111", -- cor 2: branco (RGB 111-111-111)

    3 => "11111111", -- cor 3: vermelho (RGB 111-000-000)

    4 => "00000000", -- cor 4: verde (RGB 000-111-000)

    5 => "00000000", -- cor 5: azul (RGB 000-000-111)

    -- Preenche os outros tiles com zeros (preto)
    OTHERS => "00000000"
  );

  SIGNAL green_intens: rom_array := (

    0 => "00000000", -- cor 0: transparente (RGB 000-000-000)

    1 => "00000000", -- cor 1: preto (RGB 000-000-000)

    2 => "11111111", -- cor 2: branco (RGB 111-111-111)

    3 => "00000000", -- cor 3: vermelho (RGB 111-000-000)

    4 => "11111111", -- cor 4: verde (RGB 000-111-000)

    5 => "00000000", -- cor 5: azul (RGB 000-000-111)

    -- Preenche os outros tiles com zeros (preto)
    OTHERS => "00000000"
  );

  SIGNAL blue_intens: rom_array := (

    0 => "00000000", -- cor 0: transparente (RGB 000-000-000)

    1 => "00000000", -- cor 1: preto (RGB 000-000-000)

    2 => "11111111", -- cor 2: branco (RGB 111-111-111)

    3 => "00000000", -- cor 3: vermelho (RGB 111-000-000)

    4 => "00000000", -- cor 4: verde (RGB 000-111-000)

    5 => "11111111", -- cor 5: azul (RGB 000-000-111)

    -- Preenche os outros tiles com zeros (preto)
    OTHERS => "00000000"
  );

BEGIN
  -- O circuito entrega o bitmap completo instantaneamente baseado no ID
  red   <= red_intens(TO_INTEGER(UNSIGNED(id_tile)));
  green <= green_intens(TO_INTEGER(UNSIGNED(id_tile)));
  blue  <= blue_intens(TO_INTEGER(UNSIGNED(id_tile)));

END behavioral;

