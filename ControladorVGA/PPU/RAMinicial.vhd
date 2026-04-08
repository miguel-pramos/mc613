LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY async_ram IS
  PORT (
    we       : IN  STD_LOGIC;                     -- Write Enable (Habilita a escrita quando '1')
    addr     : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); -- Endereço para ler ou escrever
    data_in  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); -- Dado que você quer salvar na memória
    data_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)  -- Dado que está saindo da memória
  );
END async_ram;

ARCHITECTURE behavioral OF async_ram IS
  TYPE ram_array IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  -- Declaração da memória. Inicializamos tudo com zeros por segurança.
  SIGNAL ram_memory : ram_array := (OTHERS => "00000000");
  
BEGIN

  -- PROCESSO DE ESCRITA ASSÍNCRONA
  PROCESS(we, addr, data_in)
  BEGIN
    -- Se a permissão de escrita estiver ligada ('1')
    IF we = '1' THEN
      ram_memory(TO_INTEGER(UNSIGNED(addr))) <= data_in;
    END IF;
  END PROCESS;

  -- PROCESSO DE LEITURA ASSÍNCRONA
  data_out <= ram_memory(TO_INTEGER(UNSIGNED(addr)));

END behavioral;