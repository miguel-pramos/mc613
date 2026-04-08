LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memorybackground IS
    PORT (
        we          : IN  STD_LOGIC;                     -- Write Enable (1 = Salvar novo ID)
        write_addr  : IN  STD_LOGIC_VECTOR (8 DOWNTO 0); -- Endereço para escrita (Aumentado para 9 bits: 0 a 511)
        data_in     : IN  STD_LOGIC_VECTOR (8 DOWNTO 0); -- ID do Tile que você quer salvar na memória
        
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); -- Coordenada X do pixel atual (0 a 639)
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); -- Coordenada Y do pixel atual (0 a 479)
        
        tile_id_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0)  -- Saída: ID do Tile onde o pixel está
    );
END memorybackground;

ARCHITECTURE behavioral OF memorybackground IS
    -- A memória precisa de pelo menos 300 posições. Vamos criar com 512 (9 bits)
    TYPE ram_array IS ARRAY (0 TO 511) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    -- Função para inicializar a memória com os IDs dos tiles (0 a 299)
    IMPURE FUNCTION preencher_ram RETURN ram_array IS
        VARIABLE tmp_ram : ram_array := (OTHERS => "000000000");
    BEGIN
        -- O laço vai da posição 0 até a 299 da tela
        FOR i IN 0 TO 299 LOOP
            tmp_ram(i) := STD_LOGIC_VECTOR(TO_UNSIGNED(i, 9));
        END LOOP;   
        RETURN tmp_ram;
    END FUNCTION;

    -- Inicializa a memória usando a função
    SIGNAL ram_memory : ram_array := preencher_ram;

    -- Sinais internos para a matemática
    SIGNAL tile_x    : UNSIGNED(4 DOWNTO 0);
    SIGNAL tile_y    : UNSIGNED(4 DOWNTO 0);
    SIGNAL read_addr : INTEGER RANGE 0 TO 511;
  
BEGIN
    -- Divisão por 32 para converter coordenadas de pixel em coordenadas de tile
    tile_x <= UNSIGNED(pixel_x(9 DOWNTO 5));
    tile_y <= UNSIGNED(pixel_y(9 DOWNTO 5));

    -- Converter o X e Y do tile em um endereço linear da memória
    read_addr <= TO_INTEGER(tile_y) * 20 + TO_INTEGER(tile_x);

    -- PROCESSO DE ESCRITA ASSÍNCRONA
    PROCESS(we, write_addr, data_in)
    BEGIN
        IF we = '1' THEN
            ram_memory(TO_INTEGER(UNSIGNED(write_addr))) <= data_in;
        END IF;
    END PROCESS;

    -- PROCESSO DE LEITURA ASSÍNCRONA (Envia o ID do Tile para a Tileset Memory continuamente)
    tile_id_out <= ram_memory(read_addr);

END behavioral;