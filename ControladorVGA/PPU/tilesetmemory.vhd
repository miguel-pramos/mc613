LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tileset_memory IS
    PORT (
        tile_id    : IN  STD_LOGIC;                     
        pixel_x    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);  -- Coordenada X da tela
        pixel_y    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);  -- Coordenada Y da tela
        
        bitmap_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END tileset_memory;

ARCHITECTURE behavioral OF tileset_memory IS

    TYPE rom_array IS ARRAY (0 TO 2047) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Função para inicializar o desenho
    IMPURE FUNCTION preencher_tileset RETURN rom_array IS
        VARIABLE tmp_rom : rom_array := (OTHERS => "00000000");
    BEGIN
        FOR i IN 0 TO 2047 LOOP
            IF i < 1024 THEN
                tmp_rom(i) := "00000010"; -- Cor base do Tile 0
            ELSE
                tmp_rom(i) := "00000011"; -- Cor base do Tile 1
            END IF;
        END LOOP;
        
        RETURN tmp_rom;
    END FUNCTION;

    SIGNAL tileset_rom : rom_array := preencher_tileset;

    -- Sinais internos para o cálculo do endereço
    SIGNAL intra_tile_x : INTEGER RANGE 0 TO 31;
    SIGNAL intra_tile_y : INTEGER RANGE 0 TO 31;
    SIGNAL base_addr    : INTEGER RANGE 0 TO 2047;
    SIGNAL read_addr    : INTEGER RANGE 0 TO 2047;

BEGIN

    -- Extraímos os 5 bits menos significativos (0 a 31) para saber 
    -- em qual pixel exato estamos dentro do bloco do tile atual.
    intra_tile_x <= TO_INTEGER(UNSIGNED(pixel_x(4 DOWNTO 0)));
    intra_tile_y <= TO_INTEGER(UNSIGNED(pixel_y(4 DOWNTO 0)));

    -- Se o tile_id for '1', pulamos os primeiros 1024 endereços
    base_addr <= 1024 WHEN tile_id = '1' ELSE 0;

    -- O endereço final é a base do Tile + (Linha atual * 32) + Coluna atual
    read_addr <= base_addr + (intra_tile_y * 32) + intra_tile_x;

    -- O bitmap_out recebe a informação lida da ROM
    bitmap_out <= tileset_rom(read_addr);

END behavioral;