LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY palette_memory IS
  PORT (
    id_color    : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
    red        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   
    green      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   
    blue       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)    
  );
END palette_memory; 

ARCHITECTURE behavioral OF palette_memory IS
  -- Array de 4 posições (Índices 0 a 3)
  TYPE rom_array IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
  
  SIGNAL red_intens: rom_array := (
    0 => "00001010", -- Cor 0: Preto (#0A0A0A)
    1 => "11011010", -- Cor 1: Vermelho (#DA251D)
    2 => "11111111", -- Cor 2: Branco (#FFFFFF)
    3 => "11110000", -- Cor 3: Rosa (#F0ACA8)
    OTHERS => "00000000"
  );

  SIGNAL green_intens: rom_array := (
    0 => "00001010", -- Cor 0: Preto
    1 => "00100101", -- Cor 1: Vermelho
    2 => "11111111", -- Cor 2: Branco
    3 => "10101100", -- Cor 3: Rosa
    OTHERS => "00000000"
  );

  SIGNAL blue_intens: rom_array := (
    0 => "00001010", -- Cor 0: Preto
    1 => "00011101", -- Cor 1: Vermelho
    2 => "11111111", -- Cor 2: Branco
    3 => "10101000", -- Cor 3: Rosa
    OTHERS => "00000000"
  );

BEGIN
  -- Saída combinacional
  red   <= red_intens(TO_INTEGER(UNSIGNED(id_color)));
  green <= green_intens(TO_INTEGER(UNSIGNED(id_color)));
  blue  <= blue_intens(TO_INTEGER(UNSIGNED(id_color)));

END behavioral;