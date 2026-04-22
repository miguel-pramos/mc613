LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tileset_memory IS
    PORT (
        tile_id    : IN  STD_LOGIC;                     
        pixel_x    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);  
        pixel_y    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);  
        
        color_id : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)   
    );
END tileset_memory;

ARCHITECTURE behavioral OF tileset_memory IS

    -- A ROM agora armazena vetores de 3 bits
    TYPE rom_array IS ARRAY (0 TO 2047) OF STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Função para inicializar o desenho com 3 bits
    IMPURE FUNCTION preencher_tileset RETURN rom_array IS
        VARIABLE tmp_rom : rom_array := (OTHERS => "000");
    BEGIN
        FOR i IN 0 TO 2047 LOOP
            IF i < 1024 THEN
                tmp_rom(i) := "010"; -- Cor do Tile 0 branco
            ELSE
                tmp_rom(i) := "011"; -- Cor do Tile 1 rosa
            END IF;
        END LOOP;
        
        RETURN tmp_rom;
    END FUNCTION;

    SIGNAL tileset_rom : rom_array := preencher_tileset;

    SIGNAL intra_tile_x : INTEGER RANGE 0 TO 31;
    SIGNAL intra_tile_y : INTEGER RANGE 0 TO 31;
    SIGNAL base_addr    : INTEGER RANGE 0 TO 2047;
    SIGNAL read_addr    : INTEGER RANGE 0 TO 2047;

BEGIN

    -- Cálculo das coordenadas locais dentro do Tile 32x32
    intra_tile_x <= TO_INTEGER(UNSIGNED(pixel_x(4 DOWNTO 0)));
    intra_tile_y <= TO_INTEGER(UNSIGNED(pixel_y(4 DOWNTO 0)));

    -- Seleção do bloco de memória (Tile 0 ou Tile 1)
    base_addr <= 1024 WHEN tile_id = '1' ELSE 0;

    -- Endereçamento linear
    read_addr <= base_addr + (intra_tile_y * 32) + intra_tile_x;

    -- Saída (Combinacional)
    color_id <= tileset_rom(read_addr);

END behavioral;