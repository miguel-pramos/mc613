LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sprite_memory IS
    PORT (
        -- Recebe o ID do sprite detectado
        sprite_id   : IN  STD_LOGIC_VECTOR (3 DOWNTO 0); 
        
        -- Coordenadas globais do raio da tela
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        
        -- Coordenadas base do sprite atual (Virá da OAM)
        sprite_x    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        sprite_y    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        
        bitmap_out  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END sprite_memory;

ARCHITECTURE behavioral OF sprite_memory IS

    -- Mantemos a criação do "molde" da memória [cite: 58]
    TYPE rom_array IS ARRAY (0 TO 4095) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- 1. Declaramos o sinal da memória (Sem chamar nenhuma função)
    SIGNAL sprite_rom : rom_array;

    -- 2. Declaramos o uso de um atributo especial de arquivo
    ATTRIBUTE ram_init_file : STRING;
    
    -- 3. Vinculamos o arquivo .mif à nossa memória
    -- ATENÇÃO: Substitua "meus_sprites.mif" pelo nome exato do seu arquivo!
    ATTRIBUTE ram_init_file OF sprite_rom : SIGNAL IS "meus_sprites.mif";

    -- Instancia a ROM já preenchida
    SIGNAL sprite_rom : rom_array := preencher_sprite;

    -- Sinais para armazenar o resultado da matemática
    SIGNAL intra_x   : INTEGER RANGE 0 TO 31;
    SIGNAL intra_y   : INTEGER RANGE 0 TO 31;
    SIGNAL read_addr : INTEGER RANGE 0 TO 4095;

BEGIN

    intra_x <= TO_INTEGER(UNSIGNED(pixel_x) - UNSIGNED(sprite_x)) MOD 32;
    intra_y <= TO_INTEGER(UNSIGNED(pixel_y) - UNSIGNED(sprite_y)) MOD 32;

    -- Fórmula: (ID do Sprite * 1024) + (Y interno * 32) + X interno
    read_addr <= (TO_INTEGER(UNSIGNED(sprite_id)) * 1024) + 
                 (intra_y * 32) + 
                 intra_x;

    -- 3. SAÍDA DA COR
    bitmap_out <= sprite_rom(read_addr);

END behavioral;