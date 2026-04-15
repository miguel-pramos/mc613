LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sprite_memory IS
    PORT (
        sprite_id   : IN  STD_LOGIC_VECTOR (2 DOWNTO 0); 
        
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        
        sprite_x    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        sprite_y    : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        
        bitmap_out  : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
    );
END sprite_memory;

ARCHITECTURE behavioral OF sprite_memory IS

    -- Tamanho de apenas 1 sprite (1024 pixels)
    TYPE rom_array IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Criamos 4 blocos de memória para os 4 pedaços do logo
    SIGNAL rom_pedaco_1 : rom_array;
    SIGNAL rom_pedaco_2 : rom_array;
    SIGNAL rom_pedaco_3 : rom_array;
    SIGNAL rom_pedaco_4 : rom_array;

    -- Dizemos ao compilador para ler seus arquivos!
    ATTRIBUTE ram_init_file : STRING;
    ATTRIBUTE ram_init_file OF rom_pedaco_1 : SIGNAL IS "imgs/unicamp00.mif";
    ATTRIBUTE ram_init_file OF rom_pedaco_2 : SIGNAL IS "imgs/unicamp01.mif";
    ATTRIBUTE ram_init_file OF rom_pedaco_3 : SIGNAL IS "imgs/unicamp02.mif";
    ATTRIBUTE ram_init_file OF rom_pedaco_4 : SIGNAL IS "imgs/unicamp03.mif";

    -- Sinais internos
    SIGNAL intra_x   : INTEGER RANGE 0 TO 31;
    SIGNAL intra_y   : INTEGER RANGE 0 TO 31;
    SIGNAL read_addr : INTEGER RANGE 0 TO 1023;
    
    -- Sinais temporários para as cores de cada bloco
    SIGNAL cor_1, cor_2, cor_3, cor_4 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL cor_selecionada            : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
    -- 1. Sua Matemática Original (Perfeita!)
    intra_x <= TO_INTEGER(UNSIGNED(pixel_x) - UNSIGNED(sprite_x)) MOD 32;
    intra_y <= TO_INTEGER(UNSIGNED(pixel_y) - UNSIGNED(sprite_y)) MOD 32;

    -- O endereço agora não precisa multiplicar pelo ID, pois as memórias são separadas!
    read_addr <= (intra_y * 32) + intra_x;

    -- 2. Lemos o mesmo pixel nas 4 memórias ao mesmo tempo
    cor_1 <= rom_pedaco_1(read_addr);
    cor_2 <= rom_pedaco_2(read_addr);
    cor_3 <= rom_pedaco_3(read_addr);
    cor_4 <= rom_pedaco_4(read_addr);

    -- 3. Escolhemos o pedaço baseado nos 2 últimos bits do ID
    -- Se o ID for "100" (pedaço 1), "101" (pedaço 2), "110" (pedaço 3) ou "111" (pedaço 4)
    WITH sprite_id(1 DOWNTO 0) SELECT
        cor_selecionada <= cor_1 WHEN "00",
                           cor_2 WHEN "01",
                           cor_3 WHEN "10",
                           cor_4 WHEN "11",
                           "000" WHEN OTHERS;

    -- 4. O seu filtro de Transparência! 
    -- Se o bit 2 (o mais significativo) for '0', forçamos a saída toda para transparente!
    bitmap_out <= "000" WHEN sprite_id(2) = '0' ELSE cor_selecionada;

END behavioral;